@echo off
title codemelted CLI Setup
:: =============================================================================
:: @file Windows BAT script to install / uninstall the codemelted.ps1 script
:: to serve as the codemelted CLI terminal module within the pwsh terminal.
:: @license MIT License
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
:: [MAIN] ---------------------------------------------------------------------
:: ----------------------------------------------------------------------------
  echo ------------------------
  echo * codemelted CLI Setup *
  echo ------------------------
  echo This script will check for pwsh terminal installation, once
  echo installed, will install the codemelted CLI, then print out
  echo the codemelted CLI information. The secondary options are to
  echo update or uninstall the codemelted CLI. Once installed run in
  echo the pwsh terminal environment to gain access to the codemelted
  echo command.
  echo.
  echo 1. install
  echo 2. update
  echo 3. uninstall
  echo.

  set /p action="CHOOSE: "
  echo.
  if "%action%" == "1" (
    call :install
  ) else if "%action%" == "2" (
    call :update
  ) else if "%action%" == "3" (
    call :uninstall
  ) else (
    echo ERROR: Invalid selection made.
    echo.
    pause
    exit /b
  )
  echo.
  echo MESSAGE: codemelted CLI setup completed.
  echo.
  pause
  exit /b

:: ----------------------------------------------------------------------------
:: Installs the codemelted.ps1 file by first checking that pwsh is installed
:: then installing the codemelted.ps1 from Microsoft Repo, then finally
:: checking the --about and --help option of the CLI.
:: ----------------------------------------------------------------------------
:install
  echo MESSAGE: Now checking if pwsh terminal is installed.
  where pwsh > nul 2>&1
  if %ERRORLEVEL% neq 0 (
    echo.
    echo MESSAGE: pwsh terminal is not installed. Installing...
    echo.
    winget install -e --id Microsoft.PowerShell
  )

  echo.
  echo MESSAGE: pwsh terminal installed. Now checking if
  echo          codemelted CLI is installed.
  echo.

  pwsh -Command codemelted -Action --about > nul 2>&1
  if %ERRORLEVEL% neq 0 (
    echo.
    echo MESSAGE: codemelted CLI is not installed. Installing...
    echo.

  )
    :: TODO: Install the codemelted.ps1 from Microsoft website.
  echo.
  echo MESSAGE: codemelted CLI is now installed. Now gathering the current
  echo          codemelted CLI information.
  echo.
  pwsh -Command codemelted -Action --about
  pwsh -Command codemelted -Action --help
  exit /b

:: ----------------------------------------------------------------------------
:: Updates the codemelted CLI script file to the latest version from the
:: Microsoft repo.
:: ----------------------------------------------------------------------------
:update
  echo update
  exit /b

:: ----------------------------------------------------------------------------
:: Uninstalls the codemelted.ps1 script file but leaves pwsh installed.
:: ----------------------------------------------------------------------------
:uninstall
  echo uninstall
  exit /b

