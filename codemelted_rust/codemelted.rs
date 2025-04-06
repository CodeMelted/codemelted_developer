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
// [DATA DEFINITION] ==========================================================
// ============================================================================

// ============================================================================
// [Async Use Case] ===========================================================
// ============================================================================

// ============================================================================
// [Audio Use Case] ===========================================================
// ============================================================================

// ============================================================================
// [Console Use Case] =========================================================
// ============================================================================

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

// ============================================================================
// [Logger Use Case] ==========================================================
// ============================================================================

// ============================================================================
// [Monitor Use Case] =========================================================
// ============================================================================

// ============================================================================
// [Network Use Case] =========================================================
// ============================================================================

// ============================================================================
// [NPU Use Case] =============================================================
// ============================================================================

// ============================================================================
// [Runtime Use Case] =========================================================
// ============================================================================

// ============================================================================
// [Storage Use Case] =========================================================
// ============================================================================

// ============================================================================
// [UI Use Case] ==============================================================
// ============================================================================

// [REFACTOR BELOW THIS LINE] =================================================

mod codemelted_api {
  use crate::{CLogLevel, CLoggedEventHandler};
  use std::sync::Mutex;

  static LOG_LEVEL: Mutex<CLogLevel> = Mutex::new(CLogLevel::Warning);
  static LOG_HANDLER: Mutex<Option<CLoggedEventHandler>> = Mutex::new(None);

  pub fn set_log_level(log_level: CLogLevel) {
    let mut data = LOG_LEVEL.lock().unwrap();
    *data = log_level;
  }
  pub fn get_log_level() -> CLogLevel {
    let data = LOG_LEVEL.lock().unwrap();
    data.clone()
  }
  pub fn set_log_handler(handler: Option<CLoggedEventHandler>) {
    let mut data = LOG_HANDLER.lock().unwrap();
    *data = handler;
  }
  pub fn get_log_handler() -> Option<CLoggedEventHandler> {
    let data = LOG_HANDLER.lock().unwrap();
    *data
  }
}

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
    let data_check = data.to_lowercase();
    true_strings.as_ref().contains(&data_check.as_str())
  }
}


/// The enumerated actions for the [codemelted_data_check] use case function.
enum CDataCheckAction {
  HasProperty,
  Type,
  Url,
}

/// Supports the data validity checks of the [CObject] dynamic type to ensure
/// it is as expected. The check performed will yield a true / false based on
/// the finding. If should_panic is set to true, the function will force a
/// panic! on a failed data check.
///
/// # HasProperty Check
/// ```
/// use codemelted::CDataCheckAction;
/// use codemelted::codemelted_data_check;
/// ```
///
/// # Data Type Check
/// ```
/// use codemelted::CDataCheckAction;
/// use codemelted::codemelted_data_check;
/// ```
///
/// # Url Validity Check
/// ```
/// use codemelted::CDataCheckAction;
/// use codemelted::codemelted_data_check;
/// ```
fn codemelted_data_check(
  action: CDataCheckAction,
  data: CObject,
  should_panic: bool,
  key: Option<&str>,
) -> bool {
  let answer = match action {
    CDataCheckAction::HasProperty => {
      data.has_key(key.unwrap())
    },
    CDataCheckAction::Type => {
      match key.unwrap() {
        "array" => data.is_array(),
        "boolean" => data.is_boolean(),
        "empty" => data.is_empty(),
        "null" => data.is_null(),
        "number" => data.is_number(),
        "object" => data.is_object(),
        "string" => data.is_string(),
        &_ => false,
      }
    },
    CDataCheckAction::Url => {
      url::Url::parse(data.as_str().unwrap()).is_err()
    },
  };

  if should_panic && !answer {
    panic!("ERROR: codemelted_data_check failed.");
  }
  answer
}

// ----------------------------------------------------------------------------
// [JSON Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// The result of a [codemelted_json] function call.
enum CJsonResult {
  /// The result if the use case function call fails.
  None,
  /// Holds the [CObject] created as a result of a successful
  /// [CJsonAction::CreateArray], [CJsonAction::CreateObject] or
  /// [CJsonAction::Parse] action.
  Object(CObject),
  /// Holds the String created as a result of a successful
  /// [CJsonAction::Stringify] creation.
  String(String),
}

/// The requested action for the [codemelted_json] use case function.
enum CJsonAction {
  /// Creates a [CJsonResult::Object] empty [CObject] array to facilitate
  /// building a JSON compliant array for later processing.
  CreateArray,
  /// Creates a [CJsonResult::Object] empty [CObject] object to facilitate
  /// building a JSON compliant object for later processing.
  CreateObject,
  /// Parses the [codemelted_json] parse_data argument transforming a str
  /// into a [CJsonResult::Object].
  Parse,
  /// Parses the [codemelted_json] stringify_data argument transforming a
  /// [CObject] into a [CJsonResult::String].
  Stringify,
}

/// Carries out the [CJsonAction] request to create a [CJsonResult] to work
/// the [CObject] json compliant data object.
///
/// # CreateArray / CreateObject Requests
/// ```
/// use codemelted::CJsonAction;
/// use codemelted::CJsonResult;
/// use codemelted::codemelted_json;
/// ```
///
/// # Parse Request
/// ```
/// use codemelted::CJsonAction;
/// use codemelted::CJsonResult;
/// use codemelted::codemelted_json;
/// ```
///
/// # Stringify Request
/// ```
/// use codemelted::CJsonAction;
/// use codemelted::CJsonResult;
/// use codemelted::codemelted_json;
/// ```
fn codemelted_json(
  action: CJsonAction,
  parse_data: Option<&str>,
  stringify_data: Option<CObject>
) -> CJsonResult {
  match action {
    CJsonAction::CreateArray => CJsonResult::Object(CObject::new_array()),
    CJsonAction::CreateObject => CJsonResult::Object(CObject::new_object()),
    CJsonAction::Parse  => {
      match parse_data {
        Some(v) => {
          let obj = json::parse(&v);
          match obj {
            Ok(v2) => CJsonResult::Object(v2),
            _ => CJsonResult::None,
          }
        },
        _ => CJsonResult::None
      }
    },
    CJsonAction::Stringify => {
      match stringify_data {
        Some(v) => CJsonResult::String(v.dump()),
        _ => CJsonResult::None,
      }
    }
  }
}

// ----------------------------------------------------------------------------
// [String Parse Use Case] ----------------------------------------------------
// ----------------------------------------------------------------------------

/// Takes a string and will transform it into either a CObject or None if
/// something fails with attempting to transform the str into the expected
/// data type.
///
/// ```
/// use codemelted::CDataCheckAction;
/// use codemelted::codemelted_data_check;
/// ```
fn codemelted_string_parse(
  data: &str
) -> Option<CObject> {
  let result = json::parse(data);
  match result {
    Ok(v) => Some(v),
    _ => None,
  }
}

// ============================================================================
// [NPU USE CASES] ============================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Math Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Collection of mathematical formulas that support the [codemelted_math]
/// function. Simply specify the formula, pass the parameters, and get the
/// answer.
enum CMathFormula {
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
}

/// Function to execute the [CMathFormula] enumerated formula by specifying
/// enumerated formula and the arguments for the calculated result.
///
/// ```rust
/// use codemelted::CMathFormula;
/// use codemelted::codemelted_math;
///
/// let fahrenheit = codemelted_math(
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
fn codemelted_math(formula: CMathFormula, args: &[f64]) -> f64 {
  use std::panic;
  let result = panic::catch_unwind(|| {
    match formula {
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
    "SyntaxError: codemelted_math args did not match the formula selected."
  )
}

// ============================================================================
// [RETENTION USE CASES] ======================================================
// ============================================================================

/// TBD
#[derive(Clone, PartialEq)]
enum CLogLevel {
  Debug,
  Info,
  Warning,
  Error,
  Off,
}
impl CLogLevel {
  pub fn as_string(&self) -> String {
    match self {
      CLogLevel::Debug => String::from("DEBUG"),
      CLogLevel::Info => String::from("INFO"),
      CLogLevel::Warning => String::from("WARNING"),
      CLogLevel::Error => String::from("ERROR"),
      CLogLevel::Off => String::from("OFF"),
    }
  }

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

/// TBD
struct CLogRecord {
  time_stamp: chrono::DateTime<chrono::Utc>,
  log_level: CLogLevel,
  data: String,
}
impl CLogRecord {
  pub fn new(log_level: CLogLevel, data: &str) -> CLogRecord {
    CLogRecord {
      time_stamp: chrono::Utc::now(),
      log_level,
      data: String::from(data),
    }
  }

  pub fn get_time_stamp(&self) -> &chrono::DateTime<chrono::Utc> {
    &self.time_stamp
  }

  pub fn get_log_level(&self) -> &CLogLevel {
    &self.log_level
  }

  pub fn get_data(&self) -> &str {
    &self.data
  }

  pub fn as_string(&self) -> String {
    format!(
      "{} [{}]: {}",
      self.get_time_stamp().format("%Y-%b-%d %H:%M:%S.%3f"),
      self.get_log_level().as_string(),
      self.get_data()
    )
  }
}

/// TBD
type CLoggedEventHandler = fn(CLogRecord);

/// TBD
enum CLoggerAction {
  SetLogLevel,
  SetHandler,
  LogDebug,
  LogInfo,
  LogWarning,
  LogError
}

/// TBD
fn codemelted_logger(
  action: CLoggerAction,
  data: Option<&str>,
  log_level: Option<CLogLevel>,
  handler: Option<CLoggedEventHandler>
) {
  match action {
    // Set our log level action
    CLoggerAction::SetLogLevel => {
      match log_level {
        Some(v) => codemelted_api::set_log_level(v),
        _ => panic!("SyntaxError: log_level expected w/ LogLevel action.")
      };
    },

    // Set our handler action.
    CLoggerAction::SetHandler => codemelted_api::set_log_handler(handler),

    // Welp, I guess we have to log something then.
    _ => {
      // See if we are logging this somewhere
      let logger_level = codemelted_api::get_log_level();
      if logger_level == CLogLevel::Off {
        return
      }

      // Get the log level of the log record to create.
      let log_record_level = match action {
        CLoggerAction::LogDebug => CLogLevel::Debug,
        CLoggerAction::LogInfo => CLogLevel::Info,
        CLoggerAction::LogWarning => CLogLevel::Warning,
        CLoggerAction::LogError => CLogLevel::Error,
        _ => panic!("The developer did something very bad!!!")
      };

      // Create the log record.
      let record = match data {
        Some(v) => CLogRecord::new(log_record_level, v),
        _ => panic!("SyntaxError: data expected with LogXXX action.")
      };

      if record.get_log_level().as_int() >= logger_level.as_int() {
        println!("{}", record.as_string())
      }

      // Now to send it to the log handler
      let log_handler = codemelted_api::get_log_handler();
      if let Some(v) = log_handler {
        v(record);
      }
    }
  }
}

/// Identifies the actions associated with the [codemelted_console] use case
/// function.
enum CConsoleAction {
  /// Prompts an alert and awaits for a user to press the enter key.
  Alert,
  /// Provides for choosing between a series of choices returning the index
  /// of the selection.
  Choose,
  /// Prompts for confirmation return true / false based on the answer.
  Confirm,
  /// Provides the ability to enter a password not reflecting the keys typed.
  Password,
  /// Provides the ability to prompt for a string answer being reflected to the
  /// console.
  Prompt,
  /// Will write text to STDOUT with no new line.
  Write,
  /// Will write text to STDOUT with a new line.
  WriteLn,
}

/// Attaches some utility methods for working with stdin / stdout to the
/// enumeration.
impl CConsoleAction {
  /// Utility function to read from stdin with a specified prompt.
  fn read(prompt: &str) -> String {
    use std::io::stdin;
    use std::io::stdout;
    use std::io::Write;

    let mut answer = String::new();
    print!("{}", prompt);
    let _ = stdout().flush();
    let _ = stdin().read_line(&mut answer);
    answer
  }

  ///Utility function to write to stdout with or without a new line.
  fn write(message: &str, use_new_line: bool) {
    if use_new_line {
      println!("{}", message);
    } else {
      print!("{}", message);
    }
  }
}

/// Provides a function to work with stdin / stdout to create basic event
/// driven console applications. The answer will be a [CObject]
/// with value held by the datatype specified by the enum.
///
/// # Alert Action
/// ```no_run
/// use codemelted::CConsoleAction;
/// use codemelted::codemelted_console;
/// ```
///
/// # Choose Action
/// ```no_run
/// use codemelted::CConsoleAction;
/// use codemelted::codemelted_console;
///
/// let answer = codemelted_console(
///   CConsoleAction::Choose,
///   None,
///   Some(&["fish", "dog", "cat"])
/// );
/// println!("{}", answer.as_number());
/// ```
///
/// # Confirm Action
/// ```no_run
/// use codemelted::CConsoleAction;
/// use codemelted::codemelted_console;
/// ```
///
/// # Password / Prompt Actions
/// ```no_run
/// use codemelted::CConsoleAction;
/// use codemelted::codemelted_console;
/// ```
///
/// # Write / WriteLn Actions
/// ```no_run
/// use codemelted::CConsoleAction;
/// use codemelted::codemelted_console;
/// ```
///
fn codemelted_console(
  action: CConsoleAction,
  message: Option<&str>,
  choices: Option<&[&str]>
) -> CObject {
  // Format our message if one was specified or not.
  let msg = match message {
    Some(v) => {
      match action {
        CConsoleAction::Alert => &format!("{} [ENTER]: ", v),
        CConsoleAction::Confirm => &format!("{} CONFIRM [y/N]: ", v),
        CConsoleAction::Choose => &format!("{}", v),
        CConsoleAction::Password =>  &format!("{}: ", v),
        CConsoleAction::Prompt =>  &format!("{}: ", v),
        CConsoleAction::Write => v,
        CConsoleAction::WriteLn => v,
      }
    },
    _ => {
      match action {
        CConsoleAction::Alert => "[ENTER]: ",
        CConsoleAction::Confirm => "CONFIRM [y/N]: ",
        CConsoleAction::Choose => "CHOOSE",
        CConsoleAction::Password => "PASSWORD: ",
        CConsoleAction::Prompt => "PROMPT: ",
        CConsoleAction::Write => "",
        CConsoleAction::WriteLn => "",
      }
    },
  };

  // Now go carry out our action to get our data.
  match action {
    CConsoleAction::Alert => {
      CConsoleAction::read(msg);
      CObject::Null
    },
    CConsoleAction::Confirm => {
      let answer: String = CConsoleAction::read(msg);
      CObject::Boolean(CObject::is_truthy(&answer))
    },
    CConsoleAction::Choose => {
      if choices.is_some() {
        let options = choices.unwrap();
        let answer: i32;
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
          let selection = CConsoleAction::read("Make a Selection: ");
          match selection.trim().parse::<i32>() {
            Ok(n) => {
              if n >=0 || n < options.len().try_into().unwrap() {
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
        CObject::Number(answer.into())
      } else {
        panic!(
          "SyntaxError: codemelted_console choices option not specified."
        );
      }
    },
    CConsoleAction::Password => {
      let password = rpassword::prompt_password(msg).unwrap();
      CObject::String(String::from(password))
    },
    CConsoleAction::Prompt => {
      let answer: String = CConsoleAction::read(msg);
      CObject::String(String::from(answer))
    },
    CConsoleAction::Write => {
      CConsoleAction::write(msg, false);
      CObject::Null
    },
    CConsoleAction::WriteLn => {
      CConsoleAction::write(msg, true);
      CObject::Null
    },
  }
}

// ============================================================================
// [UNIT TEST DEFINITIONS] ====================================================
// ============================================================================

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_is_nan() {
    assert_eq!(true, f64::is_nan((-1.0 as f64).sqrt()));
  }
}
