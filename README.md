# DjangoCon US Video Tracking

Tracks YouTube video view counts for the
[DjangoConUS channel](https://www.youtube.com/@DjangoConUS) over time.

`program.py` uses [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) to fetch video
metadata (view count, title, URL) for every video on the channel and appends a
timestamped snapshot to a SQLite database (`views.db`). A GitHub Actions
workflow runs it daily, so the database builds up a historical record of how
view counts change over time. The data is browsable with
[`datasette`](https://datasette.io/).

## Requirements

- Python 3.14+
- `jq` (used by `program.py` to parse `yt-dlp` output)

## Usage

Install dependencies (with [`uv`](https://github.com/astral-sh/uv)):

```bash
uv pip install -r requirements.txt
```

Collect a snapshot into `views.db`:

```bash
python program.py
```

Browse the data:

```bash
datasette views.db
```

## How it works

- **`program.py`** — the only module. Runs `yt-dlp` against the DjangoConUS
  channel, pipes each video through `jq` to extract `view_count`, `title`, and
  `url`, and inserts a row into the `views` table (with an auto-populated
  `date` timestamp).
- **`views.db`** — SQLite database holding the historical snapshots.
- **`.github/workflows/update.yml`** — runs `program.py` on a daily cron and
  commits the updated database.

## Dependencies

Defined in `pyproject.toml`, compiled to `requirements.txt` with `uv`:

```bash
uv pip compile pyproject.toml -o requirements.txt
```

Dependabot checks for pip and GitHub Actions updates weekly.

## License

See [LICENSE](LICENSE).
