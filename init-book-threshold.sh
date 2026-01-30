#!/usr/bin/with-contenv bash
# Set Book Match Threshold to 40% on container start

CONFIG_DB="/config/readarr.db"
THRESHOLD=40
# Set to 1 to force overwrite even if a value already exists
OVERWRITE=${OVERWRITE_BOOKMATCH_THRESHOLD:-0}

# Wait for database to exist (in case Readarr is still initializing)
WAIT_COUNT=0
while [ ! -f "$CONFIG_DB" ] && [ $WAIT_COUNT -lt 30 ]; do
    echo "**** Waiting for Readarr database to be created... ****"
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ -f "$CONFIG_DB" ]; then
    echo "**** Checking BookMatchThreshold setting ****"
    
    # Check if the setting exists
    EXISTING=$(sqlite3 "$CONFIG_DB" "SELECT Value FROM Config WHERE Key='bookmatchthreshold';")
    
    if [ -z "$EXISTING" ]; then
        # Insert new setting
        sqlite3 "$CONFIG_DB" "INSERT INTO Config (Key, Value) VALUES ('bookmatchthreshold', '${THRESHOLD}');"
        echo "**** BookMatchThreshold set to ${THRESHOLD}% ****"
    else
        if [ "$OVERWRITE" = "1" ]; then
            sqlite3 "$CONFIG_DB" "UPDATE Config SET Value='${THRESHOLD}' WHERE Key='bookmatchthreshold';"
            echo "**** BookMatchThreshold overwritten to ${THRESHOLD}% (was ${EXISTING}%) ****"
        else
            echo "**** BookMatchThreshold already configured at ${EXISTING}% (not changing) ****"
        fi
    fi
else
    echo "**** Config database not found after waiting. Readarr may need to complete first-time setup. ****"
fi
