# CUI Winter Ops (Snow Entry)

**Mode:** LIVE snow entry on Marc's `propel-mac` worker  
**Repo:** `https://github.com/masrab91-blip/CUI-Jobber`  
**Flow:** Jobber visits → CUI entry → email Marc xlsx report

## Rules (non-negotiable)

1. **Live mode** — write real CUI snow entries (not dry-run) unless the operator explicitly asks for dry-run.
2. **11 CUI properties** — enter snow work for the enterable sites listed below.
3. **Jobber → CUI** — source completed snow visits from Jobber; enter matching work in the CUI app/portal.
4. **Email Marc xlsx** — after each session, email an Excel workbook (`CUI-snow-session.xlsx`) with sheets **Entered** and **Flagged** to Marc (`marc@makeitpropel.com` / `marc.stewart09@yahoo.com`).
5. **Windcrest = flag-only** — never create a CUI entry for Windcrest; report it on the Flagged sheet only (`Windcrest not in CUI` / remote ATM).
6. **AM/PM confirm** — confirm morning vs afternoon shift/context before entering; note AM or PM on each row.
7. **Before/after photos required** — every enterable visit must have before and after photos (Sitefotos / Jobber). If missing, flag and do not enter.

## Enterable CUI properties (11)

| # | Property | Address |
|---|----------|---------|
| 1 | East Town | 545 E. Eighth Street, Holland, MI 49423 |
| 2 | Douglas | 60 Middle Street, Douglas, MI 49406 |
| 3 | 32nd & State - remote ATM | 201 E. 32nd Street, Holland, MI 49423 |
| 4 | Allendale | 5980 Lake Michigan Dr, Allendale, MI 49401 |
| 5 | Bayberry | 5745 Byron Center Ave SW, Wyoming, MI 49519 |
| 6 | Grandville Wilson | 4495 Wilson Ave SW, Grandville, MI 49418 |
| 7 | Jenison (REFS) | 501 Baldwin Street, Jenison, MI 49428 |
| 8 | North River | 329 N. River Avenue, Holland, MI 49424 |
| 9 | Standale | 3901 Lake Michigan Drive NW, Grand Rapids, MI 49544 |
| 10 | West Shore | 3413 West Shore Drive, Holland, MI 49424 |
| 11 | Zeeland Main | 101-109 E. Main Street, Zeeland, MI 49464 |

## Flag-only (do not enter in CUI)

| Property | Address | Reason |
|----------|---------|--------|
| Windcrest ATM | 762 Windcrest, Holland, MI 49423 | Not in CUI / remote ATM — flag only |

## Typical CUI service line

- Snow plow / snow services: **SN - Per Plow** (match Jobber visit type when present)

## Mac worker setup (`propel-mac`)

1. Clone this repo to `~/CUI-Jobber` (or keep it updated with `git pull`).
2. Store Cursor API key at `~/.config/propel/cursor-api-key` (or export `CURSOR_API_KEY`). Never commit keys.
3. Keep the self-hosted worker online:

```bash
cd ~/CUI-Jobber
agent worker --computer-use --name "propel-mac" --worker-dir "$(pwd)" start
```

4. Install LaunchAgents (optional but recommended):

```bash
cp scripts/mac/com.propel.propel-mac-worker.plist ~/Library/LaunchAgents/
cp scripts/mac/com.propel.cui-winter-entry.plist ~/Library/LaunchAgents/
# Edit WorkingDirectory / paths in the plists if your clone is not ~/CUI-Jobber
launchctl load ~/Library/LaunchAgents/com.propel.propel-mac-worker.plist
launchctl load ~/Library/LaunchAgents/com.propel.cui-winter-entry.plist
```

5. Manual winter entry kickoff:

```bash
./scripts/mac/start-winter-entry.sh
```

## Prompts

| File | Purpose |
|------|---------|
| `prompts/winter-entry-run.md` | Live snow-entry agent prompt (used by `start-winter-entry.sh`) |
| `prompts/winter-daily-report.md` | End-of-day / summary report prompt |

## Session outputs

- Email subject pattern: `CUI snow entries - <N> entered, <M> flagged`
- Attachment: `CUI-snow-session.xlsx` (sheets: **Entered**, **Flagged**)
- Flagged rows include: Windcrest, missing photos, non-snow Jobber visits, ambiguous matches, CUI write failures
