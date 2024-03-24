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

[string]$htmlSdkHeader = @"
<link rel="stylesheet" href="https://cdn.codemelted.com/assets/css/scrollbars.css">
<link rel="stylesheet" href="https://cdn.codemelted.com/assets/css/header.css">
<!-- <script src="https://cdn.codemelted.com/assets/js/header_actions.js"></script> -->
<div class="cm-header">
    <a title="To CodeMelted" href="https://www.codemelted.com" target="_blank"><img src="https://cdn.codemelted.com/assets/images/favicon_io_pwa/apple-touch-icon.png" /></a>
    <div>CodeMelted - DEV</div>
    <a title="To CodeMelted" href="https://www.codemelted.com" target="_blank"><img src="https://cdn.codemelted.com/assets/images/favicon_io_pwa/apple-touch-icon.png" /></a>
</div><br />
"@

[string]$htmlHeader = @"
<script src="https://cdn.codemelted.com/assets/js/header_actions.js"></script>
<div class="cm-header">
    <a title="To CodeMelted" href="https://www.codemelted.com" target="_blank"><img src="https://cdn.codemelted.com/assets/images/favicon_io_pwa/apple-touch-icon.png" /></a>
    <div>CodeMelted - DEV</div>
    <a title="To CodeMelted" href="https://www.codemelted.com" target="_blank"><img src="https://cdn.codemelted.com/assets/images/favicon_io_pwa/apple-touch-icon.png" /></a>
</div>
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
    <link rel="stylesheet" href="https://cdn.codemelted.com/assets/css/developer-theme.css">
    <link rel="icon" type="image/x-icon" href="https://cdn.codemelted.com/favicon.png">
    <style>
        .mermaid {
            background-color: grey;
        }
    </style
</head><body><div class="content-main">
$htmlHeader
[CONTENT]
[MERMAID_SCRIPT]
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

    # Transforms the README.md of this repo along with all the use_cases into
    # a static website for CDN deployment.
    function codemelted_developer {
        message "Now building codemelted_developer design"

        # Setup for a fresh build
        Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore
        New-Item -Path docs -ItemType Directory -ErrorAction Ignore
        New-Item -Path docs/use_cases/advanced -ItemType Directory -ErrorAction Ignore
        New-Item -Path docs/use_cases/core -ItemType Directory -ErrorAction Ignore
        New-Item -Path docs/use_cases/ui -ItemType Directory -ErrorAction Ignore

        # Get the mermaid script to render diagrams
        $mermaidScript = Get-Content assets/templates/mermaid.html -Raw

        # Build each of the use case areas
        $files = Get-ChildItem -Path $PSScriptRoot/use_cases/*/*.md
        foreach ($file in $files) {
            # Extract the information needed
            $readme = ConvertFrom-Markdown -Path $file.FullName
            $splitChar = $IsWindows ? "\" : "/"
            $paths = $file.DirectoryName.Split($splitChar);
            $pathName = $paths[$paths.Length - 2] + $splitChar + $paths[$paths.Length - 1]
            $title = extract "TITLE:" $readme.Html
            $keywords = extract "KEYWORDS:" $readme.Html
            $description = extract "DESCRIPTION:" $readme.Html
            $html = $htmlTemplate
            $html = $html.Replace("[TITLE]", $title)
            $html = $html.Replace("[DESCRIPTION]", $description)
            $html = $html.Replace("[KEYWORDS]", $keywords)
            $html = $html.Replace("[CONTENT]", $readme.Html)
            $html = $html.Replace("[MERMAID_SCRIPT]", $mermaidScript)
            $html = $html.Replace("README.md", "index.html")
            $htmlFilename = $file.Name.Replace(".md", ".html")
            $html | Out-File docs/$pathName/$htmlFilename -Force
        }
        Copy-Item -Path use_cases/advanced/*.png -Destination docs/use_cases/advanced
        Copy-Item -Path use_cases/core/*.png -Destination docs/use_cases/core
        Copy-Item -Path use_cases/ui/*.png -Destination docs/use_cases/ui

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
        $html = $html.Replace("[MERMAID_SCRIPT]", $mermaidScript)
        $html = $html.Replace(".md", ".html")
        $html | Out-File docs/index.html -Force
        Copy-Item -Path *.png -Destination docs/

        Set-Location $PSScriptRoot
        message "codemelted_develoepr build completed."
    }

    # Builds the codemelted_flutter module docs directory.
    function codemelted_flutter {
        message "Now building codemelted_flutter module"
        Set-Location $PSScriptRoot/modules/codemelted_flutter
        Remove-Item -Path docs -Force -Recurse -ErrorAction Ignore

        message "Running flutter test framework"
        flutter test --coverage

        if ($IsLinux -or $IsMacOS) {
            genhtml -o coverage --ignore-errors unused --dark-mode coverage/lcov.info
        } else {
            $exists = Test-Path -Path $GEN_HTML_PERL_SCRIPT -PathType Leaf
            if ($exists) {
                perl $GEN_HTML_PERL_SCRIPT -o coverage coverage/lcov.info
            } else {
                Write-Host "WARNING: genhtml not installed for windows. Run " +
                    "'choco install lcov' for pwsh terminal as Admin to install it."
            }
        }

        message "Now generating dart doc"
        dart doc --output "docs"
        Move-Item -Path coverage -Destination docs -Force
        Copy-Item -Path header.png -Destination docs -Force

        # Fix the title
        [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
        $htmlData = $htmlData.Replace("codemelted_flutter - Dart API docs", "CodeMelted - Flutter Module")
        $htmlData = $htmlData.Replace('<link rel="icon" href="static-assets/favicon.png?v1">', '<link rel="icon" href="https://cdn.codemelted.com/favicon.png"')
        $htmlData = $htmlData.Replace("<h1><img ", "$htmlSdkHeader<h1><img ")
        $htmlData | Out-File docs/index.html -Force

        Set-Location $PSScriptRoot
        message "codemelted_flutter module build completed."
    }

    # Main Exection
    switch($params[0]) {
        "--codemelted_developer" { codemelted_developer }
        "--codemelted_flutter" { codemelted_flutter }
        default { Write-Host "ERROR: Invalid parameter specified." }
    }


}
build $args