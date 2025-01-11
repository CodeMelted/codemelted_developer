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

[string]$GEN_HTML_PERL_SCRIPT = "/ProgramData/chocolatey/lib/lcov/tools/bin/genhtml"

[string]$ogTemplate = @"
 <!-- Open Graph Settings -->
<meta property="og:type" content="website">
<meta property="og:title" content="[TITLE]">
<meta property="og:site_name" content="CodeMelted PWA">
<meta property="og:image" content="https://codemelted.com/assets/images/logo-codemelted-developer.png">
<meta property="og:image:height" content="100px">
<meta property="og:image:width" content="100px">
"@

[string]$htmlNavTemplate = @"
<style>
  .codemelted-dev-nav {
    display: grid;
    grid-template-columns: auto auto auto;
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
  <a title="PWA Module" href="https://codemelted.com/developer/pwa"><img src="https://codemelted.com/assets/images/icon-codemelted-web.png" /></a>
  <a title="NPU Module" href="https://codemelted.com/developer/npu" ><img src="https://codemelted.com/assets/images/icon-codemelted-npu.png" /></a>
  <a title="Terminal Module" href="https://codemelted.com/developer/terminal"><img src="https://codemelted.com/assets/images/icon-codemelted-terminal.png" /></a>
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
  <meta property="og:site_name" content="CodeMelted PWA">
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

  # ---------------------------------------------------------------------------
  # [Testing Functions] -------------------------------------------------------
  # ---------------------------------------------------------------------------
  # The following functions support the --test option and serve as the
  # options that kicks off with the --build option which runs the tests and
  # then generates all the documentation for each of the modules.

  # Builds the npu module. This is the center of all the different modules
  # so will always be the first step in any sequence of options.
  function build_codemelted_npu {
    message "Now building codemelted.cpp npu module."
    Set-Location $PSScriptRoot/npu
    Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore

    message "Generating doxygen"
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

    message "Compiling WASM Module"
    emcc --std=c++20 codemelted.cpp -o codemelted.wasm --no-entry
    Copy-Item -Path codemelted.wasm -Destination docs/codemelted.wasm -Force
    Copy-Item -Path codemelted.wasm -Destination ../pwa/codemelted.wasm -Force

    Set-Location $PSScriptRoot
    message "codemelted.cpp npu module build completed."
  }

  # This is the next item in the testing sequence. It tests the codemelted.js module
  # then moves it along with the WASM module (previous step) for the codemelted.dart
  # testing.
  function test_codemelted_js {
    # Build our support WASM module
    build_codemelted_npu

    # Now test the codemelted.js module
    message "Now testing codemelted.js module"

    Set-Location $PSScriptRoot/pwa
    Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore

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

    # Move test elements to the docs
    Move-Item -Path coverage -Destination docs -Force
    Copy-Item codemelted.js -Destination docs
    Copy-Item codemelted.js -Destination ../test/codemelted.js -Force
    Copy-Item -Path codemelted.wasm -Destination ../test/codemelted.wasm -Force
    Copy-Item codemelted_test.html -Destination docs

    Set-Location $PSScriptRoot
    message "codemelted.js module testing completed."
  }

  # The final step in testing all the modules is the codemelted.dart module.
  # this will kick off the test_codemelted_js which kicks off the
  # build_codemelted_npu. Once those are completed, we have all the support
  # modules to support the codemelted.dart testing.
  function test_codemelted_dart {
    # First test our codemelted.js module
    test_codemelted_js

    Set-Location $PSScriptRoot
    message "Now testing the codemelted.dart module"

    Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
    flutter test --platform chrome

    message "codemelted.dart module testing completed."
  }


  # ---------------------------------------------------------------------------
  # [Build Scripts] -----------------------------------------------------------
  # ---------------------------------------------------------------------------
  # These scripts are in the order for which the documentation needs building.
  # The test_codemelted_dart will be kicked-off first setting the stage for
  # all the documentation building for deployment.


  # This is the start of the process for all the module builds
  function build_codemelted_js {
    # This cleans all of our doc directories in each of the modules and runs
    # the tests. Then we can build all of our documentation.
    test_codemelted_dart

    # Now go build the module
    message "Now generating the codemelted.js SDK documentation."
    Set-Location $PSScriptRoot/pwa

    message "Now generating the jsdoc"
    jsdoc ./codemelted.js --readme ./README.md --destination docs

    [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | PWA Modules")
    $files = Get-ChildItem -Path docs/*.html
    foreach ($file in $files) {
      [string]$htmlData = Get-Content -Path $file.FullName -Raw
      $htmlData = $htmlData.Replace("README.md", "index.html")
      $htmlData = $htmlData.Replace("/></a><br />", "/></a><br />`n$htmlNavTemplate")
      $htmlData = $htmlData.Replace("</body>", "`n$footerTemplate</body>")
      $htmlData = $htmlData.Replace("</head>", '<meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="icon" href="https://codemelted.com/favicon.png"></head>')
      $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
      $htmlData | Out-File $file.FullName -Force
    }
    Copy-Item jsdoc-default.css -Destination docs/styles

    Set-Location $PSScriptRoot
    message "codemelted.js module documentation generated."
  }

  # Builds the codemelted_ps1 module documentation.
  function build_codemelted_ps1 {
    # First build the codemelted.js documentation
    build_codemelted_js

    # Now go build the codemelted_ps1 documentation.
    message "Now building the codemelted.ps1 module documentation."

    Set-Location $PSScriptRoot/terminal
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

  # Runs the flutter build for the main page before doing all the support modules.
  function build_codemelted_dart {
    # First build codemelted.ps1 documentation
    build_codemelted_ps1

    # Now build our module items.
    message "Now building the codemelted.dart module documentation"
    Set-Location $PSScriptRoot

    message "Now generating dart doc"
    dart doc --output "docs"
    Copy-Item -Path CHANGELOG.md -Destination docs -Force

    # Fix the title
    [string]$ogData = $ogTemplate.Replace("[TITLE]", "CodeMelted DEV | Modules")
    [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
    $htmlData = $htmlData.Replace("</head>", "$ogData`n</head>")
    $htmlData = $htmlData.Replace("codemelted_developer - Dart API docs", "CodeMelted DEV | Modules")
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
    Copy-Item -Path design-notes -Destination docs -Recurse

    # Now assemble the site.
    Remove-Item -Path developer -Recurse -Force -ErrorAction Ignore
    New-Item -Path developer -ItemType Directory -ErrorAction Ignore
    New-Item -Path developer/pwa -ItemType Directory -ErrorAction Ignore
    New-Item -Path developer/npu -ItemType Directory -ErrorAction Ignore
    New-Item -Path developer/terminal -ItemType Directory -ErrorAction Ignore

    Copy-Item -Path docs/* -Destination developer/ -Recurse
    Copy-Item -Path pwa/docs/* -Destination developer/pwa/ -Recurse
    Copy-Item -Path npu/docs/* -Destination developer/npu/ -Recurse
    Copy-Item -Path terminal/docs/* -Destination developer/terminal/ -Recurse

    Set-Location $PSScriptRoot
    message "codemelted.dart module documentation completed."
  }

  # ---------------------------------------------------------------------------
  # [Deployment Scripts] ------------------------------------------------------
  # ---------------------------------------------------------------------------

  # Handles the deployment to codemelted.com/developer
  function deploy {
    Write-Host "MESSAGE: Now uploading codemelted.com/developer content.";
    Compress-Archive -Path developer -DestinationPath developer.zip -Force
    $hostService = $env:CODEMELTED_USER_AND_IP + $env:CODEMELTED_HOME
    scp developer.zip $hostService
    ssh $env:CODEMELTED_USER_AND_IP
    Remove-Item -Path developer.zip
    Set-Location $PSScriptRoot
    Write-Host "MESSAGE: Upload completed.";
  }

  # Handles the publishing of the codemelted.ps1 CLI module.
  function publish_script {
    Write-Host "MESSAGE: Now publishing the codemelted.ps1 CLI module"

    Set-Location $PSScriptRoot/terminal
    Publish-Script -Path ./codemelted.ps1 -NugetAPIKey $env:PWSH_PUBLISH_KEY -Verbose
    Set-Location $PSScriptRoot

    Write-Host "MESSAGE: Publishing completed."
  }

  # ---------------------------------------------------------------------------
  # [Main Execution] ----------------------------------------------------------
  # ---------------------------------------------------------------------------

  switch ($params[0]) {
    "--test" { test_codemelted_dart }
    "--build" { build_codemelted_dart }
    "--deploy" { deploy }
    "--publish-script" { publish_script }
    default { Write-Host "ERROR: Invalid parameter specified." }
  }
}
build $args