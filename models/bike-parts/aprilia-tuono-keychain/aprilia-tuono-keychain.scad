// === Aprilia Tuono V4 Factory Taillight Keychain ===
// Two-color AMS: black base + red detail, text on back

// --- Dimensions ---
width = 65;            // total wingspan
base_t = 2;            // black base layer thickness
detail_t = 2;          // red detail layer thickness
border = 0.8;          // black border around red detail
corner_r = 0.3;        // slight corner rounding

// Keyring mount
ring_od = 8;
ring_id = 4;
tab_w = 5;
tab_gap = 2;           // gap between shape top and ring center

// Back text
text_str = "TUONO V4";
text_size = 3.5;
text_depth = 0.6;

// --- Part Selection ---
part = "assembled";    // "base", "detail", "text", "assembled"

// --- Calculations ---
total_t = base_t + detail_t;
sf = width / 64;       // scale factor (shape defined in 64-unit space)
center_top_y = 10 * sf;
ring_cy = center_top_y + tab_gap + ring_od / 2;

// --- Taillight Profile ---
// Traced from Aprilia Tuono V4 Factory taillight silhouette
// Symmetric chevron/wing, origin at center, 64 units wide
// Top edge = upper wing contour, bottom edge = lower contour + center V-notch

tail_pts = [for (p = [
    // Top edge: center to right wing tip
    [0, 8], [6, 7], [14, 4.5], [22, 1], [28, -3], [32, -6],
    // Bottom edge: right tip back to center
    [30, -7], [24, -4], [16, -0.5], [8, 2.5],
    // Center bottom V-notch
    [3, 3], [0, 1], [-3, 3],
    // Bottom edge: center to left tip
    [-8, 2.5], [-16, -0.5], [-24, -4], [-30, -7],
    // Top edge: left tip back to center
    [-32, -6], [-28, -3], [-22, 1], [-14, 4.5], [-6, 7]
]) [p[0] * sf, p[1] * sf]];

// --- Modules ---

module taillight_2d() {
    offset(r = corner_r) offset(r = -corner_r)
        polygon(tail_pts);
}

module ring_mount_2d() {
    translate([0, ring_cy])
        circle(d = ring_od, $fn = 30);
    // Tapered tab connecting shape to ring
    hull() {
        translate([-tab_w / 2, center_top_y - 0.5])
            square([tab_w, 0.1]);
        translate([0, ring_cy])
            circle(d = tab_w, $fn = 20);
    }
}

module text_geo() {
    // Text on back face (z=0), mirrored X so it reads correctly when flipped
    translate([0, 0, 0])
    mirror([1, 0, 0])
    linear_extrude(text_depth)
        text(text_str, size = text_size, halign = "center", valign = "center",
             font = "Liberation Sans:style=Bold");
}

module base_part() {
    difference() {
        linear_extrude(total_t) {
            taillight_2d();
            ring_mount_2d();
        }
        // Keyring hole
        translate([0, ring_cy, -1])
            cylinder(d = ring_id, h = total_t + 2, $fn = 30);
        // Text recess on back
        text_geo();
    }
}

module detail_part() {
    translate([0, 0, base_t])
    linear_extrude(detail_t)
        offset(r = -border)
            taillight_2d();
}

// --- Render ---
if (part == "base") {
    base_part();
}

if (part == "detail") {
    detail_part();
}

if (part == "text") {
    text_geo();
}

if (part == "assembled") {
    color("DimGray") base_part();
    color("Red") detail_part();
    color("White") text_geo();
}
