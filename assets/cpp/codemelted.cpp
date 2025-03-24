export module codemelted;
/**
 * @file codemelted.cpp
 * @author mark.shaffer@codemelted.com
 * @date 2025-mm-dd
 * @version 0.0.0 <br />
 * 0.0.0 2025-mm-dd: TBD
 * @brief TBD
 * @note
 * @copyright 2025 Mark Shaffer. All Rights Reserved.
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

// ============================================================================
// [INCLUDES / IMPORTS] =======================================================
// ============================================================================

#include <numbers>
#include <cmath>

// ============================================================================
// [MACRO DEFINITIONS] ========================================================
// ============================================================================

/**
 * @brief MACRO that provides a fast integer lookup for the different
 * mathematical formulas to support the codemelted::math function.
 */
#define _CALC(formula, calculate) \
  case formula:                   \
    return calculate;


// ============================================================================
// [DATA DEFINITIONS] =========================================================
// ============================================================================

/**
 * @brief Enumeration of different conversions supported by this module.
 */
export enum class CFormula_t {
  geodetic_distance, /**< Distance in meters between two WGS84 points */
  geodetic_heading, /**< Heading in °N true North 0 - 359. */
  geodetic_speed, /**< Speed in meters per second between two WGS84 points. */
  temperature_celsius_to_fahrenheit, /**< °F = (°C x 9/5) + 32 */
  temperature_celsius_to_kelvin, /**< °C + 273.15 */
  temperature_fahrenheit_to_celsius, /**< (°F − 32) × 5/9 */
  temperature_fahrenheit_to_kelvin, /**< (°F − 32) × 5/9 + 273.15 */
  temperature_kelvin_to_celsius, /**< °K − 273.15 */
  temperature_kelvin_to_fahrenheit /**< (°K − 273.15) × 9/5 + 32 */
};

/**
 * @private
 * @brief Calculates the distance in meters between two WGS84 points.
 * @param startLatitude The starting latitude coordinate.
 * @param startLongitude The starting longitude coordinate.
 * @param endLatitude The ending latitude coordinate.
 * @param endLongitude The ending longitude coordinate.
 * @returns The calculated distance.
 */
double _geodetic_distance(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) {
  // Convert degrees to radians
  auto lat1 = startLatitude * std::numbers::pi / 180.0;
  auto lon1 = startLongitude * std::numbers::pi / 180.0;

  auto lat2 = endLatitude * std::numbers::pi / 180.0;
  auto lon2 = endLongitude * std::numbers::pi / 180.0;

  // radius of earth in metres
  auto r = 6378100;

  // P
  auto rho1 = r * std::cos(lat1);
  auto z1 = r * std::sin(lat1);
  auto x1 = rho1 * std::cos(lon1);
  auto y1 = rho1 * std::sin(lon1);

  // Q
  auto rho2 = r * std::cos(lat2);
  auto z2 = r * std::sin(lat2);
  auto x2 = rho2 * std::cos(lon2);
  auto y2 = rho2 * std::sin(lon2);

  // Dot product
  auto dot = (x1 * x2 + y1 * y2 + z1 * z2);
  auto cosTheta = dot / (r * r);
  auto theta = std::acos(cosTheta);

  // Distance in meters
  return r * theta;
}

/**
 * @private
 * @brief Calculates the geodetic heading WGS84 to true north represented as 0
 * and rotating around 360 degrees.
 * @param startLatitude The starting latitude coordinate.
 * @param startLongitude The starting longitude coordinate.
 * @param endLatitude The ending latitude coordinate.
 * @param endLongitude The ending longitude coordinate.
 * @returns The calculated heading.
 */
double _geodetic_heading(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) {
  // Get the initial data from our variables:
  auto lat1 = startLatitude * (std::numbers::pi / 180);
  auto lon1 = startLongitude * (std::numbers::pi  / 180);
  auto lat2 = endLatitude * (std::numbers::pi  / 180);
  auto lon2 = endLongitude * (std::numbers::pi  / 180);

  // Set up our calculations
  auto y = std::sin(lon2 - lon1) * std::cos(lat2);
  auto x = std::cos(lat1) * std::sin(lat2) -
      std::sin(lat1) * std::cos(lat2) * std::cos(lon2 - lon1);
  auto rtnval = std::atan2(y, x) * (180 / std::numbers::pi);
  rtnval = std::fmod((rtnval + 360), 360);
  return rtnval;
}

/**
 * @private
 * @brief Calculates the speed between two points in meters per second.
 * @param startMilliseconds The starting time in milliseconds.
 * @param startLatitude The starting latitude coordinate.
 * @param startLongitude The starting longitude coordinate.
 * @param endingMilliseconds The ending time in milliseconds.
 * @param endLatitude The ending latitude coordinate.
 * @param endLongitude The ending longitude coordinate.
 * @returns The calculated speed.
 */
double _geodetic_speed(double startMilliseconds, double startLatitude,
    double startLongitude, double endMilliseconds, double endLatitude,
    double endLongitude) {
  // Get the lat / lon for start / end positions
  auto distMeters = _geodetic_distance(startLatitude, startLongitude,
    endLatitude, endLongitude);

  auto timeS = (endMilliseconds - startMilliseconds) / 1000.0;
  return distMeters / timeS;
}

// ============================================================================
// [USE CASE DEFINITIONS] =====================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Async I/O Use Cases] ------------------------------------------------------
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// [Data Use Cases] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Data Use Cases] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [NPU Use Cases] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @brief A collection of Formula_t mathematical formula quickly execute
 * those formulas to arrive at the given calculated answer.
 * @param formula The identified Formula_t to execute.
 * @param arg1 The first parameter of the equation.
 * @param arg2 The next possible parameter of the equation.
 * @param arg3 The next possible parameter of the equation.
 * @param arg4 The next possible parameter of the equation.
 * @param arg5 The next possible parameter of the equation.
 * @param arg6 The next possible parameter of the equation.
 * @returns The double of the converted value or NAN if the Conversion_t was
 * not found.
 */
export double codemelted_math(
  CFormula_t formula, double arg1, double arg2 = NAN, double arg3 = NAN,
  double arg4 = NAN, double arg5 = NAN, double arg6 = NAN
) {
  switch (formula) {
    _CALC(CFormula_t::geodetic_distance, _geodetic_distance(arg1, arg2, arg3, arg4))
    _CALC(CFormula_t::geodetic_heading, _geodetic_distance(arg1, arg2, arg3, arg4))
    _CALC(CFormula_t::geodetic_speed, _geodetic_speed(arg1, arg2, arg3, arg4, arg5, arg6))
    _CALC(CFormula_t::temperature_celsius_to_fahrenheit, ((arg1 * (9/5)) + 32))
    _CALC(CFormula_t::temperature_celsius_to_kelvin, (arg1 + 273.15))
    _CALC(CFormula_t::temperature_fahrenheit_to_celsius, ((arg1 - 32) * (5 / 9)))
    _CALC(CFormula_t::temperature_fahrenheit_to_kelvin, ((arg1 - 32) * (5 / 9) + 273.15))
    _CALC(CFormula_t::temperature_kelvin_to_celsius, (arg1 - 273.15))
    _CALC(CFormula_t::temperature_kelvin_to_fahrenheit, ((arg1 - 273.15) * (9 / 5) + 32))
  }
  return NAN;
}

// ----------------------------------------------------------------------------
// [SDK Use Cases] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [User Interface Use Cases] -------------------------------------------------
// ----------------------------------------------------------------------------
