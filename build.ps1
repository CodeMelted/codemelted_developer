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

[string]$ogTemplate = @"
 <!-- Open Graph Settings -->
<meta property="og:type" content="website">
<meta property="og:title" content="[TITLE]">
<meta property="og:site_name" content="CodeMelted DEV">
<meta property="og:image" content="https://codemelted.com/assets/images/logo-codemelted-developer.png">
<meta property="og:image:height" content="100px">
<meta property="og:image:width" content="100px">
"@

[string]$footerTemplate = @"
<!-- Links to main domain assets for embedding this widget code into different configurations -->
<codemelted-navigation></codemelted-navigation>
<script src="https://codemelted.com/services/js/codemelted_navigation.js" defer></script>
<style>
    .content-container {
      overflow: auto;
      position: fixed;
      top: 0px;
      left: 0px;
      right: 0px;
      bottom: 75px;
    }
    footer {
      margin-bottom: 75px;
    }

    /* Specific to rust updates for footer */
    .sidebar {
      margin-bottom: 75px;
    }

    main {
      margin-bottom: 75px;
    }

    @media print {
      .content-container {
        position: relative;
      }
      header {
        display: none;
      }
      footer {
        display: none;
      }
    }
</style>
"@

[string]$htmlTemplate = @"
<!DOCTYPE html>
<html lang="en"><head>
  <title>[TITLE]</title>
  <meta charset="UTF-8">
  <meta name="description" content="[DESCRIPTION]">
  <meta name="keywords" content="[KEYWORDS]">
  <meta name="author" content="Mark Shaffer">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- Open Graph Settings -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="[TITLE]">
  <meta property="og:description" content="[DESCRIPTION]">
  <meta property="og:site_name" content="CodeMelted DEV">
  <meta property="og:image" content="https://codemelted.com/assets/images/logo-codemelted-developer.png">
  <meta property="og:image:height" content="100px">
  <meta property="og:image:width" content="100px">
  <link rel="stylesheet" href="https://codemelted.com/assets/css/developer-theme.css">
  <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png">
  <style>
    .content-container {
      overflow: auto;
      position: fixed;
      top: 0px;
      left: 0px;
      right: 0px;
      bottom: 75px;
    }
    .content-main {
      max-width: 47em;
      margin: auto;
      padding: 0.6250em;
    }

    @media print {
      .content-container {
        position: relative;
      }
    }
  </style>
</head><body>
  <div class="content-container">
    <div class="content-main">
      [CONTENT]
    </div>
  </div>

  [FOOTER_TEMPLATE]
</body></html>
"@

function build([string[]]$params) {
  # Utility method to support extracting information from the markdown
  # to populate the templates.
  function extract([string]$key, [string]$data) {
    [string]$value = $data.Split($key)[1]
    $value = $value.Split("`n")[0].Trim()
    return $value
  }

  # Helper function to format message output from the build script.
  function message([string]$msg) {
    Write-Host
    Write-Host "MESSAGE: $msg"
    Write-Host
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

      # Fix the title
      [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | Flutter Module")
      [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
      $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
      $htmlData = $htmlData.Replace("../README.md", "../index.html")
      $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
      $htmlData = $htmlData.Replace("margin-bottom: 75px;", "margin-bottom: 0;")
      $htmlData = $htmlData.Replace('<a href="codemelted">','<a href="codemelted/index.html">')
      $htmlData | Out-File docs/index.html -Force

      $files = Get-ChildItem -Path docs/codemelted/*.html, docs/codemelted/*/*.html -Exclude "*sidebar*"
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
        $htmlData = $htmlData.Replace("margin-bottom: 75px;", "margin-bottom: 0;")
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

      [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | JS Module")
      $files = Get-ChildItem -Path docs/*.html
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace("../README.md", "../index.html")
        $htmlData = $htmlData.Replace("</body>", "`n$footerTemplate</body>")
        $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
        $htmlData | Out-File $file.FullName -Force
      }

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

    Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
    New-Item -Path docs -ItemType Directory -ErrorAction Ignore
    Copy-Item -Path assets -Destination docs -Recurse -ErrorAction Ignore

    $readme = ConvertFrom-Markdown -Path README.md
    $title = extract "TITLE:" $readme.Html
    $keywords = extract "KEYWORDS:" $readme.Html
    $description = extract "DESCRIPTION:" $readme.Html
    $html = $htmlTemplate
    $html = $html.Replace("[TITLE]", $title)
    $html = $html.Replace("[DESCRIPTION]", $description)
    $html = $html.Replace("[KEYWORDS]", $keywords)
    $html = $html.Replace("[CONTENT]", $readme.Html)
    $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
    $html = $html.Replace("../README.md", "../index.html")
    $html | Out-File docs/index.html -Force

    Set-Location $PSScriptRoot
    message "Raspberry Pi Project module documentation completed."
  }

  # Build / test the codemelted.ps1 module.
  function build_pwsh([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    Set-Location $PSScriptRoot/codemelted_pwsh
    message "Now building the codemelted.ps1 module documentation."

    Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
    New-Item -Path docs -ItemType Directory -ErrorAction Ignore
    Copy-Item -Path assets -Destination docs -Recurse -ErrorAction Ignore

    $readme = ConvertFrom-Markdown -Path README.md
    $title = extract "TITLE:" $readme.Html
    $keywords = extract "KEYWORDS:" $readme.Html
    $description = extract "DESCRIPTION:" $readme.Html
    $html = $htmlTemplate
    $html = $html.Replace("[TITLE]", $title)
    $html = $html.Replace("[DESCRIPTION]", $description)
    $html = $html.Replace("[KEYWORDS]", $keywords)
    $html = $html.Replace("[CONTENT]", $readme.Html)
    $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
    $html = $html.Replace("../README.md", "../index.html")
    $html | Out-File docs/index.html -Force

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
      cargo doc --no-deps
      Set-Location $PSScriptRoot/codemelted_rust/target/doc
      $files = Get-ChildItem -Path codemelted/*.html, src/codemelted/*.html
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace("../README.md", "../../index.html")
        $htmlData = $htmlData.Replace("</body>", "`n$footerTemplate</body>")
        $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
        $htmlData | Out-File $file.FullName -Force
      }
    }

    Set-Location $PSScriptRoot
    message "codemelted.rs module completed."
  }

  # ---------------------------------------------------------------------------
  # [Main Execution] ----------------------------------------------------------
  # ---------------------------------------------------------------------------

  switch ($params[0]) {
    "--test" {
      build_flutter $true
      build_js $true
      build_pi $true
      build_pwsh $true
      build_rust $true
    }
    "--build" {
      # Build and test each of the modules.
      build_flutter $false
      build_js $false
      build_pi $false
      build_pwsh $false
      build_rust $false

      # Now go move all the resources
      Remove-Item -Path docs -Force -Recurse
      New-Item -Path docs/codemelted_flutter -ItemType Directory
      New-Item -Path docs/codemelted_js -ItemType Directory
      New-Item -Path docs/codemelted_pi -ItemType Directory
      New-Item -Path docs/codemelted_pwsh -ItemType Directory
      New-Item -Path docs/codemelted_rust -ItemType Directory
      Copy-Item -Path codemelted_flutter/docs/* -Destination docs/codemelted_flutter -Force -Recurse
      Copy-Item -Path codemelted_js/docs/* -Destination docs/codemelted_js -Force -Recurse
      Copy-Item -Path codemelted_pi/docs/* -Destination docs/codemelted_pi -Force -Recurse
      Copy-Item -Path codemelted_pwsh/docs/* -Destination docs/codemelted_pwsh -Force -Recurse
      Copy-Item -Path codemelted_rust/target/doc/* -Destination docs/codemelted_rust -Force -Recurse
      Copy-Item -Path index.html -Destination docs -Force -Recurse
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