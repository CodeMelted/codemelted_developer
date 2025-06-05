# 5.0 Disk Use Case

Regardless of where you run your application you will need the ability to store data. The host operating system provides access to be able to manage such files. The Disk Use Case will provide the ability to read / write file content to disk. It will also support the ability to manage these files on disk allowing for the creation of files, deletion of files, the ability to rename the files, and to delete such files.

## 5.1 Acceptance Criteria

1. The *Disk Use Case* will support the reading of an entire file from the hosted operating system disk. This will be read either as a string or a binary blob.
2. The *Disk Use Case* will support writing an entire file to disk from either a String or binary Blob. This will support either creation of a file or appending to an existing file.
3. The *Disk Use Case* will support copy files / directories from one location to another on the hosted operating system disk.
4. The *Disk Use Case* will support detecting whether a file or directory exists on the hosted operating system disk.
5. The *Disk Use Case* will support listing of files / directories on the hosted system disk.
6. The *Disk Use Case* will support the ability to monitor all attached disks to the host operating system.
7. The *Disk Use Case* will support creation of directories on the hosted system disk.
8. The *Disk Use Case* will support moving files / directories from one location to another on the hosted operating system disk.
9. The *Disk Use Case* will support removing files / directories from the hosted operating system disk.
10. The *Disk Use Case* will support getting the size of files / directories from the hosted operating system disk.
11. Failures of any of the above transactions will be indicating either by a Boolean true / false or a null for the given requested data.

## 5.2 SDK Notes

- Acceptance criteria 1 / 2 apply to all modules.
- Acceptance criteria 3 - 11 does not apply to the Flutter module.
