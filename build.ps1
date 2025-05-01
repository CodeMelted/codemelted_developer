#!/usr/bin/pwsh
# =============================================================================
# MIT License
#
# © 2024 Mark Shaffer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# =============================================================================

[string]$GEN_HTML_PERL_SCRIPT = "/ProgramData/chocolatey/lib/lcov/tools/bin/genhtml"

function build([string[]]$params) {
  # Helper function to format message output from the build script.
  function message([string]$msg) {
    Write-Host
    Write-Host "MESSAGE: $msg"
    Write-Host
  }

  # Build / test the codemelted.ps1 module.
  function build_dev([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    Set-Location $PSScriptRoot/codemelted_dev

    mdbook clean

    message "Now building the codemelted_dev module documentation."

    if (-not $isTestOnly) {
      mdbook build
    }

    Set-Location $PSScriptRoot
    message "codemelted_dev module completed."
  }

  # Build / test the codemelted.dart module.
  function build_flutter([bool]$isTestOnly = $false) {
    # Go test our module
    Set-Location $PSScriptRoot/codemelted_flutter
    message "Now testing the codemelted.dart module"

    Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
    flutter test --platform chrome

    message "codemelted.dart module testing completed."

    if (-not $isTestOnly) {
      # Now build our module items.
      message "Now building the codemelted.dart module documentation"

      message "Now generating dart doc"
      dart doc --output "docs"
      Copy-Item -Path CHANGELOG.md -Destination docs -Force

      [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
      $htmlData = $htmlData.Replace('<a href="codemelted">','<a href="codemelted/index.html">')
      $htmlData | Out-File docs/index.html -Force

      $files = Get-ChildItem -Path docs/codemelted/*.html, docs/codemelted/*/*.html -Exclude "*sidebar*"
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace('<a href="../codemelted">','<a href="../codemelted/index.html">')
        $htmlData = $htmlData.Replace('<a href="../codemelted">codemelted.dart</a>','<a href="../codemelted/index.html">codemelted.dart</a>')
        $htmlData | Out-File $file.FullName -Force
      }

      message "codemelted.dart module documentation completed."
    }
    Set-Location $PSScriptRoot
  }

  # Build / test the CodeMelted JS Project.
  function build_js([bool]$isTestOnly = $false) {
    # Go test our module
    Set-Location $PSScriptRoot/codemelted_js
    message "Now testing the codemelted.js module"
    Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore
    New-Item -Path "docs" -ItemType Directory

    message "Now Running Deno tests"
    deno test --allow-env --allow-net --allow-read --allow-sys --allow-write --coverage=coverage --no-config codemelted_test.ts
    deno coverage coverage --lcov > coverage/lcov.info

    if ($IsLinux -or $IsMacOS) {
      genhtml -o coverage --ignore-errors unused,inconsistent --dark-mode coverage/lcov.info
    }
    else {
      $exists = Test-Path -Path $GEN_HTML_PERL_SCRIPT -PathType Leaf
      if ($exists) {
        perl $GEN_HTML_PERL_SCRIPT -o coverage coverage/lcov.info
      }
      else {
        Write-Host "WARNING: genhtml not installed for windows. Run " +
        "'choco install lcov' for pwsh terminal as Admin to install it."
      }
    }
    Move-Item -Path coverage -Destination docs -Force

    if (-not $isTestOnly) {
      message "Now generating the jsdoc"
      jsdoc ./codemelted.js --readme ./README.md --destination docs

      # Some final moves to complete the module documentation.
      Copy-Item jsdoc-default.css -Destination docs/styles
      Copy-Item codemelted.js -Destination docs
      Copy-Item codemelted_test.html -Destination docs

      message "codemelted.js module documentation completed."
    }

    Set-Location $PSScriptRoot
  }

  # Build / test the Raspberry Pi Project.
  function build_pi([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    Set-Location $PSScriptRoot/codemelted_pi
    message "Now building the Raspberry Pi Project documentation."

    mdbook clean

    if (-not $isTestOnly) {
      mdbook build
    }

    Set-Location $PSScriptRoot
    message "Raspberry Pi Project module documentation completed."
  }

  # Build / test the codemelted.ps1 module.
  function build_pwsh([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    Set-Location $PSScriptRoot/codemelted_pwsh

    mdbook clean

    message "Now building the codemelted.ps1 module documentation."

    if (-not $isTestOnly) {
      mdbook build
    }

    Set-Location $PSScriptRoot
    message "codemelted.ps1 module completed."
  }

  # Build / test the CodeMelted Rust Project.
  function build_rust([bool]$isTestOnly = $false) {
    # Go test our module
    Set-Location $PSScriptRoot/codemelted_rust
    message "Now testing the codemelted.rs module"
    cargo test
    if (-not $isTestingOnly) {
      message "Now building the codemelted.rs documentation"
      cargo clean
      cargo doc --no-deps --lib
    }

    Set-Location $PSScriptRoot
    message "codemelted.rs module completed."
  }

  # ---------------------------------------------------------------------------
  # [Main Execution] ----------------------------------------------------------
  # ---------------------------------------------------------------------------

  switch ($params[0]) {
    "--test" {
      build_dev $true
      build_flutter $true
      build_js $true
      build_pi $true
      build_pwsh $true
      build_rust $true
    }
    "--build" {
      # Build and test each of the modules.
      build_dev $false
      build_flutter $false
      build_js $false
      build_pi $false
      build_pwsh $false
      build_rust $false

      # Now go move all the resources
      Remove-Item -Path docs -Force -Recurse -ErrorAction SilentlyContinue
      New-Item -Path docs/codemelted_dev -ItemType Directory
      New-Item -Path docs/codemelted_flutter -ItemType Directory
      New-Item -Path docs/codemelted_js -ItemType Directory
      New-Item -Path docs/codemelted_pi -ItemType Directory
      New-Item -Path docs/codemelted_pwsh -ItemType Directory
      New-Item -Path docs/codemelted_rust -ItemType Directory
      New-Item -Path docs/design_notes -ItemType Directory
      Copy-Item -Path codemelted_dev/book/* -Destination docs/codemelted_dev -Force -Recurse
      Copy-Item -Path codemelted_flutter/docs/* -Destination docs/codemelted_flutter -Force -Recurse
      Copy-Item -Path codemelted_js/docs/* -Destination docs/codemelted_js -Force -Recurse
      Copy-Item -Path codemelted_pi/book/* -Destination docs/codemelted_pi -Force -Recurse
      Copy-Item -Path codemelted_pwsh/book/* -Destination docs/codemelted_pwsh -Force -Recurse
      Copy-Item -Path codemelted_rust/target/doc/* -Destination docs/codemelted_rust -Force -Recurse
      Copy-Item -Path index.html -Destination docs -Force -Recurse
      Copy-Item -Path design_notes/* -Destination docs/design_notes -Force -Recurse
    }
    "--deploy" {
      Write-Host "MESSAGE: Now uploading codemelted.com/developer content.";
      Move-Item -Path docs -Destination developer -ErrorAction Stop
      Compress-Archive -Path developer -DestinationPath developer.zip -Force
      $hostService = $env:CODEMELTED_USER_AND_IP + $env:CODEMELTED_HOME
      scp developer.zip $hostService
      ssh $env:CODEMELTED_USER_AND_IP
      Remove-Item -Path developer.zip
      Remove-Item -Path developer -Recurse -Force
      Set-Location $PSScriptRoot
      Write-Host "MESSAGE: Upload completed.";
     }
    "--deploy-codemelted-com" {
      Write-Host "MESSAGE: Now deploying codemelted_com support items."
      Set-Location $PSScriptRoot/codemelted_com
      Compress-Archive -Path assets -DestinationPath assets.zip -Force
      $hostService = $env:CODEMELTED_USER_AND_IP + $env:CODEMELTED_HOME
      scp assets.zip $hostService
      ssh $env:CODEMELTED_USER_AND_IP
      Remove-Item -Path assets.zip
      Set-Location $PSScriptRoot
      Write-Host "MESSAGE: codemelted_com upload completed.";
    }
    "--publish-script" {
      Write-Host "MESSAGE: Now publishing the codemelted.ps1 CLI module"

      Publish-Script -Path ./assets/pwsh/codemelted.ps1 -NugetAPIKey $env:PWSH_PUBLISH_KEY -Verbose
      Set-Location $PSScriptRoot

      Write-Host "MESSAGE: Publishing completed."
     }
    default { Write-Host "ERROR: Invalid parameter specified." }
  }
}
build $args