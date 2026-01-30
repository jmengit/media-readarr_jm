# Readarr Book Match Threshold

Automatically set the Book Match Threshold in Readarr to 40% (or any value you prefer) via Docker initialization scripts. This modifies the database configuration directly.

**Works with new and existing Readarr installations!**

## What It Does

- Sets `bookmatchthreshold` in the Readarr SQLite database on container start
- Default threshold: **40%** (Readarr default is 80%)
- Runs automatically via LinuxServer.io's `custom-cont-init.d` system
- On first run: Sets the value in the database
- On subsequent runs: Preserves the existing value (won't overwrite)
- Optional: Force overwrite via `OVERWRITE_BOOKMATCH_THRESHOLD` environment variable

## Quick Start

### For New Installations

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jmengit/media-readarr_jm.git
   cd media-readarr_jm
   ```

2. **Start Readarr:**
   ```bash
   docker-compose up -d
   ```

3. **Verify the setting was applied:**
   ```bash
   docker exec readarr-jm sqlite3 /config/readarr.db "SELECT Value FROM Config WHERE Key='bookmatchthreshold';"
   ```
   You should see: `40`

4. **Access Readarr:**
   - Open http://localhost:8787
   - Complete the setup wizard if first-time setup

### For Existing Installations

Add the init script to your existing docker-compose:

```yaml
services:
  readarr:
    image: lscr.io/linuxserver/readarr:develop
    container_name: readarr
    volumes:
      - ./readarr-config:/config
      - ./books:/books
      - ./downloads:/downloads
      - ./init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro
    ports:
      - 8787:8787
    restart: unless-stopped
```

Then restart your container:
```bash
docker-compose down
docker-compose up -d
```

Or with `docker run`:
```bash
docker run -d \
  --name=readarr \
  -p 8787:8787 \
  -v /path/to/config:/config \
  -v /path/to/books:/books \
  -v /path/to/downloads:/downloads \
  -v /path/to/init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro \
  --restart unless-stopped \
  lscr.io/linuxserver/readarr:develop
```

## Customization

### Change the Threshold Value

#### Option A: Via Environment Variable (Recommended)

Set the `BOOKMATCH_THRESHOLD` environment variable in docker-compose:

```yaml
services:
  readarr:
    environment:
      - BOOKMATCH_THRESHOLD=50
```

Then start or restart:
```bash
docker-compose up -d
# or restart if already running
docker-compose restart
```

#### Option B: Edit the Script

Edit `init-book-threshold.sh` and modify line 6:

```bash
THRESHOLD=50  # Change to any value between 0-100
```

Then restart the container:
```bash
docker-compose restart
```

### Force Overwrite on Every Start

By default, the script preserves existing values. To force the threshold to be set on every container start, set `OVERWRITE_BOOKMATCH_THRESHOLD=1`:

```yaml
services:
  readarr:
    environment:
      - BOOKMATCH_THRESHOLD=40
      - OVERWRITE_BOOKMATCH_THRESHOLD=1
```

Now the script will update the threshold on every container start (useful for enforcing a specific value).

## Running Multiple Scripts

If you have an entire `scripts/` folder with multiple initialization scripts, mount the entire folder to the custom init directory:

```yaml
services:
  readarr:
    image: lscr.io/linuxserver/readarr:develop
    volumes:
      - ./readarr-config:/config
      - ./books:/books
      - ./downloads:/downloads
      - ./scripts:/custom-cont-init.d:ro
```

**How it works:**
- All scripts in your `./scripts/` folder execute automatically on container start
- Scripts run in **alphabetical order** by filename
- Use numeric prefixes to control execution order: `01-setup.sh`, `02-threshold.sh`, `99-cleanup.sh`
- Each script must be executable: `chmod +x scripts/*.sh`

**Example folder structure:**
```
scripts/
  01-init-database.sh
  02-book-threshold.sh
  03-configure-imports.sh
  99-final-cleanup.sh
```

## Docker Compose Configuration

### Complete Example

```yaml
version: "3.8"

services:
  readarr:
    image: lscr.io/linuxserver/readarr:develop
    container_name: readarr-jm
    environment:
      - PUID=1000                    # User ID (Linux: use `id -u`)
      - PGID=1000                    # Group ID (Linux: use `id -g`)
      - TZ=America/New_York          # Timezone
      - UMASK=022                    # File permissions mask (optional)
      - BOOKMATCH_THRESHOLD=40       # Book match threshold (0-100, default 40)
      - OVERWRITE_BOOKMATCH_THRESHOLD=0  # Force overwrite on every start (0=no, 1=yes)
    volumes:
      - ./readarr-config:/config     # Configuration & database
      - ./books:/books               # Your book library
      - ./downloads:/downloads       # Download client folder
      - ./init-book-threshold.sh:/custom-cont-init.d/99-book-threshold.sh:ro
      # Uncomment for multiple scripts:
      # - ./scripts:/custom-cont-init.d:ro
    ports:
      - 8787:8787
    restart: unless-stopped
```

### Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | 1000 | User ID for file permissions |
| `PGID` | 1000 | Group ID for file permissions |
| `TZ` | America/New_York | Timezone ([list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `UMASK` | 022 | File creation mask for permissions |
| `BOOKMATCH_THRESHOLD` | 40 | Book match threshold percentage (0-100) |
| `OVERWRITE_BOOKMATCH_THRESHOLD` | 0 | Force overwrite threshold on every start (0=no, 1=yes) |

## Checking the Configuration

After starting the container, verify the threshold was set:

```bash
# Check the database value
docker exec readarr-jm sqlite3 /config/readarr.db "SELECT Value FROM Config WHERE Key='bookmatchthreshold';"

# Check container logs for the script output
docker logs readarr-jm | grep BookMatchThreshold
```

Expected log output:
```
**** BookMatchThreshold set to 40% ****
```

Or on subsequent starts:
```
**** BookMatchThreshold already configured at 40% (not changing) ****
```

## Modifying the Threshold

### Option 1: Via Environment Variable (Easiest)

Update the `BOOKMATCH_THRESHOLD` environment variable in docker-compose and restart:

```yaml
environment:
  - BOOKMATCH_THRESHOLD=50
```

```bash
docker-compose restart
```

### Option 2: Edit the Script and Restart

1. Edit `init-book-threshold.sh` line 6:
   ```bash
   THRESHOLD=50  # Change this value
   ```

2. Clear the existing setting:
   ```bash
   docker exec readarr-jm sqlite3 /config/readarr.db "DELETE FROM Config WHERE Key='bookmatchthreshold';"
   ```

3. Restart the container:
   ```bash
   docker-compose restart
   ```

### Option 3: Force Overwrite with Environment Variable

Add to docker-compose:
```yaml
environment:
  - BOOKMATCH_THRESHOLD=50
  - OVERWRITE_BOOKMATCH_THRESHOLD=1
```

Then restart:
```bash
docker-compose restart
```

### Option 4: Direct Database Modification

```bash
docker exec readarr-jm sqlite3 /config/readarr.db "UPDATE Config SET Value='50' WHERE Key='bookmatchthreshold';"
```

## Troubleshooting

### Script didn't run
Check the logs:
```bash
docker logs readarr-jm
```

Look for lines starting with `**** BookMatchThreshold` or `**** Checking BookMatchThreshold`

### Setting not applied
The script waits up to 60 seconds for the Readarr database to be created. If it times out:
```bash
docker logs readarr-jm | grep "Waiting for Readarr database"
```

You may need to wait longer or restart:
```bash
docker-compose restart
```

### Value different than expected
Check what's currently in the database:
```bash
docker exec readarr-jm sqlite3 /config/readarr.db "SELECT Key, Value FROM Config WHERE Key='bookmatchthreshold';"
```

If it exists but differs from your script, set `OVERWRITE_BOOKMATCH_THRESHOLD=1` to force the new value.

### Permission errors
Make sure your init script has execute permissions:
```bash
chmod +x init-book-threshold.sh
chmod +x scripts/*.sh  # If using a scripts folder
```

## Project Structure

```
media-readarr_jm/
├── init-book-threshold.sh      # Single script for threshold setting
├── docker-compose.yml          # Docker Compose configuration
├── scripts/                    # (Optional) Multiple initialization scripts
│   ├── 01-setup.sh
│   ├── 02-threshold.sh
│   └── 99-cleanup.sh
└── README.md
```

## Additional Resources

- [Readarr GitHub](https://github.com/Readarr/Readarr)
- [LinuxServer.io Readarr](https://github.com/linuxserver/docker-readarr)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Timezone Database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
