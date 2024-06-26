// ignore_for_file: constant_identifier_names
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

import 'dart:math' as math;

/// Defines the formulas supported by the module.
enum CMathFormula {
  /// Kilometers squared to meters squared
  area_km2_to_m2,

  /// Gets the distance in meters between two geodetic points. The data array
  /// variables are startLatitude, startLongitude, endLatitude, endLongitude.
  geodetic_distance,

  /// Gets the head off true north between two geodetic points. The data array
  /// variables are startLatitude, startLongitude, endLatitude, endLongitude.
  geodetic_heading,

  /// Gets the speed in meters per second between two geodetic points. The data
  /// array variables are startMilliseconds, startLatitude, startLongitude,
  /// endMilliseconds, endLatitude, endLongitude.
  geodetic_speed,

  /// feet per second to miles per hour
  speed_fps_to_mph,

  /// feet per second to meters per second
  speed_fps_to_mps,

  /// feet per second to kilometers per hour
  speed_fps_to_kph,

  /// feet per second to knots
  speed_fps_to_knot,

  /// knots to miles per hour
  speed_knot_to_mph,

  /// knots to feet per second
  speed_knot_to_fps,

  /// knots to meters per second
  speed_knot_to_mps,

  /// knots to kilometers per hour
  speed_knot_to_kph,

  /// kilometers per hour to miles per hour
  speed_kph_to_mph,

  /// kilometers per hour to feet per second
  speed_kph_to_fps,

  /// kilometers per hour to meters per second
  speed_kph_to_mps,

  /// kilometers per hour to knots
  speed_kph_to_knot,

  /// meters per second to miles per hour
  speed_mps_to_mph,

  /// meters per second to feet per second
  speed_mps_to_fps,

  /// meters per second to kilometers per hour
  speed_mps_to_kph,

  /// meters per second to knots
  speed_mps_to_knot,

  /// miles per hour to feet per second
  speed_mph_to_fps,

  /// miles per hour to meters per second
  speed_mph_to_mps,

  /// miles per hour to kilometers per hour
  speed_mph_to_kph,

  /// miles per hour to knots
  speed_mph_to_knot,

  /// celsius to fahrenheit
  temp_c_to_f,

  /// celsius to kelvin
  temp_c_to_k,

  /// fahrenheit to celsius
  temp_f_to_c,

  /// fahrenheit to kelvin
  temp_f_to_k,

  /// kelvin to celsius
  temp_k_to_c,

  /// kelvin to fahrenheit
  temp_k_to_f
}

/// Internal extension to tie the formulas to the [CMathFormula] enumerated
/// values.
extension CMathFormulaExtension on CMathFormula {
  /// The mapping of the enumerated formulas to actual formulas.
  static final _data = {
    CMathFormula.area_km2_to_m2: (v) => v[0] * 1e+6,
    CMathFormula.geodetic_distance: (v) {
      // Get the lat / lon for start / end positions
      final startLatitude = v[0];
      final startLongitude = v[1];
      final endLatitude = v[2];
      final endLongitude = v[3];

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
    },
    CMathFormula.geodetic_heading: (v) {
      // Get the lat / lon for start / end positions
      final startLatitude = v[0];
      final startLongitude = v[1];
      final endLatitude = v[2];
      final endLongitude = v[3];

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
    },
    CMathFormula.geodetic_speed: (v) {
      // Get the lat / lon for start / end positions
      final startMilliseconds = v[0];
      final startLatitude = v[1];
      final startLongitude = v[2];
      final endMilliseconds = v[3];
      final endLatitude = v[4];
      final endLongitude = v[5];
      final distMeters = CMathFormula.geodetic_distance.calculate([
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      ]);
      final timeS = (endMilliseconds - startMilliseconds) / 1000.0;
      return distMeters / timeS;
    },
    CMathFormula.speed_fps_to_knot: (v) => v[0] / 1.688,
    CMathFormula.speed_fps_to_kph: (v) => v[0] * 1.097,
    CMathFormula.speed_fps_to_mph: (v) => v[0] / 1.467,
    CMathFormula.speed_fps_to_mps: (v) => v[0] / 3.281,
    CMathFormula.speed_knot_to_fps: (v) => v[0] * 1.688,
    CMathFormula.speed_knot_to_kph: (v) => v[0] * 1.852,
    CMathFormula.speed_knot_to_mph: (v) => v[0] * 1.151,
    CMathFormula.speed_knot_to_mps: (v) => v[0] / 1.944,
    CMathFormula.speed_kph_to_fps: (v) => v[0] / 1.097,
    CMathFormula.speed_kph_to_knot: (v) => v[0] / 1.852,
    CMathFormula.speed_kph_to_mph: (v) => v[0] / 1.609,
    CMathFormula.speed_kph_to_mps: (v) => v[0] / 3.600,
    CMathFormula.speed_mph_to_fps: (v) => v[0] * 1.467,
    CMathFormula.speed_mph_to_knot: (v) => v[0] / 1.151,
    CMathFormula.speed_mph_to_kph: (v) => v[0] * 1.609,
    CMathFormula.speed_mph_to_mps: (v) => v[0] / 2.237,
    CMathFormula.speed_mps_to_fps: (v) => v[0] * 3.281,
    CMathFormula.speed_mps_to_knot: (v) => v[0] * 1.944,
    CMathFormula.speed_mps_to_kph: (v) => v[0] * 3.600,
    CMathFormula.speed_mps_to_mph: (v) => v[0] * 2.237,
    CMathFormula.temp_c_to_f: (v) => (v[0] * (9 / 5)) + 32,
    CMathFormula.temp_c_to_k: (v) => v[0] + 273.15,
    CMathFormula.temp_f_to_c: (v) => (v[0] - 32) * (5 / 9),
    CMathFormula.temp_f_to_k: (v) => (v[0] - 32) * (5 / 9) + 273.15,
    CMathFormula.temp_k_to_c: (v) => v[0] - 273.15,
    CMathFormula.temp_k_to_f: (v) => (v[0] - 273.15) * (9 / 5) + 32,
  };

  /// Private method to support the module math method.
  double calculate(List<double> v) => _data[this]!(v);
}
