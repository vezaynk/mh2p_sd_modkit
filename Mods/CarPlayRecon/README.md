# CarPlayRecon (read-only, one pass)
Collects everything needed to build a CarPlay soft-keyboard (limited-UI) patch.
Nothing on the unit is modified; there is nothing to uninstall.

Output in `/Logs/CarPlayRecon/` on the SD card:
- `jars/` - every `.jar` under `/mnt/app` (Java HMI, incl. `lsd.jar`; compressed, so not greppable)
- `hits.txt`, `files/` - native files containing `limitedUI` / `softKeyboard` / `nonMusicLists`
- `mount.txt`, `df.txt`, `pidin.txt`, `ls_eso.txt`, `env.txt` - system context
- `/Logs/CarPlayRecon.log` - run log; must end with `CarPlayRecon COMPLETE`

The scan can take a while; let the update finish. Needs a few hundred MB free on the card.
Remove `Mods/CarPlayRecon` from the card after the run.
