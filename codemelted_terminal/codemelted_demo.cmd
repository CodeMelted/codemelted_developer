@echo off
title codemelted
set VERSION=v0.0.0 [Last Modified 2024-10-16]
:: =============================================================================
:: MIT License
::
:: © 2024 Mark Shaffer. All Rights Reserved.
::
:: Permission is hereby granted, free of charge, to any person obtaining a
:: copy of this software and associated documentation files (the "Software"),
:: to deal in the Software without restriction, including without limitation
:: the rights to use, copy, modify, merge, publish, distribute, sublicense,
:: and/or sell copies of the Software, and to permit persons to whom the
:: Software is furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
:: THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
:: FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
:: DEALINGS IN THE SOFTWARE.
:: ============================================================================
:: [Main Implementation] ------------------------------------------------------
:: ----------------------------------------------------------------------------

:: Grab the use case to determine what use case we are running
set use_case=%1
if /i "%use_case%" equ "--about" (
  echo %VERSION%
) else if /i "%use_case%" equ "--async" (
  call :async %2
  goto :end_main
) else if /i "%use_case%" equ "--audio" (
  call :audio %2 %3
  goto :end_main
) else if /i "%use_case%" equ "--runtime" (
  call :runtime %2
  goto :end_main
) else (
  echo.
  echo ERROR: '%use_case%' is not a known use case.
  exit /b 1
)

:end_main
exit /b

:: ----------------------------------------------------------------------------
:: [Async IO Use Case] --------------------------------------------------------
:: ----------------------------------------------------------------------------

:async
  set function=%1
  if /i "%function%" equ "hardwareConcurrency" (
    echo %NUMBER_OF_PROCESSORS%
    set CODEMELTED_QUERIED_VALUE=%NUMBER_OF_PROCESSORS%
  ) else (
    echo ERROR: '%function%' function is not supported by async use case.
  )

  exit /b

:: typeperf "\Processor Information(_Total)\% Processor Utility" to get CPU%

:: ----------------------------------------------------------------------------
:: [Audio IO Use Case] --------------------------------------------------------
:: ----------------------------------------------------------------------------

:audio
  set action=%1
  if /i "%action%" equ "beep" (
    set /a count=%2 + 0
    :audio_loop
      echo 0Y | choice > nul
      set /a count=count-1
      if %count% gtr 0 goto :audio_loop
      goto :end_audio
  ) else (
    echo ERROR: '%function%' function is not supported by audio use case.
  )
:end_audio
exit /b

:: ----------------------------------------------------------------------------
:: [Console IO Use Case] ------------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Database IO Use Case] -----------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Disk IO Use Case] ---------------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [Firebase IO Use Case] -----------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Game IO Use Case] --------------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Hardware IO Use Case] -----------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [JSON IO Use Case] ---------------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [Logger IO Use Case] -------------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [Math IO Use Case] ---------------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [Memory IO Use Case] -------------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Network IO Use Case] ------------------------------------------------------
:: ----------------------------------------------------------------------------


:: ----------------------------------------------------------------------------
:: [Runtime IO Use Case] ------------------------------------------------------
:: ----------------------------------------------------------------------------

:runtime
  set function=%1
  echo.
  echo runtime called %function%

:runtime_end
exit /b

:: ----------------------------------------------------------------------------
:: [Storage IO Use Case] ------------------------------------------------------
:: ----------------------------------------------------------------------------

:: ----------------------------------------------------------------------------
:: [User Interface IO Use Case] -----------------------------------------------
:: ----------------------------------------------------------------------------




