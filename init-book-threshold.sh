#!/usr/bin/with-contenv bash
# Set Book Match Threshold to 40% on first run

CONFIG_DB="/config/readarr.db"
THRESHOLD=40

if [ -f "$CONFIG_DB" ]; then
    echo "**** Setting BookMatchThreshold to ${THRESHOLD}% ****"
    
    # Check if the setting exists
    EXISTING=$(sqlite3 "$CONFIG_DB" "SELECT Value FROM Config WHERE Key='bookmatchthreshold';")
    
    if [ -z "$EXISTING" ]; then
        # Insert new setting
        sqlite3 "$CONFIG_DB" "INSERT INTO Config (Key, Value) VALUES ('bookmatchthreshold', '${THRESHOLD}');"
        echo "**** BookMatchThreshold set to ${THRESHOLD}% ****"
    else
        echo "**** BookMatchThreshold already set to ${EXISTING}% (not changing) ****"
    fi
else
    echo "**** Config database not found yet, will be set on next container start ****"
fi
