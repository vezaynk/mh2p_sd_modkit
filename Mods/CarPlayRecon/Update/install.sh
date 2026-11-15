#!/bin/ksh
# CarPlayRecon: READ-ONLY. Collects everything needed to build a CarPlay
# limited-UI (soft keyboard) patch in one pass. Changes nothing on the unit.
# Output: $MEDIA_PATH/Logs/$MOD/
OUT="$MEDIA_PATH/Logs/$MOD"
mkdir -p "$OUT/files" "$OUT/jars"
echo "release: $RELEASE_VERSION ($REGION $OEM $TYPE $RELEASE_TYPE $SOFTWARE_VERSION)"
date

# ---- 1. system context (cheap, helps if anything below misses)
echo "--- context"
mount > "$OUT/mount.txt" 2>&1
df -k > "$OUT/df.txt" 2>&1
pidin -f anA > "$OUT/pidin.txt" 2>&1 || pidin > "$OUT/pidin.txt" 2>&1
ls -lR /mnt/app/eso > "$OUT/ls_eso.txt" 2>&1
env > "$OUT/env.txt" 2>&1

# ---- 2. self-test grep so a silent tool failure is visible in the log
PAT=limitedUI
echo "xx limitedUIElements xx" > "$OUT/selftest.txt"
if grep -l -e limitedUI -e softKeyboard "$OUT/selftest.txt" >/dev/null 2>&1; then
    MULTI=1; echo "grep -e: OK"
elif grep -l "$PAT" "$OUT/selftest.txt" >/dev/null 2>&1; then
    MULTI=0; echo "grep -e: unsupported, using single pattern '$PAT'"
else
    MULTI=-1; echo "ERROR: grep self-test failed; string scan skipped"
fi
rm -f "$OUT/selftest.txt"

has_hit() {
    if [ "$MULTI" = 1 ]; then
        grep -l -e limitedUI -e softKeyboard -e nonMusicLists "$1" >/dev/null 2>&1
    else
        grep -l "$PAT" "$1" >/dev/null 2>&1
    fi
}

# ---- 3. all Java jars (compressed: grep cannot see inside, so copy them all)
echo "--- copying jars"
find /mnt/app -type f -name '*.jar' 2>/dev/null > "$OUT/jars.txt"
while read -r j; do
    mkdir -p "$OUT/jars$(dirname "$j")"
    cp -f "$j" "$OUT/jars$j" && echo "jar $j"
done < "$OUT/jars.txt"
echo "jars copied: $(wc -l < "$OUT/jars.txt")"

# ---- 4. string scan of native files across the whole unit
# Only real on-disk filesystems (qnx6 partitions from `mount`) plus the boot
# image and system dirs. Never walk / blindly: QNX resource managers (/pps,
# /dev, /net, ...) can block on read and hang the update. Skip files >64MB.
echo "--- scanning"
: > "$OUT/hits.txt"
ROOTS="/proc/boot /bin /sbin /lib /usr /etc /opt"
for mp in $(mount 2>/dev/null | grep 'type qnx6' | sed -e 's/.* on \([^ ]*\) type.*/\1/'); do
    case "$mp" in /|/fs/*) continue ;; esac
    ROOTS="$ROOTS $mp"
done
echo "scan roots: $ROOTS"
if [ "$MULTI" != -1 ]; then
    for root in $ROOTS; do
        [ -d "$root" ] || continue
        echo "scan $root"; date
        find "$root" -type f -size -131072 2>/dev/null | while read -r f; do
            case "$f" in
                /mnt/sd*|/mnt/usb*|/mnt/nav*|*.jar) continue ;;
            esac
            if has_hit "$f"; then
                echo "HIT $f"
                echo "$f" >> "$OUT/hits.txt"
                mkdir -p "$OUT/files$(dirname "$f")"
                cp -f "$f" "$OUT/files$f"
            fi
        done
    done
fi
echo "hits: $(wc -l < "$OUT/hits.txt")"
date
echo "CarPlayRecon COMPLETE"
