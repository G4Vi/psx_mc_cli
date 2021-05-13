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

With all commands the input filename `-` refers to stdin and only one file will be read from stdin. It CAN be combined with other filenames however.

`mkmcd BESLEM-99999TONYHAX tonyhax.mcs card1.mcd > out.mcd` to make a psx memory card `.mcd` file from save(s) in `.mcs`, `.mcd`, and raw saves.

`lsmc card.mcd thps2-us.mcs BESLEM-99999TONYHAX` to print info of save(s) included in `.mcd`, `.mcs`, and raw saves. For convenience is no files are provided, read file from stdin (`-`) is implicitly done.

`raw2mcs RAWSAVE > out.mcs` to convert a raw save to `.mcs`. Add `-o NAME` if you need to override the filename to be stored in the `.mcs`.

`mcs2raw in.mcs` to convert a `.mcs` to a raw save. Add `-p PATHNAME` to set the output filepath (note this doesn't store the save filename) OR add `-d OUTDIR` to set where to store the raw save. 

`mcsaveextract card.mcd [savesubstring] > thps2-us-copy.mcs` to extract single saves as `.mcs` from `.mcd`
`mciconextract thps2-us.mcs [savesubstring]> thps2-us.tim` to extract the save icon as TIM. 

If `.mcd` is provided without `savesubstring` the first save is extracted. The `savesubstring` param  is only used for .`mcd`, it can be the string or case insensitive substring of the save's filename i.e `BESLEM-99999TONYHAX` or title i.e. `ＴＯＮＹＨＡＸ　ＳＰＬ` or title in ascii if applicable i.e. `TONYHAX SPL`

`mciconextract` can also dump the Color LookUp Table of the save icon as a `uint16_t[16]` with `--cclut`

## License
Copyright (c) 2021 Gavin Hayes and others under MIT, see `LICENSE`

## Needed
- automated tests
- binaries
- better bat files (Don't hardcode perl path in bat files)
- lsmc
    - nonverbose mode
    - direntry only mode
    - Improve terminal save icon graphics
