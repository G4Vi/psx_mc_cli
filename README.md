# psx_mc_cli
Crossplatform cli utilities for working with PSX memory card files

Requires perl.

## *nix

Just add the `bin` dir to PATH.

`export PATH=$PATH:wherever_psx_mc_cli_bin_dir_is`

## Windows

Git for Windows has a usable perl environment if needed. For using the utils from Git BASH see the *nix notes.

For using the utils from outside of a *nix environment (`cmd.exe`, etc) add `perl` and `bin_cmd` to your PATH.

`Start` -> `View advanced system settings` -> `Advanced` -> `Environment Variables` select `Path` and edit.

## Usage

`mkmcd thps2-us.mcs tonyhax.mcs > out.mcd` to make a psx memory card `.mcd` file

`lsmc card.mcd thps2-us.mcs` to print info of save(s) included in `.mcd` and `.mcs`

`unmcd card.mcd BESLEM-99999TONYHAX > thps2-us-copy.mcs` to extract single saves (`.mcs`) from `.mcd`

`mciconextract thps2-us.mcs > thps2-us.tim` to extract the save icon as TIM. If `.mcd` is provided the first save is extracted.

## TODO
- make tests
- share code between utilities
- mciconextract
    - allow specifying save name
    - bat file on Windows
    - extract CLUT as C array
- lsmc
    - nonverbose mode
    - direntry only mode
    - Improve terminal save icon graphics
- Don't hardcode perl path in bat files
- Change `unmcd` to be more intuitive, maybe rename `mkmcd`?
- other memory card formats such as raw saves
