# Winter daily report (CUI snow)

You are running on Marc's **propel-mac** machine against repo `masrab91-blip/CUI-Jobber`.

Read `WINTER_OPS.md` first.

## Goal

Produce Marc's end-of-day (or end-of-shift) CUI snow summary for the winter season ops.

## Scope

- **11 enterable CUI properties** + **Windcrest flag-only**
- Source: today's Jobber snow visits and any CUI entries already written this session
- Output: email Marc an xlsx (and a short chat summary)

## Rules

- Do **not** invent entries. Report what was actually visited / entered / flagged.
- Windcrest never counts as Entered — Flagged only.
- Call out missing before/after photos, unmatched Jobber visits, and CUI write failures.
- Confirm whether the report is **AM**, **PM**, or full-day.

## Steps

1. Gather today's Entered and Flagged rows (from the latest session artifacts, Outlook sent items, or by re-checking Jobber/CUI).
2. Build `CUI-snow-daily.xlsx` (or reuse `CUI-snow-session.xlsx`) with sheets **Entered** and **Flagged**.
3. Email Marc (`marc@makeitpropel.com` / `marc.stewart09@yahoo.com`):
   - Subject: `CUI snow daily - <date> - <N> entered, <M> flagged`
   - Body: counts, AM/PM, blockers, Windcrest note if flagged
   - Attachment: the xlsx
4. Reply in chat with the same summary.

## Suggested columns

Same as `prompts/winter-entry-run.md` (Property, Visit date, AM/PM, Service, status/reason, photos, notes).
