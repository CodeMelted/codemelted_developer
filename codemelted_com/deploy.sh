#!/bin/bash
# =============================================================================
# MIT License
#
# © 2023 Mark Shaffer
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
function main {
  # Will deploy the specified target for the cdn.codemelted.com site.
  function deploy_content {
    # Setup the target
    target=$1

    # See if it exists
    if test -f $target.zip; then
      # It does, see if a previous deployment needs removing
      if test -d ./public_html/$target; then
          echo "MESSAGE: $target directory exists, removing it"
          rm -rf ./public_html/$target
      else
          echo "WARNING: $target directory does not exist, moving on."
      fi

      # Now go deploy the target.
      echo "MESSAGE: $target.zip file exists, unzipping it and deleting it."
      unzip $target.zip -d public_html
      rm -f $target.zip
    fi
  }

  # -------------------------------------------------------------------------
  # [Main] ------------------------------------------------------------------
  # -------------------------------------------------------------------------
  echo "MESSAGE: Now deploying the codemelted.com site."

  deploy_content "app"
  deploy_content "assets"
  deploy_content "developer"
  deploy_content "photography"

  echo "MESSAGE: codemelted.com site has been deployed."
}
main