/* ============================================================
   Two-wheel gravel wheel wall hanger
   A thin blade (fin) cantilevers straight out from a wall
   backplate. Two staggered notches in the fin's top edge each
   cradle a tire; the wheels hang below in parallel planes,
   offset in depth and height so they don't collide.
   Inspired by a commercial twin-notch "Z" wheel rack.
   ============================================================ */

part = "both";   // "mount" = printable STL, "both"/"assembled" = preview w/ ghost wheels

/* ---------- Measurements (mm) ---------- */
tire_width     = 40;    // gravel tire width (ghost preview only)
wheel_diameter = 700;   // ~700c wheel (ghost preview only)

/* ---------- Fin (the load-bearing blade) ---------- */
fin_t       = 12;    // fin thickness
fin_depth   = 150;   // how far it projects from the wall (Y)
top_back_z  = 66;    // top edge height at the wall
top_front_z = 100;   // top edge height at the tip (slope forms outer lips)
bot_front_z = 48;    // bottom edge height at the tip (tapered brace)

/* ---------- Notches (tire seats) ---------- */
notch_r      = 24;   // scallop radius (fits a 40mm tire)
notch_near_y = 40;   // near seat, closer to wall + lower
notch_far_y  = 105;  // far seat, further out + higher

/* ---------- Backplate / mounting ---------- */
plate_w       = 50;
plate_h       = 120;
plate_t       = 5;
screw_shaft_d = 4.5;
screw_head_d  = 9;
screw_x       = 18;              // holes sit either side of the fin
screw_z       = [12, 105];

rounding = 3;

/* ---------- Calculations ---------- */
wheel_r = wheel_diameter / 2;
// Height of the sloped top edge at a given depth y.
function top_z(y) = top_back_z + (top_front_z - top_back_z) * y / fin_depth;

/* ============================================================
   Fin
   ============================================================ */

// 2D blade outline in the Y-Z plane, corners rounded.
module fin_outline() {
    offset(r = rounding) offset(delta = -rounding)
        polygon([
            [0,         0],
            [fin_depth, bot_front_z],
            [fin_depth, top_front_z],
            [0,         top_back_z],
        ]);
}

// Upward-open scallop that cradles a tire at depth ny.
module notch(ny) {
    translate([ny, top_z(ny)]) circle(r = notch_r, $fn = 48);
}

module fin() {
    translate([-fin_t / 2, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = fin_t)
            difference() {
                fin_outline();
                notch(notch_near_y);
                notch(notch_far_y);
            }
}

/* ============================================================
   Backplate
   ============================================================ */

module rbox(l, w, h, r) {
    hull() for (x = [r, l - r], y = [r, w - r], z = [r, h - r])
        translate([x, y, z]) sphere(r = r, $fn = 40);
}

module screw(x, z) {
    translate([x, -1, z]) rotate([-90, 0, 0])
        cylinder(d = screw_shaft_d, h = plate_t + 2, $fn = 30);
    translate([x, plate_t, z]) rotate([90, 0, 0])
        cylinder(d1 = screw_head_d, d2 = screw_shaft_d,
                 h = (screw_head_d - screw_shaft_d) / 2, $fn = 30);
}

module backplate() {
    difference() {
        translate([-plate_w / 2, 0, 0]) rbox(plate_w, plate_t, plate_h, rounding);
        for (x = [-screw_x, screw_x], z = screw_z) screw(x, z);
    }
}

module mount() {
    backplate();
    fin();
}

/* ============================================================
   Ghost wheels (preview only, never exported) - hang from seats
   ============================================================ */

module ghost_contents() {
    for (ny = [notch_near_y, notch_far_y])
        translate([0, ny, top_z(ny) - wheel_r]) {
            color("dimgray", 0.22)
                rotate([90, 0, 0])
                    cylinder(d = wheel_diameter - tire_width, h = 2, center = true, $fn = 90);
            color("black", 0.30)
                rotate([90, 0, 0]) rotate_extrude($fn = 90)
                    translate([wheel_r - tire_width / 2, 0, 0])
                        circle(r = tire_width / 2, $fn = 24);
        }
}

/* ============================================================
   Render
   ============================================================ */

mount();
if (part != "mount") ghost_contents();
