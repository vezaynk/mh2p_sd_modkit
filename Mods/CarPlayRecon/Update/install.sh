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
