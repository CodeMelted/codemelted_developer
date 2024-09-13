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

[string]$footerTemplate = @"
<!-- Links to main domain assets for embedding this widget code into different configurations -->
<codemelted-navigation></codemelted-navigation>
<script src="https://codemelted.com/assets/js/codemelted_navigation.js" defer></script>
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
    <link rel="stylesheet" href="https://codemelted.com/assets/css/developer-theme.css">
    <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png">
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

    # Builds all project files for inclusion in the codemelted.com domain
    # deployment.
    function build_all {
        # Build all the project static sdk sites.
        codemelted_cpp
        codemelted_developer
        codemelted_flutter
        codemelted_js
        codemelted_pwsh
        codemelted_pi

        # Now go copy those static sdk sites.
        Remove-Item -Path developer -Recurse -Force -ErrorAction Ignore
        New-Item -Path developer -ItemType Directory -ErrorAction Ignore
        New-Item -Path developer/codemelted_cpp -ItemType Directory -ErrorAction Ignore
        New-Item -Path developer/codemelted_flutter -ItemType Directory -ErrorAction Ignore
        New-Item -Path developer/codemelted_js -ItemType Directory -ErrorAction Ignore
        New-Item -Path developer/codemelted_pwsh -ItemType Directory -ErrorAction Ignore
        New-Item -Path developer/codemelted_pi -ItemType Directory -ErrorAction Ignore

        Copy-Item -Path docs/* -Destination developer/ -Recurse
        Copy-Item -Path codemelted_cpp/docs/* -Destination developer/codemelted_cpp/ -Recurse
        Copy-Item -Path codemelted_flutter/docs/* -Destination developer/codemelted_flutter/ -Recurse
        Copy-Item -Path codemelted_js/docs/* -Destination developer/codemelted_js/ -Recurse
        Copy-Item -Path codemelted_pwsh/docs/* -Destination developer/codemelted_pwsh/ -Recurse
        Copy-Item -Path codemelted_pi/docs/* -Destination developer/codemelted_pi/ -Recurse
    }


    # Builds the codemelted_cpp module.
    function codemelted_cpp {
        message "Now building codemelted_cpp module."
        Set-Location $PSScriptRoot/codemelted_cpp
        Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore

        message "Generating doxygen"
        doxygen doxygen.cfg
        [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
        $htmlData = $htmlData.Replace("<center>", "$htmlSdkHeader<center>")
        $htmlData = $htmlData.Replace("README.md", "index.html")
        $htmlData = $htmlData.Replace("</head>", '    <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png"></head>')
        $htmlData = $htmlData.Replace("</body>", "<br /><br /><br /><br /><br />`n$footerTemplate`n</body>")
        $htmlData | Out-File docs/index.html -Force

        $files = Get-ChildItem -Path docs/*.html -Exclude "index.html"
        foreach ($file in $files) {
            [string]$htmlData = Get-Content -Path $file.FullName -Raw
            $htmlData = $htmlData.Replace("</head>", '    <link rel="icon" type="image/x-icon" href="https://codemelted.com/favicon.png"></head>')
            $htmlData = $htmlData.Replace("</body>", "<br /><br /><br /><br /><br />`n$footerTemplate`n</body>")
            $htmlData | Out-File $file.FullName -Force
        }

        [string]$htmlData = Get-Content -Path "docs/navtree.css" -Raw
        $htmlData = $htmlData.Replace("overflow:auto", "overflow:display")
        $htmlData | Out-File docs/navtree.css -Force

        Set-Location $PSScriptRoot
        message "codemelted_cpp module build completed."
    }

    # Transforms the README.md of this repo along with all the use_cases into
    # a static website for CDN deployment.
    function codemelted_developer {
        message "Now building codemelted_developer design"

        # Setup for a fresh build
        Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
        New-Item -Path docs -ItemType Directory -ErrorAction Ignore
        New-Item -Path docs/use_cases -ItemType Directory -ErrorAction Ignore

        # Build each of the use case areas
        $files = Get-ChildItem -Path $PSScriptRoot/use_cases/*.md
        foreach ($file in $files) {
            # Extract the information needed
            $readme = ConvertFrom-Markdown -Path $file.FullName
            $title = extract "TITLE:" $readme.Html
            $keywords = extract "KEYWORDS:" $readme.Html
            $description = extract "DESCRIPTION:" $readme.Html
            $html = $htmlTemplate
            $html = $html.Replace("[TITLE]", $title)
            $html = $html.Replace("[DESCRIPTION]", $description)
            $html = $html.Replace("[KEYWORDS]", $keywords)
            $html = $html.Replace("[CONTENT]", $readme.Html)
            $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
            $html = $html.Replace("README.md", "index.html")
            $htmlFilename = $file.Name.Replace(".md", ".html")
            $html | Out-File docs/use_cases/$htmlFilename -Force
        }
        Copy-Item -Path use_cases/assets -Destination docs/use_cases -Recurse

        # Now build the main README.md
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
        $html = $html.Replace("README.md", "index.html")
        $html = $html.Replace(".md", ".html")
        $html | Out-File docs/index.html -Force

        # Don't forget the getting_started.md
        $readme = ConvertFrom-Markdown -Path getting_started.md
        $title = extract "TITLE:" $readme.Html
        $keywords = extract "KEYWORDS:" $readme.Html
        $description = extract "DESCRIPTION:" $readme.Html
        $html = $htmlTemplate
        $html = $html.Replace("[TITLE]", $title)
        $html = $html.Replace("[DESCRIPTION]", $description)
        $html = $html.Replace("[KEYWORDS]", $keywords)
        $html = $html.Replace("[CONTENT]", $readme.Html)
        $html = $html.Replace("[FOOTER_TEMPLATE]", $footerTemplate)
        $html = $html.Replace("README.md", "index.html")
        $html = $html.Replace(".md", ".html")
        $html | Out-File docs/getting_started.html -Force

        Set-Location $PSScriptRoot
        message "codemelted_develoepr build completed."
    }

    # Builds the codemelted_flutter module docs directory.
    function codemelted_flutter {
        message "Now building codemelted_flutter module"
        Set-Location $PSScriptRoot/codemelted_flutter
        Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore

        message "Running flutter test framework"
        flutter test --platform chrome

        message "Now generating dart doc"
        dart doc --output "docs"
        Copy-Item -Path CHANGELOG.md -Destination docs -Force

        # Fix the title
        [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
        $htmlData = $htmlData.Replace("codemelted_flutter - Dart API docs", "CodeMelted - Flutter Module")
        $htmlData = $htmlData.Replace('<link rel="icon" href="static-assets/favicon.png?v1">', '<link rel="icon" href="https://codemelted.com/favicon.png">')
        $htmlData = $htmlData.Replace("README.md", "index.html")
        $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
        $htmlData | Out-File docs/index.html -Force

        $files = Get-ChildItem -Path docs/codemelted_*/*.html, docs/codemelted_*/*/*.html -Exclude "*sidebar*"
        foreach ($file in $files) {
            [string]$htmlData = Get-Content -Path $file.FullName -Raw
            $htmlData = $htmlData.Replace('<link rel="icon" href="static-assets/favicon.png?v1">', '<link rel="icon" href="https://codemelted.com/favicon.png">')
            $htmlData = $htmlData.Replace("</head>", '<link rel="stylesheet" href="https://codemelted.com/assets/css/footer.css"><script src="https://codemelted.com/assets/js/footer.js" defer></script></head>')
            $htmlData = $htmlData.Replace("</footer>", "</footer>`n$footerTemplate")
            $htmlData | Out-File $file.FullName -Force
        }

        Set-Location $PSScriptRoot
        message "codemelted_flutter module build completed."
    }

    # Builds the codemelted_js module.
    function codemelted_js {
        message "Now building codemelted_js module"
        Set-Location $PSScriptRoot/codemelted_js
        Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore

        message "Now Running Deno tests"
        deno test --allow-env --allow-net --allow-read --allow-sys --allow-write --coverage=coverage codemelted_test.ts
        deno coverage coverage --lcov > coverage/lcov.info

        if ($IsLinux -or $IsMacOS) {
            genhtml -o coverage --ignore-errors unused --dark-mode coverage/lcov.info
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

        # Generate and cleanup the documentation
        message "Now generating the jsdoc"
        jsdoc ./codemelted.js --readme ./README.md --destination docs
        $files = Get-ChildItem -Path docs/*.html
        foreach ($file in $files) {
            [string]$htmlData = Get-Content -Path $file.FullName -Raw
            $htmlData = $htmlData.Replace("README.md", "index.html")
            $htmlData = $htmlData.Replace("</body>", "`n$footerTemplate</body>")
            $htmlData = $htmlData.Replace("</head>", '<meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="icon" href="https://codemelted.com/favicon.png"></head>')
            $htmlData | Out-File $file.FullName -Force
        }

        # Some final moves to complete the module documentation.
        Move-Item -Path coverage -Destination docs -Force
        Copy-Item jsdoc-default.css -Destination docs/styles
        Copy-Item codemelted.js -Destination docs

        Set-Location $PSScriptRoot
        message "codemelted_js module build completed."
    }

    # Builds the codemelted_pwsh module.
    function codemelted_pwsh {
        message "Now building codemelted_pwsh module"

        Set-Location $PSScriptRoot/codemelted_pwsh
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
        $html = $html.Replace("README.md", "index.html")
        $html | Out-File docs/index.html -Force

        Set-Location $PSScriptRoot
        message "codemelted_pwsh module build completed."
    }

    # Builds the codemelted_pi module.
    function codemelted_pi {
        message "Now building codemelted_pi project"

        Set-Location $PSScriptRoot/codemelted_pi
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
        $html = $html.Replace("README.md", "index.html")
        $html | Out-File docs/index.html -Force

        Set-Location $PSScriptRoot
        message "codemelted_pi project build completed."
    }

    # Handles the deployment to developer.codemelted.com
    function deploy {
        Write-Host "MESSAGE: Now uploading developer.codemelted.com content.";
        Compress-Archive -Path developer -DestinationPath developer.zip -Force
        $hostService = $env:CODEMELTED_USER_AND_IP + $env:CODEMELTED_HOME
        scp developer.zip $hostService
        ssh $env:CODEMELTED_USER_AND_IP
        Remove-Item -Path developer.zip
        Set-Location $PSScriptRoot
        Write-Host "MESSAGE: Upload completed.";
    }

    # Main Exection
    switch ($params[0]) {
        "--build_all" { build_all }
        "--codemelted_cpp" { codemelted_cpp }
        "--codemelted_developer" { codemelted_developer }
        "--codemelted_flutter" { codemelted_flutter }
        "--codemelted_js" { codemelted_js }
        "--codemelted_pwsh" { codemelted_pwsh }
        "--codemelted_pi" { codemelted_pi }
        "--deploy" { deploy }
        default { Write-Host "ERROR: Invalid parameter specified." }
    }
}
build $args