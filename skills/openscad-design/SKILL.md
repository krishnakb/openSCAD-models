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

### Ghost/Phantom Insert Objects
- ALWAYS add a `ghost_contents()` module showing translucent representations of items that go inside
- NEVER include ghost objects in exportable parts (`box_only`, `lid`, `text`) — only in preview parts (`both`, `assembled`)
- Use `color("name", 0.4)` for 40% opacity per item type
- Use distinct colors per category (e.g., red/green/blue/orange for card slots, purple for devices)
- Show items at actual dimensions (no clearance) so the gap between ghost and slot walls visualizes fit
- Include ghost contents in `"both"` and `"assembled"` views
- This lets the user see what real life looks like before printing

### Over-Fit Lids (Preferred)
- Default tolerance: `lid_tol = 0.5mm` per side (FDM-safe; 0.3mm is too tight)
- Lid skirt goes OVER the box exterior, not inside
- `lid_outer_w/y = outer_w/y + 2 * lid_tol` (inner opening matches box + gap)
- `lid_full_w/y = lid_outer_w/y + 2 * lid_wall` (total lid footprint)
- Top plate: full lid footprint, 2.5mm thick
- Skirt: hollow rectangle, 1.5mm wall thickness, 8mm depth
- Print orientation: top plate on bed, skirt pointing up (no supports needed)
- Round lid vertical edges with `minkowski()` + cylinder
- Grid cutouts in top plate for material savings (solid border + ribs, rectangular holes)
- No `lip_inset` needed — skirt is exterior so it doesn't interfere with contents

### Snap-Fit Locking (Over-Fit)
- Small sphere grooves (`snap_r = 0.8mm`) subtracted from box OUTER walls
- Matching sphere bumps on lid skirt INNER face
- Place at Y midpoint of box, near skirt bottom (`lip_h - 2*snap_r` from top)
- The skirt wall (1.5mm) provides flex for snap engagement
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
- [ ] Over-fit lid skirt clears box exterior by `lid_tol` per side
- [ ] Device/tall items have enough height (rounding raises effective slot floor by `rounding` mm)
- [ ] Lid gap is exactly `lid_tol` per side on all axes
- [ ] Snap bumps are on solid walls, not where cutouts exist
- [ ] No zero-clearance dimensions (always add `clearance` to both width AND depth of item slots)
- [ ] Assembled view: lid sits flush on box top, skirt hangs down, snaps align in Z/Y

### Assembly Transform (Over-Fit Lid)
The lid prints with top plate on bed, skirt up. To assemble:
```
translate([-(lid_tol + lid_wall), -(lid_tol + lid_wall), box_h + floor + lid_top])
    mirror([0, 0, 1])
        lid();
```
- `mirror([0,0,1])` flips skirt downward
- X/Y offset centers lid over box (accounts for tolerance + wall overhang)
- Z places plate bottom at box top

## STL Export via CLI

OpenSCAD CLI is at `/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD`. Use `-D` to override the `part` variable and `-o` for output.

Export all printable parts in parallel:
```bash
SCAD="/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
"$SCAD" -o box.stl -D 'part="box_only"' file.scad
"$SCAD" -o lid.stl -D 'part="lid"' file.scad
"$SCAD" -o text.stl -D 'part="text"' file.scad
```

- Export each printable piece as a separate STL (box, lid, text)
- Use timeout of 120s — box renders can take 30-40s with minkowski
- Verify output reports `Simple: yes` (no geometry errors)
- Place STLs in the same directory as the .scad file
- Always offer to export STLs when a design is finalized

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
