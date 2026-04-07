// ============================================================
// Power Strip Wall Mount Clips
// ============================================================
// Two-clip system for vertical wall mounting.
// Clips mount to wall via side flanges — fully accessible screws.
// Removal method: lift strip upward to disengage.
//
// Install:
//   1. Mount both clips to wall using flange screws (2 per clip).
//   2. Tilt top of strip toward wall, slide it up into the top clip.
//   3. Press the bottom against the wall and drop it onto the bottom clip floor.
// Remove:
//   1. Lift strip up until the bottom clears the bottom clip floor.
//   2. Tilt bottom of strip away from wall, slide strip down and out.
//
// Wall mounting:
//   - Mount TOP clip so its bottom edge is ~20 mm from the strip's top end.
//   - Mount BOTTOM clip so its floor is ~20 mm from the strip's bottom end.
//   - Recommended vertical center-to-center spacing between clips: ~257 mm
//     (for a 317 mm strip with 20 mm clearance each end + 40 mm clip height)
// ============================================================

// --- Strip Dimensions (measured) ---
strip_w = 50;       // width across the outlet face (mm)
strip_d = 40;       // depth front-to-back (mm)
strip_l = 317;      // total length — reference only, not used in geometry

// --- Fit ---
tol        = 0.5;   // clearance added per side so strip slides in easily
back_ridge = 1;     // height of back-face assembly ridges (mm)

// --- Cable ---
cable_w = 13.6;     // width of cable housing at bottom end (mm)

// --- Clip Geometry ---
wall_t   = 4;       // wall thickness (mm)
clip_h   = 40;      // height of each clip (mm)
lip_h    = 12;      // height of the front retaining lip (mm)
flange_w = 15;      // width of each side mounting flange (mm)

// --- Wall Screws (M4 countersunk) ---
screw_d      = 4.0;   // shank diameter
screw_head_d = 8.0;   // countersunk head diameter
screw_head_h = 3.0;   // countersunk recess depth

// --- Part to render ---
// "bottom"    — bottom clip only (has floor; strip rests on it)
// "top"       — top clip only   (open bottom; lip retains strip at top)
// "both"      — both clips side by side (print layout)
// "assembled" — both clips at install spacing with ghost strip
part = "assembled";

$fn = 32;

// --- Derived ---
iw = strip_w + 2*tol;   // inner channel width
id = strip_d + tol + back_ridge;   // inner channel depth: front tolerance + back ridge clearance
ow = iw + 2*wall_t;     // outer channel width (without flanges)

// ============================================================
// Screw holes centered on each side flange, one per flange.
module _flange_holes() {
    for (x = [-flange_w/2, ow + flange_w/2]) {
        translate([x, wall_t + 0.1, clip_h/2])
        rotate([90, 0, 0]) {
            cylinder(d=screw_head_d, h=screw_head_h + 0.1);   // countersink (opens toward front)
            cylinder(d=screw_d,      h=wall_t + 0.2);          // through-hole into wall
        }
    }
}

// Bottom clip — strip bottom end rests on the floor; front lip at the bottom
// prevents the strip from tipping away from the wall.
// Floor has a centered front-open notch for the cable exiting the bottom of the strip.
module bottom_clip() {
    cable_x = wall_t + tol + (strip_w - cable_w) / 2;   // notch centered on strip width
    difference() {
        union() {
            // Back plate spanning channel + both flanges
            translate([-flange_w, 0, 0])
                cube([ow + 2*flange_w, wall_t, clip_h]);
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
        _flange_holes();
        // Front-open cable notch through floor and full lip height
        translate([cable_x, -0.1, -0.1])
            cube([cable_w, wall_t + id + wall_t + 0.2, lip_h + 0.2]);
    }
}

// Top clip — open at the bottom so the strip slides up in;
// front lip at the top keeps the strip from pulling away.
module top_clip() {
    difference() {
        union() {
            // Back plate spanning channel + both flanges
            translate([-flange_w, 0, 0])
                cube([ow + 2*flange_w, wall_t, clip_h]);
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
        _flange_holes();
    }
}

// Ghost power strip — actual strip dimensions, no clearance.
// Only used in "assembled" preview; never included in printable parts.
module ghost_contents() {
    translate([wall_t, wall_t, wall_t])
        color("gray", 0.35)
            cube([strip_w, strip_d, strip_l]);
}

// ============================================================
// Assembled layout: bottom clip at z=0, top clip positioned so
// its top lip sits ~20 mm above the strip's top end.
top_clip_z = wall_t + strip_l + 20 - clip_h;   // = 301 mm

if (part == "bottom") {
    bottom_clip();
} else if (part == "top") {
    top_clip();
} else if (part == "both") {
    bottom_clip();
    translate([ow + 2*flange_w + 15, 0, 0])
        top_clip();
} else if (part == "assembled") {
    bottom_clip();
    translate([0, 0, top_clip_z])
        top_clip();
    ghost_contents();
}
