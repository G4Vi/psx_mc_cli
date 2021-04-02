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

`lsmc out.mcd thps2-us.mcs` to print info of save(s) included in `.mcd` and `.mcs`

`unmcd out.cmd BESLEM-99999TONYHAX > thps2-us-copy.mcs` to extract single saves (`.mcs`) from `.mcd`

## TODO
- make tests
- Support multi-block saves
- Don't hardcode perl path in bat files
- Change `unmcd` to be more intuitive.
- Only check for 15 directory entries?
- other memory card formats
- Render save graphics to terminal?