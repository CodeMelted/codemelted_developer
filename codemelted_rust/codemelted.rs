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

pub enum CUseCaseResponse {
  None,
  Bool(bool),
  Double(f64),
  Int(i128),
  String(String),
}

impl CUseCaseResponse {
  const TRUE_STRINGS: [&'static str; 9] = [
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

  fn is_true_string(v: &str) -> bool {
    CUseCaseResponse::TRUE_STRINGS.as_ref().contains(&v.to_lowercase().as_str())
  }
}

// ============================================================================
// [ASYNC IO USE CASES] =======================================================
// ============================================================================

fn _codemelted_process() {
  unimplemented!();
}

fn _codemelted_task() {
  unimplemented!();
}

fn _codemelted_worker() {
  unimplemented!();
}

// ============================================================================
// [DATA USE CASES] ===========================================================
// ============================================================================

fn _codemelted_data_check() {
  unimplemented!();
}

fn _codemelted_json() {
  unimplemented!();
}

fn _codemelted_string_parse<T>(v: &str) -> Option<T> {
  unimplemented!();
}

fn _codemelted_xml() {
  unimplemented!();
}

// ============================================================================
// [NPU USE CASES] ============================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Compute Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

fn _codemelted_compute() {
  unimplemented!();
}

// ----------------------------------------------------------------------------
// [Math Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Collection of mathematical formulas that support the [codemelted_math]
/// function. Simply specify the formula, pass the parameters, and get the
/// answer.
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
pub fn codemelted_math(formula: CMathFormula, args: &[f64]) -> f64 {
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
    "SyntaxError: args did not match the math formula selected"
  )
}

// ============================================================================
// [RETENTION USE CASES] ======================================================
// ============================================================================

fn _codemelted_database() {
  unimplemented!();
}

fn _codemelted_disk() {
  unimplemented!();
}

fn _codemelted_file() {
  unimplemented!();
}

fn _codemelted_storage() {
  unimplemented!();
}

// ============================================================================
// [SERVICES USE CASES] =======================================================
// ============================================================================

fn _codemelted_logger() {
  unimplemented!();
}

fn _codemelted_network() {
  unimplemented!();
}

fn _codemelted_pi() {
  unimplemented!();
}

fn _codemelted_runtime() {
  unimplemented!();
}

// ============================================================================
// [USER INTERFACE USE CASES] =================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [App Use Case] -------------------------------------------------------------
// ----------------------------------------------------------------------------

fn _codemelted_app() {
  unimplemented!();
}

// ----------------------------------------------------------------------------
// [Console Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/// Identifies the actions associated with the [codemelted_console] use case
/// function.
pub enum CConsoleAction {
  Alert,
  Confirm,
  Choose,
  Password,
  Prompt,
  Write,
  WriteLn,
}

impl CConsoleAction {
  fn read(prompt: &str, is_password: bool) -> String {
    use std::io::stdin;
    let mut answer = String::new();
    print!("{}", prompt);
    let _ = stdin().read_line(&mut answer);
    answer
  }

  fn write(message: &str, use_new_line: bool) {
    if use_new_line {
      println!("{}", message);
    } else {
      print!("{}", message);
    }
  }
}

pub fn codemelted_console(
  action: CConsoleAction,
  message: &str,
  choices: Option<Vec<String>>
) -> CUseCaseResponse {
  match action {
    CConsoleAction::Alert => {
      let msg: &str = if message.is_empty() {
        "[ENTER]: "
      } else {
        &format!("{} [ENTER]: ", message)
      };
      CConsoleAction::read(msg, false);
      CUseCaseResponse::None
    },
    CConsoleAction::Confirm => {
      let msg: &str = if message.is_empty() {
        "[ENTER]: "
      } else {
        &format!("{} [ENTER]: ", message)
      };
      let answer: String = CConsoleAction::read(msg, false);
      CUseCaseResponse::Bool(CUseCaseResponse::is_true_string(&answer))
    },
    CConsoleAction::Choose => {
      CUseCaseResponse::Int(0)
    },
    CConsoleAction::Password => {
      CUseCaseResponse::String(String::from(""))
    },
    CConsoleAction::Prompt => {
      CUseCaseResponse::String(String::from(""))
    },
    CConsoleAction::Write => {
      CConsoleAction::write(message, false);
      CUseCaseResponse::None
    },
    CConsoleAction::WriteLn => {
      CConsoleAction::write(message, true);
      CUseCaseResponse::None
    },
  }
}

// ----------------------------------------------------------------------------
// [Dialog Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

fn _codemelted_dialog() {
  unimplemented!();
}

// ----------------------------------------------------------------------------
// [UI Widget Use Case] -------------------------------------------------------
// ----------------------------------------------------------------------------

fn _codemelted_ui() {
  unimplemented!();
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

// Used to play around with functions before test definition.
// Delete when no longer needed.
fn main() {

}