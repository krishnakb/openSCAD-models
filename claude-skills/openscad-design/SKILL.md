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
- Prefer orientations that remove more material from the interior
- Raised shelves instead of full-height slots when items are shorter than the box — the un-cut material below is handled by slicer infill
- Do NOT model grid/honeycomb patterns for solid walls/floors — let the slicer handle infill
- Grid cutouts on lids/covers ARE appropriate (structural, not infill)

### Parametric Design
- All measurements at the top of the file as named variables
- Group parameters by section: measurements, design, layout
- Computed values in a calculations section after parameters
- Use `module` for each major piece

### Multi-Piece / Multi-Color Support
- Add a `part` variable to select which piece to render
- Always include: individual parts for STL export, a combined preview, and an assembled preview
- For multi-color (AMS): separate colored elements into their own modules so they can be exported as independent STLs
- Use `color()` for visual preview — add color parameters
- For text labels: keep them in a separate `labels()` module, NOT merged into other geometry

### Ghost/Phantom Insert Objects
- ALWAYS add a `ghost_contents()` module showing translucent representations of items that go inside/onto the model
- NEVER include ghost objects in exportable parts — only in preview parts (`both`, `assembled`)
- Use `color("name", 0.4)` for 40% opacity per item type
- Use distinct colors per item category
- Show items at actual dimensions (no clearance) so the gap visualizes fit
- This lets the user see what real life looks like before printing

### Text/Labels
- Use `text()` with `linear_extrude()` for embossed labels
- Front face rotation: `rotate([90, 0, 0])` — extrudes outward in -Y, readable from front
- Back face rotation: `rotate([90, 0, 180])` — extrudes outward in +Y, readable from back
- Default: `text_depth = 1mm`, `text_size = 10`
- Text requires F6 (full render) in OpenSCAD to be visible

### General Tolerance
- Default tolerance for mating parts: `0.5mm` per side (FDM-safe; 0.3mm is too tight)
- Always add `clearance` to both width AND depth of item slots
- Account for rounding reducing usable space at corners

## STL Export via CLI

OpenSCAD CLI is at `/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD`. Use `-D` to override the `part` variable and `-o` for output.

Export all printable parts in parallel:
```bash
SCAD="/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
"$SCAD" -o part1.stl -D 'part="part1"' file.scad
"$SCAD" -o part2.stl -D 'part="part2"' file.scad
```

- Export each printable piece as a separate STL
- Use timeout of 120s — complex renders with minkowski can take 30-40s
- Verify output reports `Simple: yes` (no geometry errors)
- Place STLs in the same directory as the .scad file
- Always offer to export STLs when a design is finalized

## Print Guidance — Always Include at End

After the design is complete, ALWAYS provide step-by-step Bambu Lab / Bambu Studio slicer guidance:

### Slicer Settings Checklist
1. **Import STLs** — import each part separately
2. **Filament assignment** — assign colors per object for AMS multi-color
3. **Supports**:
   - Enable only if slicer flags overhangs
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
│   └── accessories/
└── skills/
    ├── openscad-design/
    │   └── SKILL.md
    └── openscad-container/
        └── SKILL.md
```

### For Every New Design
1. Create a new folder under `models/<category>/<project-name>/`
2. Place the `.scad` file(s) there
3. Commit and push to the repo
4. If any skill was updated, copy to both `~/.claude/skills/` and repo `skills/`, then commit and push
