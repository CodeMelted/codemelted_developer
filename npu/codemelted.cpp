/**
 * @file codemelted.cpp
 * @author Mark Shaffer
 * @date 2024-12-16
 * @version 0.0.1 <br />
 * - [0.0.1 / 2024-12-16]: Sets up the initial file construct to support
 * tooling and integrating with the other modules.
 * @brief Serves as a software Numerical Processing Unit (NPU) to the
 * other codemelted modules. This module will contain all mathematical
 * calculations to leverage the power of C++ but will also provide
 * other mechanisms for running complicated tasks suited for C++ processing
 * via DLL or WASM compilation target.
 * @note Testing of this module will be handled by the other codemelted
 * modules which will provide the interfaces to consume this module.
 * @see <i>CodeMelted Developer:</i> https://codemelted.com/developer/
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

#include <emscripten.h>
#include <cmath>

// ----------------------------------------------------------------------------
// [MACROS] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @brief MACRO that provides a fast integer lookup for the different
 * mathematical formulas to support the cm_math function.
 */
#define _EXEC_FORMULA(formula, calculate) \
  case formula:                            \
    return calculate;

// ----------------------------------------------------------------------------
// [DATA DEFINITION] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @brief Enumeration of different conversions supported by this module.
 */
typedef enum {
  temperature_celsius_to_fahrenheit, /**< Converts celsius to fahrenheit. */
} Formula_t;

// ----------------------------------------------------------------------------
// [MODULE DEFINITION] --------------------------------------------------------
// ----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief A collection of Formula_t mathematical formula quickly execute
 * those formulas to arrive at the given calculated answer.
 * @param formula The identified Formula_t to execute.
 * @param arg1 - The first parameter of the equation.
 * @returns The double of the converted value or NAN if the Conversion_t was
 * not found.
 */
EMSCRIPTEN_KEEPALIVE double cm_math(
    Formula_t formula, double arg1
) {
  switch (formula) {
    _EXEC_FORMULA(temperature_celsius_to_fahrenheit, ((arg1 * (9/5)) + 32));
  }
  return NAN;
}

#ifdef __cplusplus
}
#endif
