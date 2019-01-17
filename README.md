# Description

These scripts are desgined to make it easier to run URSim [[1]](https://www.universal-robots.com/download/) on Arch Linux.

The vanilla URSim makes a number of symlinks when running the `start-ursim.sh` script and removes them again when closing the simulator.
That is a somewhat fragile process, and it makes it difficult to run the simulator multiple times for different robot types.
These scripts make subdirectories for each robot type (currently UR3, UR5 and UR10), and `cd` into them before running the simulator instead.
They also unpack the `.deb` dependencies in a dedicated folder for the simulator, meaning you don't have to install them system wide.
Finally, the scripts patch the controller with `patchelf` and `setcap` to enable the Modbus server of the controller without running it as root.

# Dependencies

The controller (`URControl`) is a 32-bit executable.
That means you need a 32 bit runtime to be able to run it.
On Arch Linux this means you need to enable to `multilib` repository [[2]](https://wiki.archlinux.org/index.php/multilib).
`URControl` itself needs atleast `lib32-gcc-libs` and `lib32-curl`.

For the PolyScope interface to work, you need to have `java3d` installed.
On Arch Linux this can be done by installing `java3d` from the AUR [[3]](https://aur.archlinux.org/packages/java3d/).
If you install `java3d` by some other means, it may be necessary to modify the `-Djava.library.path` in `interface.sh` so that the library can be found when launching the interface.

The install script uses `patchelf` to modify the `RPATH` of the controller with an absolute path to the unpacked `.deb` packages.
This is the only way to make it use the libraries while also running with elevated privileges for the Modbus server.

Additionally, the `controller.sh` script uses netcat (OpenBSD netcat, not GNU netcat) to send a few commands to the controller after launching it.
This allows it to be used without the PolyScope interface.
It should be straightforward to modify it for GNU netcat if desired.

# Usage
Set up the subdirectories, unpack dependencies and patch the controller:
```
cd $ursim_root
$ursim_archlinux/clean-install.sh
```

Run the controller:
```
$ursim_root/controller.sh [UR3|UR5|UR10]
```

Run the PolyScope interface:
```
$ursim_root/interface.sh [UR3|UR5|UR10]
```

You will need to use the PolyScope interface once after initial installation to accept the safety parameters.
You have to do that for each robot type separately.
After that, you can run the controller without the interface.
For some reason it may be necessary to run the interface before starting the controller when accepting the safety parameters.

The robot type argument for `controller.sh` and `interface.sh` is optional.
If no robot type is given, UR5 is assumed.
Make sure that the controller and interface use the same robot type, or weird things may happen.

If you move the simulator to a different location, the `RPATH` of the controller will not be correct anymore.
This can be fixed by manually running `patch-controller.sh` after the move:
```
cd $new_ursim_root
$ursim_archlinux/patch-controller.sh
```



# Links
- [[1] https://www.universal-robots.com/download/](https://www.universal-robots.com/download/)
- [[2] https://wiki.archlinux.org/index.php/multilib](https://wiki.archlinux.org/index.php/multilib)
- [[3] https://aur.archlinux.org/packages/java3d/](https://aur.archlinux.org/packages/java3d/)
