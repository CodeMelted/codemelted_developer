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

/// Defines the formulas supported by the module.
enum CMathFormula {
  /// Kilometers squared to meters squared
  area_km2_to_m2;
}

/// Internal extension to tie the formulas to the [CMathFormula] enumerated
/// values.
extension CMathFormulaExtension on CMathFormula {
  /// The mapping of the enumerated formulas to actual formulas.
  static final _data = {
    CMathFormula.area_km2_to_m2: (List<double> v) => v[0] * 1e+6,
  };

  /// Private method to support the module math method.
  double calculate(List<double> v) => _data[this]!(v);
}
