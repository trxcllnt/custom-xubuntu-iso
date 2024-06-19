Use [Cubic](https://github.com/PJ-Singh-001/Cubic) to create a custom [xubuntu-24.04-desktop-amd64.iso](https://xubuntu.org/release/24-04/) that looks and feels a bit more like MacOS.

## What it is

Pre-installs the software and settings listed in [`customize.sh`](customize/customize.sh).

Includes a [script](customize/usr/local/bin/xubuntu-postinstall.sh) to run on first login to install and configure user-specific packages and settings.

## Create the image

1. Open [Cubic](https://github.com/PJ-Singh-001/Cubic) and start a new project
2. Select [xubuntu-24.04-desktop-amd64.iso](https://xubuntu.org/release/24-04/)
3. Drag and drop [`customize`](customize) into the terminal and run `./customize/customize.sh`
4. Click through the rest of the prompts until you see the final screen

I recommend [Ventoy](https://www.ventoy.net/en/index.html) to make a live USB.

## Modify assets image

1. Clone this repo
2. Run `./extract-assets.sh` and add/remove/modify anything in the resulting `assets` directory
3. Run `./compress-assets.sh` to zip the contents of `assets` into `customize/assets.zip`
4. Recreate the image following the instructions above
