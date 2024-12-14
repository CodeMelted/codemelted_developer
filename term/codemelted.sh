#!/usr/bin/env bash
# =============================================================================
# MIT License
#
# © 2024 Mark Shaffer. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
# =============================================================================
function main {
    # -------------------------------------------------------------------------
    # [CONSTANTS] -------------------------------------------------------------
    # -------------------------------------------------------------------------
    VERSION="v0.0.0 (Last Updated on YYYY-MM-DD)"

    # -------------------------------------------------------------------------
    # Will provide the overall help system for this script similar to that
    # of the pwsh script.
    # -------------------------------------------------------------------------
    function about {
        echo "------------------------"
        echo "CodeMelted - Bash Script"
        echo "------------------------"
        echo "   ABOUT: This script is a BASH specific implementation of the "
        echo "      CodeMelted - Developer use cases tied to the "
        echo "      CodeMelted - PowerShell module. If you cannot utilize "
        echo "      pwsh on your system then this will give you some of "
        echo "      those options."
        echo
        echo "   VERSION: $VERSION"
        echo
        echo "   SYNTAX:"
        echo "      TBD"
    }

    # -------------------------------------------------------------------------
    # [MAIN] ------------------------------------------------------------------
    # -------------------------------------------------------------------------
    action=$1
    case "$action" in
        --about) about ;;
        *) echo "ERROR: Invalid option specified." ;;
    esac
}
main $@