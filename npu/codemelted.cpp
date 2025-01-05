module;
/**
 * @file codemelted.cpp
 * @author Mark Shaffer
 * @date 2025-01-05
 * @version 0.0.1 <br />
 * - [0.0.2 / 2025-01-05]: Implemented the macros to allow for cross compiling
 * between a WASM file, C++ 20 included source file, and as a static library
 * for mac, windows, and linux. Also stubbed some other functions as I ponder
 * the NPU design.
 * - [0.0.1 / 2024-12-27]: Sets up the initial file construct to support
 * tooling and integrating with PWA modules.
 * @brief Serves as a software Numerical Processing Unit (NPU) to the
 * other codemelted modules. This module will contain all mathematical
 * calculations to leverage the power of C++ but will also provide
 * other mechanisms for running complicated tasks suited for C++ processing
 * via DLL or WASM compilation target.
 * @note Testing of this module will be handled by the other codemelted
 * modules which will provide the interfaces to consume this module.
 * @see <i>CodeMelted DEV | Modules:</i> https://developer.codemelted.com
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
    return calculate;                     \

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

// TBD: Functions to assist the public api

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
    temperature_celsius_to_fahrenheit, /**< °F = (°C x 9/5) + 32 */
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
      CFormula_t formula, double arg1
  ) {
    switch (formula) {
      _EXEC_FORMULA(temperature_celsius_to_fahrenheit, ((arg1 * (9/5)) + 32));
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
