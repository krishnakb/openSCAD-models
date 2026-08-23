/* ============================================================
   Two-wheel gravel wheel wall mount
   Cantilever rim/tire-saddle bracket, inspired by a single-wheel
   wall hook. A flat backplate screws to the wall; a saddle block
   projects out with two side-by-side U-troughs (split by a divider)
   so two 40mm tires nest parallel to the wall at different depths.
   ============================================================ */

part = "both";   // "mount" = printable STL, "both"/"assembled" = preview w/ ghost wheels

/* ---------- Measurements (mm) ---------- */
tire_width     = 40;    // gravel tire width (sizes the trough)
wheel_diameter = 700;   // ~700c wheel, ghost preview only

/* ---------- Design ---------- */
clearance   = 2;    // added to trough width for easy drop-in
wall        = 5;    // outer + back walls (load bearing)
divider     = 6;    // wall between the two tire troughs
floor_thick = 6;    // material below trough bottom
cover       = 8;    // wall height above tire crown (side retention)
crest_r     = 3;    // rounding on trough top edges
rounding    = 3;    // outer edge rounding

saddle_len  = 60;   // X length of the saddle block
channel_x   = 50;   // X length of each trough (leaves solid end caps)

/* ---------- Backplate / mounting ---------- */
plate_thick    = 5;
plate_h        = 130;
screw_shaft_d  = 4.5;   // wood screw / anchor shaft
screw_head_d   = 9;     // countersink top diameter
screw_z_bottom = 12;
screw_z_top    = 118;

/* ---------- Calculations ---------- */
channel_w   = tire_width + clearance;                    // 42 trough width
trough_r    = channel_w / 2;                             // 21
tire_r      = tire_width / 2;                            // 20
trough_z    = floor_thick + trough_r;                    // 27 (from block bottom)
block_h     = trough_z + tire_r + cover;                 // 55
block_z0    = 25;                                        // block height up the plate
back_ch_y   = wall + trough_r;                           // 26 back trough center
front_ch_y  = back_ch_y + 2*trough_r + divider;          // 74 front trough center
block_depth = front_ch_y + trough_r + wall;              // 100
wheel_r     = wheel_diameter / 2;
cx          = saddle_len / 2;                            // shared X center

/* ============================================================
   Helpers
   ============================================================ */

// Rounded box, spans x:[0,l] y:[0,w] z:[0,h]; all faces flat, edges rounded.
module rbox(l, w, h, r) {
    hull() for (x = [r, l - r], y = [r, w - r], z = [r, h - r])
        translate([x, y, z]) sphere(r = r, $fn = 40);
}

// X-axis cylinder centered on the saddle length.
module xcyl(y, z, r, len, fn) {
    translate([cx, y, z]) rotate([0, 90, 0])
        cylinder(r = r, h = len, center = true, $fn = fn);
}

/* ============================================================
   Parts
   ============================================================ */

module backplate() {
    rbox(saddle_len, plate_thick, plate_h, rounding);
}

module block() {
    translate([0, 0, block_z0])
        rbox(saddle_len, block_depth, block_h, rounding);
}

// U-trough: rounded bottom, near-vertical walls, rounded crest, open top.
module trough(cy) {
    zc = block_z0 + trough_z;      // trough centerline
    tz = block_z0 + block_h;       // block top (crest)
    hull() {
        xcyl(cy, zc, trough_r, channel_x, 60);
        xcyl(cy - trough_r, tz, crest_r, channel_x, 24);
        xcyl(cy + trough_r, tz, crest_r, channel_x, 24);
    }
}

// Countersunk screw hole through the backplate (head on the front face).
module screw(z) {
    translate([cx, -1, z]) rotate([-90, 0, 0])
        cylinder(d = screw_shaft_d, h = plate_thick + 2, $fn = 30);
    translate([cx, plate_thick, z]) rotate([90, 0, 0])
        cylinder(d1 = screw_head_d, d2 = screw_shaft_d,
                 h = (screw_head_d - screw_shaft_d) / 2, $fn = 30);
}

module mount() {
    difference() {
        union() { backplate(); block(); }
        trough(back_ch_y);
        trough(front_ch_y);
        screw(screw_z_bottom);
        screw(screw_z_top);
    }
}

// Translucent wheels HANGING from the troughs (preview only, never exported).
// Groove catches the tire near the top of the wheel; wheel dangles below.
module ghost_contents() {
    for (cy = [back_ch_y, front_ch_y])
        translate([cx, cy, block_z0 + trough_z - wheel_r]) {
            color("dimgray", 0.22)                       // wheel body
                rotate([90, 0, 0])
                    cylinder(d = wheel_diameter - tire_width, h = 2, center = true, $fn = 90);
            color("black", 0.30)                         // tire (wheel plane = X-Z)
                rotate([90, 0, 0]) rotate_extrude($fn = 90)
                    translate([wheel_r - tire_r, 0, 0])
                        circle(r = tire_r, $fn = 24);
        }
}

/* ============================================================
   Render
   ============================================================ */

translate([-cx, 0, 0]) {
    mount();
    if (part != "mount") ghost_contents();
}
