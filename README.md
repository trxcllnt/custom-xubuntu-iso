Use [Cubic](https://github.com/PJ-Singh-001/Cubic) to create a custom [xubuntu-22.04.2-desktop-amd64.iso](https://xubuntu.org/release/22-04/) that looks and feels a bit more like MacOS.

## What it is

Pre-installs the software and settings listed in `customize.sh`. Includes a script (defined in `root.zip` at the path `usr/local/bin/xubuntu-postinstall.sh`) to run on first login to install and configure user-specific packages and settings.

## Modify the image

1. Clone this repo
2. Run `./extract.sh` and add/remove/modify anything in the resulting `mnt` directory
3. Run `./compress.sh` to zip the contents of `mnt` into `root.zip`
4. Recreate the image following the instructions below

## Create the image

1. Open [Cubic](https://github.com/PJ-Singh-001/Cubic) and start a new project
2. Select [xubuntu-22.04.2-desktop-amd64.iso](https://xubuntu.org/release/22-04/)
3. Drag and drop [`customize.sh`](customize.sh) and [`root.zip`](root.zip) into the terminal and run `./customize.sh`
4. On the packages screen, **un-check** both boxes for the following packages:
  * `xfce4-cpugraph-plugin:amd64`
  * `xfce4-netload-plugin`
  * `xfce4-taskmanager`
  * `xfce4-tumblr:amd64`
5. Click through the rest of the prompts until you see the final screen

I recommend [Ventoy](https://www.ventoy.net/en/index.html) to make a live USB.

I like to keep the following additional non-critical packages in the custom image:
  * `cifs-utils`
  * `efibootmgr`
  * `gnome-disk-utility`
  * `lightdm-gtk-greeter-settings`
  * `mousepad`
  * `network-manager-pptp`
  * `ristretto`
