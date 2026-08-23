// Gridfinity 2x2 Watch Bin — low-profile, pillow-style
// Raised pads on underside per official gridfinity spec
// All corners rounded

// ===== PART SELECTOR =====
part = "bin"; // "bin", "ghost", "both"

// ===== WATCH MEASUREMENTS =====
watch_case_dia    = 42;
watch_case_thick  = 13;
watch_lug_width   = 22;
watch_band_thick  = 3;
watch_crown_size  = 4;

// ===== GRIDFINITY PARAMETERS =====
grid_size    = 42;
grid_x       = 2;
grid_y       = 2;
height_units = 1;    // 1U = 7mm above base
unit_height  = 7;

// ===== DESIGN PARAMETERS =====
wall          = 1.6;
clearance     = 1;
pillow_dia    = 30;
pillow_height = 16;
rounding      = 2;   // outer corner rounding radius

// ===== GRIDFINITY BASE SPEC (from kennetek/standard.scad) =====
// BASE_PROFILE: [0,0] [0.8,0.8] [0.8,2.6] [2.95,4.75]
// Measured from inner edge outward and upward
chamfer1       = 0.8;    // bottom 45° chamfer
vertical       = 1.8;    // vertical section
chamfer2       = 2.15;   // top 45° flare
profile_h      = 4.75;   // profile height (chamfer1+vertical+chamfer2)
bridge_h       = 2.25;   // bridge connecting pads to floor
base_h         = 7;      // total base height (profile_h + bridge_h)

// Pad dimensions per spec
pad_top_w      = 41.5;   // BASE_TOP_DIMENSIONS
pad_mid_w      = pad_top_w - 2 * chamfer2; // 37.2mm
pad_bot_w      = pad_mid_w - 2 * chamfer1; // 35.6mm
pad_top_r      = 3.75;   // BASE_TOP_RADIUS — corner fillet at top
pad_bot_r      = pad_top_r - 2.95; // 0.8mm — corner fillet at bottom

// ===== CALCULATIONS =====
bin_x      = grid_x * grid_size - 2 * 0.25; // 83.5mm (0.25 clearance/side)
bin_y      = grid_y * grid_size - 2 * 0.25;
bin_height = base_h + height_units * unit_height;
floor_z    = base_h;
inner_h    = bin_height - floor_z;

// ===== MAIN BIN =====
module bin() {
    // Floor/bridge plate — connects pad tops to interior
    translate([0, 0, profile_h])
        rounded_plate(bin_x, bin_y, bridge_h, rounding);

    // Walls — rounded, above base only
    translate([0, 0, floor_z])
        rounded_walls(bin_x, bin_y, inner_h, wall, rounding);

    // Gridfinity base pads
    for (gx = [0:grid_x-1], gy = [0:grid_y-1])
        translate([gx * grid_size + grid_size/2,
                   gy * grid_size + grid_size/2, 0])
            grid_pad();

    // Central pillow post
    translate([bin_x/2, bin_y/2, floor_z])
        pillow_post();
}

// ===== GRIDFINITY BASE PAD =====
// Stepped profile with rounded corners per spec
module grid_pad() {
    // Interpolate corner radius at each height
    mid_r = pad_bot_r + chamfer1; // ~1.6mm at vertical section

    // Bottom 45° chamfer (z=0 to 0.8)
    hull() {
        rounded_plate_centered(pad_bot_w, pad_bot_w, 0.01, pad_bot_r);
        translate([0, 0, chamfer1])
            rounded_plate_centered(pad_mid_w, pad_mid_w, 0.01, mid_r);
    }
    // Vertical section (z=0.8 to 2.6)
    translate([0, 0, chamfer1])
        rounded_plate_centered(pad_mid_w, pad_mid_w, vertical, mid_r);
    // Top 45° flare (z=2.6 to 4.75)
    hull() {
        translate([0, 0, chamfer1 + vertical])
            rounded_plate_centered(pad_mid_w, pad_mid_w, 0.01, mid_r);
        translate([0, 0, profile_h])
            rounded_plate_centered(pad_top_w, pad_top_w, 0.01, pad_top_r);
    }
}

// ===== ROUNDED PRIMITIVES =====

// Rounded-corner plate centered at origin
module rounded_plate_centered(w, d, h, r) {
    translate([-w/2, -d/2, 0])
        rounded_plate(w, d, h, r);
}

// Rounded-corner plate at origin corner
module rounded_plate(w, d, h, r) {
    cr = min(r, w/2, d/2); // clamp radius
    hull()
        for (x = [cr, w-cr], y = [cr, d-cr])
            translate([x, y, 0])
                cylinder(r=cr, h=h, $fn=30);
}

// Rounded walls (hollow rounded box)
module rounded_walls(w, d, h, t, r) {
    difference() {
        rounded_plate(w, d, h, r);
        translate([t, t, -0.01])
            rounded_plate(w - 2*t, d - 2*t, h + 0.02, max(r - t, 0.5));
    }
}

// ===== PILLOW POST =====
module pillow_post() {
    straight = pillow_height - 2;
    cylinder(d=pillow_dia, h=straight, $fn=60);
    translate([0, 0, straight])
    resize([pillow_dia, pillow_dia, 4])
        sphere(d=pillow_dia, $fn=60);
}

// ===== GHOST WATCH =====
module ghost_watch() {
    cx = bin_x / 2;
    cy = bin_y / 2;

    color("Silver", 0.4)
    translate([cx + pillow_dia/2 + clearance, cy, floor_z])
        cylinder(d=watch_case_dia, h=watch_case_thick, $fn=60);

    color("LightBlue", 0.3)
    translate([cx + pillow_dia/2 + clearance, cy,
               floor_z + watch_case_thick - 1])
        cylinder(d=watch_case_dia - 6, h=1.5, $fn=60);

    color("Gold", 0.4)
    translate([cx + pillow_dia/2 + clearance + watch_case_dia/2,
               cy, floor_z + watch_case_thick/2])
    rotate([0, 90, 0])
        cylinder(d=watch_crown_size, h=watch_crown_size, $fn=16);

    color("SaddleBrown", 0.4)
    translate([cx, cy, floor_z]) {
        wrap_r = pillow_dia/2 + clearance + watch_band_thick/2;
        for (a = [0:5:260])
            hull() {
                rotate([0, 0, a])
                translate([wrap_r, 0, 0])
                    cube([watch_band_thick, 0.5,
                          watch_lug_width], center=true);
                rotate([0, 0, a + 5])
                translate([wrap_r, 0, 0])
                    cube([watch_band_thick, 0.5,
                          watch_lug_width], center=true);
            }
    }
}

// ===== RENDER =====
if (part == "bin") {
    bin();
} else if (part == "ghost") {
    ghost_watch();
} else if (part == "both") {
    bin();
    ghost_watch();
}
