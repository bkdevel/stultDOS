# stultDOS

[![License](https://img.shields.io/github/license/bkdevel/stultDOS.svg)](https://github.com/bkdevel/stultDOS/blob/main/LICENSE) [![Top language](https://img.shields.io/github/languages/top/bkdevel/stultDOS.svg)](https://github.com/bkdevel/stultDOS)

stultDOS will be a DOS (Disk Operating System) running in 16-bit real mode.

## Achievements
- [ ] rewrite bootsector myself
- [x] printing stuff to the screen
- [ ] getting input from the user
- [ ] FAT12: reading files
- [ ] FAT12: writing files
- [ ] FAT12: executing files
- [ ] a basic shell
- [ ] a few userspace programs

## Building
Building should work on any UNIX-like OS. If you are on Windows try WSL, idk if it works (no idea why one would use Windows anyways).

These tools are required as of now: nasm, some make tool (i prefer bmake), dosfstools, mtools

## Credits
[Bootloader](https://github.com/nanobyte-dev/nanobyte_os/blob/videos/part2/src/bootloader/boot.asm) by nanobyte - will make my own later on
