// Gridfinity 2x2 Watch Bin — pillow + coin slot
// Band wraps around pillow, case sits on edge in a floor slot
// Works with leather, rubber, NATO, and steel bracelets

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
height_units = 1;
unit_height  = 7;

// ===== DESIGN PARAMETERS =====
wall          = 1.6;
clearance     = 1;
rounding      = 2;
pillow_dia    = 34;
pillow_height = 24;
fillet_r      = 4;    // wider base fillet for smoother transition
dome_h        = 8;    // dome on pillow

// Coin slot for watch case
slot_w      = watch_case_thick + clearance;     // 14mm
slot_l      = watch_case_dia + 2 * clearance;   // 44mm
slot_depth  = 1;      // shallow — leaves 1.25mm of bridge plate intact
slot_chamfer = 1;     // chamfer around slot top edge
slot_offset = pillow_dia/2 + slot_w/2 + 2;


// ===== GRIDFINITY BASE SPEC =====
chamfer1       = 0.8;
vertical       = 1.8;
chamfer2       = 2.15;
profile_h      = 4.75;
bridge_h       = 2.25;
base_h         = 7;

pad_top_w      = 41.5;
pad_mid_w      = pad_top_w - 2 * chamfer2;
pad_bot_w      = pad_mid_w - 2 * chamfer1;
pad_top_r      = 3.75;
pad_bot_r      = pad_top_r - 2.95;

// ===== CALCULATIONS =====
bin_x      = grid_x * grid_size - 0.5;
bin_y      = grid_y * grid_size - 0.5;
bin_height = base_h + height_units * unit_height;
floor_z    = base_h;
inner_h    = bin_height - floor_z;
pillow_cx  = bin_x/2 + slot_offset - slot_w/2 - pillow_dia/2 - 5;

// ===== MAIN BIN =====
module bin() {
    difference() {
        union() {
            // Floor/bridge plate
            translate([0, 0, profile_h])
                rounded_plate(bin_x, bin_y, bridge_h, rounding);

            // Walls with rounded top edges
            translate([0, 0, floor_z])
                rounded_top_walls(bin_x, bin_y, inner_h, wall, rounding);

        }

        // Coin slot with chamfered entry
        slot_with_chamfer();

    }

    // Gridfinity base pads
    for (gx = [0:grid_x-1], gy = [0:grid_y-1])
        translate([gx * grid_size + grid_size/2,
                   gy * grid_size + grid_size/2, 0])
            grid_pad();

    // Pillow post with base fillet
    translate([pillow_cx, bin_y/2, floor_z])
        pillow_with_fillet();
}


// ===== SLOT WITH CHAMFERED ENTRY =====
module slot_with_chamfer() {
    sx = bin_x/2 + slot_offset;
    sy = bin_y/2;

    // Main slot cut
    translate([sx, sy, floor_z - slot_depth])
        rounded_slot(slot_w, slot_l, slot_depth + 0.01);

    // Chamfered top edge — wider cut that tapers in
    translate([sx, sy, floor_z - slot_chamfer])
        rounded_slot(slot_w + 2*slot_chamfer, slot_l + 2*slot_chamfer,
                     slot_chamfer + 0.01);
}



// ===== ROUNDED SLOT =====
module rounded_slot(w, l, h) {
    sr = w / 2;
    hull() {
        translate([0, -(l/2 - sr), 0])
            cylinder(r=sr, h=h, $fn=30);
        translate([0, (l/2 - sr), 0])
            cylinder(r=sr, h=h, $fn=30);
    }
}

// ===== PILLOW WITH BASE FILLET =====
module pillow_with_fillet() {
    straight = pillow_height - dome_h;

    // Base fillet — torus where pillow meets floor
    fillet_torus(pillow_dia/2, fillet_r);

    // Straight cylinder
    cylinder(d=pillow_dia, h=straight, $fn=90);

    // Smooth dome top
    translate([0, 0, straight])
    resize([pillow_dia, pillow_dia, dome_h * 2])
        sphere(d=pillow_dia, $fn=90);
}

// ===== FILLET TORUS =====
// Quarter-round fillet at cylinder base
module fillet_torus(cyl_r, fr) {
    translate([0, 0, fr])
    rotate_extrude($fn=90)
    translate([cyl_r - fr, 0, 0])
    difference() {
        square(fr);
        translate([fr, 0, 0])
            circle(r=fr, $fn=40);
    }
}

// ===== WALLS WITH ROUNDED TOP EDGE =====
module rounded_top_walls(w, d, h, t, r) {
    tr = min(t/2, 0.8); // top edge rounding radius

    difference() {
        // Outer wall with rounded top
        hull() {
            rounded_plate(w, d, h - tr, r);
            translate([tr, tr, h - tr])
                rounded_plate(w - 2*tr, d - 2*tr, tr, max(r - tr, 0.5));
        }
        // Inner cutout
        translate([t, t, -0.01])
            cube([w - 2*t, d - 2*t, h + 0.02]);
    }
}

// ===== GRIDFINITY BASE PAD =====
module grid_pad() {
    mid_r = pad_bot_r + chamfer1;

    hull() {
        rounded_plate_centered(pad_bot_w, pad_bot_w, 0.01, pad_bot_r);
        translate([0, 0, chamfer1])
            rounded_plate_centered(pad_mid_w, pad_mid_w, 0.01, mid_r);
    }
    translate([0, 0, chamfer1])
        rounded_plate_centered(pad_mid_w, pad_mid_w, vertical, mid_r);
    hull() {
        translate([0, 0, chamfer1 + vertical])
            rounded_plate_centered(pad_mid_w, pad_mid_w, 0.01, mid_r);
        translate([0, 0, profile_h])
            rounded_plate_centered(pad_top_w, pad_top_w, 0.01, pad_top_r);
    }
}

// ===== ROUNDED PRIMITIVES =====

module rounded_plate_centered(w, d, h, r) {
    translate([-w/2, -d/2, 0])
        rounded_plate(w, d, h, r);
}

module rounded_plate(w, d, h, r) {
    cr = min(r, w/2, d/2);
    hull()
        for (x = [cr, w-cr], y = [cr, d-cr])
            translate([x, y, 0])
                cylinder(r=cr, h=h, $fn=30);
}

// ===== GHOST WATCH =====
module ghost_watch() {
    cx = bin_x / 2;
    cy = bin_y / 2;
    slot_cx = cx + slot_offset;

    // Case on its edge in the coin slot
    color("Silver", 0.4)
    translate([slot_cx, cy, floor_z - slot_depth])
    rotate([0, 90, 0])
    translate([0, 0, -watch_case_thick/2])
        cylinder(d=watch_case_dia, h=watch_case_thick, $fn=60);

    // Crown
    color("Gold", 0.4)
    translate([slot_cx + watch_case_thick/2 + 1,
               cy, floor_z - slot_depth + watch_case_dia/2])
    rotate([0, 90, 0])
        cylinder(d=watch_crown_size, h=watch_crown_size, $fn=16);

    // Band wrapping around pillow
    color("SaddleBrown", 0.4)
    translate([pillow_cx, cy, floor_z]) {
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
