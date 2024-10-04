<!--
TITLE: CodeMelted - DEV | Use Case: Audio
PUBLISH_DATE: 2024-08-05
AUTHOR: Mark Shaffer
KEYWORDS: CodeMelted - DEV, Disk, Use Case, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: Applications have access to hard disk which houses directories, files, and other information. This use case will expose the ability to manage the disk along with interface with said files from the disk.
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logos/logo-developer-smaller.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icons/design.png" /> Use Case: Disk</h1>

Applications have access to hard disk which houses directories, files, and other information. This use case will expose the ability to manage the disk along with interface with said files from the disk.

**Table of Contents**

- [FUNCTIONAL DECOMPOSITION](#functional-decomposition)
  - [Manage Items on Disk](#manage-items-on-disk)
  - [Read / Write Files](#read--write-files)
- [DESIGN NOTES](#design-notes)
- [TEST NOTES](#test-notes)
- [REFERENCES](#references)

## FUNCTIONAL DECOMPOSITION

<center><img style="width: 100%; max-width: 560px;" src="assets/disk/use-case-model.drawio.png" /></center>

### Manage Items on Disk

**Description:** This use case is the management of files / directories on a local disk. This includes getting of listing of files, being able to copy, delete, or move those file. Along with this is the management of directories to also include copying, deleting, or moving them. Lastly is the ability to determine the temporary and user's home directory on the disk.

**Acceptance Criteria:**

1. The disk namespace will provide the ability to copy files and directories on disk.
2. The disk namespace will provide the ability to delete files and directories on disk.
3. The disk namespace will provide the ability to move files and directories on disk.
4. The disk namespace will provide the ability to query for a system's temporary directory or a user's home directory.

### Read / Write Files

**Description:** Besides managing files, a user will want to read and write data from a file. This use case will provide the ability to work with files in an array of configurations based on the targeted SDK environment.

**Acceptance Criteria:**

1. The disk namespace will provide the ability to read an entire file as either bytes or a string.
2. The disk namespace will provide the ability to write an entire file as either bytes or a string.
3. The disk namespace will provide the ability to append to an existing file as either bytes or a string.
4. The disk namespace will provide the ability to read / write a file in chunks vs. the entire file contents as reflected in acceptance criteria 2 and 3.

## DESIGN NOTES

<mark>TBD</mark>

## TEST NOTES

<mark>TBD</mark>

## REFERENCES

<mark>TBD</mark>