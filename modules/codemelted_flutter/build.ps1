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

function build([string[]]$params) {
    # Helper function to format message output from the build script.
    function message([string]$msg) {
        Write-Host
        Write-Host "MESSAGE: $msg"
        Write-Host
    }

    # Main Script Execution
    message "Now building codemelted_flutter module"
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
build