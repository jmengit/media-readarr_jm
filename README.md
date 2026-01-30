# Readarr with Custom Book Match Threshold

This setup uses the official LinuxServer.io Readarr image with a custom book match threshold of 40% (default is 80%).

**Works with both new and existing Readarr installations!**

## For Existing Readarr Installations

### Option 1: Add to existing docker-compose

Add this volume mount to your existing Readarr service:
```yaml
services:
  readarr:
    image: lscr.io/linuxserver/readarr:develop
    # ... your existing config ...
    volumes:
      # ... your existing volumes ...
      - /path/to/init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro
```

### Option 2: Add to existing Docker run command

Add this flag to your `docker run` command:
```bash
-v /path/to/init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro
```

Full example:
```bash
docker run -d \
  --name=readarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -p 8787:8787 \
  -v /path/to/config:/config \
  -v /path/to/books:/books \
  -v /path/to/downloads:/downloads \
  -v /path/to/init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro \
  --restart unless-stopped \
  lscr.io/linuxserver/readarr:develop
```

### Steps for existing install:

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/jmengit/media-readarr_jm/develop/init-book-threshold.sh
   chmod +x init-book-threshold.sh
   ```

2. **Restart your container** (with the new volume mount added)

3. **Check the logs:**
   ```bash
   docker logs readarr
   ```
   You should see: `**** BookMatchThreshold set to 40% ****`

4. **Verify it was applied:**
   ```bash
   docker exec readarr sqlite3 /config/readarr.db "SELECT * FROM Config WHERE Key='bookmatchthreshold';"
   ```

## For New Readarr Installations

### Step-by-Step Setup

### 1. Clone or download this repository
```bash
git clone https://github.com/jmengit/media-readarr_jm.git
cd media-readarr_jm
```

### 2. Make the init script executable
```bash
chmod +x init-book-threshold.sh
```

**Windows users:** Skip this step - Docker Desktop handles this automatically.

### 3. (Optional) Customize the threshold
Edit `init-book-threshold.sh` and change line 5 if you want a different value:
```bash
THRESHOLD=40  # Change to any value between 0-100
```

### 4. Start the container
```bash
docker-compose up -d
```

### 5. Access Readarr and verify
1. Open http://localhost:8787
2. If this is a fresh install, complete the setup wizard
3. Check logs: `docker-compose logs readarr`
4. Verify setting:
   ```bash
   docker exec readarr-jm sqlite3 /config/readarr.db "SELECT * FROM Config WHERE Key='bookmatchthreshold';"
   ```
   Expected output: `bookmatchthreshold|40`

## How It Works

**The script runs every time the container starts**, but it has smart logic:
- **First run**: Inserts the threshold setting into the database
- **Subsequent runs**: Checks if the setting exists and does NOT change it
- **Result**: Your manual changes in the Readarr UI are preserved

This means you can:
- Let the script set it automatically on first run
- Or manually set it in Readarr UI (Settings → Media Management → Advanced)
- Either way, the script won't overwrite your choice

## Change the Threshold Later

### Method 1: Via Readarr UI (Recommended)
1. Go to Settings → Media Management
2. Click "Show Advanced" at the top
3. Change "Book Match Threshold"
4. Click Save

### Method 2: Via the init script
1. Stop the container: `docker-compose down`
2. Edit `init-book-threshold.sh` and change the `THRESHOLD` value
3. Delete the existing database setting:
   ```bash
   docker-compose up -d
   docker exec readarr-jm sqlite3 /config/readarr.db "DELETE FROM Config WHERE Key='bookmatchthreshold';"
   docker-compose restart
   ```
4. The script will now insert the new value on next start

## Volumes

Create these directories before starting (or let Docker create them):
- `./readarr-config` - Configuration and database
- `./books` - Your book library
- `./downloads` - Download client output folder

## Environment Variables

Adjust in `docker-compose.yml`:
- `PUID=1000` - User ID for file permissions (Linux/Mac: use `id -u`)
- `PGID=1000` - Group ID for file permissions (Linux/Mac: use `id -g`)
- `TZ=America/New_York` - Your timezone ([list here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))

## Troubleshooting

### Script not running?
Check the container logs:
```bash
docker logs readarr  # or: docker-compose logs readarr
```
Look for lines like: `**** BookMatchThreshold set to 40% ****`

### Already have a threshold configured?
The script will NOT overwrite your existing setting. You'll see:
```
**** BookMatchThreshold already configured at XX% (not changing) ****
```

To force it to apply the new value:
```bash
docker exec readarr sqlite3 /config/readarr.db "DELETE FROM Config WHERE Key='bookmatchthreshold';"
docker restart readarr
```

### Script says "already configured" but I don't see it in the UI?
The setting may be set to a different value. Check the current value:
```bash
docker exec readarr sqlite3 /config/readarr.db "SELECT * FROM Config WHERE Key='bookmatchthreshold';"
```

### Permission denied on Linux?
Make sure the script is executable:
```bash
chmod +x init-book-threshold.sh
```
