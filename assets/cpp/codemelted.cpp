module;
/**
 * @file codemelted.cpp
 * @author Mark Shaffer
 * @date 2025-02-02
 * @version 0.0.0 <br />
 * @brief TBD
 * @see <i>CodeMelted DEV | Modules:</i> https://codemelted.com/developer
 * @see <i>WASM Use Cases:</i> https://webassembly.org/docs/use-cases/
 * @copyright 2024 Mark Shaffer. All Rights Reserved.
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

// Directives to disable warnings that are not a problem given the
// multi-targetted nature of the module.
#if defined(__clang__) && defined(__EMSCRIPTEN__) || defined(__wasm__)
  // This one deals with the re-use on EMSCRIPTEN_KEEPALIVE on struct
  // and enums. These are needed for exports of native libraries vs.
  // WASM itself. So this removes the warning when building WASM.
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wignored-attributes"
#elif defined(__GNUC__)
#elif defined(_MSC_VER)
#endif

#if defined(__EMSCRIPTEN__) || defined(__wasm__)
#include <emscripten.h>
#endif

#include <numbers>
#include <cmath>

// ----------------------------------------------------------------------------
// [MACRO DEFINITIONS] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @brief Something something star wars.
 */
#define CODEMELTED_NPU_API export
#if defined(__EMSCRIPTEN__) || defined(__wasm__)
  #undef CODEMELTED_NPU_API
  #define CODEMELTED_NPU_API EMSCRIPTEN_KEEPALIVE
#elif defined(_WIN32) || defined(_WIN64)
  #if defined(CODEMELTED_NPU_EXPORT)
    #undef CODEMELTED_NPU_API
    #define CODEMELTED_NPU_API __declspec(dllexport)
  #else
    #undef CODEMELTED_NPU_API
    #define CODEMELTED_NPU_API __declspec(dllimport)
  #endif
#elif defined(__linux__) || defined(__linux)   \
    || defined(__APPLE__) || defined(__MACH__)
  #if defined(CODEMELTED_NPU_EXPORT)
    #undef CODEMELTED_NPU_API
    #define CODEMELTED_NPU_API __attribute__((__visibility__("default")))
  #endif
#endif

/**
 * @brief MACRO that provides a fast integer lookup for the different
 * mathematical formulas to support the codemelted::math function.
 */
#define _EXEC_FORMULA(formula, calculate) \
  case formula:                           \
    return calculate;

// ---------------------------------------------------------------------------
// [MODULE DEFINITION] -------------------------------------------------------
// ---------------------------------------------------------------------------

/**
 * @brief something something star wars.
 */
export module codemelted_npu;

/**
 * @brief Something Something star wars.
 */
namespace codemelted {

// ----------------------------------------------------------------------------
// [Private API] --------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
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

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

  // --------------------------------------------------------------------------
  // [Data Definitions] -------------------------------------------------------
  // --------------------------------------------------------------------------

  CODEMELTED_NPU_API typedef enum {
    calculate_stats
  } CComputeRequest_t;


  CODEMELTED_NPU_API typedef struct {
    char _reserved[8];
    int size;
    CComputeRequest_t request;
  } CComputeHeader_t;

  /**
   * @brief Enumeration of different conversions supported by this module.
   */
  CODEMELTED_NPU_API typedef enum {
    geodetic_distance, /**< */
    geodetic_heading, /**< */
    geodetic_speed, /**< */
    temperature_celsius_to_fahrenheit, /**< °F = (°C x 9/5) + 32 */
    temperature_celsius_to_kelvin, /**< °C + 273.15 */
    temperature_fahrenheit_to_celsius, /**< (°F − 32) × 5/9 */
    temperature_fahrenheit_to_kelvin, /**< (°F − 32) × 5/9 + 273.15 */
    temperature_kelvin_to_celsius, /**< °K − 273.15 */
    temperature_kelvin_to_fahrenheit /**< (°K − 273.15) × 9/5 + 32 */
  } CFormula_t;

  // --------------------------------------------------------------------------
  // [Function Definitions] ---------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * @brief A collection of Formula_t mathematical formula quickly execute
   * those formulas to arrive at the given calculated answer.
   * @param formula The identified Formula_t to execute.
   * @param arg1 - The first parameter of the equation.
   * @returns The double of the converted value or NAN if the Conversion_t was
   * not found.
   */
  CODEMELTED_NPU_API double math(
      CFormula_t formula, double arg1, double arg2 = NAN, double arg3 = NAN,
      double arg4 = NAN, double arg5 = NAN, double arg6 = NAN
  ) {
    switch (formula) {
      _EXEC_FORMULA(geodetic_distance, _geodetic_distance(arg1, arg2, arg3, arg4))
      _EXEC_FORMULA(geodetic_heading, _geodetic_distance(arg1, arg2, arg3, arg4))
      _EXEC_FORMULA(geodetic_speed, _geodetic_speed(arg1, arg2, arg3, arg4, arg5, arg6))
      _EXEC_FORMULA(temperature_celsius_to_fahrenheit, ((arg1 * (9/5)) + 32))
      _EXEC_FORMULA(temperature_celsius_to_kelvin, (arg1 + 273.15))
      _EXEC_FORMULA(temperature_fahrenheit_to_celsius, ((arg1 - 32) * (5 / 9)))
      _EXEC_FORMULA(temperature_fahrenheit_to_kelvin, ((arg1 - 32) * (5 / 9) + 273.15))
      _EXEC_FORMULA(temperature_kelvin_to_celsius, (arg1 - 273.15))
      _EXEC_FORMULA(temperature_kelvin_to_fahrenheit, ((arg1 - 273.15) * (9 / 5) + 32))
    }
    return NAN;
  }

#ifdef __cplusplus
}
#endif

} // END codemelted

// Wrap up our disabling of warnings depending on the compiler and target of
// the module.
#if defined(__clang__)
  #pragma clang diagnostic pop
#elif defined(__GNUC__)
#elif defined(_MSC_VER)
#endif
