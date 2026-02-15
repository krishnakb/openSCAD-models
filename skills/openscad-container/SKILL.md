---
name: openscad-container
description: Use when designing OpenSCAD containers, boxes, or organizers with lids. Extends openscad-design with over-fit lids, snap-fit locking, slots, dividers, and assembly transforms. Always use alongside openscad-design.
---

# OpenSCAD Container Skill

Extends `openscad-design` with container-specific patterns. Use BOTH skills together when designing boxes, organizers, or any model with a lid.

## Container Part Options
```
part = "both";       // all pieces side by side (preview)
part = "box_only";   // box body without text (STL export)
part = "text";       // text labels only (STL export)
part = "lid";        // lid only (STL export)
part = "assembled";  // everything stacked as in use (preview)
```

## Over-Fit Lids (Preferred)
- Lid skirt goes OVER the box exterior, not inside
- `lid_tol = 0.5mm` gap per side between skirt inner face and box outer wall
- `lid_outer_w/y = outer_w/y + 2 * lid_tol` (inner opening matches box + gap)
- `lid_full_w/y = lid_outer_w/y + 2 * lid_wall` (total lid footprint)
- Top plate: full lid footprint, `lid_top = 2.5mm` thick
- Skirt: hollow rectangle, `lid_wall = 1.5mm` wall thickness, `lip_h = 8mm` depth
- Print orientation: top plate on bed, skirt pointing up (no supports needed)
- Round lid vertical edges with `minkowski()` + cylinder
- Grid cutouts in top plate for material savings (solid border + ribs, rectangular holes)
- No `lip_inset` needed — skirt is exterior so it doesn't interfere with contents

## Snap-Fit Locking (Over-Fit)
- Small sphere grooves (`snap_r = 0.8mm`) subtracted from box OUTER walls
- Matching sphere bumps on lid skirt INNER face
- Place at Y midpoint of box, near skirt bottom (`lip_h - 2*snap_r` from top)
- The skirt wall (1.5mm) provides flex for snap engagement
- Bump protrusion (0.8mm) minus gap (0.5mm) = 0.3mm flex — achievable for thin PLA walls

## Slot Design
- Half-height dividers when finger access is needed — use `divider_height` parameter
- Shared upper trough (single large cutout spanning all slots above divider height) for open finger space
- Alternating slot X offset (`slot_offset`) to stagger items for easier grabbing
- Raised shelves (`card_shelf`) for items shorter than box height — saves material below

## Assembly Transform (Over-Fit Lid)
The lid prints with top plate on bed, skirt up. To place on box:
```
translate([-(lid_tol + lid_wall), -(lid_tol + lid_wall), box_h + floor + lid_top])
    mirror([0, 0, 1])
        lid();
```
- `mirror([0,0,1])` flips skirt downward
- X/Y offset centers lid over box (accounts for tolerance + wall overhang)
- Z places plate bottom at box top

## Container Tolerance Checklist
Before finalizing, verify:
- [ ] All items fit with clearance (rounding reduces usable space at corners)
- [ ] Over-fit lid skirt clears box exterior by `lid_tol` per side
- [ ] Tall items have enough height (rounding raises effective slot floor by `rounding` mm)
- [ ] Lid gap is exactly `lid_tol` per side on all axes
- [ ] Snap bumps on solid walls, not where cutouts exist
- [ ] Assembled view: lid sits flush on box top, skirt hangs down, snaps align in Z/Y
- [ ] Ghost contents visible in preview, absent from exportable parts
