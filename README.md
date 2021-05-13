# psx_mc_cli
Crossplatform cli utilities for working with PSX memory card files

Requires perl.

## *nix

Just add the `bin` dir to PATH. On debian, add the bottom to `~/.profile`

`export PATH=$PATH:wherever/psx_mc_cli/bin`

## Windows

Git for Windows has a usable perl environment if needed. For using the utils from Git BASH see the *nix notes.

For using the utils from outside of a *nix environment (`cmd.exe`, etc) add `perl` and `bin_cmd` to your PATH.

`Start` -> `View advanced system settings` -> `Advanced` -> `Environment Variables` select `Path` and edit.

## Usage

`mkmcd thps2-us.mcs tonyhax.mcs card1.mcd > out.mcd` to make a psx memory card `.mcd` file from save(s) in `.mcs` and `.mcs`

`lsmc card.mcd thps2-us.mcs` to print info of save(s) included in `.mcd` and `.mcs`

`mcsaveextract card.mcd [savesubstring] > thps2-us-copy.mcs` to extract single saves (`.mcs`) from `.mcd`
`mciconextract thps2-us.mcs [savesubstring]> thps2-us.tim` to extract the save icon as TIM. If `.mcd` is provided the first save is extracted.

`savesubstring` param only used for .`mcd`, it can be the string or case insensitive substring of the save's filename i.e `BESLEM-99999TONYHAX` or title i.e. `ＴＯＮＹＨＡＸ　ＳＰＬ` or title in ascii if applicable i.e. `TONYHAX SPL`


## TODO
- make tests
- load from stdin
- binaries
- better bat files (Don't hardcode perl path in bat files)
- mciconextract
    - extract CLUT as C array
- lsmc
    - nonverbose mode
    - direntry only mode
    - Improve terminal save icon graphics
- other memory card formats such as raw saves
