/*
===============================================================================
MIT License

© 2025 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

#![doc(html_favicon_url = "https://codemelted.com/favicon.png")]
#![doc(html_logo_url =
  "https://codemelted.com/assets/favicon/apple-touch-icon.png")]
#![doc = include_str!("README.md")]

// ============================================================================
// [MODULE DATA DEFINITION] ===================================================
// ============================================================================

/// Defines a trait to allow a struct to transform its data into a CSV format.
pub trait CCsvFormat {
  /// Utility method to get the system id for a given monitor.
  fn system_id() -> String {
    format!(
      "{} / {} / {}",
      codemelted_hw::os_name(),
      codemelted_hw::os_version(),
      codemelted_hw::kernel_version(),
    )
  }
  /// Identifies the header associated with the data.
  fn csv_header(&self) -> String;
  /// Transforms the data into a CSV format.
  fn as_csv(&self) -> String;
}

/// Defines a trait for the "rules" of objects that will setup a protocol that
/// directly exchanges data with an external item, will continuously run until
/// terminated, requires the ability to know it is running and get any errors
/// that have occurred during it run.
pub trait CProtocolHandler<T> {
  /// Retrieves any currently processed errors.
  fn get_error(&mut self) -> Option<T>;
  /// Retrieves any currently processed messages.
  fn get_message(&mut self) -> Option<T>;
  /// Signals if the protocol is running or not.
  fn is_running(&self) -> bool;
  /// Handles the sending of the message to the protocol for processing.
  fn post_message(&self, data: T);
  /// Signals for the protocol to terminate.
  fn terminate(&mut self);
}

/// Defines a trait to attach to the [CObject] providing utility function
/// definitions to make a bool based on a series of strings that can be
/// considered true in nature.
pub trait CTruthyString {
  /// Provides a binding to attach the ability for a [CObject] to determine
  /// if its held str value is truthy or not.
  fn as_truthy(&self) -> bool;
  /// Static function that implements the truthy string logic.
  fn is_truthy(data: &str) -> bool;
}

/// The binding that provides the codemelted module's "dynamic" data allowing
/// for full support of JSON along with holding general Rust data types that
/// can be returned from different use case functions.
pub type CObject = json::JsonValue;

/// Implements the [CTruthyString] trait for our [CObject] dynamic type.
impl CTruthyString for CObject {
  fn as_truthy(&self) -> bool {
    CObject::is_truthy(self.as_str().unwrap())
  }

  fn is_truthy(data: &str) -> bool {
    let true_strings: [&'static str; 9] = [
      "true",
      "1",
      "t",
      "y",
      "yes",
      "yeah",
      "yup",
      "certainly",
      "uh-huh",
    ];
    let data_check = String::from(data.to_lowercase());
    for el in true_strings {
      if el.contains(&data_check) {
        return true;
      }
    }
    false
  }
}

// ============================================================================
// [Async Use Case] ===========================================================
// ============================================================================

/// Implements the CodeMelted DEV Async use case. Provides the ability to
/// process items in the background utilizing different methodologies. There
/// is the one off [crate::codemelted_async::task]. There is a repeating
/// [crate::codemelted_async::timer]. Then there is the ability to have a
/// dedicated [crate::codemelted_async::worker] with a FIFO queue. Finally the
/// module provides a [crate::codemelted_async::CPerformanceMonitor] object
/// to monitor overall platform performance in terms of cpu / memory
/// utilization.
#[doc = mermaid!("models/codemelted_async.mmd")]
pub mod codemelted_async {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::CProtocolHandler;
  use std::{
    sync::mpsc::{channel, Receiver, Sender},
    thread::{self, JoinHandle},
    time
  };
  use simple_mermaid::mermaid;
  use sysinfo::System;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Provides a monitoring object to measure the platform's overall CPU /
  /// memory utilization. This is accomplished by calling the [monitor]
  /// function to get a reference of the object. From here you have the ability
  /// to sample the data of interest, refresh to get the latest update, and if
  /// necessary capture a [crate::CCsvFormat] of the data.
  pub struct CPerformanceMonitor {
    sys: System
  }
  impl CPerformanceMonitor {
    /// Creates an instance of the monitor object. Only accessible via the
    /// [monitor] function.
    fn new() -> CPerformanceMonitor {
      let sys = System::new_all();
      CPerformanceMonitor { sys }
    }

    /// Refreshes the CPU and memory statistics.
    pub fn refresh(&mut self) {
      self.sys.refresh_memory();
      self.sys.refresh_cpu_usage();
    }

    /// Identifies the current CPU % utilization distributed across the whole
    /// of the available CPUs of the operating system.
    pub fn cpu_load(&self) -> f32 {
      let mut count: f32 = 0.0;
      let mut total: f32 = 0.0;
      for cpu in self.sys.cpus() {
        total += cpu.cpu_usage();
        count += 1.0;
      }
      total / count
    }

    /// Identifies the current available memory in bytes.
    pub fn memory_available_bytes(&self) -> u64 {
      self.sys.available_memory()
    }

    /// Identifies the current free memory in bytes.
    pub fn memory_free_bytes(&self) -> u64 {
      self.sys.free_memory()
    }

    /// Identifies the current used memory in bytes.
    pub fn memory_used_bytes(&self) -> u64 {
      self.sys.used_memory()
    }

    /// Identifies the total memory in bytes.
    pub fn memory_total_bytes(&self) -> u64 {
      self.sys.total_memory()
    }

    /// Determines the percentage of used memory vs. total bytes.
    pub fn memory_load(&self) -> f32 {
      let used_bytes = self.memory_used_bytes() as f32;
      let total_bytes = self.memory_total_bytes() as f32;
      (used_bytes / total_bytes) * 100.0
    }

    /// Identifies the swap free space in bytes.
    pub fn swap_free_bytes(&self) -> u64 {
      self.sys.free_swap()
    }

    /// Identifies the swap used space in bytes.
    pub fn swap_used_bytes(&self) -> u64 {
      self.sys.used_swap()
    }

    /// Identifies the swap space total bytes.
    pub fn swap_total_bytes(&self) -> u64 {
      self.sys.total_swap()
    }

    /// Identifies the swap load percentage.
    pub fn swap_load(&self) -> f32 {
      let used_bytes = self.swap_used_bytes() as f32;
      let total_bytes = self.swap_total_bytes() as f32;
      (used_bytes / total_bytes) * 100.0
    }
  }
  impl crate::CCsvFormat for CPerformanceMonitor {
    fn csv_header(&self) -> String {
      format!(
        "{},{},{},{},{},{},{},{},{},{},{},{},{}",
        String::from("system_id"),
        String::from("cpu_arch"),
        String::from("cpu_count"),
        String::from("cpu_load"),
        String::from("memory_available_bytes"),
        String::from("memory_free_bytes"),
        String::from("memory_used_bytes"),
        String::from("memory_total_bytes"),
        String::from("memory_load"),
        String::from("swap_free_bytes"),
        String::from("swap_used_bytes"),
        String::from("swap_total_bytes"),
        String::from("swap_load")
      )
    }

    fn as_csv(&self) -> String {
      format!(
        "{},{},{},{},{},{},{},{},{},{},{},{},{}",
        Self::system_id(),
        cpu_arch(),
        cpu_count(),
        self.cpu_load(),
        self.memory_available_bytes(),
        self.memory_free_bytes(),
        self.memory_used_bytes(),
        self.memory_total_bytes(),
        self.memory_load(),
        self.swap_free_bytes(),
        self.swap_used_bytes(),
        self.swap_total_bytes(),
        self.swap_load()
      )
    }
  }

  /// The task that runs as part of the [CTaskResult] internal thread.
  pub type CTaskCB<T> = fn(Option<T>) -> Option<T>;

  /// The result of a [task] call. This holds an internal thread that will
  /// call the [CTaskCB] to process specified data and return the result.
  /// The [CTaskResult::has_completed] will let you know when the thread
  /// has completed so you can then call [CTaskResult::value] for the
  /// processed value.
  pub struct CTaskResult<T> {
    /// Holds the the handle for the internal thread.
    handle: JoinHandle<()>,

    /// Holds the receiver to wait for the process result from the [CTaskCB].
    recv: Receiver<Option<T>>,
  }
  impl<T: std::marker::Send + 'static> CTaskResult<T> {
    /// Private constructor to support the [task] function.
    fn new(task: CTaskCB<T>, data: Option<T>, delay: u64) -> CTaskResult<T> {
      // Setup our message channel.
      let (tx, rx) = channel::<Option<T>>();

      // Kick-off the thread to process the task.
      let handle = thread::spawn(move || {
        sleep(delay);
        let result = task(data);
        let _ = tx.send(result);
      });

      // Return the constructed object.
      CTaskResult { handle, recv: rx }
    }

    /// Indicator to whether the task thread has completed the [CTaskCB]
    pub fn has_completed(&self) -> bool {
      self.handle.is_finished()
    }

    /// Retrieves the value processed by this task. Will block if the
    /// task thread has not completed.
    pub fn value(&self) -> Option<T> {
      let result = self.recv.recv();
      match result {
        Ok(v) => v,
        Err(_) => None,
      }
    }
  }

  /// The task that runs within the [CTimerResult] thread.
  pub type CTimerCB = fn();

  /// The result of a [timer] function call. This holds the internals of the
  /// thread running the [CTimerCB] until the [CTimerResult::stop] is
  /// called.
  pub struct CTimerResult {
    /// The handle to the internally spawned thread.
    handle: JoinHandle<()>,
    /// The sender to support the [CTimerResult::stop] call to terminate
    /// the thread.
    sender: Sender<bool>
  }
  impl CTimerResult {
    /// Private function to create the object via the [timer] function.
    fn new(task: CTimerCB, interval: u64) -> CTimerResult {
      // Setup our channel
      let (tx, rx) = channel::<bool>();

      // Kick-off the internal thread loop.
      let handle = thread::spawn(move || {
        loop {
          sleep(interval);
          task();
          let result = rx.try_recv();
          if result.is_ok() {
            let stop_thread = result.ok().unwrap();
            if stop_thread {
              break;
            }
          }
        }
      });

      // Return the result object.
      CTimerResult { handle, sender: tx }
    }

    /// Indicates if the timer is running (true) or not (false).
    pub fn is_running(&self) -> bool {
      !self.handle.is_finished()
    }

    /// Terminates the internal timer thread. This blocks until fully
    /// stopped.
    pub fn stop(&self) {
      self.sender.send(true).unwrap();
      loop {
        sleep(100);
        if !self.is_running() {
          break;
        }
      }
    }
  }

  /// The task that runs within the [CWorkerProtocol] thread.
  pub type CWorkerCB<T> = fn(T) -> Option<T>;

  /// The result of a [worker] call. This holds a dedicated thread that is
  /// waiting for data via the [CWorkerProtocol::post_message]. This will
  /// queue of data for processing and the internal thread will process that
  /// data in accordance with the [CWorkerCB]. Any processed data is available
  /// via the [CProtocolHandler] bound trait functions.
  pub struct CWorkerProtocol<T> {
    handle: JoinHandle<()>,
    protocol_tx: Option<Sender<T>>,
    protocol_rx: Receiver<T>,
  }
  impl<T: std::marker::Send + 'static> CWorkerProtocol<T> {
    /// Constructs the new [CWorkerProtocol] implementing bi-directional
    /// communication with the background thread.
    fn new(task: CWorkerCB<T>) -> CWorkerProtocol<T> {
      let (protocol_tx, thread_rx) = channel::<T>();
      let (thread_tx, protocol_rx) = channel::<T>();

      // Setup our thread and kick it off.
      let handle = thread::spawn(move || {
        loop {
          // Block until we get data via post_message.
          match thread_rx.recv() {
            Ok(v) => {
              let result = task(v);
              if result.is_some() {
                let data = result.unwrap();
                let _ = thread_tx.send(data);
              }
            },
            // The channel was disconnected via terminate.
            // Break thread loop.
            Err(_) => break,
          }
        }
      });

      // Return the worker protocol.
      CWorkerProtocol::<T> {
        handle,
        protocol_tx: Some(protocol_tx),
        protocol_rx,
      }
    }
  }
  impl<T> CProtocolHandler<T> for CWorkerProtocol<T> {
    fn get_error(&mut self) -> Option<T> {
      None
    }

    fn get_message(&mut self) -> Option<T> {
      match self.protocol_rx.try_recv() {
        Ok(v) => Some(v),
        Err(_) => None,
      }
    }

    fn is_running(&self) -> bool {
      !self.handle.is_finished()
    }

    fn post_message(&self, data: T) {
      let _ = self.protocol_tx.as_ref().unwrap().send(data);
    }

    fn terminate(&mut self) {
      self.protocol_tx = None;
      loop {
        sleep(100);
        if !self.is_running() {
          break;
        }
      }
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Will identify the current CPU architecture.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  ///
  /// let arch = codemelted_async::cpu_arch();
  /// assert!(!arch.is_empty());
  /// ```
  pub fn cpu_arch() -> String {
    System::cpu_arch()
  }

  /// Will identify the number of available CPUs for background thread
  /// processing. If it can't be determined then 1 is returned.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  ///
  /// let count = codemelted_async::cpu_count();
  /// assert!(count >= 1);
  /// ```
  pub fn cpu_count() -> usize {
    match System::physical_core_count() {
      Some(v) => v,
      None => 1,
    }
  }

  /// Constructs a [CPerformanceMonitor] to monitor the overall CPU / memory
  /// utilization.
  ///
  /// ```
  /// use codemelted::codemelted_async;
  /// use codemelted::codemelted_async::CPerformanceMonitor;
  ///
  /// let mut monitor = codemelted_async::monitor();
  /// monitor.refresh();
  /// let cpu_load1 = monitor.cpu_load();
  /// monitor.refresh();
  /// let cpu_load2 = monitor.cpu_load();
  /// assert!(cpu_load1 != cpu_load2);
  /// ```
  pub fn monitor() -> CPerformanceMonitor {
    CPerformanceMonitor::new()
  }

  /// Will put a currently running thread (main or background) to sleep for
  /// a specified delay in milliseconds.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  ///
  /// let now = std::time::Instant::now();
  /// codemelted_async::sleep(2000);
  /// assert!(now.elapsed() >= std::time::Duration::from_millis(2000));
  /// ```
  pub fn sleep(delay: u64) {
    let delay = time::Duration::from_millis(delay);
    thread::sleep(delay);
  }

  /// Creates a [CTaskResult] which runs a background thread to
  /// eventually retrieve the value of the task. The data in the examples
  /// are [`Option<T>`] to represent the optional data for the task and
  /// optional data returned. The function is templated so you can use any
  /// data type.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  /// use codemelted::codemelted_json;
  /// use codemelted::CObject;
  ///
  /// fn task_cb(data: Option<CObject>) -> Option<CObject> {
  ///   codemelted_async::sleep(1000);
  ///   let data_to_process = match data {
  ///     Some(v) => v.as_i64().unwrap(),
  ///     None => panic!("Why did this fail!"),
  ///   };
  ///
  ///   let answer = data_to_process + 42;
  ///   Some(CObject::from(answer))
  /// }
  ///
  /// let async_task = codemelted_async::task(
  ///   task_cb,
  ///   Some(CObject::from(24)),
  ///   250
  /// );
  /// assert!(!async_task.has_completed());
  /// let answer = async_task.value();
  /// assert!(async_task.has_completed());
  /// assert!(answer.is_some());
  /// ```
  pub fn task<T: std::marker::Send + 'static>(
    task: CTaskCB<T>,
    data: Option<T>,
    delay: u64
  ) -> CTaskResult<T> {
    CTaskResult::new(task, data, delay)
  }

  /// Creates a repeating [CTimerCB] on the specified interval
  /// (in milliseconds). The task is completed when the [CTimerResult::stop]
  /// is called.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  ///
  /// fn timer_cb() {
  ///   println!("Hello");
  /// }
  ///
  /// let timer_task = codemelted_async::timer( timer_cb, 250);
  /// codemelted_async::sleep(100);
  /// assert!(timer_task.is_running());
  /// codemelted_async::sleep(1000);
  /// timer_task.stop();
  /// assert!(!timer_task.is_running());
  /// ```
  pub fn timer(task: CTimerCB, interval: u64) -> CTimerResult {
    CTimerResult::new(task, interval)
  }

  /// Creates a [CWorkerProtocol] object that has a dedicated background
  /// thread for processing any data type you specify for the [CWorkerCB]
  /// loop. The task is ran when data is received via the
  /// [CWorkerProtocol::post_message] call. Messages are processed in the
  /// order received (First In First Out). The thread is blocked
  /// (i.e. no data, not doing anything) until the protocol receives a
  /// message. To get process data simply call [CWorkerProtocol::get_message].
  ///
  /// *NOTE: This is more efficient then constant creations of [task] calls
  /// so use this construct when you know you need a dedicated thread vs. a
  /// one off task that is not frequent.*
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  /// use codemelted::CObject;
  /// use codemelted::CProtocolHandler;
  ///
  /// fn worker_cb(_data: CObject) -> Option<CObject> {
  ///   // DO SOMETHING IN THE BACKGROUND
  ///   Some(CObject::new_object())
  /// }
  ///
  /// let mut worker = codemelted_async::worker(
  ///   worker_cb,
  /// );
  /// assert!(worker.is_running());
  /// worker.post_message(CObject::new_object());
  /// codemelted_async::sleep(100);
  ///
  /// let data = worker.get_message();
  /// assert!(data.is_some());
  ///
  /// let data = worker.get_message();
  /// assert!(data.is_none());
  ///
  /// worker.terminate();
  /// assert!(!worker.is_running());
  /// ```
  pub fn worker<T: std::marker::Send + 'static>(
    task: CWorkerCB<T>,
  ) -> CWorkerProtocol<T> {
    CWorkerProtocol::new(task)
  }
}

// ============================================================================
// [Console Use Case] =========================================================
// ============================================================================

/// Implements the CodeMelted DEV Console use case. Provides the ability to
/// create terminal applications using STDIN / STDOUT to interact with the
/// user with simple prompts to guide them through a terminal based app.
#[doc = mermaid!("models/codemelted_console.mmd")]
pub mod codemelted_console {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::{CObject, CTruthyString};
  use simple_mermaid::mermaid;
  use std::io::{stdin, stdout, Write};

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  // NONE

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Utility function to read from stdin with a specified prompt.
  fn read(prompt: &str) -> String {
    let mut answer = String::new();
    print!("{}", prompt);
    let _ = stdout().flush();
    let _ = stdin().read_line(&mut answer);
    String::from(answer.trim())
  }

  /// Utility function to write to stdout with or without a new line.
  fn write_stdout(message: &str, use_new_line: bool) {
    if use_new_line {
      println!("{}", message);
    } else {
      print!("{}", message);
    }
  }

  /// Puts out an alert to STDOUT awaiting for the user to press the ENTER
  /// key.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// codemelted_console::alert("Oh no it exploded!");
  /// ```
  pub fn alert(message: &str) {
    let msg = match message {
      "" => "[ENTER]: ",
      _ => &format!("{} [ENTER]: ", message),
    };
    read(msg);
  }

  /// Prompts a user via STDIN to confirm a choice. The response will be a
  /// true / false based on [CObject::is_truthy] testing of the response.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// let answer = codemelted_console::confirm(
  ///   "Are you sure you want to do this"
  /// );
  /// ```
  pub fn confirm(message: &str) -> bool {
    let msg = match message {
      "" => "CONFIRM [y/N]: ",
      _ => &format!("{} CONFIRM [y/N]: ", message),
    };
    let answer: String = read(msg);
    CObject::is_truthy(&answer)
  }

  /// Prompts a user via STDIN to choose from a set of choices. The response
  /// will be a u32 based on the selection made. Entering invalid data will
  /// repeat the menu of choices until a valid selection is made.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// let answer = codemelted_console::choose(
  ///   "Best Pet",
  ///   &["bird", "cat", "dog", "fish"],
  /// );
  /// ```
  pub fn choose(message: &str, choices: &[&str]) -> u32 {
    let msg = match message {
      "" => "CHOOSE",
      _ => &format!("{}", message),
    };
    let options = choices;
    let answer: u32;
    loop {
      println!("{}", "-".repeat(msg.chars().count()));
      println!("{}", msg);
      println!("{}", "-".repeat(msg.chars().count()));
      let mut x = -1;
      for option in options {
        x += 1;
        println!("{}. {}", x, option);
      }
      println!("");
      let selection = read("Make a Selection: ");
      match selection.trim().parse::<u32>() {
        Ok(n) => {
          if n < options.len().try_into().unwrap() {
            answer = n;
            break;
          } else {
            println!("");
            println!("ERROR: Invalid selection, please try again.");
            println!("");
          }
        },
        Err(_e) => {
          println!("");
          println!("ERROR: Invalid selection, please try again.");
          println!("");
        }
      }
    }
    answer
  }

  /// Prompts a user via STDIN to enter their password. The password will not
  /// be reflected as they type.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// let answer = codemelted_console::password(
  ///   "Whats Your Password",
  /// );
  /// ```
  pub fn password(message: &str) -> String {
    let msg = match message {
      "" => "PASSWORD: ",
      _ => &format!("{}: ", message),
    };
    let password = rpassword::prompt_password(msg).unwrap();
    String::from(password)
  }

  /// Prompts a user via STDIN to answer a question.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// let answer = codemelted_console::prompt(
  ///   "DC or Marvel",
  /// );
  /// ```
  pub fn prompt(message: &str) -> String {
    let msg = match message {
      "" => "PROMPT: ",
      _ => &format!("{}: ", message),
    };
    let answer: String = read(msg);
    String::from(answer)
  }

  /// Will put a string to STDOUT without the new line character.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// codemelted_console::write("Oh Know!");
  /// ```
  pub fn write(message: &str) {
    write_stdout(message, false);
  }

  /// Will put a string to STDOUT with a new line character.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// codemelted_console::write("Oh Know!");
  /// ```
  pub fn writeln(message: &str) {
    write_stdout(message, true);
  }
}

// ============================================================================
// [DB Use Case] ==============================================================
// ============================================================================

/// <center><b><mark>FUTURE IMPLEMENTATION. DOES NOTHING</mark></b></center>
pub mod codemelted_db {
  // FUTURE IMPLEMENTATION
}

// ============================================================================
// [Disk Use Case] ============================================================
// ============================================================================

/// Implements the CodeMelted DEV Disk use case. Provides the ability to
/// manage files / directories on disk, query properties associated with
/// managing the disk, reading / writing files, and the ability to monitor the
/// disks attached to the host operating system.
#[doc = mermaid!("models/codemelted_disk.mmd")]
pub mod codemelted_disk {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::{codemelted_storage, CCsvFormat};
  use std::io::{Read, Write};
  use std::fs::{self, File, Metadata, OpenOptions};
  use std::path::Path;
  use simple_mermaid::mermaid;
  use sysinfo::Disks;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// The result of the [monitor] call provide a view of the host operating
  /// systems available data disk storage. This is a self contained array of
  /// disks and their associated information. Any index call beyond the
  /// available disks will panic your application.
  pub struct CDiskMonitor {
    disks: Disks
  }
  impl CDiskMonitor {
    /// Creates a new instance of the [CDiskMonitor] struct.
    fn new() -> CDiskMonitor {
      let mut disks = Disks::new_with_refreshed_list();
      disks.refresh(true);
      CDiskMonitor { disks }
    }

    /// Identifies how many disks are attached to the host operating system.
    pub fn len(&self) -> usize {
      self.disks.len()
    }

    /// Refreshes the disk data to get the latest information.
    pub fn refresh(&mut self) {
      self.disks.refresh(true);
    }

    /// Identifies how the disk is known to the host operating system.
    pub fn name(&self, index: usize) -> String {
      match self.disks.get(index) {
        Some(v) => {
          match v.name().to_str() {
            Some(v) => String::from(v),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Identifies the available disk space in bytes.
    pub fn disk_available_bytes(&self, index: usize) -> u64 {
      match self.disks.get(index) {
        Some(v) => v.available_space(),
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Identifies the used space in bytes of the disk.
    pub fn disk_used_bytes(&self, index: usize) -> u64 {
      self.disk_total_bytes(index) - self.disk_available_bytes(index)
    }

    /// Identifies how big the disk is in bytes.
    pub fn disk_total_bytes(&self, index: usize) -> u64 {
      match self.disks.get(index) {
        Some(v) => v.total_space(),
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Identifies how much of the disk is used.
    pub fn disk_load(&self, index: usize) -> f32 {
      let used_space = self.disk_used_bytes(index) as f32;
      let total_space = self.disk_total_bytes(index) as f32;
      (used_space / total_space) * 100.0
    }

    /// Identifies how the disk is formatted.
    pub fn file_system(&self, index: usize) -> String {
      match self.disks.get(index) {
        Some(v) => {
          match v.file_system().to_str() {
            Some(v) => String::from(v),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Determines if this disk is readonly or writeable.
    pub fn is_read_only(&self, index: usize) -> bool {
      match self.disks.get(index) {
        Some(v) => v.is_read_only(),
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Determines if this disk is removable or not.
    pub fn is_removable(&self, index: usize) -> bool {
      match self.disks.get(index) {
        Some(v) => v.is_removable(),
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Determines what type of disk this is.
    pub fn kind(&self, index: usize) -> String {
      match self.disks.get(index) {
        Some(v) => v.kind().to_string(),
        None => panic!("SyntaxError: index out of range."),
      }
    }

    /// Identifies the mount point of the disk.
    pub fn mount_point(&self, index: usize) -> String {
      match self.disks.get(index) {
        Some(v) => {
          match v.mount_point().to_str() {
            Some(v) => String::from(v),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: index out of range."),
      }
    }
  }
  impl CCsvFormat for CDiskMonitor {
    fn csv_header(&self) -> String {
      format!(
        "{},{},{},{},{},{},{},{},{},{},{}",
        String::from("system_id"),
        String::from("name"),
        String::from("disk_available_bytes"),
        String::from("disk_used_bytes"),
        String::from("disk_total_bytes"),
        String::from("disk_load"),
        String::from("file_system"),
        String::from("is_readonly"),
        String::from("is_removable"),
        String::from("kind"),
        String::from("mount_point"),
      )
    }

    fn as_csv(&self) -> String {
      let mut csv_data = String::new();
      let mut x = 0;
      while x < self.len() {
        let data = format!(
          "{},{},{},{},{},{},{},{},{},{},{}",
          Self::system_id(),
          self.name(x),
          self.disk_available_bytes(x),
          self.disk_used_bytes(x),
          self.disk_total_bytes(x),
          self.disk_load(x),
          self.file_system(x),
          self.is_read_only(x),
          self.is_removable(x),
          self.kind(x),
          self.mount_point(x)
        );
        csv_data.push_str(&data);
        csv_data.push('\n');
        x += 1
      }
      csv_data
    }
  }

  /// Identifies the type of src on the disk when attempting to see if it
  /// [exists] or not.
  pub enum CDiskType {
    /// Does not matter the type, just does it exist or not.
    Either,
    /// Only true if it is a directory.
    Directory,
    /// Only true if it is a file.
    File,
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Will copy a file / directory from one location on the host operating
  /// system disk to the other.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let temp_filename = format!(
  ///   "{}/test.txt",
  ///   codemelted_disk::temp_path()
  /// );
  /// let home_filename = format!(
  ///   "{}/test.txt",
  ///   codemelted_disk::home_path()
  /// );
  ///
  /// let _ = codemelted_disk::write_file_as_string(
  ///   &home_filename,
  ///   "Hello",
  ///   false
  /// );
  /// let result = codemelted_disk::cp(&home_filename, &temp_filename);
  /// assert!(result.is_ok());
  /// ```
  pub fn cp(src: &str, dest: &str) -> Result<(), std::io::Error> {
    let result = fs::copy(src, dest);
    match result {
      Ok(_) => Ok(()),
      Err(why) => Err(why),
    }
  }

  /// Determines if a directory or file exists on the host operating system
  /// and will further determine if it is of the expected [CDiskType].
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  /// use codemelted::codemelted_disk::CDiskType;
  ///
  /// let path = codemelted_disk::home_path();
  /// assert_eq!(codemelted_disk::exists(&path, CDiskType::Either), true);
  /// assert_eq!(codemelted_disk::exists(&path, CDiskType::Directory), true);
  /// assert_eq!(codemelted_disk::exists(&path, CDiskType::File), false);
  /// ```
  pub fn exists(src: &str, disk_type: CDiskType) -> bool {
    match disk_type {
      CDiskType::Either => Path::new(src).is_dir()
        || Path::new(src).is_file(),
      CDiskType::Directory => Path::new(src).is_dir(),
      CDiskType::File => Path::new(src).is_file(),
    }
  }

  /// Gets the home path of the logged in user from the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  /// use codemelted::codemelted_disk::CDiskType;
  ///
  /// let path = codemelted_disk::home_path();
  /// assert_eq!(codemelted_disk::exists(&path, CDiskType::Directory), true);
  /// ```
  pub fn home_path() -> String {
    let home_path = if cfg!(target_os = "windows") {
      codemelted_storage::environment("USERPROFILE")
    } else {
      codemelted_storage::environment("HOME")
    };
    match home_path {
      Some(v) => v,
      None => {
        panic!("SyntaxError: codemelted_disk::home_path() unable to query.")
      },
    }
  }

  /// Will list the files / directories in a given location on the host
  /// operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let temp_path = codemelted_disk::temp_path();
  /// let result = codemelted_disk::ls(&temp_path);
  /// assert!(result.is_ok());
  /// ```
  pub fn ls(src: &str) -> Result<fs::ReadDir, std::io::Error> {
    fs::read_dir(src)
  }

  /// Retrieves metadata about the specified directory or stored on the
  /// host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let path = codemelted_disk::home_path();
  /// let answer = codemelted_disk::metadata(&path);
  /// assert!(answer.is_ok());
  /// ```
  pub fn metadata(src: &str) -> Result<Metadata, std::io::Error> {
    Path::new(src).metadata()
  }

  /// Will create a directory and sub-directories in a given location on the
  /// host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let temp_path = codemelted_disk::temp_path();
  /// let new_path = format!("{}/1/2/ready/go", temp_path);
  /// let result = codemelted_disk::mkdir(&new_path);
  /// assert!(result.is_ok());
  pub fn mkdir(src: &str) -> Result<(), std::io::Error> {
    fs::create_dir_all(src)
  }

  /// Constructs a [CDiskMonitor] to monitor the attached disk drives to
  /// the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  /// use codemelted::codemelted_disk::CDiskMonitor;
  ///
  /// let mut monitor = codemelted_disk::monitor();
  /// monitor.refresh();
  /// let len = monitor.len();
  /// let disk_load = monitor.disk_load(0);
  /// assert!(len > 0);
  /// assert!(disk_load > 0.0);
  /// ```
  pub fn monitor() -> CDiskMonitor {
    CDiskMonitor::new()
  }

  /// Will move a file / directory from one location on the host operating
  /// system disk to the other.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let temp_filename = format!(
  ///   "{}/test.txt",
  ///   codemelted_disk::temp_path()
  /// );
  /// let new_filename = format!(
  ///   "{}/test_new.txt",
  ///   codemelted_disk::temp_path()
  /// );
  ///
  /// let _ = codemelted_disk::write_file_as_string(
  ///   &temp_filename,
  ///   "Hello",
  ///   false
  /// );
  /// let result = codemelted_disk::mv(&temp_filename, &new_filename);
  /// assert!(result.is_ok());
  /// ```
  pub fn mv(src: &str, dest: &str) -> Result<(), std::io::Error> {
    let result = fs::rename(src, dest);
    match result {
      Ok(_) => Ok(()),
      Err(why) => Err(why),
    }
  }

  /// Retrieves the newline character utilized by the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let newline = codemelted_disk::newline();
  /// assert!(newline.len() > 0);
  /// ```
  pub fn newline() -> String {
    if cfg!(target_os = "windows") {
      String::from("\r\n")
    } else {
      String::from("\n")
    }
  }

  /// Gets the path separator slash character based on the host operating
  /// system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let separator = codemelted_disk::path_separator();
  /// assert!(separator.len() > 0);
  /// ```
  pub fn path_separator() -> String {
    if cfg!(target_os = "windows") {
      String::from("\\")
    } else {
      String::from("/")
    }
  }

  /// Reads a binary file from the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let data = Vec::<u8>::from([0x01, 0x02]);
  /// let filename = format!("{}/test.bin", codemelted_disk::temp_path());
  /// let result = codemelted_disk::write_file_as_bytes(
  ///   &filename,
  ///   &data,
  ///   false
  /// );
  /// assert!(result.is_ok());
  /// let data = codemelted_disk::read_file_as_bytes(
  ///   &filename,
  /// );
  /// assert!(data.is_ok());
  /// ```
  pub fn read_file_as_bytes(
    filename: &str
  ) -> Result<Vec<u8>, std::io::Error> {
    let file = File::open(filename);
    match file {
      Ok(_) => {
        let mut data = Vec::new();
        let result = file?.read_to_end(&mut data);
        match result {
          Ok(_) => Ok(data),
          Err(err) => Err(err),
        }
      },
      Err(err) => Err(err),
    }
  }

  /// Reads a text file from the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let filename = format!("{}/test.txt", codemelted_disk::temp_path());
  /// let result = codemelted_disk::write_file_as_string(
  ///   &filename,
  ///   "Hello",
  ///   false
  /// );
  /// assert!(result.is_ok());
  /// let data = codemelted_disk::read_file_as_string(
  ///   &filename,
  /// );
  /// assert!(data.is_ok());
  /// ```
  pub fn read_file_as_string(
    filename: &str
  ) -> Result<String, std::io::Error> {
    let file = File::open(filename);
    match file {
      Ok(_) => {
        let mut data = String::new();
        let result = file?.read_to_string(&mut data);
        match result {
          Ok(_) => Ok(data),
          Err(err) => Err(err),
        }
      },
      Err(err) => Err(err),
    }
  }

  /// Will remove a file / directory from one location on the host operating
  /// system disk to the other.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let temp_filename = format!(
  ///   "{}/test.txt",
  ///   codemelted_disk::temp_path()
  /// );
  ///
  /// let _ = codemelted_disk::write_file_as_string(
  ///   &temp_filename,
  ///   "Hello",
  ///   false
  /// );
  /// let result = codemelted_disk::rm(&temp_filename);
  /// assert!(result.is_ok());
  /// ```
  pub fn rm(src: &str) -> Result<(), std::io::Error> {
    let is_file = exists(src, CDiskType::File);
    let is_dir = exists(src, CDiskType::Directory);
    if is_file {
      let result = fs::remove_file(src);
      match result {
        Ok(_) => return Ok(()),
        Err(why) => return Err(why),
      }
    } else if is_dir {
      let result = fs::remove_dir_all(src,);
      match result {
        Ok(_) => return Ok(()),
        Err(why) => return Err(why),
      }
    }
    panic!("codemelted_disk::rm - Specified src was not found!");
  }

  /// Retrieves the temporary path for storing data by the host operating
  /// system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let path = codemelted_disk::temp_path();
  /// assert!(path.len() > 0);
  /// ```
  pub fn temp_path() -> String {
    match std::env::temp_dir().to_str() {
      Some(v) => String::from(v),
      None => {
        panic!("SyntaxError: codemelted_disk::temp_path() unable to query.")
      }
    }
  }

  /// Writes a binary file to the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let data = Vec::<u8>::from([0x01, 0x02]);
  /// let filename = format!("{}/test.bin", codemelted_disk::temp_path());
  /// let result = codemelted_disk::write_file_as_bytes(
  ///   &filename,
  ///   &data,
  ///   false
  /// );
  /// assert!(result.is_ok());
  /// ```
  pub fn write_file_as_bytes(
    filename: &str,
    data: &[u8],
    append: bool,
  ) -> Result<(), std::io::Error> {
    let mut file = if append {
      OpenOptions::new()
        .append(true)
        .create(true)
        .open(filename)?
    } else {
      OpenOptions::new()
        .write(true)
        .create(true)
        .open(filename)?
    };
    let _ = file.write_all(data)?;
    Ok(())
  }

  /// Writes a text file to the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_disk;
  ///
  /// let filename = format!("{}/test.txt", codemelted_disk::temp_path());
  /// let result = codemelted_disk::write_file_as_string(
  ///   &filename,
  ///   "hello",
  ///   false
  /// );
  /// assert!(result.is_ok());
  /// ```
  pub fn write_file_as_string(
    filename: &str,
    data: &str,
    append: bool,
  ) -> Result<(), std::io::Error> {
    write_file_as_bytes(filename, data.as_bytes(), append)
  }
}

// ============================================================================
// [HW Use Case] ==============================================================
// ============================================================================

/// <center><b><mark>IN ACTIVE DEVELOPMENT</mark></b></center>
pub mod codemelted_hw {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------

  use crate::{codemelted_storage, CCsvFormat};
  use sysinfo::{Components, System};

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// The result of a [monitor] call providing a view of a system's
  /// internal components and their current health (i.e. temperature in °C)
  /// along with their failure points.
  pub struct CComponentMonitor {
    components: Components
  }
  impl CComponentMonitor {
    /// Creates a new instance of the [CComponentMonitor] object.
    fn new() -> CComponentMonitor {
      let mut components = Components::new_with_refreshed_list();
      components.refresh(true);
      CComponentMonitor { components }
    }

    /// Refreshes the current set of tracked component data.
    pub fn refresh(&mut self) {
      self.components.refresh(true);
    }

    /// The total of components being tracked after a refresh.
    pub fn len(&self) -> usize {
      self.components.len()
    }

    /// The identifier of the given component at the specified index.
    pub fn label(&self, index: usize) -> String {
      match self.components.get(index) {
        Some(v) => {
          v.label().to_string()
        },
        None => panic!("SyntaxError: invalid index specified."),
      }
    }

    /// The current temperature °C of the given component at the specified
    /// index.
    pub fn temp_current_c(&self, index: usize) -> f32 {
      match self.components.get(index) {
        Some(v) => {
          match v.temperature() {
            Some(v) => v,
            None => f32::NAN,
          }
        },
        None => panic!("SyntaxError: invalid index specified."),
      }
    }

    /// The max temperature °C of the given component at the specified index.
    pub fn temp_max_c(&self, index: usize) -> f32 {
      match self.components.get(index) {
        Some(v) => {
          match v.max() {
            Some(v) => v,
            None => f32::NAN,
          }
        },
        None => panic!("SyntaxError: invalid index specified."),
      }
    }


    /// The critical temperature °C of the given component at the specified
    /// index.
    pub fn temp_critical_c(&self, index: usize) -> f32 {
      match self.components.get(index) {
        Some(v) => {
          match v.critical() {
            Some(v) => v,
            None => f32::NAN,
          }
        },
        None => panic!("SyntaxError: invalid index specified."),
      }
    }
  }

  impl CCsvFormat for CComponentMonitor {
    fn csv_header(&self) -> String {
      format!(
        "{},{},{},{},{}",
        String::from("system_id"),
        String::from("label"),
        String::from("temp_current_c"),
        String::from("temp_max_c"),
        String::from("temp_critical_c"),
      )
    }

    fn as_csv(&self) -> String {
      let mut csv_data = String::new();
      let mut x = 0;
      while x < self.len() {
        let data = format!(
          "{},{},{},{},{}",
          Self::system_id(),
          self.label(x),
          self.temp_current_c(x),
          self.temp_max_c(x),
          self.temp_critical_c(x),
        );
        csv_data.push_str(&data);
        csv_data.push('\n');
        x += 1
      }
      csv_data
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Retrieves the kernel version of the host operating system. UNDETERMINED
  /// is returned if it could not be determined.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_hw;
  ///
  /// let version = codemelted_hw::kernel_version();
  /// assert!(version.len() > 0);
  /// ```
  pub fn kernel_version() -> String {
    match System::kernel_version() {
      Some(v) => v,
      None => String::from("UNDETERMINED"),
    }
  }

  /// Constructs a [CComponentMonitor] to monitor attached hardware component
  /// temperatures in °C.
  ///
  /// _NOTE: Only certain operating systems will support this. If they don't
  ///        the [CComponentMonitor::len] will always be 0._
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_hw;
  /// use codemelted::codemelted_hw::CComponentMonitor;
  ///
  /// let mut monitor = codemelted_hw::monitor();
  /// monitor.refresh();
  /// let len = monitor.len();
  /// assert!(len >= 0);
  /// ```
  pub fn monitor() -> CComponentMonitor {
    CComponentMonitor::new()
  }

  /// Retrieves the operating system name of the host operating system.
  /// UNDETERMINED is returned if it could not be determined.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_hw;
  ///
  /// let name = codemelted_hw::os_name();
  /// assert!(name.len() > 0);
  /// ```
  pub fn os_name() -> String {
    match System::name() {
      Some(v) => v,
      None => String::from("UNDETERMINED"),
    }
  }

  /// Retrieves the operating system version of the host operating system.
  /// UNDETERMINED is returned if it could not be determined.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_hw;
  ///
  /// let version = codemelted_hw::os_version();
  /// assert!(version.len() > 0);
  /// ```
  pub fn os_version() -> String {
    match System::os_version() {
      Some(v) => v,
      None => String::from("UNDETERMINED"),
    }
  }

  /// Retrieves the logged in user session for the host operating system.
  /// UNDETERMINED is returned if it could not be determined.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_hw;
  ///
  /// let user = codemelted_hw::user();
  /// assert!(user.len() > 0);
  /// ```
  pub fn user() -> String {
    let user = if cfg!(target_os = "windows") {
      codemelted_storage::environment("USERNAME")
    } else {
      codemelted_storage::environment("USER")
    };
    match user {
      Some(v) => v,
      None => String::from("UNDETERMINED"),
    }
  }
}

// ============================================================================
// [JSON Use Case] ============================================================
// ============================================================================

/// Implements the CodeMelted DEV JSON use case. Provides the ability to work
/// with JSON based data. This includes performing data validations, parsing,
/// stringify, and converting to basic data types. This is based on the
/// [CObject] which represents rust based JSON data.
#[doc = mermaid!("models/codemelted_json.mmd")]
pub mod codemelted_json {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::CObject;
  use json::number::Number;
  use simple_mermaid::mermaid;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Enumeration to support the [check_type] function for checking if a
  /// [CObject] holds the specified data type.
  pub enum CDataType {
    /// Check if the data type is an array.
    Array,
    /// Check if the data type is a bool.
    Boolean,
    /// Check if the data type is not set to anything.
    Empty,
    /// Check if the data type is a null type.
    Null,
    /// Check if the data type is a Rust number (i.e. u / f types)
    Number,
    /// Check if the data type is another [CObject] type.
    Object,
    /// Check if the data type is a String type.
    String,
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Will convert the given [CObject] to its equivalent bool value. This will
  /// also be false if not a valid value.
  ///
  /// **Example (Successful Conversion):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::Boolean(true);
  /// assert_eq!(codemelted_json::as_bool(&obj), true);
  /// ```
  ///
  /// **Example (Convert false with actual data or invalid):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj1 = CObject::Boolean(false);
  /// assert_eq!(codemelted_json::as_bool(&obj1), false);
  ///
  /// let obj2 = CObject::String("Oh Know!".to_string());
  /// assert_eq!(codemelted_json::as_bool(&obj2), false);
  /// ```
  pub fn as_bool(data: &CObject) -> bool {
    let answer = data.as_bool();
    match answer {
      Some(v) => v,
      _ => false,
    }
  }

  /// Will convert the given [CObject] to its equivalent number value. This
  /// will be set to None if the conversion fails.
  ///
  /// **Example (Successful Conversion):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::from(542.65);
  /// assert_eq!(codemelted_json::as_number(&obj).is_some(), true);
  /// ```
  ///
  /// **Example (Failed Conversion):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::from("Hello Boss");
  /// assert_eq!(codemelted_json::as_number(&obj).is_some(), false);
  /// ```
  ///
  pub fn as_number(data: &CObject) -> Option<Number>{
    data.as_number()
  }

  /// Will convert the given [CObject] to its equivalent string value. This
  /// will be None if the conversion fails.
  ///
  /// **Example (Successful Conversion):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::from("Hello");
  /// assert_eq!(codemelted_json::as_string(&obj).is_some(), true);
  /// ```
  ///
  /// **Example (Failed Conversion):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::Null;
  /// assert_eq!(codemelted_json::as_string(&obj).is_some(), false);
  /// ```
  ///
  pub fn as_string(data: &CObject) -> Option<String> {
    let answer = data.as_str();
    match answer {
      Some(v) => Some(String::from(v)),
      _ => None,
    }
  }

  /// Will determine if the specified [CObject] is of the specified
  /// [CDataType] enumeration.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_object();
  /// assert_eq!(
  ///   codemelted_json::check_type(CDataType::Object, &obj, false),
  ///   true
  /// );
  /// assert_eq!(
  ///   codemelted_json::check_type(CDataType::Number, &obj, false),
  ///   false
  /// );
  /// ```
  pub fn check_type(
    data_type: CDataType,
    data: &CObject,
    should_panic: bool,
  ) -> bool {
    let answer = match data_type {
      CDataType::Array => data.is_array(),
      CDataType::Boolean => data.is_boolean(),
      CDataType::Empty => data.is_empty(),
      CDataType::Null => data.is_null(),
      CDataType::Number => data.is_number(),
      CDataType::Object => data.is_object(),
      CDataType::String => data.is_string(),
    };

    if should_panic && !answer {
      panic!("ERROR: codemelted_json::check_type() failed.");
    }
    answer
  }

  /// Creates a JSON compliant [CObject] for working with array JSON data.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_array();
  /// assert_eq!(
  ///   codemelted_json::check_type(CDataType::Array, &obj, false),
  ///   true
  /// );
  /// ```
  pub fn create_array() -> CObject {
    CObject::new_array()
  }

  /// Creates a JSON compliant [CObject] for working with object JSON data.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_object();
  /// assert_eq!(
  ///   codemelted_json::check_type(CDataType::Object, &obj, false),
  ///   true
  /// );
  /// ```
  pub fn create_object() -> CObject {
    CObject::new_object()
  }

  /// Will check if a [CObject] object data JSON type has the specified key
  /// property before working with it.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let mut obj = codemelted_json::create_object();
  /// let _ = obj.insert("field1", 42);
  /// assert_eq!(codemelted_json::has_key(&obj, "field1", false), true);
  /// ```
  pub fn has_key(
    data: &CObject,
    key: &str,
    should_panic: bool,
  ) -> bool {
    let answer = data.has_key(key);
    if should_panic && !answer {
      panic!("ERROR: codemelted_json::has_key() failed.");
    }
    answer
  }

  /// Takes a JSON serialized string and parses it to create a [CObject].
  /// Returns None if the parse fails.
  ///
  /// **Example (Successful Parse):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let mut obj1 = codemelted_json::create_object();
  /// let _ = obj1.insert("field1", 42);
  /// let stringified_data = codemelted_json::stringify(obj1.clone());
  /// let obj2 = codemelted_json::parse(&stringified_data).unwrap();
  /// assert_eq!(obj1, obj2);
  /// ```
  ///
  /// **Example (Failed Parse):**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// let obj = codemelted_json::parse("{,},");
  /// assert_eq!(obj.is_some(), false);
  /// ```
  pub fn parse(data: &str) -> Option<CObject> {
    let answer = json::parse(&data);
    match answer {
      Ok(v) => Some(v),
      _ => None,
    }
  }

  /// Takes a [CObject] and converts it the serialized JSON string. See
  /// [parse] for examples.
  pub fn stringify(data: CObject) -> String {
    json::stringify(data)
  }

  /// Validates if a specified data str represents a valid URL. True if it is
  /// and false if not.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// assert_eq!(
  ///   codemelted_json::valid_url("https://google.com", false),
  ///   true
  /// );
  /// assert_eq!(codemelted_json::valid_url("{230924!!}}|}", false), false);
  /// ```
  pub fn valid_url(
    data: &str,
    should_panic: bool,
  ) -> bool {
    let answer = !(url::Url::parse(data).is_err());
    if should_panic && !answer {
      panic!("ERROR: codemelted_json::valid_url() failed.");
    }
    answer
  }
}

// ============================================================================
// [Logger Use Case] ==========================================================
// ============================================================================

/// Implements the CodeMelted DEV Logger use case. Provides a simple utility
/// to log to STDOUT for logging levels represented via the CLogLevel
/// enumeration. It also provides the ability to attach a
/// CLoggedEventHandler callback for post processing of a logging event
/// once logged to STDOUT.
#[doc = mermaid!("models/codemelted_logger.mmd")]
pub mod codemelted_logger {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use std::sync::Mutex;
  use simple_mermaid::mermaid;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Holds the log level for the logger module.
  static LOG_LEVEL: Mutex<CLogLevel> = Mutex::new(CLogLevel::Warning);

  /// Holds the log handler reference for post log processing.
  static LOG_HANDLER: Mutex<Option<CLoggedEventHandler>> = Mutex::new(None);

  /// Represents the log levels for the logging module.
  #[derive(Clone, PartialEq, Debug)]
  pub enum CLogLevel {
    /// Ideal for debugging the running application.
    Debug,
    /// Something good has happened in your app.
    Info,
    /// Something recoverable happened within the app.
    Warning,
    /// Something really bad happened within the app.
    Error,
    /// We don't care what happens within the app.
    Off,
  }
  impl CLogLevel {
    /// Retrieves the string representation of the logging level.
    pub fn as_string(&self) -> String {
      match self {
        CLogLevel::Debug => String::from("DEBUG"),
        CLogLevel::Info => String::from("INFO"),
        CLogLevel::Warning => String::from("WARNING"),
        CLogLevel::Error => String::from("ERROR"),
        CLogLevel::Off => String::from("OFF"),
      }
    }

    /// Retrieves the int representation of the logging level.
    pub fn as_int(&self) -> u8 {
      match self {
        CLogLevel::Debug => 0,
        CLogLevel::Info => 1,
        CLogLevel::Warning => 2,
        CLogLevel::Error => 3,
        CLogLevel::Off => 4,
      }
    }
  }

  /// The record created to represent the logged event.
  pub struct CLogRecord {
    time_stamp: chrono::DateTime<chrono::Utc>,
    log_level: CLogLevel,
    data: String,
  }
  /// The attached support functions for the [CLogRecord] struct.
  impl CLogRecord {
    /// Creates the [CLogRecord] when a [log] event occurs with the module.
    fn new(log_level: CLogLevel, data: &str) -> CLogRecord {
      CLogRecord {
        time_stamp: chrono::Utc::now(),
        log_level,
        data: String::from(data),
      }
    }

    /// Retrieves when the logged event was handled.
    pub fn get_time_stamp(&self) -> &chrono::DateTime<chrono::Utc> {
      &self.time_stamp
    }

    /// Gets the log level of the event.
    pub fn get_log_level(&self) -> &CLogLevel {
      &self.log_level
    }

    /// Gets the data associated with the event.
    pub fn get_data(&self) -> &str {
      &self.data
    }

    /// Translates a string representation of the [CLogRecord] struct.
    pub fn as_string(&self) -> String {
      format!(
        "{} [{}]: {}",
        self.get_time_stamp().format("%Y-%b-%d %H:%M:%S.%3f"),
        self.get_log_level().as_string(),
        self.get_data()
      )
    }
  }

  /// Function type definition for post processing logged events.
  pub type CLoggedEventHandler = fn(CLogRecord);

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Gets the [CLogLevel] for the logging module.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogLevel;
  ///
  /// codemelted_logger::set_log_level(CLogLevel::Debug);
  /// assert_eq!(codemelted_logger::get_log_level(), CLogLevel::Debug);
  /// ```
  pub fn get_log_level() -> CLogLevel {
    let data = LOG_LEVEL.lock().unwrap();
    data.clone()
  }

  /// Sets the [CLogLevel] for the logging module.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogLevel;
  ///
  /// codemelted_logger::set_log_level(CLogLevel::Debug);
  /// assert_eq!(codemelted_logger::get_log_level(), CLogLevel::Debug);
  /// ```
  pub fn set_log_level(log_level: CLogLevel) {
    let mut data = LOG_LEVEL.lock().unwrap();
    *data = log_level;
  }

  /// Gets the [CLoggedEventHandler] for the logging module.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogRecord;
  /// use codemelted::codemelted_logger::CLoggedEventHandler;
  ///
  /// fn log_handler(data: CLogRecord) {
  ///   // Do something
  /// }
  ///
  /// codemelted_logger::set_log_handler(Some(log_handler));
  /// assert_eq!(codemelted_logger::get_log_handler().is_some(), true);
  /// ```
  pub fn get_log_handler() -> Option<CLoggedEventHandler> {
    let data = LOG_HANDLER.lock().unwrap();
    *data
  }

  /// Sets the [CLoggedEventHandler] for the logging module.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogRecord;
  /// use codemelted::codemelted_logger::CLoggedEventHandler;
  ///
  /// fn log_handler(data: CLogRecord) {
  ///   // Do something
  /// }
  ///
  /// codemelted_logger::set_log_handler(Some(log_handler));
  /// assert_eq!(codemelted_logger::get_log_handler().is_some(), true);
  /// ```
  pub fn set_log_handler(handler: Option<CLoggedEventHandler>) {
    let mut data = LOG_HANDLER.lock().unwrap();
    *data = handler;
  }

  /// Will log an event via the logger module so long as it meets the
  /// currently set [CLogLevel]. Once logged to STDOUT, if a
  /// [CLoggedEventHandler], will pass the [CLogRecord] along for further
  /// processing.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogLevel;
  ///
  /// codemelted_logger::log(CLogLevel::Error, "Oh Know!");
  /// ```
  pub fn log(level: CLogLevel, data: &str) {
    // See if we are logging this somewhere
    let logger_level = get_log_level();
    if logger_level == CLogLevel::Off {
      return
    }

    // Create the log record.
    let record = CLogRecord::new(level, data);

    if record.get_log_level().as_int() >= logger_level.as_int() {
      println!("{}", record.as_string())
    }

    // Now to send it to the log handler
    let log_handler = get_log_handler();
    if let Some(v) = log_handler {
      v(record);
    }
  }
}

// ============================================================================
// [Network Use Case] =========================================================
// ============================================================================

/// <center><b><mark>IN ACTIVE DEVELOPMENT</mark></b></center>
pub mod codemelted_network {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::CCsvFormat;
  use sysinfo::{Networks, System};

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// The result of the [monitor] call provide a view of the host
  /// operating systems available network interfaces. This is a self contained
  /// hashtable of network interfaces with statistics related to overall
  /// received / transmitted bytes, packets, and encountered errors.
  pub struct CNetworkMonitor {
    networks: Networks
  }
  impl CNetworkMonitor {
    /// Creates the new [CNetworkMonitor] object.
    fn new() -> CNetworkMonitor {
      let networks = Networks::new_with_refreshed_list();
      CNetworkMonitor { networks }
    }

    /// Refreshes the currently held hashtable of network interfaces.
    pub fn refresh(&mut self) {
      self.networks.refresh(true);
    }

    /// Gets the name of the network interface.
    pub fn names(&self) -> Vec<String> {
      let mut names = Vec::<String>::new();
      for (name, _network) in &self.networks {
        names.push(name.to_string());
      }
      names
    }

    /// Gets the MAC address associated with the network interface.
    pub fn mac_address(&self, name: &str) -> String{
      match self.networks.get(name) {
        Some(v) => {
          v.mac_address().to_string()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the Maximum Transfer Unit of the network interface.
    pub fn mtu(&self, name: &str) -> u64{
      match self.networks.get(name) {
        Some(v) => {
          v.mtu()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total received bytes on the network interface.
    pub fn network_total_rx_bytes(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_received()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total received errors on the network interface.
    pub fn network_total_rx_errors(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_errors_on_received()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total received packets on the network interface.
    pub fn network_total_rx_packets(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_packets_received()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total transmitted bytes on the network interface.
    pub fn network_total_tx_bytes(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_transmitted()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total transmitted errors on the network interface.
    pub fn network_total_tx_errors(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_errors_on_received()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }

    /// Gets the total transmitted packets on the network interface.
    pub fn network_total_tx_packets(&self, name: &str) -> u64 {
      match self.networks.get(name) {
        Some(v) => {
          v.total_packets_received()
        },
        None => panic!("SyntaxError: Unknown name specified."),
      }
    }
  }
  impl CCsvFormat for CNetworkMonitor {
    fn csv_header(&self) -> String {
      format!(
        "{},{},{},{},{},{},{},{},{},{}",
        String::from("system_id"),
        String::from("name"),
        String::from("mac_address"),
        String::from("mtu"),
        String::from("network_total_rx_bytes"),
        String::from("network_total_rx_errors"),
        String::from("network_total_rx_packets"),
        String::from("network_total_tx_bytes"),
        String::from("network_total_tx_errors"),
        String::from("network_total_tx_packets"),
      )
    }
    fn as_csv(&self) -> String {
      let mut csv_data = String::new();
      let names = self.names();
      for name in names {
        let data = format!(
          "{},{},{},{},{},{},{},{},{},{}",
          Self::system_id(),
          name,
          self.mac_address(&name),
          self.mtu(&name),
          self.network_total_rx_bytes(&name),
          self.network_total_rx_errors(&name),
          self.network_total_rx_packets(&name),
          self.network_total_tx_bytes(&name),
          self.network_total_tx_errors(&name),
          self.network_total_tx_packets(&name),
        );
        csv_data.push_str(&data);
        csv_data.push('\n');
      }
      csv_data
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Retrieves the hostname of the given computer on the network. Will return
  /// UNDETERMINED if it cannot be determined.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_network;
  ///
  /// let hostname = codemelted_network::host_name();
  /// assert!(hostname.len() > 0);
  /// ```
  pub fn host_name() -> String {
    match System::host_name() {
      Some(v) => v,
      None => String::from("UNDETERMINED"),
    }
  }

  /// Constructs a [CNetworkMonitor] to monitor the network interfaces to the
  /// host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_network;
  /// use codemelted::codemelted_network::CNetworkMonitor;
  ///
  /// let mut monitor = codemelted_network::monitor();
  /// monitor.refresh();
  /// let len = monitor.names().len();
  /// assert!(len >= 0);
  /// ```
  pub fn monitor() -> CNetworkMonitor {
    CNetworkMonitor::new()
  }

  /// Determines if the host operating system has access to the open Internet.
  ///
  /// ```
  /// use codemelted::codemelted_network;
  ///
  /// let online = codemelted_network::online(Some(1));
  /// assert!(online == true || online == false);
  /// ```
  pub fn online(timeout: Option<u64>) -> bool {
    online::check(timeout).is_ok()
  }
}

// ============================================================================
// [NPU Use Case] =============================================================
// ============================================================================

/// Implements the CodeMelted DEV NPU use case. NPU stands for Numerical
/// Processing Unit. This means this module will hold all mathematical
/// processing for this module. It is broken into two functions. The
/// [crate::codemelted_npu::compute] function is for longer processing
/// computations. The  [crate::codemelted_npu::math] function will provide
/// access to the  [crate::codemelted_npu::CMathFormula] enumerated formulas.
#[doc = mermaid!("models/codemelted_npu.mmd")]
pub mod codemelted_npu {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------

  use simple_mermaid::mermaid;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Collection of mathematical formulas that support the [math] function.
  /// Simply specify the formula, pass the parameters, and get the answer.
  pub enum CMathFormula {
    /// Distance in meters between two WGS84 points.
    GeodeticDistance,
    /// Heading in °N true North 0 - 359.
    GeodeticHeading,
    /// Speed in meters per second between two WGS84 points.
    GeodeticSpeed,
    /// `°F = (°C x 9/5) + 32`
    TemperatureCelsiusToFahrenheit,
    /// `°K = °C + 273.15`
    TemperatureCelsiusToKelvin,
    /// `°C = (°F − 32) × 5/9`
    TemperatureFahrenheitToCelsius,
    /// `°K = (°F − 32) × 5/9 + 273.15`
    TemperatureFahrenheitToKelvin,
    /// `°C = °K − 273.15`
    TemperatureKelvinToCelsius,
    /// `°F = (°K − 273.15) × 9/5 + 32`
    TemperatureKelvinToFahrenheit
  }

  /// Collection of constants and supporting functions to support executing the
  /// run function which houses the associated formula.
  impl CMathFormula {
    /// Holds the constant of PI for working with circles.
    const PI: f64 = std::f64::consts::PI;

    /// Implementation of a float based modulus function.
    fn fmod(a: f64, b: f64) -> f64 {
      // Handling negative values
      let mut answer: f64 = if a < 0.0 { -a  } else { a };
      let use_of_b: f64 = if b < 0.0 { -b } else { b };

      // Finding mod by repeated subtraction
      while answer >= use_of_b {
        answer -= b;
      }

      // Sign of result typically depends on sign of a.
      // Return answer
      if a < 0.0 {
        answer = -answer
      }

      answer
    }

    /// Helper method for calculating the geodetic distance between two points.
    fn geodetic_distance(start_latitude: f64, start_longitude: f64,
        end_latitude: f64, end_longitude: f64) -> f64 {
      // Convert degrees to radians
      let lat1 = start_latitude * CMathFormula::PI / 180.0;
      let lon1 = start_longitude * CMathFormula::PI / 180.0;

      let lat2 = end_latitude * CMathFormula::PI / 180.0;
      let lon2 = end_longitude * CMathFormula::PI / 180.0;

      // radius of earth in metres
      let r = 6378100.0;

      // P
      let rho1 = r * lat1.cos();
      let z1 = r * lat1.sin();
      let x1 = rho1 * lon1.cos();
      let y1 = rho1 * lon1.sin();

      // Q
      let rho2 = r * lat2.cos();
      let z2 = r * lat2.sin();
      let x2 = rho2 * lon2.cos();
      let y2 = rho2 * lon2.sin();

      // Dot product
      let dot = x1 * x2 + y1 * y2 + z1 * z2;
      let cos_theta = dot / (r * r);
      let theta = cos_theta.acos();

      // Distance in meters
      r * theta
    }

    /// Helper function for calculating the geodetic heading
    /// between two points.
    fn geodetic_heading(start_latitude: f64, start_longitude: f64,
        end_latitude: f64, end_longitude: f64) -> f64 {
      // Get the initial data from our variables:
      let lat1 = start_latitude * (CMathFormula::PI / 180.0);
      let lon1 = start_longitude * (CMathFormula::PI  / 180.0);
      let lat2 = end_latitude * (CMathFormula::PI  / 180.0);
      let lon2 = end_longitude * (CMathFormula::PI  / 180.0);

      // Set up our calculations
      let y = (lon2 - lon1).sin() * lat2.cos();
      let x = (lat1.cos() * lat2.sin()) -
        (lat1.sin() * lat2.cos() * (lon2 - lon1).cos());
      let rtnval = y.atan2(x) * (180.0 / CMathFormula::PI);
      CMathFormula::fmod(rtnval + 360.0, 360.0)
    }

    /// Helper function for calculating the geodetic speed between two points.
    fn geodetic_speed(start_milliseconds: f64, start_latitude: f64,
      start_longitude: f64, end_milliseconds: f64, end_latitude: f64,
      end_longitude: f64) -> f64 {
        let dist_meters = CMathFormula::geodetic_distance(
          start_latitude, start_longitude,
          end_latitude, end_longitude
        );
        let time_s = (end_milliseconds - start_milliseconds) / 1000.0;
        return dist_meters / time_s;
    }

    /// Function that is the brains for doing all the enumerated calculations.
    fn math(&self, args: &[f64]) -> f64 {
      use std::panic;
      let result = panic::catch_unwind(|| {
        match self {
          CMathFormula::GeodeticDistance => CMathFormula::geodetic_distance(
            args[0],
            args[1],
            args[2],
            args[3]
          ),
          CMathFormula::GeodeticHeading => CMathFormula::geodetic_heading(
            args[0],
            args[1],
            args[2],
            args[3]
          ),
          CMathFormula::GeodeticSpeed => CMathFormula::geodetic_speed(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5]
          ),
          CMathFormula::TemperatureCelsiusToFahrenheit =>
            (args[0] * 9.0 / 5.0) + 32.0,
          CMathFormula::TemperatureCelsiusToKelvin => args[0] + 273.15,
          CMathFormula::TemperatureFahrenheitToCelsius =>
            (args[0] - 32.0) * (5.0 / 9.0),
          CMathFormula::TemperatureFahrenheitToKelvin =>
            (args[0] - 32.0) * (5.0 / 9.0) + 273.15,
          CMathFormula::TemperatureKelvinToCelsius => args[0] - 273.15,
          CMathFormula::TemperatureKelvinToFahrenheit =>
            (args[0] - 273.15) * (9.0 / 5.0) + 32.0,
        }
      });

      Result::expect(
        result,
        "SyntaxError: args did not match the formula selected."
      )
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// <center><b><mark>FUTURE IMPLEMENTATION. DON'T CALL.</mark></b></center>
  pub fn compute() {
    unimplemented!("FUTURE IMPLEMENTATION!");
  }

  /// Function to execute the [CMathFormula] enumerated formula by specifying
  /// enumerated formula and the arguments for the calculated result.
  ///
  /// **Example:**
  /// ```rust
  /// use codemelted::codemelted_npu;
  /// use codemelted::codemelted_npu::CMathFormula;
  ///
  /// let fahrenheit = codemelted_npu::math(
  ///   CMathFormula::TemperatureCelsiusToFahrenheit,
  ///   &[0.0]
  /// );
  /// assert_eq!(fahrenheit, 32.0);
  /// ```
  ///
  /// The result will either be the calculated f64, std::f64::NAN if the
  /// formula encounters a bad mathematical condition (i.e. -1.0.sqrt()), or
  /// a panic if the wrong number of args are specified.
  ///
  /// - _NOTE: The args slice of f64 types go left to right in terms of the
  /// associated formula when passing the args._
  ///
  pub fn math(formula: CMathFormula, args: &[f64]) -> f64 {
    formula.math(args)
  }
}

// ============================================================================
// [Process Use Case] =========================================================
// ============================================================================

/// <center><b><mark>IN ACTIVE DEVELOPMENT</mark></b></center>
pub mod codemelted_process {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use std::{
    io::{Read, Write},
    process::{Child, Command, Stdio},
  };
  use crate::CProtocolHandler;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Represents a bi-directional process able to allow a Rust application to
  /// communicate with a hosted operating system process / command via STDIN /
  /// STDOUT / STDERR. This continues until the [CProcessProtocol::terminate]
  /// is called.
  pub struct CProcessProtocol {
    process: Child,
    is_running: bool,
  }
  impl CProcessProtocol {
    /// Creates a new [CProcessProtocol] object via the [spawn] call.
    fn new(command: &str, args: &str) -> CProcessProtocol {
      let cmd = format!("{} {}", command, args);
      let proc = if cfg!(target_os = "windows") {
        Command::new("cmd").args(["/c", &cmd])
          .stdin(Stdio::piped())
          .stdout(Stdio::piped())
          .stderr(Stdio::piped())
          .spawn()
      } else {
        Command::new("sh").args(["-c", &cmd])
          .stdin(Stdio::piped())
          .stdout(Stdio::piped())
          .stderr(Stdio::piped())
          .spawn()
      };

      let process = match proc {
        Ok(v) => v,
        Err(why) => panic!("Failed to create CProcessProtocol: {}", why),
      };

      CProcessProtocol { process, is_running: true }
    }

    /// Retrieves the id associated with the held process running.
    pub fn id(&self) -> u32 {
      self.process.id()
    }
  }

  /// Implements the [CProtocolHandler] for the [CProcessProtocol]. While the
  /// process wrapped by the protocol is in its own operating system process
  /// meaning it won't block your application processing, any call to
  /// [CProcessProtocol::get_message], [CProcessProtocol::get_error] and
  /// [CProcessProtocol::post_message] are synchronous calls. No thread is
  /// implemented as part of this [CProtocolHandler].
  impl CProtocolHandler<String> for CProcessProtocol {
    fn get_error(&mut self) -> Option<String> {
      let obj = self.process.stderr.as_mut().unwrap();
      let mut stderr_data = String::new();
      let stderr_result = obj.read_to_string(&mut stderr_data);
      match stderr_result {
        Ok(_) => Some(stderr_data),
        Err(_) => None,
      }
    }

    fn get_message(&mut self) -> Option<String> {
      let obj = self.process.stdout.as_mut().unwrap();
      let mut stdout_data = String::new();
      let stdout_result = obj.read_to_string(&mut stdout_data);
      match stdout_result {
        Ok(_) => Some(stdout_data),
        Err(_) => None,
      }
    }

    fn is_running(&self) -> bool {
      self.is_running
    }

    fn post_message(&self, data: String) {
      let mut obj = self.process.stdin.as_ref().unwrap();
      let result = obj.write_all(data.as_bytes());
      match result {
        Ok(()) => {
          let _ = obj.flush();
        },
        Err(why) => {
          panic!("CProcessProtocol failed to post message: {}", why);
        }
      }
    }

    fn terminate(&mut self) {
      self.is_running = false;
      let _ = self.process.kill();
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Determines if a given executable command exists on the host operating
  /// system. Indicated with a true / false return.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_process;
  ///
  /// let answer = codemelted_process::exists("deno");
  /// println!("{}", answer);
  /// ```
  /// _NOTE: System commands (like dir on windows) will return false. This is
  /// regular executables._
  pub fn exists(command: &str) -> bool {
    let mut proc = if cfg!(target_os = "windows") {
      Command::new("cmd")
        .args(["/c", "where", command])
        .spawn()
        .expect("Expected process to execute.")
    } else {
      Command::new("sh")
        .args(["-c", "which", command])
        .spawn()
        .expect("Expected process to execute.")
    };
    let rc = proc.wait().expect("Expected process to wait.");
    rc.success()
  }

  /// <center><b><mark>FUTURE DEVELOPMENT. DON'T CALL!</mark></b></center>
  pub fn list() {
    unimplemented!("FUTURE DEVELOPMENT")
  }

  /// <center><b><mark>FUTURE DEVELOPMENT. DON'T CALL!</mark></b></center>
  pub fn kill() {
    unimplemented!("FUTURE DEVELOPMENT");
  }

  /// Will execute a command with the host operating system and return its
  /// reported output. This is a blocking non-interactive call so no
  /// communicating with the process via STDIN.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_process;
  ///
  /// let output = if cfg!(target_os = "windows") {
  ///   codemelted_process::run("dir")
  /// } else {
  ///   codemelted_process::run("ls")
  /// };
  /// println!("{}", output);
  /// ```
  pub fn run(command: &str) -> String {
    let proc = if cfg!(target_os = "windows") {
      Command::new("cmd")
        .args(["/c", command])
        .output()
        .expect("Expected process to execute.")
    } else {
      Command::new("sh")
        .args(["-c", command])
        .output()
        .expect("Expected process to execute.")
    };
    String::from_utf8(proc.stdout).expect("Should vec<u8> to String")
  }

  /// <center><b><mark>FUTURE DEVELOPMENT. DON'T CALL!</mark></b></center>
  pub fn spawn(command: &str, args: &str) -> CProcessProtocol {
    CProcessProtocol::new(command, args)
  }
}

// ============================================================================
// [Storage Use Case] =========================================================
// ============================================================================

/// Implements the CodeMelted DEV Storage use case. This implements a
/// string key / value storage that is initialized into memory and stored as
/// file for later running of the application. This means you can set / get
/// values from this storage between app runs.
#[doc = mermaid!("models/codemelted_storage.mmd")]
pub mod codemelted_storage {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::{codemelted_disk::{self, CDiskType}, CObject};
  use simple_mermaid::mermaid;
  use std::ops::DerefMut;
  use std::sync::Mutex;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Mutex to hold the storage object for tracking items
  static STORAGE: Mutex<Option<CObject>> = Mutex::new(None);

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Responsible for saving the storage to a private file on disk anytime
  /// a change is made to the storage.
  fn save_storage(data: &str) {
    let home_path = codemelted_disk::home_path().to_string();
    let filename = format!("{}/{}",
      home_path,
      ".codemelted_storage"
    );
    if codemelted_disk::exists(&filename, CDiskType::File) {
      let _ = codemelted_disk::rm(&filename);
    }
    let result = codemelted_disk::write_file_as_string(
      &filename,
      &data,
      false
    );
    if result.is_err() {
      panic!("codemelted_storage: {}", result.err().unwrap());
    }
  }

  /// Provides access to the operating system environment settings. Simply
  /// specify the key and get the result. If the key is not found then None
  /// is returned.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  /// let answer = codemelted_storage::environment("PATH").unwrap();
  /// assert!(answer.len() > 0);
  /// ```
  pub fn environment(key: &str) -> Option<String> {
    match std::env::var(key) {
      Ok(val) => Some(val),
      Err(_) => None,
    }
  }

  /// Responsible for initializing the [crate::codemelted_storage] module.
  /// This must be called first before the module can be used or a panic will
  /// occur. It will read previous storage from disk and bring it into memory
  /// for later access.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  /// codemelted_storage::init();
  /// ```
  pub fn init() {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if storage_mutex.is_none() {
      let home_path = codemelted_disk::home_path();
      let filename = format!("{}/{}",
        home_path,
        ".codemelted_storage"
      );
      let data = codemelted_disk::read_file_as_string(&filename);
      let storage_obj = match data {
        Ok(v) => {
          if v.len() == 0 {
            CObject::new_object()
          } else {
            match crate::codemelted_json::parse(&v) {
              Some(v) => v,
              None => {
                panic!("SyntaxError: .codemelted_storage file is corrupt.")
              },
            }
          }
        },
        Err(_) => CObject::new_object(),
      };
      *storage_mutex = Some(storage_obj);
    }
  }

  /// Clears the currently held [crate::codemelted_storage] memory and disk.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  /// codemelted_storage::init();
  /// codemelted_storage::clear();
  /// assert!(codemelted_storage::length() == 0);
  /// ```
  pub fn clear() {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if let Some(storage_obj) = storage_mutex.deref_mut().as_mut() {
      storage_obj.clear();
      save_storage("");
    } else {
      panic!("SyntaxError: codemelted_storage::init() not yet called!");
    }
  }

  /// Gets a key from the [crate::codemelted_storage] or None if it don't exist.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  ///
  /// codemelted_storage::init();
  /// codemelted_storage::set("test", "test");
  /// let result = codemelted_storage::get("test");
  /// assert!(result.is_some());
  /// let result = codemelted_storage::get("test2");
  /// assert!(result.is_none());
  /// ```
  pub fn get(key: &str) -> Option<String> {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if let Some(storage_obj) = storage_mutex.deref_mut().as_mut() {
      match storage_obj.has_key(key) {
        true => {
          Some(storage_obj[key].to_string())
        },
        false => None
      }
    } else {
      panic!("SyntaxError: codemelted_storage::init() not yet called!");
    }
  }

  /// Retrieves the currently held key / value pairs by the
  /// [crate::codemelted_storage] module.
  pub fn length() -> usize {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if let Some(storage_obj) = storage_mutex.deref_mut().as_mut() {
      storage_obj.len()
    } else {
      panic!("SyntaxError: codemelted_storage::init() not yet called!");
    }
  }

  /// Removes a key / value in the [crate::codemelted_storage].
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  ///
  /// codemelted_storage::init();
  /// codemelted_storage::set("test", "test");
  /// let length1 = codemelted_storage::length();
  /// codemelted_storage::remove("test");
  /// let length2 = codemelted_storage::length();
  /// assert!(length2 < length1);
  /// ```
  pub fn remove(key: &str) {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if let Some(storage_obj) = storage_mutex.deref_mut().as_mut() {
      storage_obj.remove(key);
      let data = storage_obj.dump();
      save_storage(&data);
    } else {
      panic!("SyntaxError: codemelted_storage::init() not yet called!");
    }
  }

  /// Sets a key / value in the [crate::codemelted_storage].
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_storage;
  ///
  /// codemelted_storage::init();
  /// codemelted_storage::set("test", "test");
  /// assert!(codemelted_storage::length() != 0);
  /// ```
  pub fn set(key: &str, value: &str) {
    let mut storage_mutex = STORAGE.lock().unwrap();
    if let Some(storage_obj) = storage_mutex.deref_mut().as_mut() {
      let _ = storage_obj.insert(key, value);
      let data = storage_obj.dump();
      save_storage(&data);
    } else {
      panic!("SyntaxError: codemelted_storage::init() not yet called!");
    }
  }
}

// ============================================================================
// [UI Use Case] ==============================================================
// ============================================================================

/// <center><b><mark>FUTURE IMPLEMENTATION. DOES NOTHING</mark></b></center>
pub mod codemelted_ui {
  // FUTURE IMPLEMENTATION
}

// ============================================================================
// [UNIT TEST DEFINITIONS] ====================================================
// ============================================================================

#[cfg(test)]
mod tests {
  // use super::*;

  #[test]
  fn test_is_nan() {
    assert_eq!(true, f64::is_nan((-1.0 as f64).sqrt()));
  }
}
