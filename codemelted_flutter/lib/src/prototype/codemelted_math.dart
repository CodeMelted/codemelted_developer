/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

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

/// A collection of mathematical formulas you probably will never need to
/// calculate.
library codemelted_math;

import 'dart:math' as math;

/// Provides a math utility API with a collection of mathematical formulas I
/// have either had to use, research, or just found on the Internet.
class CodeMeltedMath {
  /// Converts celsius to fahrenheit.
  double celsiusToFahrenheit({required double temp}) => (temp * (9 / 5)) + 32;

  /// Converts celsius to kelvin
  double celsiusToKelvin({required double temp}) => temp + 273.15;

  /// Converts fahrenheit to celsius.
  double fahrenheitToCelsius({required double temp}) => (temp - 32) * (5 / 9);

  /// Converts fahrenheit to kelvin.
  double fahrenheitToKelvin({required double temp}) =>
      (temp - 32) * (5 / 9) + 273.15;

  /// Calculates the distance in meters between two WGS84 points.
  double geodeticDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    // Convert degrees to radians
    final lat1 = startLatitude * math.pi / 180.0;
    final lon1 = startLongitude * math.pi / 180.0;

    final lat2 = endLatitude * math.pi / 180.0;
    final lon2 = endLongitude * math.pi / 180.0;

    // radius of earth in metres
    const r = 6378100;

    // P
    final rho1 = r * math.cos(lat1);
    final z1 = r * math.sin(lat1);
    final x1 = rho1 * math.cos(lon1);
    final y1 = rho1 * math.sin(lon1);

    // Q
    final rho2 = r * math.cos(lat2);
    final z2 = r * math.sin(lat2);
    final x2 = rho2 * math.cos(lon2);
    final y2 = rho2 * math.sin(lon2);

    // Dot product
    final dot = (x1 * x2 + y1 * y2 + z1 * z2);
    final cosTheta = dot / (r * r);
    final theta = math.acos(cosTheta);

    // Distance in meters
    return r * theta;
  }

  /// Calculates the geodetic heading WGS84 to true north represented as 0 and
  /// rotating around 360 degrees.
  double geodeticHeading({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    // Get the initial data from our variables:
    final lat1 = startLatitude * (math.pi / 180);
    final lon1 = startLongitude * (math.pi / 180);
    final lat2 = endLatitude * (math.pi / 180);
    final lon2 = endLongitude * (math.pi / 180);

    // Set up our calculations
    final y = math.sin(lon2 - lon1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);
    var rtnval = math.atan2(y, x) * (180 / math.pi);
    rtnval = (rtnval + 360) % 360;
    return rtnval;
  }

  /// Calculates the speed between two points in meters per second.
  double geodeticSpeed({
    required double startMilliseconds,
    required double startLatitude,
    required double startLongitude,
    required double endMilliseconds,
    required double endLatitude,
    required double endLongitude,
  }) {
    // Get the lat / lon for start / end positions
    final distMeters = geodeticDistance(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );

    final timeS = (endMilliseconds - startMilliseconds) / 1000.0;
    return distMeters / timeS;
  }

  /// Converts kelvin to celsius
  double kelvinToCelsius({required double temp}) => temp - 273.15;

  /// Converts kelvin to fahrenheit
  double kelvinToFahrenheit({required double temp}) =>
      (temp - 273.15) * (9 / 5) + 32;

  /// Gets the single instance of the API.
  static CodeMeltedMath? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedMath() => _instance ?? CodeMeltedMath._();

  /// Sets up the namespace for the [CodeMeltedMath] object.
  CodeMeltedMath._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedMath] object.
final codemelted_async = CodeMeltedMath();
