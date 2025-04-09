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

/// Defines a trait to attach to the [CObject] providing utility function
/// definitions to make a bool based on a series of strings that can be
/// considered true in nature.
pub trait IsTruthyString {
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

/// Implements the [IsTruthyString] trait for our [CObject] dynamic type.
impl IsTruthyString for CObject {
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

// ============================================================================
// [Audio Use Case] ===========================================================
// ============================================================================

// NOT APPLICABLE TO THIS MODULE

// ============================================================================
// [Console Use Case] =========================================================
// ============================================================================

/// Implements the CodeMelted DEV Console use case. Provides the ability to
/// create terminal applications using STDIN / STDOUT to interact with the
/// user with simple prompts to guide them through a terminal based app.
pub mod codemelted_console {
  use crate::{CObject, IsTruthyString};

  /// Utility function to read from stdin with a specified prompt.
  fn read(prompt: &str) -> String {
    use std::io::stdin;
    use std::io::stdout;
    use std::io::Write;

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
  /// ```no_run
  /// use codemelted::codemelted_console;
  /// codemelted_console::write("Oh Know!");
  /// ```
  pub fn write(message: &str) {
    write_stdout(message, false);
  }

  /// Will put a string to STDOUT with a new line character.
  ///
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

// ============================================================================
// [Disk Use Case] ============================================================
// ============================================================================

// ============================================================================
// [HW Use Case] ==============================================================
// ============================================================================

// ============================================================================
// [JSON Use Case] ============================================================
// ============================================================================

/// Implements the CodeMelted DEV JSON use case. Provides the ability to work
/// with JSON based data. This includes performing data validations, parsing,
/// stringifying, and converting to basic data types. This is based on the
/// [CObject] which represents rust based JSON data.
pub mod codemelted_json {
  use crate::CObject;
  use json::number::Number;

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

  /// Will convert the given [CObject] to its equivalent bool value. This will
  /// also be false if not a valid value.
  ///
  /// # Successful Conversion
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::Boolean(true);
  /// assert_eq!(codemelted_json::as_bool(&obj), true);
  /// ```
  ///
  /// # Convert False (data or invalid)
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
  /// # Successful Conversion
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::from(542.65);
  /// assert_eq!(codemelted_json::as_number(&obj).is_some(), true);
  /// ```
  ///
  /// # Failed Conversion
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
  /// # Successful Conversion
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let obj = CObject::from("Hello");
  /// assert_eq!(codemelted_json::as_string(&obj).is_some(), true);
  /// ```
  ///
  /// # Failed Conversion
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
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_object();
  /// assert_eq!(codemelted_json::check_type(CDataType::Object, &obj, false), true);
  /// assert_eq!(codemelted_json::check_type(CDataType::Number, &obj, false), false);
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
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_array();
  /// assert_eq!(codemelted_json::check_type(CDataType::Array, &obj, false), true);
  /// ```
  pub fn create_array() -> CObject {
    CObject::new_array()
  }

  /// Creates a JSON compliant [CObject] for working with object JSON data.
  ///
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  /// use codemelted::codemelted_json::CDataType;
  ///
  /// let obj = codemelted_json::create_object();
  /// assert_eq!(codemelted_json::check_type(CDataType::Object, &obj, false), true);
  /// ```
  pub fn create_object() -> CObject {
    CObject::new_object()
  }

  /// Will check if a [CObject] object data JSON type has the specified key
  /// property before working with it.
  ///
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// let mut obj = codemelted_json::create_object();
  /// let _ = obj.insert("field1", 42);
  /// assert_eq!(codemelted_json::has_property(&obj, "field1", false), true);
  /// ```
  pub fn has_property(
    data: &CObject,
    key: &str,
    should_panic: bool,
  ) -> bool {
    let answer = data.has_key(key);
    if should_panic && !answer {
      panic!("ERROR: codemelted_json::has_property() failed.");
    }
    answer
  }

  /// Takes a JSON serialized string and parses it to create a [CObject].
  /// Returns None if the parse fails.
  ///
  /// # Successful Parse
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
  /// # Failed Parse
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
  /// ```
  /// use codemelted::CObject;
  /// use codemelted::codemelted_json;
  ///
  /// assert_eq!(codemelted_json::valid_url("https://google.com", false), true);
  /// assert_eq!(codemelted_json::valid_url("{aslkj230924!!}}|}", false), false);
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
pub mod codemelted_logger {
  use std::sync::Mutex;

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
    pub fn new(log_level: CLogLevel, data: &str) -> CLogRecord {
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

  /// Gets / sets the [CLogLevel] for the logging module.
  ///
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
  pub fn set_log_level(log_level: CLogLevel) {
    let mut data = LOG_LEVEL.lock().unwrap();
    *data = log_level;
  }

  /// Gets / sets the [CLoggedEventHandler] for the logging module.
  ///
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
  pub fn set_log_handler(handler: Option<CLoggedEventHandler>) {
    let mut data = LOG_HANDLER.lock().unwrap();
    *data = handler;
  }

  /// Will log an event via the logger module so long as it meets the
  /// currently set [CLogLevel]. Once logged to STDOUT, if a
  /// [CLoggedEventHandler], will pass the [CLogRecord] along for further
  /// processing.
  ///
  /// ```no_run
  /// use codemelted::codemelted_logger;
  /// use codemelted::codemelted_logger::CLogLevel;
  ///
  /// codemelted_logger::log(CLogLevel::Error, "Oh Know!");
  /// ```
  ///
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
// [Monitor Use Case] =========================================================
// ============================================================================

// ============================================================================
// [Network Use Case] =========================================================
// ============================================================================

// ============================================================================
// [NPU Use Case] =============================================================
// ============================================================================

/// Implements the CodeMelted DEV NPU use case. NPU stands for Numerical
/// Processing Unit. This means this module will hold all mathematical
/// processing for this module. It is broken into two functions. The compute()
/// function is for longer processing computations. The math() function will
/// provide access to the CodeMeltedNPU enumerated formulas.
pub mod codemelted_npu {
  /// Collection of mathematical formulas that support the [math] function.
  /// Simply specify the formula, pass the parameters, and get the answer.
  pub enum CodeMeltedNPU {
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
  impl CodeMeltedNPU {
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
      let lat1 = start_latitude * CodeMeltedNPU::PI / 180.0;
      let lon1 = start_longitude * CodeMeltedNPU::PI / 180.0;

      let lat2 = end_latitude * CodeMeltedNPU::PI / 180.0;
      let lon2 = end_longitude * CodeMeltedNPU::PI / 180.0;

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
      let lat1 = start_latitude * (CodeMeltedNPU::PI / 180.0);
      let lon1 = start_longitude * (CodeMeltedNPU::PI  / 180.0);
      let lat2 = end_latitude * (CodeMeltedNPU::PI  / 180.0);
      let lon2 = end_longitude * (CodeMeltedNPU::PI  / 180.0);

      // Set up our calculations
      let y = (lon2 - lon1).sin() * lat2.cos();
      let x = (lat1.cos() * lat2.sin()) -
        (lat1.sin() * lat2.cos() * (lon2 - lon1).cos());
      let rtnval = y.atan2(x) * (180.0 / CodeMeltedNPU::PI);
      CodeMeltedNPU::fmod(rtnval + 360.0, 360.0)
    }

    /// Helper function for calculating the geodetic speed between two points.
    fn geodetic_speed(start_milliseconds: f64, start_latitude: f64,
      start_longitude: f64, end_milliseconds: f64, end_latitude: f64,
      end_longitude: f64) -> f64 {
        let dist_meters = CodeMeltedNPU::geodetic_distance(
          start_latitude, start_longitude,
          end_latitude, end_longitude
        );
        let time_s = (end_milliseconds - start_milliseconds) / 1000.0;
        return dist_meters / time_s;
    }

    fn math(&self, args: &[f64]) -> f64 {
      use std::panic;
      let result = panic::catch_unwind(|| {
        match self {
          CodeMeltedNPU::GeodeticDistance => CodeMeltedNPU::geodetic_distance(
            args[0],
            args[1],
            args[2],
            args[3]
          ),
          CodeMeltedNPU::GeodeticHeading => CodeMeltedNPU::geodetic_heading(
            args[0],
            args[1],
            args[2],
            args[3]
          ),
          CodeMeltedNPU::GeodeticSpeed => CodeMeltedNPU::geodetic_speed(
            args[0],
            args[1],
            args[2],
            args[3],
            args[4],
            args[5]
          ),
          CodeMeltedNPU::TemperatureCelsiusToFahrenheit =>
            (args[0] * 9.0 / 5.0) + 32.0,
          CodeMeltedNPU::TemperatureCelsiusToKelvin => args[0] + 273.15,
          CodeMeltedNPU::TemperatureFahrenheitToCelsius =>
            (args[0] - 32.0) * (5.0 / 9.0),
          CodeMeltedNPU::TemperatureFahrenheitToKelvin =>
            (args[0] - 32.0) * (5.0 / 9.0) + 273.15,
          CodeMeltedNPU::TemperatureKelvinToCelsius => args[0] - 273.15,
          CodeMeltedNPU::TemperatureKelvinToFahrenheit =>
            (args[0] - 273.15) * (9.0 / 5.0) + 32.0,
        }
      });

      Result::expect(
        result,
        "SyntaxError: codemelted_math args did not match the formula selected."
      )
    }
  }

  /// TBD - unimplemented!()
  pub fn compute() {
    unimplemented!();
  }

  /// Function to execute the [CodeMeltedNPU] enumerated formula by specifying
  /// enumerated formula and the arguments for the calculated result.
  ///
  /// ```rust
  /// use codemelted::codemelted_npu;
  /// use codemelted::codemelted_npu::CodeMeltedNPU;
  ///
  /// let fahrenheit = codemelted_npu::math(
  ///   CodeMeltedNPU::TemperatureCelsiusToFahrenheit,
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
  pub fn math(formula: CodeMeltedNPU, args: &[f64]) -> f64 {
    formula.math(args)
  }
}

// ============================================================================
// [Runtime Use Case] =========================================================
// ============================================================================

// ============================================================================
// [Storage Use Case] =========================================================
// ============================================================================

// ============================================================================
// [UI Use Case] ==============================================================
// ============================================================================

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

// Only used for testing out modules that can't have a unit test derived.
// Comment out when ready to deliver module to crate.
pub fn main() {
  use crate::codemelted_logger;
  use crate::codemelted_logger::CLogLevel;

  codemelted_logger::log(CLogLevel::Error, "Oh Know!");
}
