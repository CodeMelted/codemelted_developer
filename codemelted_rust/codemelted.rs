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
  /// Identifies the protocol for debugging / reporting purposes.
  fn id(&mut self) -> String;
  /// Used to check if any errors occurred with a given protocol. If None is
  /// returned, no errors were detected.
  fn error(&mut self) -> Option<String>;
  /// Retrieves any currently processed messages. Also provide support for
  /// string commands to further support the given protocol you build.
  fn get_message(&mut self, request: Option<&str>) -> T;
  /// Signals if the protocol is running or not.
  fn is_running(&self) -> bool;
  /// Handles the sending of the message to the protocol for processing.
  fn post_message(&mut self, data: T);
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
  pub type CWorkerCB<T> = fn(T) -> T;

  /// The result of a [worker] call. This holds a dedicated thread that is
  /// waiting for data via the [CWorkerProtocol::post_message]. This will
  /// queue of data for processing and the internal thread will process that
  /// data in accordance with the [CWorkerCB]. Any processed data is available
  /// via the [CProtocolHandler] bound trait functions.
  pub struct CWorkerProtocol<T> {
    id: String,
    handle: JoinHandle<()>,
    protocol_tx: Option<Sender<T>>,
    protocol_rx: Receiver<T>,
  }
  impl<T: std::marker::Send + 'static> CWorkerProtocol<T> {
    /// Constructs the new [CWorkerProtocol] implementing bi-directional
    /// communication with the background thread.
    fn new(id: &str, task: CWorkerCB<T>) -> CWorkerProtocol<T> {
      let (protocol_tx, thread_rx) = channel::<T>();
      let (thread_tx, protocol_rx) = channel::<T>();

      // Setup our thread and kick it off.
      let handle = thread::spawn(move || {
        loop {
          // Block until we get data via post_message.
          match thread_rx.recv() {
            Ok(v) => {
              let result = task(v);
              let _ = thread_tx.send(result);
            },
            // The channel was disconnected via terminate.
            // Break thread loop.
            Err(_) => break,
          }
        }
      });

      // Return the worker protocol.
      CWorkerProtocol::<T> {
        id: id.to_string(),
        handle,
        protocol_tx: Some(protocol_tx),
        protocol_rx,
      }
    }
  }

  impl<T> CProtocolHandler<Option<T>> for CWorkerProtocol<Option<T>> {
    fn id(&mut self) -> String {
      self.id.to_string()
    }

    /// Will always return None. The only Errors one can encounter is
    /// programmatic errors or improper calling other functions after
    /// thread shutdown which results in a panic.
    fn error(&mut self) -> Option<String> {
      None
    }

    fn get_message(&mut self, _request: Option<&str>) -> Option<T> {
      match self.protocol_rx.try_recv() {
        Ok(v) => v,
        Err(_) => None,
      }
    }

    fn is_running(&self) -> bool {
      !self.handle.is_finished()
    }

    fn post_message(&mut self, data: Option<T>) {
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
  /// codemelted_async::sleep(500);
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
  ///   500
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
  /// fn worker_cb(_data: Option<CObject>) -> Option<CObject> {
  ///   // DO SOMETHING IN THE BACKGROUND
  ///   Some(CObject::new_object())
  /// }
  ///
  /// let mut worker = codemelted_async::worker::<Option<CObject>>(
  ///   "test_worker",
  ///   worker_cb,
  /// );
  ///
  /// assert!(worker.is_running());
  /// worker.post_message(Some(CObject::new_object()));
  /// codemelted_async::sleep(100);
  ///
  /// let data = worker.get_message(None);
  /// assert!(data.is_some());
  ///
  /// let data = worker.get_message(None);
  /// assert!(data.is_none());
  ///
  /// worker.terminate();
  /// assert!(!worker.is_running());
  /// ```
  pub fn worker<T: std::marker::Send + 'static>(
    id: &str,
    task: CWorkerCB<T>,
  ) -> CWorkerProtocol<T> {
    CWorkerProtocol::new(id, task)
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

/// Implements the CodeMelted DEV DB use case. This module provides the
/// ability to create / manage a database via the
/// [crate::codemelted_db::manage] function. From here utilization of the
/// [crate::codemelted_db::exists] function ensures the database file exists
/// before utilizing the [crate::codemelted_db::query] and
/// [crate::codemelted_db::update] functions.
///
/// _NOTE: Any failure with the database results in a panic as this would be
/// do to missing database file, SQL syntax error, or a permissions issue._
#[doc = mermaid!("models/codemelted_db.mmd")]
pub mod codemelted_db {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::codemelted_disk::{self, CDiskType};
  use rusqlite::{Connection, Result, Row};
  use simple_mermaid::mermaid;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  // NONE

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Ensures a database exists as any of the [query] and [update] functions
  /// will panic if the specified database does not exist. So this will aid
  /// in ensuring expected configurations.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_db;
  /// use codemelted::codemelted_disk;
  ///
  /// let db_file = format!("{}/test.db", codemelted_disk::temp_path());
  /// assert!(!codemelted_db::exists(&db_file, false));
  /// ```
  pub fn exists(db_path: &str, should_panic: bool) -> bool {
    match codemelted_disk::exists(db_path, CDiskType::File) {
      true => true,
      false => {
        if should_panic {
          panic!("SyntaxError: {} database does not exist!", db_path);
        }
        false
      },
    }
  }

  /// Manages the sqlite3 database on disk by creating the initial database
  /// if it does not already exist along with execute Data Definition Language
  /// SQL statements to manage the database.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_db;
  /// use codemelted::codemelted_disk;
  ///
  /// let db_file = format!("{}/test.db", codemelted_disk::temp_path());
  /// assert!(!codemelted_db::exists(&db_file, false));
  /// codemelted_db::manage(&db_file, true, None);
  /// assert!(codemelted_db::exists(&db_file, false));
  /// let _ = codemelted_disk::rm(&db_file);
  /// ```
  pub fn manage(db_path: &str, create_db: bool, sql: Option<&str>) {
    // If not creating the database on connection, check to make sure
    // it is where we expect.
    if !create_db {
      exists(db_path, true);
    }

    // Alrighty, time to go carry out the DDL statement and panic if
    // something about it fails.
    match Connection::open(db_path) {
      Ok(conn) => {
        match sql {
          // Welp, we were asked to perform the DDL statement. Go do it
          // and see what happens.
          Some(stmt) => {
            match conn.execute(stmt, ()) {
              Ok(_) => {},
              Err(why) => panic!("SyntaxError: codemelted_db {}", why),
            }
          },
          // The sql was None so it may have been to just create the
          // database.
          None => {},
        }
      },
      Err(why) => panic!("SyntaxError: codemelted_db {}", why),
    };
  }

  /// Will query a table specified by the db_path to retrieve the data
  /// as a vector of the given type. This represents the Data Query
  /// Language (DQL) SELECT statement.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_db;
  /// use codemelted::codemelted_disk;
  ///
  /// // Create the database file and table.
  /// let db_file = format!("{}/test.db", codemelted_disk::temp_path());
  /// assert!(!codemelted_db::exists(&db_file, false));
  /// let sql = "CREATE TABLE person (
  ///   id    INTEGER PRIMARY KEY,
  ///   name  TEXT NOT NULL,
  ///   data  BLOB
  /// )";
  /// codemelted_db::manage(&db_file, true, Some(sql));
  /// assert!(codemelted_db::exists(&db_file, false));
  ///
  /// // Go add a person to the database.
  /// #[derive(Debug)]
  /// struct Person {
  ///   id: i32,
  ///   name: String,
  ///   data: Option<Vec<u8>>,
  /// }
  ///
  /// let sql = "INSERT INTO person (name, data) VALUES (?1, ?2)";
  /// let me = Person {
  ///    id: 0,
  ///    name: "Steven".to_string(),
  ///    data: None,
  /// };
  /// let rows = codemelted_db::update(
  ///   &db_file,
  ///   sql,
  ///   (&me.name, &me.data)
  /// );
  /// assert!(rows == 1);
  ///
  /// // Now lets query the data back
  /// let sql = "SELECT id, name, data FROM person";
  /// let row_data = codemelted_db::query(
  ///   &db_file,
  ///   sql,
  ///   [],
  ///   |row| {
  ///     Ok(Person {
  ///       id: row.get(0)?,
  ///       name: row.get(1)?,
  ///       data: row.get(2)?,
  ///     })
  ///   }
  /// );
  /// assert!(row_data.len() == 1);
  /// let _ = codemelted_disk::rm(&db_file);
  /// ```
  pub fn query<
      P: rusqlite::Params,
      T,
      F: FnMut(&Row<'_>) -> Result<T>>(
        db_path: &str,
        sql: &str,
        params: P,
        f: F
  ) -> Vec<T> {
    // Ensure database exists and we can connect to it.
    exists(db_path, true);
    match Connection::open(db_path) {
      Ok(conn) => {
        // Prepare the SQL statement and binding parameters.
        match conn.prepare(sql) {
          Ok(mut stmt) => {
            // Execute the query based on the params and function binding.
            match stmt.query_map(params, f) {
              Ok(rows) => {
                // Capture the results into from the query to return
                // to the caller.
                let mut results = Vec::<T>::new();
                for row in rows {
                  match row {
                    Ok(v) => results.push(v),
                    // Something happened with the bindings
                    Err(why) => panic!(
                      "SyntaxError: codemelted_db {}",
                      why
                    ),
                  }
                }
                results
              },
              // Unable to do the query.
              Err(why) => panic!("SyntaxError: codemelted_db {}", why),
            }
          },
          // Unable to prepare the SQL
          Err(why) => panic!("SyntaxError: codemelted_db {}", why),
        }
      },
      // Failed to make the database connection.
      Err(why) => panic!("{}", why),
    }
  }

  /// Provides the ability Data Manipulation Language (DML) statements
  /// (i.e. INSERT, DELETE, or UPDATE) with the number of rows updated
  /// based on the transaction.
  ///
  /// **Example:*
  /// ```no_run
  /// use codemelted::codemelted_db;
  /// use codemelted::codemelted_disk;
  ///
  /// // Create the database file and table.
  /// let db_file = format!("{}/test.db", codemelted_disk::temp_path());
  /// assert!(!codemelted_db::exists(&db_file, false));
  /// let sql = "CREATE TABLE person (
  ///   id    INTEGER PRIMARY KEY,
  ///   name  TEXT NOT NULL,
  ///   data  BLOB
  /// )";
  /// codemelted_db::manage(&db_file, true, Some(sql));
  /// assert!(codemelted_db::exists(&db_file, false));
  ///
  /// // Go add a person to the database.
  /// #[derive(Debug)]
  /// struct Person {
  ///   id: i32,
  ///   name: String,
  ///   data: Option<Vec<u8>>,
  /// }
  ///
  /// let sql = "INSERT INTO person (name, data) VALUES (?1, ?2)";
  /// let me = Person {
  ///    id: 0,
  ///    name: "Steven".to_string(),
  ///    data: None,
  /// };
  /// let rows = codemelted_db::update(
  ///   &db_file,
  ///   sql,
  ///   (&me.name, &me.data)
  /// );
  /// assert!(rows == 1);
  ///
  /// // Now lets query the data back
  /// let sql = "SELECT id, name, data FROM person";
  /// let row_data = codemelted_db::query(
  ///   &db_file,
  ///   sql,
  ///   [],
  ///   |row| {
  ///     Ok(Person {
  ///       id: row.get(0)?,
  ///       name: row.get(1)?,
  ///       data: row.get(2)?,
  ///     })
  ///   }
  /// );
  /// assert!(row_data.len() == 1);
  /// let _ = codemelted_disk::rm(&db_file);
  /// ```
  pub fn update<P: rusqlite::Params>(
    db_path: &str,
    sql: &str,
    params: P
  ) -> usize {
    // Ensure database exists and connect to it.
    exists(db_path, true);
    match Connection::open(db_path) {
      Ok(conn) => {
        // Prepare the SQL statement for execution.
        match conn.prepare(sql) {
          Ok(mut stmt) => {
            // Execute the prepared SQL statement and return the #
            // of rows updated
            match stmt.execute(params) {
              Ok(v) => v,
              // Failed binding of parameters to prepared statement
              Err(why) => panic!("SyntaxError: codemelted_db {}", why),
            }
          },
          // Failed to prepare the SQL statement
          Err(why) => panic!("SyntaxError: codemelted_db {}", why),
        }
      },
      // Failed to Connect
      Err(why) => panic!("SyntaxError: codemelted_db {}", why),
    }
  }

  /// Determines the setup version of sqlite supported by the module
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_db;
  ///
  /// assert!(codemelted_db::version().len() > 0);
  /// ```
  pub fn version() -> String {
    rusqlite::version().to_string()
  }
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

/// Implements the CodeMelted DEV HW use case. Provides the ability to scan
/// for [crate::codemelted_hw::available_bluetooth_devices] and
/// [crate::codemelted_hw::available_serial_ports]. Once determined the
/// developer can [crate::codemelted_hw::open_bluetooth_device] or
/// [crate::codemelted_hw::open_serial_port] to interact with the hardware
/// attached to the host operating system. This module also provides the
/// ability to [crate::codemelted_hw::monitor] via the created
/// [crate::codemelted_hw::CComponentMonitor] struct. This will report
/// hardware component temperatures and failure points. Finally the user can
/// query hardware aspects about the computer to include
/// [crate::codemelted_hw::kernel_version] / [crate::codemelted_hw::os_name]
/// [crate::codemelted_hw::os_version] / [crate::codemelted_hw::user].
#[doc = mermaid!("models/codemelted_hw.mmd")]
pub mod codemelted_hw {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------

  use std::time::Duration;
  use crate::{
    codemelted_async,
    codemelted_storage,
    CCsvFormat,
    CProtocolHandler
  };
  use btleplug::api::{
    Central,
    Manager as _,
    Peripheral as _,
    ScanFilter,
  };
  use btleplug::platform::{Manager, Peripheral};
  use serialport::{
    ClearBuffer,
    DataBits,
    FlowControl,
    Parity,
    SerialPort,
    SerialPortInfo,
    StopBits
  };
  use simple_mermaid::mermaid;
  use sysinfo::{Components, System};
  use tokio::runtime::Runtime;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Result of the [available_bluetooth_devices] call identified devices one
  /// can open to exchange data via the [open_bluetooth_device] call.
  pub struct CBluetoothInfo {
    peripheral: Peripheral,
  }
  impl CBluetoothInfo {
    /// Helper function to facilitate creating this object.
    fn new(peripheral: Peripheral) -> CBluetoothInfo {
      CBluetoothInfo { peripheral }
    }

    /// Identifies the MAC address of the device.
    pub fn address(&self) -> String {
      self.peripheral.address().to_string()
    }

    /// Identifies the id of the device.
    pub fn id(&self) -> String {
      self.peripheral.id().to_string()
    }
  }

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

  /// Provides the [CSerialPortProtocol] ability to both
  /// [CSerialPortProtocol::post_message] utilizing the [CSerialPortData]
  /// as the data wrapper and as the [CSerialPortProtocol::get_message]
  /// request via the [CSerialPortData::get_message_request] function to
  /// query the port for data.
  #[derive(Debug)]
  pub enum CSerialPortData {
    /// Signals an error was detected with the [CSerialPortProtocol] request
    /// and the [CSerialPortProtocol::error] will hold what was wrong.
    ErrorDetected,
    /// Configurable [CSerialPortProtocol] item.
    BaudRate(Option<u32>),
    /// Configurable [CSerialPortProtocol] item.
    DataBits(Option<DataBits>),
    /// Configurable [CSerialPortProtocol] item.
    FlowControl(Option<FlowControl>),
    /// Configurable [CSerialPortProtocol] item.
    Parity(Option<Parity>),
    /// Configurable [CSerialPortProtocol] item.
    StopBits(Option<StopBits>),
    /// Configurable [CSerialPortProtocol] item.
    Timeout(Option<Duration>),
    /// Line control status of the [CSerialPortProtocol].
    Break(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    ClearBuffer(Option<ClearBuffer>),
    /// Line control status of the [CSerialPortProtocol].
    CarrierDetect(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    ClearToSend(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    DataSetReady(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    DataTerminalReady(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    RequestToSend(Option<bool>),
    /// Line control status of the [CSerialPortProtocol].
    RingIndicator(Option<bool>),
    /// Reads a buffer from a [CSerialPortProtocol].
    ReadData(Option<Vec<u8>>),
    /// Writes a buffer from a [CSerialPortProtocol].
    WriteData(Option<Vec<u8>>)
  }
  /// Specialization of the [CSerialPortData] to support the two way nature
  /// of this enumeration as both a request / data write object.
  impl CSerialPortData {
    /// Extracts the held Option bool values by those enum types.
    /// Returns None otherwise.
    pub fn as_bool(&self) -> Option<bool> {
      match self {
        CSerialPortData::Break(v) => *v,
        CSerialPortData::CarrierDetect(v) => *v,
        CSerialPortData::ClearToSend(v) => *v,
        CSerialPortData::DataSetReady(v) => *v,
        CSerialPortData::DataTerminalReady(v) => *v,
        CSerialPortData::RequestToSend(v) => *v,
        CSerialPortData::RingIndicator(v) => *v,
        _ => None
      }
    }

    /// Extracts the held Option Vec u8 values by those enum types.
    /// Returns None otherwise.
    pub fn as_bytes(&self) -> Option<Vec<u8>> {
      match self {
        CSerialPortData::ReadData(items) => items.clone(),
        CSerialPortData::WriteData(items) => items.clone(),
        _ => None,
      }
    }

    /// Extracts the held Option DataBits values by those enum types.
    /// Returns None otherwise.
    pub fn as_data_bits(&self) -> Option<DataBits> {
      match self {
        CSerialPortData::DataBits(data_bits) => *data_bits,
        _ => None,
      }
    }

    /// Extracts the held Option FlowControl values by those enum types.
    /// Returns None otherwise.
    pub fn as_flow_control(&self) -> Option<FlowControl> {
      match self {
        CSerialPortData::FlowControl(flow_control) => *flow_control,
        _ => None,
      }
    }

    /// Extracts the held Option Parity values by those enum types.
    /// Returns None otherwise.
    pub fn as_parity(&self) -> Option<Parity> {
      match self {
        CSerialPortData::Parity(parity) => *parity,
        _ => None,
      }
    }

    /// Extracts the held Option StopBits values by those enum types.
    /// Returns None otherwise.
    pub fn as_stop_bits(&self) -> Option<StopBits> {
      match self {
        CSerialPortData::StopBits(stop_bits) => *stop_bits,
        _ => None,
      }
    }

    /// Extracts the held Option Duration values by those enum types.
    /// Returns None otherwise.
    pub fn as_timeout(&self) -> Option<Duration> {
      match self {
        CSerialPortData::Timeout(v) => *v,
        _ => None,
      }
    }

    /// Extracts the held Option u8 by those enum types.
    /// Returns None otherwise.
    pub fn as_u32(&self) -> Option<u32> {
      match self {
        CSerialPortData::BaudRate(v) => *v,
        _ => None,
      }
    }

    /// Provides the string representation to support the
    /// [CSerialPortProtocol::get_message] request string to get specific
    /// types of data from an open port.
    pub fn get_message_request(&self) -> Option<&str> {
      match self {
        CSerialPortData::BaudRate(_) => Some("baud_rate"),
        CSerialPortData::DataBits(_) => Some("data_bits"),
        CSerialPortData::FlowControl(_) => Some("flow_control"),
        CSerialPortData::Parity(_) => Some("parity"),
        CSerialPortData::StopBits(_) => Some("stop_bits"),
        CSerialPortData::Timeout(_) => Some("duration"),
        CSerialPortData::CarrierDetect(_) => Some("carrier_detect"),
        CSerialPortData::ClearToSend(_) => Some("clear_to_send"),
        CSerialPortData::DataSetReady(_) => Some("data_set_ready"),
        CSerialPortData::RingIndicator(_) => Some("ring_indicator"),
        CSerialPortData::ReadData(_) => Some("read_data"),
        _ => None,
      }
    }
  }

  /// Created via the [open_serial_port] function of the module. This
  /// implements [CProtocolHandler] to support a bi-directional communication
  /// with an attached device via a serial port.
  pub struct CSerialPortProtocol {
    /// Holds the wrapped [SerialPort] of the module until closed.
    port: Option<Box<dyn SerialPort>>,
    /// Holds the latest error message encountered.
    error: Option<String>
  }

  /// Implements a series of helper functions for the [CSerialPortProtocol].
  impl CSerialPortProtocol {
    /// Opens a [CSerialPortProtocol] with a default baud rate of 9600. A failure
    /// will result in a panic.
    fn new(port_info: &SerialPortInfo) -> CSerialPortProtocol {
      let port = serialport::new(
        port_info.port_name.to_string(),
        9600
      ).open().expect("CSerialPortProtocol: Failed to open!");
      CSerialPortProtocol { port: Some(port), error: None }
    }

    /// Helper function to unwrap the port for access of the
    /// [CProtocolHandler] implemented functions. Will panic once
    /// the protocol is terminated.
    fn port_ref(&mut self) -> &mut Box<dyn SerialPort + 'static> {
      self.port.as_mut().unwrap()
    }
  }
  /// The [CSerialPortProtocol] implementation of the [CProtocolHandler] utilizing
  /// the [CSerialPortData] enumeration as the bi-directional read / write
  /// method of the protocol definition rules.
  impl CProtocolHandler<CSerialPortData> for CSerialPortProtocol {
    fn id(&mut self) -> String {
      match self.port_ref().name() {
        Some(v) => v,
        None => String::from(""),
      }
    }

    /// Will hold the last error encountered via the
    /// [CSerialPortProtocol::get_message] or
    /// [CSerialPortProtocol::post_message]. Returns None if no error has
    /// occurred.
    fn error(&mut self) -> Option<String> {
      if self.error.is_none() {
        return None;
      }
      let rtnval = self.error.clone();
      self.error = None;
      rtnval
    }

    /// Will query the [CSerialPortProtocol] for the latest status / data associated
    /// via the request. Utilize the [CSerialPortData::get_message_request] to
    /// utilize the proper string. The [CSerialPortData] will either hold the
    /// particular result or [CSerialPortData::ErrorDetected] if an error
    /// occurred.
    ///
    /// Will panic if an invalid request is received.
    fn get_message(&mut self, request: Option<&str>) -> CSerialPortData {
      if request.unwrap() == "baud_rate" {
        match self.port_ref().baud_rate() {
          Ok(v) => CSerialPortData::BaudRate(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "data_bits" {
        match self.port_ref().baud_rate() {
          Ok(v) => CSerialPortData::BaudRate(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "flow_control" {
        match self.port_ref().flow_control() {
          Ok(v) => CSerialPortData::FlowControl(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "parity" {
        match self.port_ref().parity() {
          Ok(v) => CSerialPortData::Parity(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "stop_bits" {
        match self.port_ref().stop_bits() {
          Ok(v) => CSerialPortData::StopBits(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "timeout" {
        CSerialPortData::Timeout(Some(self.port_ref().timeout()))
      } else if request.unwrap() == "carrier_detect" {
        match self.port_ref().read_carrier_detect() {
          Ok(v) => CSerialPortData::CarrierDetect(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "clear_to_send" {
        match self.port_ref().read_clear_to_send() {
          Ok(v) => CSerialPortData::ClearToSend(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "data_set_ready" {
        match self.port_ref().read_data_set_ready() {
          Ok(v) => CSerialPortData::DataSetReady(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "ring_indicator" {
        match self.port_ref().read_ring_indicator() {
          Ok(v) => CSerialPortData::RingIndicator(Some(v)),
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else if request.unwrap() == "read_data" {
        match self.port_ref().bytes_to_read() {
          Ok(buffer_size) => {
            let mut buffer = vec![0; buffer_size as usize];
            match self.port_ref().read_exact(&mut buffer) {
              Ok(_) => CSerialPortData::ReadData(Some(buffer)),
              Err(why) => {
                self.error = Some(why.to_string());
                CSerialPortData::ErrorDetected
              },
            }
          },
          Err(why) => {
            self.error = Some(why.to_string());
            CSerialPortData::ErrorDetected
          },
        }
      } else {
        panic!(
          "CSerialPortProtocol::get_message() received an invalid request!"
        );
      }
    }

    /// Signals the [CSerialPortProtocol::terminate] has not been called.
    fn is_running(&self) -> bool {
      self.port.is_some()
    }

    /// Will write the [CSerialPortData] to the open serial port. Check with
    /// the [CSerialPortProtocol::error()] for success / failure of transaction. Will
    /// panic if a [CSerialPortData] not writable is specified or the port has
    /// been terminated.
    fn post_message(&mut self, data: CSerialPortData) {
      // Go carry out the post_message request.
      let result = match data {
        CSerialPortData::BaudRate(v) => {
          self.port_ref().set_baud_rate(v.unwrap())
        },
        CSerialPortData::DataBits(data_bits) => {
          self.port_ref().set_data_bits(data_bits.unwrap())
        },
        CSerialPortData::FlowControl(flow_control) => {
          self.port_ref().set_flow_control(flow_control.unwrap())
        },
        CSerialPortData::Parity(parity) => {
          self.port_ref().set_parity(parity.unwrap())
        },
        CSerialPortData::StopBits(stop_bits) => {
          self.port_ref().set_stop_bits(stop_bits.unwrap())
        },
        CSerialPortData::Timeout(duration) => {
          self.port_ref().set_timeout(duration.unwrap())
        },
        CSerialPortData::DataTerminalReady(v) => {
          self.port_ref().write_data_terminal_ready(v.unwrap())
        },
        CSerialPortData::RequestToSend(v) => {
          self.port_ref().write_request_to_send(v.unwrap())
        },
        CSerialPortData::WriteData(data) => {
          match self.port_ref().write_all(&data.unwrap()) {
            Ok(_) => {
              match self.port_ref().flush() {
                Ok(_) => Ok(()),
                Err(why) => {
                  Err(serialport::Error::new(
                    serialport::ErrorKind::Io(why.kind()),
                    why.to_string())
                  )
                }
              }
            },
            Err(why) => {
              Err(serialport::Error::new(
                serialport::ErrorKind::Io(why.kind()),
                why.to_string())
              )
            }
          }
        },
        CSerialPortData::Break(v) =>{
          if v.unwrap() {
            self.port_ref().set_break()
          } else {
            self.port_ref().clear_break()
          }
        },
        CSerialPortData::ClearBuffer(v) => {
          self.port_ref().clear(v.unwrap())
        },
        // All other enumerations do no support post_message
        _ => {
          panic!(
            "CSerialPortProtocol::post_message(): received invalid data!"
          );
        }
      };

      // If we have an error, signal it.
      if result.is_err() {
        let err = result.err().unwrap();
        self.error = Some(err.to_string());
      }
    }

    /// Closes the port connection. All transaction with the
    /// [CSerialPortProtocol] object will panic after this is performed.
    fn terminate(&mut self) {
      self.port = None;
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Scans for available bluetooth devices in the area to allow for later
  /// connection via the [open_bluetooth_device] function.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_hw;
  ///
  /// println!("Now scanning for available bluetooth devices...");
  /// match codemelted_hw::available_bluetooth_devices(5000) {
  ///   Ok(devices) => {
  ///     println!("Found {} devices...", devices.len());
  ///     for device in devices {
  ///       println!("{} / {}", device.id(), device.address());
  ///     }
  ///   },
  ///   Err(why) => println!("Error Detected = {}", why),
  /// }
  /// ```
  pub fn available_bluetooth_devices(scan_time_milliseconds: u64)
      -> Result<Vec<CBluetoothInfo>, btleplug::Error> {
    // Create the runtime
    let rt = Runtime::new().unwrap();
    let devices: Result<Vec<CBluetoothInfo>, btleplug::Error> =
        rt.block_on(async {
      // Grab the operating system adapter to sus out bluetooth devices.
      let manager = Manager::new().await?;
      let adapters = manager.adapters().await?;
      let mut devices = Vec::<CBluetoothInfo>::new();
      let central = adapters.into_iter().nth(0);
      if central.is_none() {
        return Ok(devices);
      }

      // Start scan for the devices and add them to our list.
      let adapter = central.unwrap();
      adapter.start_scan(ScanFilter::default()).await?;

      // Give some time for the scan to find devices.
      codemelted_async::sleep(scan_time_milliseconds);
      let peripherals = adapter.peripherals().await?;
      for p in peripherals {
        devices.push(CBluetoothInfo::new(p));
      }
      adapter.stop_scan().await?;
      Ok(devices)
    });
    devices
  }

  /// Scans for available serial ports returning a Vector of [SerialPortInfo]
  /// objects that can be utilized with [open_serial_port] function for a
  /// selected port.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_hw;
  ///
  /// match codemelted_hw::available_serial_ports() {
  ///   Ok(v) => {
  ///     println!("Available Ports = {}", v.len());
  ///     for el in v {
  ///       println!("{} / {:?}", el.port_name, el.port_type);
  ///     }
  ///   },
  ///   Err(why) => println!("{:?}", why),
  /// }
  /// ```
  pub fn available_serial_ports() -> Result<
      Vec<SerialPortInfo>, serialport::Error> {
    serialport::available_ports()
  }

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

  /// <center><b><mark>FUTURE IMPLEMENTATION. DON'T USE</mark></b></center>
  pub fn open_bluetooth_device() {
    unimplemented!("FUTURE IMPLEMENTATION!");
  }

  /// Takes a [SerialPortInfo] object to create a [CSerialPortProtocol] to
  /// interact with a device attached to the host operating system.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::CProtocolHandler;
  /// use codemelted::codemelted_async;
  /// use codemelted::codemelted_hw;
  /// use codemelted::codemelted_hw::{CSerialPortData};
  ///
  /// // Open and configure the port
  /// let port_info = &codemelted_hw::available_serial_ports().unwrap()[0];
  /// let mut port = codemelted_hw::open_serial_port(port_info);
  /// port.post_message(CSerialPortData::BaudRate(Some(115200)));
  /// port.post_message(CSerialPortData::DataTerminalReady(Some(true)));
  /// port.post_message(CSerialPortData::RequestToSend(Some(true)));
  /// port.post_message(CSerialPortData::DataBits(Some(serialport::DataBits::Eight)));
  /// port.post_message(CSerialPortData::StopBits(Some(serialport::StopBits::One)));
  /// port.post_message(CSerialPortData::Parity(Some(serialport::Parity::None)));
  ///
  /// // Get the name of the port and process the data.
  /// let name = port.id();
  /// println!("{} is {}", name, port.is_running());
  ///
  /// // Read and print buffer until <ctrl>+c is hit.
  /// loop {
  ///   let buffer = port.get_message(
  ///     CSerialPortData::ReadData(None).get_message_request()
  ///   ).as_bytes().unwrap();
  ///   println!("buffer len = {}", buffer.len());
  ///   let data = String::from_utf8(buffer);
  ///   if data.is_ok() {
  ///     println!("{}", data.unwrap());
  ///   }
  ///   codemelted_async::sleep(1000);
  /// }
  /// ```
  pub fn open_serial_port(
    port_info: &SerialPortInfo
  ) -> CSerialPortProtocol {
    CSerialPortProtocol::new(port_info)
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

/// Implements the CodeMelted DEV Network use case. Provides the ability to
/// [crate::codemelted_network::monitor] a network stack of the host operating
/// system via the [crate::codemelted_network::CNetworkMonitor] struct, query
/// aspects about the network whether [crate::codemelted_network::online] or
/// the [crate::codemelted_network::host_name] of the network stack. Finally
/// provides the either [crate::codemelted_network::fetch] data from a
/// server REST API or to [crate::codemelted_network::serve] a REST API as a
/// server along with supporting the
/// [crate::codemelted_network::upgrade_web_socket] creating a bi-directional
/// [crate::codemelted_network::CWebSocketProtocol] struct serving as a
/// bi-directional websocket server. Finally this module will also support
/// the [crate::codemelted_network::web_rtc] to facilitate peer-connections
/// between clients as an orchestration server to facilitate the protocol
/// between clients.
#[doc = mermaid!("models/codemelted_network.mmd")]
pub mod codemelted_network {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::{codemelted_json, CCsvFormat, CObject, CProtocolHandler};
  use reqwest::{Client, RequestBuilder};
  use rouille::{
    start_server,
    websocket::{
      self, Message, SendError, WebsocketError
    },
    Request,
  };
  use simple_mermaid::mermaid;
  use std::collections::HashMap;
  use sysinfo::{Networks, System};
  use tokio::runtime::Runtime;

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Supports the [CFetchRequest::new] object construction in order to set
  /// the appropriate action to take with the URL specified.
  pub enum CFetchAction {
    /// Performs a DELETE (as stated 🙂)request to a backend REST API.
    Delete,
    /// Performs a GET (query) request to a backend REST API.
    Get,
    /// Performs a POST (update) request to a backend REST API.
    Post,
    /// Performs a PUT (add) request to a backend REST API.
    Put,
  }

  /// Object utilized with the [fetch] function to configure the request to be
  /// made to a backend server REST API.
  pub struct CFetchRequest {
    /// Wrapped request builder to support our object API.
    client: RequestBuilder
  }
  impl CFetchRequest {
    /// Creates a new [CFetchRequest] object for the [fetch] function
    /// specifying the [CFetchAction] along with the URL endpoint of the
    /// REST API.
    pub fn new(action: CFetchAction, url: &str) -> CFetchRequest {
      let client = match action {
        CFetchAction::Delete => Client::new().delete(url),
        CFetchAction::Get => Client::new().get(url),
        CFetchAction::Post => Client::new().post(url),
        CFetchAction::Put => Client::new().put(url),
      };
      CFetchRequest { client }
    }

    /// Sets the basic auth for the request.
    pub fn basic_auth(self, username: &str, password: Option<&str>) {
      let _ = self.client.basic_auth(username, password);
    }

    /// Sets a bearer token for the request.
    pub fn bearer_auth(self, token: &str) {
      let _ = self.client.bearer_auth(token);
    }

    /// Sets the JSON body of the request.
    pub fn body(self, data: CObject) {
      let serialized = match codemelted_json::as_string(&data) {
        Some(v) => v,
        None => panic!("CFetchRequest::body(): data was not valid CObject!"),
      };
      let _ = self.client.body(serialized);
    }

    /// Sets the form body of the request.
    pub fn form(self, params: HashMap::<String, String>) {
      let _ = self.client.form(&params);
    }

    /// Sets a header parameter for the request. Call this multiple times
    /// to set multiple values.
    pub fn header(self, key: &str, value: &str) {
      let _ = self.client.header(key, value);
    }

    /// Handles the async call of the request to get the server
    /// [CFetchResponse] with the results of the call.
    async fn send(self) -> CFetchResponse {
      // Await for the response send to the API
      match self.client.send().await {
        // It says it is ok. Double check the status code.
        Ok(resp) => {
          // Make sure we are in the 200 range of HTTP status codes.
          let status = resp.status().as_u16();
          if status >= 200 || status <= 299 {
            // We are, go get the content type to determine what data was
            // received.
            println!("We got a {}", status);
            println!("Headers are {:?}", resp.headers());
            let content_type = match resp.headers().get("Content-Type") {
              Some(v) =>  {
                match v.to_str() {
                  Ok(v) => v.to_string(),
                  Err(_) => String::from(""),
                }
              },
              None => String::from(""),
            };

            // Was the data a byte array or blob?
            if content_type.to_lowercase().contains("application/octet-stream") ||
               content_type.to_lowercase().contains("image/") {
              let data_as_bytes = match resp.bytes().await {
                Ok(v) => Some(v.to_vec()),
                Err(_) => None,
              };
               CFetchResponse::new(status, "OK", data_as_bytes, None, None)
            // Was it JSON data?
            } else if content_type.to_lowercase().contains("application/json") {
              let data_as_json = match resp.text().await {
                Ok(data_as_string) => {
                  match codemelted_json::parse(&data_as_string) {
                    Some(v) => Some(v),
                    None => None,
                  }
                }
                Err(_) => None,
              };
              CFetchResponse::new(status, "OK", None, data_as_json, None)
            // Welp was not JSON or bytes, assume it is text then.
            } else {
              let data_as_string = match resp.text().await {
                Ok(v) => Some(v),
                Err(_) => None,
              };
              CFetchResponse::new(status, "OK", None, None, data_as_string)
            }
          } else {
            // We might have had an OK but the status code returned was not 2XX range.
            CFetchResponse::new(status, "UNDETERMINED", None, None, None)
          }
        },
        // We had an error, go determine what the issue was.
        Err(why) => {
          let status = match why.status() {
            Some(v) => v.as_u16(),
            None => 418,
          };
          let status_text = why.without_url().to_string();
          CFetchResponse::new(status, &status_text, None, None, None)
        },
      }
    }
  }

  /// The response of the [fetch] call holding the result and associated data
  /// of the request.
  pub struct CFetchResponse {
    status: u16,
    status_text: String,
    data_as_bytes: Option<Vec<u8>>,
    data_as_json: Option<CObject>,
    data_as_string: Option<String>,
  }
  impl CFetchResponse {
    /// Creates a new [CFetchResponse] from the [CFetchRequest::send] call.
    fn new(
      status: u16,
      status_text: &str,
      data_as_bytes: Option<Vec<u8>>,
      data_as_json: Option<CObject>,
      data_as_string: Option<String>
    ) -> CFetchResponse {
      CFetchResponse {
        status,
        status_text:
        status_text.to_string(),
        data_as_bytes,
        data_as_json,
        data_as_string,
      }
    }

    /// The final HTTP Status Code associated with the request. 2XX good,
    /// 4XX - 5XX bad.
    pub fn status(&self) -> u16 {
      self.status
    }

    /// Any associated text with the status code if it was provided.
    pub fn status_text(&self) -> String {
      self.status_text.to_string()
    }

    /// The data as bytes if the request results in a blob / byte array
    /// data. None returned if not.
    pub fn data_as_bytes(&self) -> Option<Vec<u8>> {
      self.data_as_bytes.clone()
    }

    /// The data as JSON if the request results in a JSON return type
    /// data. None returned if not.
    pub fn data_as_json(&self) -> Option<CObject> {
      self.data_as_json.clone()
    }

    /// The data as string if the request results in a string return type
    /// data. None returned if not.
    pub fn data_as_string(&self) -> Option<String> {
      self.data_as_string.clone()
    }
  }

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

  /// Wrapper over the rouille::Request struct to prevent name collisions.
  pub type CServerRequest = rouille::Request;

  /// Wrapper over the rouille::Response struct to prevent name collisions.
  pub type CServerResponse = rouille::Response;

  /// Supports the [CWebSocketProtocol::post_message] to hold data of an
  /// appropriate type along with the [CWebSocketProtocol::get_message] to
  /// get read messages if available.
  pub enum CWebSocketData {
    /// Signals no data was available on the [CWebSocketProtocol::get_message]
    /// call.
    NoData,
    /// General signal indicating the socket is no longer usable.
    SocketClosed,
    /// Signals an error occurred when attempting to call
    /// [CWebSocketProtocol::post_message].
    IoError(String),
    /// Holds byte data from either message posting / getting.
    Bytes(Vec<u8>),
    /// Holds byte data from either message posting / getting.
    String(String),
  }
  impl CWebSocketData {
    /// Retrieves the bytes held by the [CWebSocketData::Bytes] or None
    /// if not that enumerated type.
    pub fn data_as_bytes(&self) -> Option<Vec<u8>> {
      match self {
        CWebSocketData::Bytes(items) => Some(items.to_owned()),
        _ => None,
      }
    }

    /// Retrieves the bytes held by the [CWebSocketData::String] or None
    /// if not that enumerated type.
    pub fn data_as_string(&self) -> Option<String> {
      match self {
        CWebSocketData::String(v) => Some(v.to_owned()),
        _ => None,
      }
    }

    /// Retrieves the bytes held by the [CWebSocketData::IoError] or None
    /// if not that enumerated type.
    pub fn io_error_as_string(&self) -> Option<String> {
      match self {
        CWebSocketData::IoError(v) => Some(v.to_owned()),
        _ => None,
      }
    }
  }

  /// Object created from the [upgrade_web_socket] call when a web socket
  /// client request is handled in the [serve] function call of http
  /// requests.
  pub struct CWebSocketProtocol {
    id: String,
    socket: Option<websocket::Websocket>,
    error: Option<String>
  }
  impl CWebSocketProtocol {
    /// Supports the [upgrade_web_socket] in creating a bi-directional
    /// server-side web socket.
    fn new(id: &str, socket: websocket::Websocket) -> CWebSocketProtocol {
      CWebSocketProtocol {
        id: id.to_string(),
        socket: Some(socket),
        error: None
      }
    }
  }
  /// Implementation of the [CProtocolHandler] to wrap the
  /// rouille::websocket::Websocket into this modules protocol rules. There
  /// usage further explained.
  impl CProtocolHandler<CWebSocketData> for CWebSocketProtocol {
    /// id given as part of the [upgrade_web_socket] function call.
    fn id(&mut self) -> String {
      self.id.to_string()
    }

    /// Will hold any errors from the [CWebSocketProtocol::post_message]
    /// call if an error is encountered at that time.
    fn error(&mut self) -> Option<String> {
      if self.error.is_none() {
        return None;
      }
      let rtnval = self.error.clone();
      self.error = None;
      rtnval
    }

    /// Peeks to see if a message is available on the socket and then reads
    /// it if one is available. The [CWebSocketData] will hold the given data
    /// if available.
    fn get_message(&mut self, _request: Option<&str>) -> CWebSocketData {
      // If socket closed by terminate, return socket closed.
      if self.socket.is_none() {
        return CWebSocketData::SocketClosed;
      }

      // Nope we still have socket, go see if we have data.
      let socket = self.socket.as_mut().unwrap();
      if socket.by_ref().peekable().peek().is_some() {
        match socket.by_ref().next() {
          // We have something, go get it.
          Some(data) => {
            match data {
              Message::Text(v) => CWebSocketData::String(
                v.to_owned()
              ),
              Message::Binary(items) => CWebSocketData::Bytes(
                items.to_owned()
              ),
            }
          },
          // No data available, signal as such.
          None => CWebSocketData::NoData,
        }
      } else {
        // We have nothing, signal as such.
        CWebSocketData::NoData
      }
    }

    /// Returns true if socket is not closed, once closed, the socket is
    /// considered dead from a server perspective.
    fn is_running(&self) -> bool {
      if self.socket.is_none() {
        return false;
      }
      self.socket.as_ref().unwrap().is_closed()
    }

    /// Post a message to a client from the server. Check the
    /// [CWebSocketProtocol::error] is_none() to ensure post success.
    fn post_message(&mut self, data: CWebSocketData) {
      // If server terminated connection, signal as such.
      if self.socket.is_none() {
        self.error = Some(String::from("socket is closed!"));
        return;
      }

      // We still have connection, go post message and check the result.
      let socket = self.socket.as_mut().unwrap();
      let result = match data {
        // We are transmitting bytes.
        CWebSocketData::Bytes(data) => {
          socket.send_binary(&data)
        },
        // We are transmitting string.
        CWebSocketData::String(data) =>{
          socket.send_text(&data)
        },
        // An invalid enumerated value used, panic to flag how to use this object
        // properly
        _ => {
          panic!(
            "CWebSocketProtocol::post_message(): Invalid data received"
          );
        }
      };

      // See if we have an error to handle or not.
      match result {
        Ok(_) => {},
        Err(why) => {
          match why {
            SendError::IoError(error) => {
              let msg = format!("I/O Error: {}", error.to_string());
              self.error = Some(msg);
            },
            SendError::Closed => {
              self.error = Some(String::from("socket is closed!"));
            },
          }
        },
      }
    }

    /// Sets the internal socket reference to None thereby no longer being
    /// able to use the socket.
    ///
    /// _NOTE: Make sure when implementing this, properly shutdown sockets
    /// from client side._
    fn terminate(&mut self) {
      self.socket = None;
    }
  }

  // --------------------------------------------------------------------------
  // [Module Function Definitions] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Executes a [CFetchRequest] to a REST API endpoint resulting in a
  /// [CFetchResponse] from that given server endpoint.
  ///
  /// **Example:*
  /// ```
  /// use codemelted::codemelted_network;
  /// use codemelted::codemelted_network::{CFetchRequest, CFetchAction};
  ///
  /// let resp = codemelted_network::fetch(
  ///   CFetchRequest::new(
  ///     CFetchAction::Get,
  ///     "https://codemelted.com/favicon.png"
  ///   )
  /// );
  /// assert!(resp.status() == 200);
  /// assert!(resp.data_as_bytes().is_some());
  /// ```
  pub fn fetch(request: CFetchRequest) -> CFetchResponse {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
      request.send().await
    })
  }

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

  /// Starts a http server listener to service http socket requests via the
  /// passed to the function. This function is a light wrapper around the
  /// <a href="https://docs.rs/rouille/latest/rouille/index.html" target="_blank">
  /// rouille crate
  /// </a> building a similar API as other CodeMelted DEV modules for serving
  /// HTTP endpoints. This is also a blocking call so once started, it blocks
  /// until quit so setup appropriate threading if your app is doing other
  /// things besides acting as a REST API endpoint.
  ///
  /// **Example:**
  /// ```no_run
  /// use codemelted::codemelted_network;
  /// use codemelted::codemelted_network::{
  ///   CServerRequest,
  ///   CServerResponse
  /// };
  ///
  /// // Setup the handler
  /// fn http_server_handler(_request: &CServerRequest) -> CServerResponse {
  ///   // Handle the request and return a response.
  ///   CServerResponse::text("Hello World")
  /// }
  ///
  /// // Serve it up, this is a blocking call.
  /// codemelted_network::serve("127.0.0.1:80", &http_server_handler);
  /// ```
  pub fn serve<F>(bind_addr: &str, handler: F)
  where
    F: Send + Sync + 'static + Fn(&CServerRequest) -> CServerResponse,
  {
    start_server(bind_addr, move |request| {
      handler(request)
    });
  }

  /// Provides the mechanism for upgrading a to a web socket from the [serve]
  /// function call. The result will either Websocket with response or an
  /// error if the upgrade could not be carried out. The Receiver is held open
  /// until the server closes the connection or the connection is lost meaning
  /// the client must re-connect.
  ///
  /// **Example (NOT TESTED):**
  /// ```no_run
  /// use codemelted::codemelted_network;
  /// use codemelted::codemelted_network::{
  ///   CServerRequest,
  ///   CServerResponse
  /// };
  ///
  /// // Setup the handler
  /// fn http_server_handler(request: &CServerRequest) -> CServerResponse {
  ///   // Determine you have a web socket request...
  ///   match codemelted_network::upgrade_web_socket(
  ///       "web_socket", request, None) {
  ///     Ok(socket) => {
  ///       // Do something with the socket. This is bi-directional socket
  ///       // usable until the socket is terminated or closed by the client.
  ///     },
  ///     Err(why) => {
  ///       // However you are handling error handling.
  ///     }
  ///   }
  ///   // Remember, you always must return a response after you get the
  ///   // socket.
  ///   CServerResponse::text("Hello World")
  /// }
  ///
  /// // Serve it up, this is a blocking call.
  /// codemelted_network::serve("127.0.0.1:80", &http_server_handler);
  /// ```
  pub fn upgrade_web_socket(
    id: &str,
    request: &Request,
    subprotocol: Option<&'static str>
  ) -> Result<CWebSocketProtocol, WebsocketError> {
    match websocket::start(request, subprotocol) {
      Ok(v) => {
        let socket = v.1.recv().unwrap();
        Ok(CWebSocketProtocol::new(id, socket))
      },
      Err(why) => Err(why),
    }
  }

  /// <center><b><mark>FUTURE IMPLEMENTATION. DON'T CALL.</mark></b></center>
  pub fn web_rtc() {
    unimplemented!("FUTURE IMPLEMENTATION!");
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

/// Implements the CodeMelted DEV Process use case. This module provides all
/// the functionality necessary to interact with host operating system
/// processes, applications, and services. This is from checking an
/// application [crate::codemelted_process::exists],
/// [crate::codemelted_process::run] one off commands to get the output,
/// [crate::codemelted_process::spawn] a bi-directional process, and the
/// ability [crate::codemelted_process::monitor] the overall host
/// operating system.
///
/// _NOTE: You may need proper administrator privileges to utilize some
/// features of this module.
#[doc = mermaid!("models/codemelted_process.mmd")]
pub mod codemelted_process {
  // --------------------------------------------------------------------------
  // [Module Use Statements] --------------------------------------------------
  // --------------------------------------------------------------------------
  use crate::{codemelted_async, CCsvFormat, CProtocolHandler};
  use std::{
    io::{Read, Write},
    process::{Child, ChildStdin, Command, Stdio},
    sync::mpsc::{channel, Receiver, Sender},
    thread::{self, JoinHandle}
  };
  use simple_mermaid::mermaid;
  use sysinfo::{Pid, ProcessesToUpdate, System};

  // --------------------------------------------------------------------------
  // [Module Data Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// The result of the [monitor] call provide a view of the host
  /// operating systems currently running processes. It allows for gathering
  /// data about the processes (statistics, originating application, etc.)
  /// while also providing the ability to know the current run status, the
  /// ability to kill, and wait for the process to exit.
  ///
  /// - _NOTE 1: This level of monitoring may require elevated privileges of
  /// the user running the application. If a panic occurs that may be the
  /// reason._
  /// - _NOTE 2: Any item that can't be determined will either be UNDETERMINED
  /// if a String return type or 0 if a integer based field._
  pub struct CProcessMonitor {
    sys: System
  }
  impl CProcessMonitor {
    /// Function that supports the [monitor] call of the module.
    fn new() -> CProcessMonitor {
      let sys = System::new_all();
      CProcessMonitor { sys }
    }

    /// Refreshes the held processes by this object removing any processes
    /// no longer running.
    pub fn refresh(&mut self) {
      self.sys.refresh_processes(ProcessesToUpdate::All, true);
    }

    /// Gets the operating system currently running Process Ids from the host
    /// operating system.
    pub fn pids(&self) -> Vec<u32> {
      let mut pids = Vec::<u32>::new();
      for (pid, _process) in self.sys.processes() {
        pids.push(pid.as_u32());
      }
      pids
    }

    /// Gets the CPU% for the running process. This takes into account the
    /// number of CPUs so the value will be between 0.0 / 100.0%.
    pub fn cpu_usage(&self, pid: u32) -> f32 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          v.cpu_usage() / codemelted_async::cpu_count() as f32
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// The current working directory of the given pid.
    pub fn cwd(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.cwd() {
            Some(v) => {
              match v.to_str() {
                Some(v) => String::from(v),
                None => String::from("UNDETERMINED"),
              }
            },
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns number of bytes read to disk for the given pid.
    pub fn disk_total_read_bytes(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.disk_usage().total_read_bytes,
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns number of bytes written to disk for the given pid.
    pub fn disk_total_written_bytes(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.disk_usage().total_written_bytes,
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// The path to the process being run for the given pid.
    pub fn exe(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.exe() {
            Some(v) => {
              match v.to_str() {
                Some(v) => String::from(v),
                None => String::from("UNDETERMINED"),
              }
            },
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the group ID of the process. For Windows this will always
    /// return UNDETERMINED.
    pub fn group_id(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.group_id() {
            Some(v) => v.to_string(),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the memory usage (in bytes) of the specified pid.
    pub fn memory_usage_bytes(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.memory(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the virtual memory usage (in bytes) of the specified pid.
    pub fn memory_virtual_bytes(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.virtual_memory(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the name of the process of the specified pid.
    pub fn name(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.name().to_str() {
            Some(v) => String::from(v),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the number of open files in the current process for
    /// the given pid.
    pub fn open_files(&self, pid: u32) -> u32 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.open_files() {
            Some(v) => v,
            None => 0,
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the parent PID of the specified pid.
    pub fn parent_pid(&self, pid: u32) -> u32 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.parent() {
            Some(v) => v.as_u32(),
            None => 0,
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the path of the root directory for the given pid.
    pub fn root(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.root() {
            Some(v) => {
              match v.to_str() {
                Some(v) => String::from(v),
                None => String::from("UNDETERMINED"),
              }
            },
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the session ID for the current process or 0 if it couldn't
    /// be retrieved for the given pid.
    pub fn session_id(&self, pid: u32) -> u32 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.session_id() {
            Some(v) => v.as_u32(),
            None => 0,
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the status of the process for the given pid.
    pub fn status(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.status().to_string(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the time where the process was started (in seconds)
    /// from epoch of the specified pid.
    pub fn time_started_seconds(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.start_time(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns for how much time the process has been running (in seconds)
    /// of the given pid.
    pub fn time_running_seconds(&self, pid: u32) -> u64 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.run_time(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Returns the ID of the owner user of this process or UNDETERMINED
    /// for the given pid.
    pub fn user_id(&self, pid: u32) -> String {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.user_id()  {
            Some(v) => v.to_string(),
            None => String::from("UNDETERMINED"),
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Kills the specified pid returning true if the signal was sent. This
    /// does not wait for the given pid to be killed. Call
    /// [CProcessMonitor::wait] after calling this to wait.
    pub fn kill(&self, pid: u32) -> bool {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => v.kill(),
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }

    /// Waits for a given pid to complete and returns its status code from the
    /// operating system. `-1` is returned if it could not be determined.
    pub fn wait(&self, pid: u32) -> i32 {
      match self.sys.process(Pid::from_u32(pid)) {
        Some(v) => {
          match v.wait() {
            Some(v) => {
              match v.code() {
                Some(v) => v,
                None => -1 as i32,
              }
            },
            None => -1 as i32,
          }
        },
        None => panic!("SyntaxError: Unknown pid specified."),
      }
    }
  }
  impl CCsvFormat for CProcessMonitor {
    fn csv_header(&self) -> String {
      format!(
        "{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}",
        String::from("system_id"),
        String::from("pid"),
        String::from("cpu_usage"),
        String::from("cwd"),
        String::from("disk_total_read_bytes"),
        String::from("disk_total_written_bytes"),
        String::from("exe"),
        String::from("group_id"),
        String::from("memory_usage_bytes"),
        String::from("memory_virtual_bytes"),
        String::from("name"),
        String::from("open_files"),
        String::from("parent_pid"),
        String::from("root"),
        String::from("session_id"),
        String::from("status"),
        String::from("time_started_seconds"),
        String::from("time_running_seconds"),
        String::from("user_id"),
      )
    }

    fn as_csv(&self) -> String {
      let mut csv_data = String::new();
      let pids = self.pids();
      for pid in pids {
        let data = format!(
          "{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}",
          Self::system_id(),
          pid,
          self.cpu_usage(pid),
          self.cwd(pid),
          self.disk_total_read_bytes(pid),
          self.disk_total_written_bytes(pid),
          self.exe(pid),
          self.group_id(pid),
          self.memory_usage_bytes(pid),
          self.memory_virtual_bytes(pid),
          self.name(pid),
          self.open_files(pid),
          self.parent_pid(pid),
          self.root(pid),
          self.session_id(pid),
          self.status(pid),
          self.time_started_seconds(pid),
          self.time_running_seconds(pid),
          self.user_id(pid),
        );
        csv_data.push_str(&data);
        csv_data.push('\n');
      }
      csv_data
    }
  }

  /// Represents a bi-directional process able to allow a Rust application to
  /// communicate with a hosted operating system process / command via STDIN /
  /// STDOUT / STDERR. This continues until the [CProcessProtocol::terminate]
  /// is called.
  pub struct CProcessProtocol {
    protocol_stderr_rx: Receiver<u8>,
    protocol_stdout_rx: Receiver<u8>,
    protocol_rx_thread: JoinHandle<()>,
    protocol_shutdown_tx: Sender<bool>,
    process: Child,
    protocol_stdin: ChildStdin,
  }
  impl CProcessProtocol {
    fn new(command: &str, args: &str) -> CProcessProtocol {
      // Go setup the process and spawn it.
      let cmd = format!("{} {}", command, args);
      let mut process = if cfg!(target_os = "windows") {
        Command::new("cmd").args(["/c", &cmd])
          .stdin(Stdio::piped())
          .stdout(Stdio::piped())
          .stderr(Stdio::piped())
          .spawn().unwrap()
      } else {
        Command::new("sh").args(["-c", &cmd])
          .stdin(Stdio::piped())
          .stdout(Stdio::piped())
          .stderr(Stdio::piped())
          .spawn().unwrap()
      };

      // Setup our receive pipe thread for data
      let mut stdout = process.stdout.take().unwrap();
      let mut stderr = process.stderr.take().unwrap();
      let (thread_stdout_tx, protocol_stdout_rx) = channel::<u8>();
      let (thread_stderr_tx, protocol_stderr_rx) = channel::<u8>();
      let (protocol_shutdown_tx, thread_shutdown_rx) = channel::<bool>();

      let protocol_rx_thread = thread::spawn(move || {
        // The items we need to handle a bi-directional process in Rust.
        // Sometimes it blocks and sometimes it does not. Observed behavior
        // suggests we need a buffer of one because if the read pipe cannot
        // fill the available bytes, it will block. So only a buffer of 1 wil
        // suffice.
        let mut backoff_counter = 0;
        let mut buf = [0x00];
        loop {
          // Go read data and see what we have. This may become a blocking read
          // depending on the operating system. If it does then we are good, if
          // not then we utilize the backoff_counter to prevent us from
          // throttling the thread.
          match stdout.read(&mut buf) {
            Ok(v) => {
              if v != 0 {
                backoff_counter = 0;
                match thread_stdout_tx.send(buf[0]) {
                  Ok(_) => continue,
                  Err(_) => break, // Something bad happened, break thread.
                }
              } else {
                backoff_counter += 1;
              }
            },
            Err(_) => continue,
          }

          match stderr.read(&mut buf) {
            Ok(v) => {
              if v != 0 {
                backoff_counter = 0;
                match thread_stderr_tx.send(buf[0]) {
                  Ok(_) => continue,
                  Err(_) => break, // Something bad happened, break thread.
                }
              } else {
                backoff_counter += 1;
              }
            },
            Err(_) => continue,
          }

          // Determine if we have been called to terminate this thread.
          match thread_shutdown_rx.try_recv() {
            Ok(_) => break, // We were ordered to shutdown.
            Err(_) => {
              // A way to prevent thread throttling if we do not have a blocking
              // pipe on read.
              if backoff_counter >= 10 {
                codemelted_async::sleep(1000);
              }
              continue
            },
          }
        }
      });

      // Return the created protocol
      let protocol_stdin = process.stdin.take().unwrap();
      CProcessProtocol {
        protocol_stderr_rx,
        protocol_stdout_rx,
        protocol_rx_thread,
        protocol_shutdown_tx,
        process,
        protocol_stdin,
      }
    }
  }

  /// Implements the [CProtocolHandler] for the [CProcessProtocol]. While the
  /// process wrapped by the protocol is in its own operating system process
  /// meaning it won't block your application processing, any call to
  /// [CProcessProtocol::get_message], [CProcessProtocol::error] and
  /// [CProcessProtocol::post_message] are synchronous calls. No thread is
  /// implemented as part of this [CProtocolHandler].
  impl CProtocolHandler<String> for CProcessProtocol {
    fn id(&mut self) -> String {
      self.process.id().to_string()
    }

    /// Reads STDERR of the process to see if anything is wrong with the
    /// process you are interacting.
    fn error(&mut self) -> Option<String> {
      let mut rx_buf = Vec::<u8>::new();
      loop {
        match self.protocol_stderr_rx.try_recv() {
          Ok(v) => rx_buf.push(v),
          Err(_) => break,
        };
      }
      match String::from_utf8(rx_buf) {
        Ok(v) => Some(v),
        Err(_) => None,
      }
    }

    fn get_message(&mut self, _request: Option<&str>) -> String {
      let mut rx_buf = Vec::<u8>::new();
      loop {
        match self.protocol_stdout_rx.try_recv() {
          Ok(v) => rx_buf.push(v),
          Err(_) => break,
        };
      }
      match String::from_utf8(rx_buf) {
        Ok(v) => v,
        Err(_) => String::from(""),
      }
    }

    fn is_running(&self) -> bool {
      !self.protocol_rx_thread.is_finished()
    }

    fn post_message(&mut self, data: String) {
      let _ = self.protocol_stdin.write_all(data.as_bytes());
      let _ = self.protocol_stdin.flush();
    }

    fn terminate(&mut self) {
      self.process.kill().expect("Process should have terminated!");
      let _ = self.protocol_shutdown_tx.send(true);
      loop {
        if !self.is_running() {
          break;
        }
        codemelted_async::sleep(100);
      }
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

  /// Constructs a [CProcessMonitor] to monitor the the different running
  /// processes on the host operating system.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_process;
  /// use codemelted::codemelted_process::CProcessMonitor;
  ///
  /// let mut monitor = codemelted_process::monitor();
  /// monitor.refresh();
  /// let len = monitor.pids().len();
  /// assert!(len >= 0);
  /// ```
  pub fn monitor() -> CProcessMonitor {
    CProcessMonitor::new()
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
  ///   codemelted_process::run("dir", "")
  /// } else {
  ///   codemelted_process::run("ls", "")
  /// };
  /// println!("{}", output);
  /// ```
  pub fn run(command: &str, args: &str) -> String {
    let cmd = format!("{} {}", command, args);
    let proc = if cfg!(target_os = "windows") {
      Command::new("cmd")
        .args(["/c", &cmd])
        .output()
        .expect("Expected process to execute.")
    } else {
      Command::new("sh")
        .args(["-c", &cmd])
        .output()
        .expect("Expected process to execute.")
    };
    String::from_utf8(proc.stdout).expect("Should vec<u8> to String")
  }

  /// Creates a bi-directional [CProcessProtocol] to support communicating
  /// with other hosted operating system applications / services via STDIN,
  /// STDOUT, and STDERR. You must call [CProcessProtocol::terminate] to
  /// properly cleanup the process.
  ///
  /// **Example:**
  /// ```
  /// use codemelted::codemelted_async;
  /// use codemelted::codemelted_process;
  /// use codemelted::CProtocolHandler;
  /// use codemelted::codemelted_process::CProcessProtocol;
  ///
  /// let mut protocol = if cfg!(windows) {
  ///   codemelted_process::spawn("pause", "")
  /// } else {
  ///   codemelted_process::spawn(
  ///     "echo Press enter to continue; read dummy;",
  ///     ""
  ///   )
  /// };
  /// assert!(protocol.is_running());
  /// codemelted_async::sleep(250);
  /// let data = protocol.get_message(None);
  /// assert!(data.len() > 0);
  /// protocol.post_message("\n".to_owned());
  /// protocol.post_message("\r".to_owned());
  /// protocol.terminate();
  /// assert!(!protocol.is_running());
  /// ```
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

// /// Used to vet logic in the `codemelted.rs` module, build complicated tests,
// /// or aid in fleshing out documentation. This is only to support the module's
// /// development and nothing more. Don't call this for anything.
// pub fn main() {
//   unimplemented!("TEST PURPOSES ONLY!");
// }