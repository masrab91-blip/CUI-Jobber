# Winter CUI snow entry (LIVE)

You are running on Marc's **propel-mac** machine against repo `masrab91-blip/CUI-Jobber`.

Read `WINTER_OPS.md` first and follow it exactly.

## Goal

Process today's (or the operator-specified window's) Jobber snow visits for the **11 enterable CUI properties**, enter matching snow work in CUI, then email Marc an xlsx session report.

## Hard rules

- **LIVE mode** — create real CUI entries. Only skip writes if the human says `DRY RUN`.
- **Jobber → CUI** — Jobber is the source of truth for what was done; CUI is where entries are written.
- **Windcrest = flag-only** — never enter Windcrest in CUI; put it on Flagged only.
- **AM/PM confirm** — establish AM vs PM for the session/visit before writing; record it on every Entered/Flagged row.
- **Before/after photos required** — if either is missing, do not enter; flag with reason `missing before/after photos`.
- **Keep Jobber site map pinned** — when going through Jobber notes/visits, keep the site map pinned to the top of the view the whole time so property/context stays visible. If it scrolls away or unpins, pin it again before continuing. Do this before reviewing last-3-days snow visits.
- Do not invent visits. If Jobber has nothing for a property, skip it (no fake entries).
- Prefer service line **SN - Per Plow** when the Jobber visit is a plow/snow service.

## Enterable properties (11)

East Town · Douglas · 32nd & State - remote ATM · Allendale · Bayberry · Grandville Wilson · Jenison (REFS) · North River · Standale · West Shore · Zeeland Main

## Flag-only

Windcrest ATM — `Windcrest not in CUI`

## Steps

1. Confirm AM/PM with the operator if not already clear; note the session date.
2. In Jobber, pin the site map to the top of the view and keep it pinned for the whole review. If it scrolls away or unpins, pin it again before continuing.
3. With the site map pinned, review last-3-days snow visits/notes and pull completed Jobber snow visits for the enterable properties (and note Windcrest if present).
4. For each enterable visit with before + after photos: enter in CUI (date, property, SN - Per Plow / matching service, notes as needed).
5. Collect Entered and Flagged rows.
6. Build `CUI-snow-session.xlsx` with sheets **Entered** and **Flagged**.
7. Email Marc (`marc@makeitpropel.com` and/or `marc.stewart09@yahoo.com`) with:
   - Subject: `CUI snow entries - <N> entered, <M> flagged`
   - Body: short summary (counts + any blockers)
   - Attachment: the xlsx
8. Reply in chat with the same summary and any items that need human follow-up.

## Suggested xlsx columns

**Entered:** Property, Address, Visit date, AM/PM, Service, Jobber ref, CUI status, Photos (Y/N), Notes  
**Flagged:** Property, Reason, Visit date, AM/PM, Jobber ref, Photos (Y/N), Notes

## Apps / tools on this Mac

Jobber · CUI portal/app · Sitefotos · Outlook (or Mail) for Marc · Discord if dispatch ping is needed
