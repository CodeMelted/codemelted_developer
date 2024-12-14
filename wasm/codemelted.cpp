/**
 * @file codemelted.cpp
 * @author Mark Shaffer
 * @date dd mmm yyyy
 * @version X.Y.Z
 * @brief Is a WASM module to provide an embeddable speedy engine for the
 * codemelted modules. This will contain all math calculations to leverage
 * the power of C++ but will also provide mechanisms for running complicated
 * tasks from those modules as more is learned about what WASM can do. For now
 * all math will be handled by this module and the other modules will hook into
 * it.
 * @see <i>CodeMelted Developer:</i> https://codemelted.com/developer/
 * @see <i>WASM Use Cases:</i> https://webassembly.org/docs/use-cases/
 *
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
 * @brief MACRO that provides a fast integer lookup for the different formulas
 * of the codemelted_math() function. So repetitive but from the research the
 * fastest way to get quick mathematical executions from the module.
 */
#define _EXEC_FORMULA(formula, calculate) \
  case formula:                           \
    return calculate;

// ----------------------------------------------------------------------------
// [DATA DEFINITION] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @brief Enumeration of different formulas collected and accessible via the
 * codemelted_math function.
 */
typedef enum {
  temperature_celsius_to_fahrenheit, /**< Converts celsius to fahrenheit. */
} MathFormula_t;

// ----------------------------------------------------------------------------
// [MODULE DEFINITION] --------------------------------------------------------
// ----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief A collection of MathFormula_t calculations quickly accessible for
 * the fastest execution time for performing the calculations and returning
 * the most accurate result.
 * @param formula The identified MathFormula_t to execute.
 * @param arg1 - A double required for the equation.
 * @param arg2 - A double for a second parameter in a equation if required.
 * @returns The calculated double answer based on the specified args and
 * chosen formula. NAN returned if an error encountered during the
 * calculation.
 */
EMSCRIPTEN_KEEPALIVE double codemelted_math(
    MathFormula_t formula, double arg1,
    double arg2 = NAN
) {
  switch (formula) {
    _EXEC_FORMULA(temperature_celsius_to_fahrenheit, (arg1));
  }
  return NAN;
}

#ifdef __cplusplus
}
#endif
