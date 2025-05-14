set -euo pipefail

FILE=${1:?need hash-list}
API_KEY="...."

while IFS= read -r line || [[ -n $line ]]; do
    line=${line#"${line%%[![:space:]]*}"}
    line=${line%"${line##*[![:space:]]}"}
    [[ -z $line || $line =~ ^# ]] && continue

    zipfile="$line.zip"
    max=5 delay=1
    for (( try=1; try<=max; try++ )); do
        echo "[$try/$max] GET $line"
        wget --header "AUTH-KEY: $API_KEY" \
             --post-data "query=get_file&sha256_hash=$line" \
             -O "$zipfile" \
             https://mb-api.abuse.ch/api/v1/ \
             && break               
        echo "   failed (wget exit $?), retrying in $delay s…" >&2
        rm -f "$zipfile"
        sleep "$delay"
        delay=$(( delay * 2 ))
    done

    if [[ ! -s $zipfile ]]; then
        echo "!! giving up on $line after $max tries" >&2
        continue
    fi

    7z x "$zipfile" -pinfected
    rm -f "$zipfile"
done < "$FILE"

