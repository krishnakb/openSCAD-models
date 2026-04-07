// ============================================================
// Power Strip Wall Mount Clips
// ============================================================
// Two-clip system for vertical wall mounting.
// Removal method: lift strip upward to disengage.
//
// Install:
//   1. Tilt top of strip toward wall, slide it up into the top clip.
//   2. Press the bottom against the wall and drop it onto the bottom clip floor.
// Remove:
//   1. Lift strip up until the bottom clears the bottom clip floor.
//   2. Tilt bottom of strip away from wall, slide strip down and out.
//
// Wall mounting:
//   - Mount TOP clip so its bottom edge is ~20 mm from the strip's top end.
//   - Mount BOTTOM clip so its top edge (floor) is ~20 mm from the strip's bottom end.
//   - Recommended vertical center-to-center spacing between clips: ~257 mm
//     (for a 317 mm strip with 20 mm clearance each end + 40 mm clip height)
// ============================================================

// --- Strip Dimensions (measured) ---
strip_w = 50;       // width across the outlet face (mm)
strip_d = 40;       // depth front-to-back (mm)
strip_l = 317;      // total length — reference only, not used in geometry

// --- Fit ---
tol = 0.5;          // clearance added per side so strip slides in easily

// --- Clip Geometry ---
wall_t = 4;         // wall thickness (mm)
clip_h = 40;        // height of each clip (mm)
lip_h  = 12;        // height of the front retaining lip (mm)

// --- Wall Screws (M4 countersunk) ---
screw_d      = 4.0;   // shank diameter
screw_head_d = 8.0;   // countersunk head diameter
screw_head_h = 3.0;   // countersunk recess depth

// --- Part to render ---
// "bottom"  — bottom clip only (has floor; strip rests on it)
// "top"     — top clip only   (open bottom; lip retains strip at top)
// "both"    — both clips side by side (default preview / layout for printing)
part = "both";

$fn = 32;

// --- Derived ---
iw = strip_w + 2*tol;   // inner channel width
id = strip_d + tol;     // inner channel depth (tolerance only on open/front side)
ow = iw + 2*wall_t;     // outer width

// ============================================================
module _screw_holes() {
    for (z = [clip_h * 0.28, clip_h * 0.72]) {
        translate([ow/2, -0.1, z])
        rotate([-90, 0, 0]) {
            cylinder(d=screw_head_d, h=screw_head_h + 0.1);   // countersink recess
            cylinder(d=screw_d,      h=wall_t + 0.2);          // through-hole
        }
    }
}

// Bottom clip — strip bottom end rests on the floor; front lip at the bottom
// prevents the strip from tipping away from the wall.
module bottom_clip() {
    difference() {
        union() {
            // Back plate (against wall)
            cube([ow, wall_t, clip_h]);
            // Left side wall
            translate([0, wall_t, 0])
                cube([wall_t, id, clip_h]);
            // Right side wall
            translate([ow - wall_t, wall_t, 0])
                cube([wall_t, id, clip_h]);
            // Floor — strip bottom end sits on this
            cube([ow, wall_t + id, wall_t]);
            // Front retaining lip at bottom
            translate([wall_t, wall_t + id, 0])
                cube([iw, wall_t, lip_h]);
        }
        _screw_holes();
    }
}

// Top clip — open at the bottom so the strip slides up in;
// front lip at the top keeps the strip from pulling away.
module top_clip() {
    difference() {
        union() {
            // Back plate (against wall)
            cube([ow, wall_t, clip_h]);
            // Left side wall
            translate([0, wall_t, 0])
                cube([wall_t, id, clip_h]);
            // Right side wall
            translate([ow - wall_t, wall_t, 0])
                cube([wall_t, id, clip_h]);
            // Front retaining lip at top
            translate([wall_t, wall_t + id, clip_h - lip_h])
                cube([iw, wall_t, lip_h]);
        }
        _screw_holes();
    }
}

// ============================================================
if (part == "bottom") {
    bottom_clip();
} else if (part == "top") {
    top_clip();
} else {
    // Both side by side for preview / single-plate print layout
    bottom_clip();
    translate([ow + 15, 0, 0])
        top_clip();
}
