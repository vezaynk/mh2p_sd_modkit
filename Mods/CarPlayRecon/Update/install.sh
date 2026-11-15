#!/bin/ksh
# CarPlayRecon: READ-ONLY. Finds where the PCM declares CarPlay limited-UI
# elements and copies those files to the SD card for offline analysis.
# Changes nothing on the unit.
OUT="$MEDIA_PATH/Logs/$MOD"
mkdir -p "$OUT/files"
echo "release: $RELEASE_VERSION ($REGION $OEM $TYPE $RELEASE_TYPE $SOFTWARE_VERSION)"

echo "--- processes"
pidin -f an 2>/dev/null | grep -i -e carplay -e airplay -e cp_ -e iap -e smartphone > "$OUT/processes.txt"
cat "$OUT/processes.txt"

# Java HMI (lsd.jar) is zip-compressed, so grep cannot see strings inside it.
# Copy it explicitly; the fullscreen mod shadows classes from it via jars/fc.jar.
echo "--- copying Java HMI"
mkdir -p "$OUT/files/mnt/app/eso/hmi/lsd"
cp -f /mnt/app/eso/hmi/lsd/lsd.jar "$OUT/files/mnt/app/eso/hmi/lsd/" && echo "copied lsd.jar"
cp -rf /mnt/app/eso/hmi/lsd/jars "$OUT/files/mnt/app/eso/hmi/lsd/" 2>/dev/null
ls -l /mnt/app/eso/hmi/lsd > "$OUT/lsd_dir.txt" 2>&1

for root in /mnt/app /mnt/system /mnt/persist /mnt/persist_new /mnt/ota /etc; do
    [[ -d "$root" ]] || continue
    echo "--- scanning $root"
    find "$root" -type f 2>/dev/null | while read -r f; do
        if grep -l -e limitedUIElements -e softKeyboard -e nonMusicLists -e limitedUI "$f" >/dev/null 2>&1; then
            sz=$(ls -l "$f" | awk '{print $5}')
            echo "HIT $sz $f" | tee -a "$OUT/hits.txt"
            # copy hits (cap 40 MB each) preserving path
            if [[ "$sz" -lt 41943040 ]]; then
                mkdir -p "$OUT/files$(dirname "$f")"
                cp -f "$f" "$OUT/files$f"
            fi
        fi
    done
done
echo "done; see $OUT/hits.txt"
