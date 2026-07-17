# Level QA

This document tracks structural validation and playtest status for Cat Logic Mansion levels.

## Automated Validation

Run:

```bash
swift run validate-levels
```

Current result:

```text
PASS level_001.json
PASS level_002.json
PASS level_003.json
PASS level_004.json
PASS level_005.json
PASS level_006.json
PASS level_007.json
PASS level_008.json
PASS level_009.json
PASS level_010.json
PASS level_011.json
PASS level_012.json
PASS level_013.json
PASS level_014.json
PASS level_015.json

Validated 15 level file(s).
```

The validator checks:

- JSON decodes into the `Level` model.
- Map dimensions match `width`, `height`, and tile row lengths.
- Tile characters are limited to `#` and `.`.
- Player, exit, and objects are inside the map.
- Player, exit, and objects are not placed on walls.
- Object IDs are unique.
- `exit.unlockBy` points to an existing object.
- Object `targetIds` point to existing objects.

## Automated Solve Check

Run:

```bash
swift run solve-levels
```

Current result:

```text
PASS level_001.json
  clear: 8 moves, 3 star(s)
  3-star: 8 moves, 3 star(s)
PASS level_002.json
  clear: 9 moves, 3 star(s)
  3-star: 9 moves, 3 star(s)
PASS level_003.json
  clear: 9 moves, 2 star(s)
  3-star: 17 moves, 3 star(s)
PASS level_004.json
  clear: 9 moves, 2 star(s)
  3-star: 17 moves, 3 star(s)
PASS level_005.json
  clear: 15 moves, 3 star(s)
  3-star: 15 moves, 3 star(s)
PASS level_006.json
  clear: 11 moves, 2 star(s)
  3-star: 11 moves, 3 star(s)
PASS level_007.json
  clear: 11 moves, 2 star(s)
  3-star: 13 moves, 3 star(s)
PASS level_008.json
  clear: 16 moves, 2 star(s)
  3-star: 22 moves, 3 star(s)
PASS level_009.json
  clear: 10 moves, 2 star(s)
  3-star: 24 moves, 3 star(s)
PASS level_010.json
  clear: 13 moves, 2 star(s)
  3-star: 25 moves, 3 star(s)
PASS level_011.json
  clear: 26 moves, 2 star(s)
  3-star: 34 moves, 3 star(s)
PASS level_012.json
  clear: 26 moves, 2 star(s)
  3-star: 46 moves, 3 star(s)
PASS level_013.json
  clear: 17 moves, 2 star(s)
  3-star: 37 moves, 3 star(s)
PASS level_014.json
  clear: 22 moves, 2 star(s)
  3-star: 36 moves, 3 star(s)
PASS level_015.json
  clear: 17 moves, 2 star(s)
  3-star: 45 moves, 3 star(s)

Solved 15 level file(s).
```

This proves the current levels have at least one clear route and one 3-star route through the real `GameEngine` rules. Some fastest clear routes are 2-star routes because they skip optional collectibles. Levels 11-15 also have a regression test that rejects 3-star routes under 32 moves and verifies every placed mechanic object is used by the 3-star route.

## Manual Playtest Matrix

Automated validation does not prove a level is fun. Use this table for real playthrough notes.
The 2026-07-17 pass for levels 5-10 used scripted simulator replay through the app launch argument `--moves`, then captured the 3-star result screens in `docs/level_qa/scripted_replay/contact_sheet.png`.
The 2026-07-17 pass for levels 11-15 used the same scripted replay flow; evidence: `docs/level_qa/chapter_01_15/contact_sheet.png`.
The game board now scales tile size to fit the visible `SpriteView`, so wider or taller levels must show every grid cell instead of clipping edge columns or rows. Level 013 start-state evidence: `docs/level_qa/chapter_01_15/level_013_start_fit.png`.

| Level | Mechanic | Structural QA | Auto Clear | Auto Stars | Playable | 3-Star Checked | Notes |
|---|---|---:|---:|---:|---:|---:|---|
| level_001 | Movement, exit | Pass | Pass | 3 | Pass | Pass | Player-confirmed 3-star |
| level_002 | Walls | Pass | Pass | 3 | Pass | Pass | Player-confirmed 3-star |
| level_003 | Fish treats | Pass | Pass | 3 | Pass | Pass | Player-confirmed 3-star |
| level_004 | Key, locked exit | Pass | Pass | 3 | Pass | Pass | Player-confirmed 3-star |
| level_005 | Box push | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 15 moves; box route gates exit cleanly |
| level_006 | Box on button | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 11 moves; box-on-button visual fixed and door opens |
| level_007 | Temporary button | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 13 moves; temporary button tutorial remains readable |
| level_008 | Box, key, bridge | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 22 moves; bridge and key route verified |
| level_009 | Target steps | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 24 moves; route requires collection planning |
| level_010 | Chapter review | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 25 moves; chapter mechanics combine correctly |
| level_011 | Double treat detour | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 34 moves; box/button route and three fish detours verified |
| level_012 | Bridge and key loop | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 46 moves; box, button, bridge, key, and fish route verified |
| level_013 | Button hold | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 37 moves; compact board keeps larger tiles while requiring box-held button and collection backtracking |
| level_014 | Long gallery | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 36 moves; key, box/button door, and long route collection verified |
| level_015 | Foyer finale | Pass | Pass | 3 | Pass | Pass | Scripted simulator 3-star: 45 moves; box/button gate, bridge, door, key, and finale route verified |

## Scripted 3-Star Routes

| Level | Moves | Route |
|---|---:|---|
| level_005 | 15 | up right right right left left left up up up up right right right right |
| level_006 | 11 | up right left up up up up right right right right |
| level_007 | 13 | up up down down right right right right up up up up up |
| level_008 | 22 | up right right right down right right left left up left up up up up left left right right right right right |
| level_009 | 24 | up up up up up down down right right left left down down down right right right right right up up up up up |
| level_010 | 25 | up up right right right left up up left left right right right right right down down down down up up up up up up |
| level_011 | 34 | up up right right right right right right left left left left left left up up right right right right right right right right down down down down up up up up up up |
| level_012 | 46 | right right right right right right right right left left left left left left left left up up right right right right right right left left up up left left left left up up down down right right right right right right right right up up |
| level_013 | 37 | up up up up down right left down down right right right right right right right right up up up up left left left left left left left right right right right right right right up up |
| level_014 | 36 | left left left left left left left left up up right right right right right left left left up up left left up up down down right right right right right right right right up up |
| level_015 | 45 | right right right right right right right right up left left left left left left left left up up up up up up down down down down right right right right right left up up left left right right right right right right up up |

## Next QA Step

Do one human-play pass for levels 11-15 after this expansion, then record richer playtest notes:

- First successful completion moves.
- Best known 3-star moves.
- Any soft-lock or non-obvious reset moment.
- Whether target steps should be raised or lowered.
- Whether tutorial copy is enough for the introduced mechanic.
