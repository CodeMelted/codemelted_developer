#!/usr/local/bin/pwsh
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

[string]$ogTemplate = @"
 <!-- Open Graph Settings -->
<meta property="og:type" content="website">
<meta property="og:title" content="[TITLE]">
<meta property="og:site_name" content="CodeMelted DEV">
<meta property="og:image" content="https://codemelted.com/assets/images/logo-codemelted-developer.png">
<meta property="og:image:height" content="100px">
<meta property="og:image:width" content="100px">
"@

[string]$htmlNavTemplate = @"
<style>
  .codemelted-dev-nav {
    display: grid;
    grid-template-columns: auto auto auto auto;
    width: 100%;
    max-width: 375px;
    border: none;
    border-top: 5px solid black;
    border-bottom: 5px solid black;
    margin: 0;
    padding: 0;
  }
  .codemelted-dev-nav a {
    padding: 5px;
    text-decoration: none;
    cursor: pointer;
  }
  .codemelted-dev-nav a:hover {
    background-color: maroon;
  }
  .codemelted-dev-nav img {
    height: 50px;
  }
</style>
<div class="codemelted-dev-nav">
  <a title="Flutter Module" href="https://codemelted.com/developer/"><img src="https://codemelted.com/assets/images/icon-codemelted-flutter.png" /></a>
  <a title="C++ Module" href="https://codemelted.com/developer/assets/cpp"><img src="https://codemelted.com/assets/images/icon-codemelted-wasm.png" /></a>
  <a title="pwsh Module" href="https://codemelted.com/developer/assets/pwsh" ><img src="https://codemelted.com/assets/images/icon-codemelted-pwsh.png" /></a>
  <a title="Pi" href="https://codemelted.com/developer/assets/pi"><img src="https://codemelted.com/assets/images/icon-codemelted-pi.png" /></a>
</div>
"@

[string]$footerTemplate = @"
<!-- Links to main domain assets for embedding this widget code into different configurations -->
<codemelted-navigation></codemelted-navigation>
<script src="https://codemelted.com/assets/js/codemelted_navigation.js" defer></script>
<style>
div.contents {
  margin-bottom: 65px;
}
.content-main {
  margin-bottom: 65px;
}
footer {
  margin-bottom: 85px;
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
    .main-content {
      margin-bottom: 65px;
    }
    footer {
      margin-bottom: 85px;
    }
  </style>
</head><body><div class="content-main">
  [CONTENT]
  [FOOTER_TEMPLATE]
</div></body></html>
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

  # Build / test the codemelted.cpp module.
  function build_cpp([bool]$isTestOnly = $false) {
    message "Compiling codemelted.cpp WASM Module"
    Set-Location $PSScriptRoot/assets/cpp
    Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore
    New-Item -Path "docs" -ItemType Directory

    emcc --std=c++20 codemelted.cpp -o codemelted.js
    Copy-Item -Path codemelted.wasm -Destination docs/codemelted.wasm -Force
    Move-Item -Path codemelted.wasm -Destination $PSScriptRoot/test -Force
    Copy-Item -Path codemelted.js -Destination docs/codemelted.js -Force
    Move-Item -Path codemelted.js -Destination $PSScriptRoot/test -Force

    if (-not $isTestOnly) {
      message "Now documenting codemelted.cpp module."
      doxygen doxygen.cfg
      [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | NPU Module")
      [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
      $htmlData = $htmlData.Replace("/></a><br  />", "/></a><br  />`n$htmlNavTemplate")
      $htmlData = $htmlData.Replace("README.md", "index.html")
      $htmlData = $htmlData.Replace("</head>", '    <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png"></head>')
      $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
      $htmlData = $htmlData.Replace("</body>", "<p><br /><br /><br /><br /><br /></p><p><br /><br /><br /><br /><br /></p>`n$footerTemplate`n</body>")
      $htmlData | Out-File docs/index.html -Force

      $files = Get-ChildItem -Path docs/*.html -Exclude "index.html"
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace("</head>", '    <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png"></head>')
        $htmlData = $htmlData.Replace("/></a><br  />", "/></a><br  />`n$htmlNavTemplate")
        $htmlData = $htmlData.Replace("</body>", "<p><br /><br /><br /><br /><br /></p><p><br /><br /><br /><br /><br /></p>`n$footerTemplate`n</body>")
        $htmlData | Out-File $file.FullName -Force
      }

      [string]$htmlData = Get-Content -Path "docs/navtree.css" -Raw
      $htmlData = $htmlData.Replace("overflow:auto", "overflow:display")
      $htmlData | Out-File docs/navtree.css -Force

      Set-Location $PSScriptRoot
      message "codemelted.cpp module documentation completed."
    }
  }

  # Build / test the codemelted.dart module.
  function build_flutter([bool]$isTestOnly = $false) {
    # Go test our module
    Set-Location $PSScriptRoot
    message "Now testing the codemelted.dart module"

    Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
    flutter test --platform chrome

    message "codemelted.dart module testing completed."

    if (-not $isTestOnly) {
      # Now build our module items.
      message "Now building the codemelted.dart module documentation"
      Set-Location $PSScriptRoot

      message "Now generating dart doc"
      dart doc --output "docs"
      Copy-Item -Path CHANGELOG.md -Destination docs -Force

      # Fix the title
      [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | Flutter Module")
      [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
      $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
      $htmlData = $htmlData.Replace("codemelted_developer - Dart API docs", "CodeMelted DEV | Flutter Module")
      $htmlData = $htmlData.Replace('<link rel="icon" href="static-assets/favicon.png?v1">', '<link rel="icon" href="https://codemelted.com/favicon.png">')
      $htmlData = $htmlData.Replace(".png`"><br>", ".png`"><br>`n$htmlNavTemplate")
      $htmlData = $htmlData.Replace("README.md", "index.html")
      $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
      $htmlData | Out-File docs/index.html -Force

      $files = Get-ChildItem -Path docs/codemelted/*.html, docs/codemelted/*/*.html -Exclude "*sidebar*"
      foreach ($file in $files) {
        [string]$htmlData = Get-Content -Path $file.FullName -Raw
        $htmlData = $htmlData.Replace('<link rel="icon" href="static-assets/favicon.png?v1">', '<link rel="icon" href="https://codemelted.com/favicon.png">')
        $htmlData = $htmlData.Replace("</head>", '<link rel="stylesheet" href="https://codemelted.com/assets/css/footer.css"><script src="https://codemelted.com/assets/js/footer.js" defer></script></head>')
        $htmlData = $htmlData.Replace(".png`"><br>", ".png`"><br>`n$htmlNavTemplate")
        $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
        $htmlData | Out-File $file.FullName -Force
      }

      Set-Location $PSScriptRoot
      message "codemelted.dart module documentation completed."
    }
  }

  # Build / test the Raspberry Pi Project.
  function build_pi([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    message "Now building the Raspberry Pi Project documentation."

    Set-Location $PSScriptRoot/assets/pi
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
    $html = $html.Replace("/></a><br />", "/></a><br />`n$htmlNavTemplate")
    $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
    $html = $html.Replace("README.md", "index.html")
    $html | Out-File docs/index.html -Force

    Set-Location $PSScriptRoot
    message "Raspberry Pi Project module documentation completed."
  }

  # Build / test the codemelted.ps1 module.
  function build_pwsh([bool]$isTestOnly = $false) {
    # Now go build the codemelted_ps1 documentation.
    message "Now building the codemelted.ps1 module documentation."

    Set-Location $PSScriptRoot/assets/pwsh
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
    $html = $html.Replace("/></a><br />", "/></a><br />`n$htmlNavTemplate")
    $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
    $html = $html.Replace("README.md", "index.html")
    $html | Out-File docs/index.html -Force

    Set-Location $PSScriptRoot
    message "codemelted.ps1 module documentation completed."
  }

  # ---------------------------------------------------------------------------
  # [Main Execution] ----------------------------------------------------------
  # ---------------------------------------------------------------------------

  switch ($params[0]) {
    "--test" {
      build_cpp $true
      build_flutter $true
      build_pi $true
      build_pwsh $true
    }
    "--build" {
      # Build and test each of the modules.
      build_cpp $false
      build_flutter $false
      build_pi $false
      build_pwsh $false

      # Now go move all the resources
      New-Item -Path docs/assets/cpp -ItemType Directory
      New-Item -Path docs/assets/pi -ItemType Directory
      New-Item -Path docs/assets/pwsh -ItemType Directory
      Copy-Item -Path design-notes -Destination docs -Force -Recurse
      Copy-Item -Path assets/cpp/docs/* -Destination docs/assets/cpp -Force -Recurse
      Copy-Item -Path assets/pi/docs/* -Destination docs/assets/pi -Force -Recurse
      Copy-Item -Path assets/pwsh/docs/* -Destination docs/assets/pwsh -Force -Recurse
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

      Set-Location $PSScriptRoot/terminal
      Publish-Script -Path ./codemelted.ps1 -NugetAPIKey $env:PWSH_PUBLISH_KEY -Verbose
      Set-Location $PSScriptRoot

      Write-Host "MESSAGE: Publishing completed."
     }
    default { Write-Host "ERROR: Invalid parameter specified." }
  }
}
build $args