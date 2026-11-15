# CarPlayRecon (read-only)
Locates the files on the PCM that declare CarPlay limited-UI elements
(`limitedUIElements`, `softKeyboard`, `nonMusicLists`, `limitedUI`) and copies
them to `/Logs/CarPlayRecon/files/` on the SD card. Nothing on the unit is modified.
Delete this folder from `Mods/` after one run.

Also copies `/mnt/app/eso/hmi/lsd/lsd.jar` and `jars/` (the Java HMI). Grep cannot see
strings inside compressed jars; decompile `lsd.jar` offline (e.g. Recaf/CFR) and search
the `de.audi.app.terminalmode` packages.
