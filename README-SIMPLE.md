# Readarr with Custom Book Match Threshold

This setup uses the official LinuxServer.io Readarr image with a custom book match threshold of 40% (default is 80%).

## Quick Start

1. **Make the init script executable:**
   ```bash
   chmod +x init-book-threshold.sh
   ```

2. **Start the container:**
   ```bash
   docker-compose up -d
   ```

3. **Access Readarr:**
   Open http://localhost:8787

## How It Works

The `init-book-threshold.sh` script automatically sets the `BookMatchThreshold` to 40% in the database when the container starts. This only sets it on first run - if you've already configured it, it won't override your setting.

## Change the Threshold

Edit `init-book-threshold.sh` and change the `THRESHOLD` value:
```bash
THRESHOLD=40  # Change this to any value between 0-100
```

Then restart the container:
```bash
docker-compose restart
```

## Volumes

- `./readarr-config` - Configuration and database
- `./books` - Your book library
- `./downloads` - Download client output folder

## Environment Variables

Adjust in `docker-compose.yml`:
- `PUID=1000` - User ID for file permissions
- `PGID=1000` - Group ID for file permissions  
- `TZ=America/New_York` - Timezone

## Verifying the Setting

After first start, you can verify the setting was applied:
```bash
docker exec readarr-jm sqlite3 /config/readarr.db "SELECT * FROM Config WHERE Key='bookmatchthreshold';"
```

You should see output like: `bookmatchthreshold|40`
