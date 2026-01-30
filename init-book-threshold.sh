#!/usr/bin/with-contenv bash
# Set Book Match Threshold via BOOKMATCH_THRESHOLD environment variable (default 40%)

CONFIG_DB="/config/readarr.db"
# Allow threshold to be set via environment variable, default to 40
THRESHOLD=${BOOKMATCH_THRESHOLD:-40}
# Set to 1 to force overwrite even if a value already exists
OVERWRITE=${OVERWRITE_BOOKMATCH_THRESHOLD:-0}

# Install sqlite3 if not available (Alpine Linux uses apk, not apt-get)
if ! command -v sqlite3 &> /dev/null; then
    echo "**** Installing sqlite3... ****"
    apk add --no-cache sqlite > /dev/null 2>&1
    if ! command -v sqlite3 &> /dev/null; then
        echo "**** ERROR: Failed to install sqlite3. Cannot set BookMatchThreshold. ****"
        exit 1
    fi
    echo "**** sqlite3 installed successfully ****"
fi

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
    EXISTING=$(sqlite3 "$CONFIG_DB" "SELECT Value FROM Config WHERE Key='bookmatchthreshold';" 2>/dev/null)
    
    if [ -z "$EXISTING" ]; then
        # Insert new setting
        if sqlite3 "$CONFIG_DB" "INSERT INTO Config (Key, Value) VALUES ('bookmatchthreshold', '${THRESHOLD}');" 2>/dev/null; then
            echo "**** BookMatchThreshold set to ${THRESHOLD}% ****"
        else
            echo "**** ERROR: Failed to insert BookMatchThreshold ****"
        fi
    else
        if [ "$OVERWRITE" = "1" ]; then
            if sqlite3 "$CONFIG_DB" "UPDATE Config SET Value='${THRESHOLD}' WHERE Key='bookmatchthreshold';" 2>/dev/null; then
                echo "**** BookMatchThreshold overwritten to ${THRESHOLD}% (was ${EXISTING}%) ****"
            else
                echo "**** ERROR: Failed to update BookMatchThreshold ****"
            fi
        else
            echo "**** BookMatchThreshold already configured at ${EXISTING}% (not changing) ****"
        fi
    fi
else
    echo "**** Config database not found after waiting. Readarr may need to complete first-time setup. ****"
fi
