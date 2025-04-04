# MHP3rd Target Camera

Adds target camera, similar to that of Monster Hunter 4 to Monster Hunter Portable 3rd.

## Compiling

In a Linux environment, you will need Make and CMake. Use `make deps` to install the dependencies and `make` to generate the binaries and the `CHEATS.TXT` file


## Usage

Use `L` + `DpadUp` to enable target camera. When target camera is enabled, pressing `L` will turn the camera to the selected target. 

`L` + `DpadLeft` or `DpadRight` to select a target monster. Quest target is usually the leftmost.

Pressing `L` + `DpadDown` will disable the mod.

## Issues

This was developed and tested only in the PPSSPP emulator, it was literally the first thing I've ever wrote in assembly, so it most likely won't work on original hardware, vita, nor an emulator that's more accurate.

### Known bugs

Aiming with bows (and possibly bowguns), makes the game crash if the mod's enabled.
