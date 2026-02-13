---
name: openscad-design
description: Use when designing or modifying OpenSCAD 3D printable models. Applies user preferences for kid safety, filament efficiency, multi-color printing, and FDM printability. Always ends with Bambu Lab slicer guidance.
---

# OpenSCAD Design Skill

You are designing a 3D-printable model in OpenSCAD. Follow these preferences and principles throughout the design process.

## Design Principles

### Kid Safety — No Sharp Edges
- Round ALL outer edges using `hull()` with spheres (top) and cylinders (bottom, for flat print surface)
- Round ALL inner edges where hands touch using quarter-round fillets (subtract cube-minus-cylinder)
- Round slot/cutout edges using `minkowski()` with `sphere()` on the cutout shapes
- Round transition edges (e.g., finger notches) using `minkowski()` on the subtracted shape
- Default rounding radius: 3mm. Expose as a `rounding` parameter for tuning
- Inner fillets need a `flip` parameter for near vs far wall orientation

### Filament Optimization
- Use thinnest viable walls: 2mm outer walls, 1.5mm internal dividers
- Minimize clearances: 1mm per slot unless the user specifies otherwise
- Prefer orientations that remove more material from the interior (e.g., cards wide-side-down creates wider slot cutouts = less plastic)
- Raised shelves instead of full-height slots when items are shorter than the box — the un-cut material below is handled by slicer infill
- Do NOT model grid/honeycomb patterns — let the slicer handle infill

### Parametric Design
- All measurements at the top of the file as named variables
- Group parameters by section: measurements, box design, lid design, snap fit, labels, layout
- Computed values in a calculations section after parameters
- Use `module` for each major piece (box, lid, labels, etc.)

### Multi-Piece / Multi-Color Support
- Add a `part` variable to select which piece to render
- Always include: individual parts for STL export, a combined preview, and an assembled preview
- For multi-color (AMS): separate colored elements into their own modules so they can be exported as independent STLs
- Use `color()` for visual preview — add `box_color` and `text_color` parameters
- For text labels: keep them in a separate `labels()` module, NOT inside the box module, so box and text can be exported independently
- Part options pattern:
  - `"both"` — all pieces side by side with colors (preview)
  - `"box_only"` — box body without text (STL export)
  - `"text"` — text only (STL export)
  - `"lid"` — lid only (STL export)
  - `"assembled"` — everything stacked as it would look in use (preview)

### Friction-Fit Lids
- Default tolerance: `lid_tol = 0.5mm` per side (FDM-safe; 0.3mm is too tight)
- Lid top plate: full outer footprint, 2.5mm thick
- Lip/rim: hangs down inside box, 1.5mm wall thickness, 8mm depth
- Print orientation: top plate on bed, lip pointing up (no supports needed)
- Round lid vertical edges with `minkowski()` + cylinder (lid is too thin for sphere rounding)
- Add `lip_inset` (lid_wall + lid_tol) between outer walls and internal slots to prevent lid lip from colliding with contents

### Snap-Fit Locking
- Small sphere bumps (`snap_r = 0.8mm`) on the lid lip outer face
- Matching sphere grooves subtracted from box inner walls
- Place on walls with solid material behind them (not where slot cutouts are)
- Bumps positioned near the lip tip for a click at full insertion
- The lip wall (1.5mm) provides flex for snap engagement
- Bump protrusion (0.8mm) minus gap (0.5mm) = 0.3mm flex — achievable for thin PLA walls

### Text/Labels
- Use `text()` with `linear_extrude()` for embossed labels
- Front face rotation: `rotate([90, 0, 0])` — extrudes outward in -Y, readable from front
- Back face rotation: `rotate([90, 0, 180])` — extrudes outward in +Y, readable from back
- Default: `text_depth = 1mm`, `text_size = 10`
- Text requires F6 (full render) in OpenSCAD to be visible

### Tolerance Verification Checklist
Before finalizing any design, verify:
- [ ] All items fit with clearance (account for rounding reducing usable space at corners)
- [ ] Lid lip does not collide with contents (lip_inset between walls and slots)
- [ ] Device/tall items have enough height (rounding raises effective slot floor by `rounding` mm)
- [ ] Lid gap is exactly `lid_tol` per side on all axes
- [ ] Snap bumps are on solid walls, not where cutouts exist
- [ ] No zero-clearance dimensions (always add `clearance` to both width AND depth of item slots)

## Print Guidance — Always Include at End

After the design is complete, ALWAYS provide step-by-step Bambu Lab / Bambu Studio slicer guidance:

### Slicer Settings Checklist
1. **Import STLs** — import each part separately (`box_only`, `text`, `lid`)
2. **Filament assignment** — assign colors per object for AMS multi-color
3. **Supports**:
   - Enable only if slicer flags overhangs (bridging areas like finger notches)
   - Type: Tree (Auto) or Paint-on (preferred — paint only where needed)
   - Support filament: PLA support filament (not dissolvable unless available)
   - Support/Raft base: regular PLA (cheaper)
   - Support/Raft interface: support filament (clean separation)
   - Top Z distance: 0.2mm (default, for snap-off support)
   - Interface layers: 2
   - Support on build plate only: OFF (mid-air overhangs need support too)
4. **Filament savings**:
   - Sparse infill density: 10-15%
   - Sparse infill pattern: Gyroid
   - Wall loops: 2
   - Top/bottom shell layers: 3
   - Top paint penetration layer: 1 (for multi-color, prevents waste)
5. **Verify** — scrub through layer preview to confirm supports only appear where expected

## Repository Workflow

All OpenSCAD models live in `git@github.com:krishnakb/openSCAD-models.git`, cloned at `~/codebase/krishnakb/openSCAD-models`.

### Directory Structure
```
openSCAD-models/
├── models/
│   ├── organizers/
│   │   ├── flashcards-set-container/
│   │   └── butterbox/
│   └── accessories/
│       └── vacuum-extension/
└── skills/
    └── openscad-design/
        └── SKILL.md
```

### For Every New Design
1. Create a new folder under `models/<category>/<project-name>/`
2. Place the `.scad` file(s) there
3. Commit and push to the repo
4. If the skill (SKILL.md) was updated during the session, copy the updated version to both `~/.claude/skills/openscad-design/SKILL.md` and `skills/openscad-design/SKILL.md` in the repo, then commit and push
