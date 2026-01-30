# Readarr with Custom Book Match Threshold

This setup uses the official LinuxServer.io Readarr image with a custom book match threshold of 40% (default is 80%).

## Step-by-Step Setup

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

### 5. Complete Readarr initial setup
1. Open http://localhost:8787
2. Complete the initial setup wizard
3. The threshold will be set automatically

### 6. Verify the setting was applied
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
docker-compose logs readarr
```
Look for lines like: `**** Setting BookMatchThreshold to 40% ****`

### Database not found on first start?
This is normal. Readarr creates the database after initial setup. The script will set the threshold on the second container start.

**Solution:** After completing the Readarr setup wizard, restart the container:
```bash
docker-compose restart
```

### Want to force the script to run again?
Delete the setting and restart:
```bash
docker exec readarr-jm sqlite3 /config/readarr.db "DELETE FROM Config WHERE Key='bookmatchthreshold';"
docker-compose restart
```
