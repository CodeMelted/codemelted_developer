module;
/**
 * @file codemelted.cpp
 * @author Mark Shaffer
 * @date 2025-02-09
 * @version 0.0.1 <br />
 * 0.0.1 2025-02-09: Updated the module to support the toolchains of building
 * a WASM / JS module for usage on web pages and to support the current
 * codemelted.dart beta module bindings.
 * @brief The codemelted.cpp is a C++ 20 module that supports three targets
 * of compilation. One as a WASM module mixing C++ and JS bindings accessible
 * in a web page. The secondary compilation target is as a static library.
 * This is to support the codemelted.ps1 module. The final is as an included
 * C++20 module in a developer's toolchain. This is for module bound
 * namespaced functions to support native C++ application development.
 * @note Set compiler directive of __CODEMELTED_TARGET_WASM__ for wasm
 * compile, __CODEMELTED_TARGET_LIB__ for dynamic library build. If simply
 * including the C++ 20 module into your build toolchain, no directive is
 * needed.
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

// ============================================================================
// [INCLUDES] =================================================================
// ============================================================================

#if defined(__CODEMELTED_TARGET_WASM__)
  #include <emscripten.h>
#endif

#include <numbers>
#include <cmath>

// ============================================================================
// [MACRO DEFINITIONS] ========================================================
// ============================================================================

/**
 * @brief Sets up the CODEMELTED_API that based on the set compilation target
 * will properly setup the public export for the C++ functions.
 */
#define CODEMELTED_API
#if defined(__CODEMELTED_TARGET_WASM__)
  #undef CODEMELTED_API
  #define CODEMELTED_API EMSCRIPTEN_KEEPALIVE
#elif defined(__CODEMELTED_TARGET_LIB__)
  #undef CODEMELTED_API
  #if defined(_WIN32) || defined(_WIN64)
    #define CODEMELTED_API __declspec(dllexport)
  #else
    #define CODEMELTED_API __attribute__((__visibility__("default")))
  #endif
#else
  #undef CODEMELTED_API
  #define CODEMELTED_API export
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
export module codemelted;

/**
 * @brief Something Something star wars.
 */
namespace codemelted {

// ----------------------------------------------------------------------------
// [Private API] --------------------------------------------------------------
// ----------------------------------------------------------------------------

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

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Enumeration of different conversions supported by this module.
 */
CODEMELTED_API typedef enum {
  geodetic_distance, /**< Distance in meters between two WGS84 points */
  geodetic_heading, /**< Heading in °N true North 0 - 359. */
  geodetic_speed, /**< Speed in meters per second between two WGS84 points. */
  temperature_celsius_to_fahrenheit, /**< °F = (°C x 9/5) + 32 */
  temperature_celsius_to_kelvin, /**< °C + 273.15 */
  temperature_fahrenheit_to_celsius, /**< (°F − 32) × 5/9 */
  temperature_fahrenheit_to_kelvin, /**< (°F − 32) × 5/9 + 273.15 */
  temperature_kelvin_to_celsius, /**< °K − 273.15 */
  temperature_kelvin_to_fahrenheit /**< (°K − 273.15) × 9/5 + 32 */
} CFormula_t;

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
CODEMELTED_API double math(
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

// ============================================================================
// [JS WASM BINDINGS] =========================================================
// ============================================================================

#if defined(__CODEMELTED_TARGET_WASM__)

/**
 * @name setup_codemelted_js_module
 * @brief Sets up a codemelted global object to provide for configuration /
 * utility methods to be available to the codemelted_XXX use case functions.
 */
EM_JS(void, setup_codemelted_js_module, (), {
  // If we are already defined, then don't redefine ourselves.
  if (globalThis["codemelted"]) {
    return;
  }

  // Setup our codemelted global object to facilitate JS to C++
  // communications along with setting up a way of capturing values
  // accessible by both sides of the application.
  window["codemelted"] = (function() {
    // PRIVATE MODULE MEMBERS


    // PUBLIC API
    return {
      /**
       * Will try a synchronous transaction within the module definition.
       * @private
       * @returns {any | undefined}
       * @throws {SyntaxError} if an unexpected module error occurs.
       */
      trySyncTransaction: function(func) {
        try {
          return func();
        } catch (err) {
          let moduleError = new SyntaxError();
          moduleError.stack = err?.stack;
          moduleError.message = `ModuleError: ${err?.message}`;
          throw moduleError;
        }
      },
    };
  })();
});

/**
 * @name setup_runtime_uc_functions
 * @brief Something Something star wars.
 */
EM_JS(void, setup_runtime_uc_functions, (), {
  function codemelted_is_pwa() {
    return codemelted.trySyncTransaction(() => {
      return globalThis.matchMedia('(display-mode: standalone)').matches
       || ('standalone' in navigator && (navigator).standalone === true);
    });
  }

  function codemelted_is_touch_enabled() {
    return codemelted.trySyncTransaction(() => {
      return globalThis.navigator.maxTouchPoints > 0;
    });
  }

  /**
   * Loads a specified resource into a new or existing browsing context
   * (that is, a tab, a window, or an iframe) under a specified name. These
   * are based on the different schema supported protocol items.
   * @param {object} params The named parameters.
   * @param {string} params.schema Either "file:", "http://",
   * "https://", "mailto:", "tel:", or "sms:".
   * @param {boolean} [params.popupWindow = false] true to open a new
   * popup browser window. false to utilize the _target for browser
   * behavior.
   * @param {string} [params.mailtoParams] Object to assist in the
   * mailto: schema URL construction.
   * @param {string} [params.url] The url to utilize with the schema.
   * @param {string} [params.target = "_blank"] The target to utilize when
   * opening the schema. Only valid when not utilizing popupWindow.
   * @param {number} [params.width] The width to open the window with.
   * @param {number} [params.height] The height to open the window with.
   * @returns {void}
   */
  function codemelted_open_schema({
    schema,
    popupWindow = false,
    mailtoParams, url,
    target = "_blank",
    width,
    height
  }) {
    codemelted.trySyncTransaction(() => {
      let urlToLaunch = "";
      if (schema === "file:" ||
          schema === "http://" ||
          schema === "https://" ||
          schema === "sms:" ||
          schema === "tel:") {
        urlToLaunch = `${schema}${url}`;
      } else if (schema === "mailto:") {
        urlToLaunch = mailtoParams != null
            ? `mailto:${mailtoParams.toString()}`
            : `mailto:${url}`;
      } else {
        throw new SyntaxError("Invalid schema specified");
      }

      let rtnval = null;
      if (popupWindow) {
        const w = width ?? 900.0;
        const h = height ?? 600.0;
        const top = (globalThis.screen.height - h) / 2;
        const left = (globalThis.screen.width - w) / 2;
        const settings = "toolbar=no, location=no, " +
            "directories=no, status=no, menubar=no, " +
            "scrollbars=no, resizable=yes, copyhistory=no, " +
            `width=${w}, height=${h}, top=${top}, left=${left}`;
        globalThis.open(
          urlToLaunch,
          "_blank",
          settings,
        );
      } else {
        globalThis.open(urlToLaunch, target);
      }
    });
  }

  // Now bind the functions
  globalThis["codemelted_is_pwa"] = codemelted_is_pwa;
  globalThis["codemelted_is_touch_enabled"] = codemelted_is_touch_enabled;
  globalThis["codemelted_open_schema"] = codemelted_open_schema;
});

/**
 * @brief Calls the series of setup functions to configure the C++ / JS
 * bindings.
 * @returns always 0.
 */
int main(void) {
  setup_codemelted_js_module();
  setup_runtime_uc_functions();
  return 0;
}

#endif

// Wrap up our disabling of warnings depending on the compiler and target of
// the module.
#if defined(__clang__)
  #pragma clang diagnostic pop
#elif defined(__GNUC__)
#elif defined(_MSC_VER)
#endif
