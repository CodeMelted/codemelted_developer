# 11.0 NPU Use Case

According to Wikipedia,

> A floating-point unit (FPU), numeric processing unit (NPU), colloquially math coprocessor, is a part of a computer system specially designed to carry out operations on floating-point numbers. Typical operations are addition, subtraction, multiplication, division, and square root.

The *NPU Use Case* will build upon this idea by setting up a collection of mathematical formulas for execution. These will range the gambit of typical formulas a developer may encounter. Furthermore, a compute capability will also exist to carry out complicated computations that involve more than a standard mathematical formula.

## 11.1 Acceptance Criteria

1. The *NPU Use Case* will support the execution of mathematical formulas by providing a selection of said formula and passing the arguments necessary to complete the calculation. Mismatched arguments will result in an exception. Failed calculations (i.e. square of negative number, etc.) will result in a NAN return.
2. The *NPU Use Case* will support the ability to compute (i.e. series of computations) and return the result. The communication method of this capability will be JSON compliant data for both the request and result of the run. Unknown requests will be handled as an exception.

## 11.2 SDK Notes

None.

## 11.3 Mathematical Formulas
