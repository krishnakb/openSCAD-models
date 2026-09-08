/* ============================================================
   Rolled foam mat clamp
   A deep-throat C that slips over the end rim of a rolled mat:
   the inner leg drops into the hollow core, the outer leg rides
   the outside, and the bridge crosses the end face between them.
   The leg gap is a few mm under the mat's rolled wall thickness,
   so the compressed foam supplies the clamping force and every
   layer -- including the loose outer tail -- is pinned at once.
   Print TWO, one for each end of the roll.

   Modelled in print orientation: bridge flat on the bed, legs
   pointing up, no supports. In use the clamp sits over the roll
   with the legs pointing down.
   ============================================================ */

part = "both";   // "clamp" = printable STL, "both"/"assembled" = preview w/ ghost roll

/* ---------- Measurements (mm) ---------- */
roll_od = 260;   // outside diameter of the rolled-up mat
core_id = 110;   // diameter of the hollow core down the middle

/* ---------- Clamp ---------- */
squeeze   = 3;    // radial bite into the foam, per leg
leg_t     = 7;    // leg thickness
leg_h     = 55;   // how far the legs reach along the roll
bridge_t  = 8;    // bridge thickness (spans the end face)
arc       = 30;   // angular width of the clamp, degrees
lead_in   = 10;   // length of the tip flare that starts the clamp
lead_flare= 4;    // how far the tip flares open

/* ---------- Grip ridges (both leg faces) ---------- */
ridge_r     = 1.5;  // half sits proud of the face
ridge_n     = 3;
ridge_z0    = 20;   // first ridge, measured from the bed
ridge_pitch = 12;

/* ---------- Pull slot (finger hook / lanyard point) ---------- */
slot_w  = 10;
slot_r0 = 78;
slot_r1 = 112;

/* ---------- Design ---------- */
rounding      = 2;   // radius on every convex edge
corner_fillet = 6;   // gussets at the bridge-to-leg junctions

/* ---------- Preview ---------- */
ghost_roll_len = 300;  // shortened stand-in for the full-length roll

/* ---------- Calculations ---------- */
r_core   = core_id / 2;
r_out    = roll_od / 2;

ri_face  = r_core + squeeze;      // inner leg gripping face
ri_back  = ri_face - leg_t;       // inner leg back, sits inside the core
ro_face  = r_out - squeeze;       // outer leg gripping face
ro_back  = ro_face + leg_t;       // outer leg back, the outside of the clamp

leg_top  = bridge_t + leg_h;
flare_z  = leg_top - lead_in;
ri_tip   = ri_face - lead_flare;
ro_tip   = ro_face + lead_flare;

/* ============================================================
   2D profile, swept about the roll axis
   x = radius, y = height off the bed
   ============================================================ */

// Rounded bumps straddling a leg face; half the circle stands proud.
module grip_ridges() {
    for (i = [0 : ridge_n - 1]) {
        z = ridge_z0 + i * ridge_pitch;
        translate([ri_face, z]) circle(r = ridge_r, $fn = 16);
        translate([ro_face, z]) circle(r = ridge_r, $fn = 16);
    }
}

// Triangular gussets inside the mouth, stiffening the leg roots.
module corner_gussets() {
    polygon([[ri_face, bridge_t], [ri_face + corner_fillet, bridge_t],
             [ri_face, bridge_t + corner_fillet]]);
    polygon([[ro_face, bridge_t], [ro_face - corner_fillet, bridge_t],
             [ro_face, bridge_t + corner_fillet]]);
}

module clamp_profile() {
    union() {
        offset(r = rounding) offset(delta = -rounding)
            polygon([
                [ri_back, 0],       [ro_back, 0],
                [ro_back, leg_top], [ro_tip,  leg_top],
                [ro_face, flare_z], [ro_face, bridge_t],
                [ri_face, bridge_t],[ri_face, flare_z],
                [ri_tip,  leg_top], [ri_back, leg_top],
            ]);
        corner_gussets();
        grip_ridges();
    }
}

/* ============================================================
   Clamp body
   ============================================================ */

// Pie slice with rounded outer corners; trims the sweep so the
// arc ends are not sharp vertical edges.
module arc_wedge(h) {
    linear_extrude(h)
        offset(r = rounding) offset(delta = -rounding)
            polygon(concat([[0, 0]],
                [for (a = [-arc/2 : arc/40 : arc/2])
                    [2 * r_out * cos(a), 2 * r_out * sin(a)]]));
}

module pull_slot() {
    hull() for (r = [slot_r0, slot_r1])
        translate([r, 0, -1]) cylinder(d = slot_w, h = bridge_t + 2, $fn = 30);
}

module clamp() {
    difference() {
        intersection() {
            rotate([0, 0, -arc / 2])
                rotate_extrude(angle = arc, $fn = 180) clamp_profile();
            arc_wedge(leg_top + 10);
        }
        pull_slot();
    }
}

/* ============================================================
   Ghost roll (preview only, never exported)
   ============================================================ */

module ghost_contents() {
    color("sienna", 0.25)
        translate([0, 0, bridge_t])
            rotate_extrude($fn = 120)
                translate([r_core, 0])
                    square([r_out - r_core, ghost_roll_len]);
}

// Both clamps in place, one on each end of the roll.
module assembled() {
    clamp();
    translate([0, 0, 2 * bridge_t + ghost_roll_len])
        rotate([0, 0, 90]) mirror([0, 0, 1]) clamp();
    ghost_contents();
}

/* ============================================================
   Render
   ============================================================ */

if (part == "assembled") assembled();
else {
    clamp();
    if (part != "clamp") ghost_contents();
}
