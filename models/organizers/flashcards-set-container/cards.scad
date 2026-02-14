// --- Card & Device Measurements ---
card_w = 60;
card_h = 90;
total_card_thick = 37;
num_categories = 4;

dev_w = 105.5;
dev_thick = 25;
dev_h = 92;

// --- Box Design ---
wall = 2;
divider = 1.5;
floor = 2;
clearance = 2;
box_h = 95;
rounding = 3;

// --- Lid Design (over-fit) ---
lid_tol = 0.5;
lip_h = 8;
lid_wall = 1.5;
lid_top = 2.5;

// --- Snap Fit ---
snap_r = 0.8;

// --- Label ---
label = "flash cards";
text_size = 10;
text_depth = 1;
box_color = "white";
text_color = "blue";

// --- Layout ---
// "both", "box_only", "lid", "text", or "assembled"
part = "both";
spacing = 10;

// --- Calculations ---
slot_thick = (total_card_thick / num_categories) + clearance;
slot_w = card_h + clearance;       // card length + clearance
inner_w = max(slot_w, dev_w) + 4;
top_gap = 3;                      // clearance below lid
card_shelf = box_h - card_w - top_gap;
slot_offset = 8;                  // alternating X shift per slot
divider_height = 35;              // half-height dividers for finger access
outer_w = inner_w + 2 * wall;
outer_y = 2 * wall
         + num_categories * slot_thick
         + num_categories * divider
         + dev_thick + clearance;

// Over-fit lid: skirt goes OVER the box exterior
lid_outer_w = outer_w + 2 * lid_tol;
lid_outer_y = outer_y + 2 * lid_tol;
lid_full_w = lid_outer_w + 2 * lid_wall;
lid_full_y = lid_outer_y + 2 * lid_wall;

// --- Helpers ---
module rounded_cube(size, r) {
    hull() for (x = [r, size[0]-r], y = [r, size[1]-r]) {
        translate([x, y, 0])
            cylinder(r = r, h = 0.01, $fn = 40);
        translate([x, y, size[2] - r])
            sphere(r, $fn = 40);
    }
}

// Quarter-round fillet for a concave inner edge
module inner_fillet(pos, len, r, axis = "x", flip = false) {
    translate(pos)
        difference() {
            if (axis == "x")
                cube([len, r + 0.01, r + 0.01]);
            else
                cube([r + 0.01, len, r + 0.01]);

            if (axis == "x")
                translate([-0.01, flip ? 0 : r, 0])
                    rotate([0, 90, 0])
                        cylinder(r = r, h = len + 0.02, $fn = 30);
            else
                translate([flip ? 0 : r, -0.01, 0])
                    rotate([-90, 0, 0])
                        cylinder(r = r, h = len + 0.02, $fn = 30);
        }
}

// --- Labels ---
module labels() {
    // Front label
    translate([outer_w / 2, 0, (box_h + floor) / 2])
        rotate([90, 0, 0])
            linear_extrude(text_depth)
                text(label, size = text_size,
                     halign = "center", valign = "center");

    // Back label
    translate([outer_w / 2, outer_y, (box_h + floor) / 2])
        rotate([90, 0, 180])
            linear_extrude(text_depth)
                text(label, size = text_size,
                     halign = "center", valign = "center");
}

// --- Box ---
module box() {
    color(box_color)
        difference() {
            rounded_cube([outer_w, outer_y, box_h + floor], rounding);

            // Card slots (rounded edges)
            for (i = [0 : num_categories - 1]) {
                x_shift = (i % 2 == 0) ? -slot_offset/2 : slot_offset/2;
                translate([wall + (inner_w - slot_w) / 2 + x_shift + rounding,
                           wall + i * (slot_thick + divider) + rounding,
                           floor + card_shelf + rounding])
                    minkowski() {
                        cube([slot_w - 2*rounding,
                              slot_thick - 2*rounding,
                              box_h - card_shelf + 1 - 2*rounding]);
                        sphere(rounding, $fn = 30);
                    }
            }

            // Shared upper trough: removes dividers above divider_height
            trough_y_start = wall;
            trough_y_end = wall + num_categories * (slot_thick + divider);
            trough_z = floor + card_shelf + divider_height;
            translate([wall + rounding, trough_y_start + rounding, trough_z + rounding])
                minkowski() {
                    cube([inner_w - 2*rounding,
                          trough_y_end - trough_y_start - 2*rounding,
                          box_h + floor - trough_z + 1 - 2*rounding]);
                    sphere(rounding, $fn = 30);
                }

            // Device slot (rounded edges)
            translate([wall + (inner_w - dev_w - clearance) / 2 + rounding,
                       wall + num_categories * (slot_thick + divider) + rounding,
                       floor + rounding])
                minkowski() {
                    cube([dev_w + clearance - 2*rounding,
                          dev_thick + clearance - 2*rounding,
                          box_h + 1 - 2*rounding]);
                    sphere(rounding, $fn = 30);
                }

            // Device slot finger notch (centered)
            translate([outer_w / 2,
                       wall + num_categories * (slot_thick + divider)
                       + (dev_thick + clearance) / 2,
                       box_h + floor])
                sphere(r = 15, $fn = 60);

            // Snap grooves on left/right OUTER walls
            for (x = [0, outer_w])
                translate([x, outer_y / 2,
                           box_h + floor - lip_h + 2 * snap_r])
                    sphere(snap_r, $fn = 20);

            // Inner top edge fillets
            inner_fillet([0, wall, box_h + floor - rounding],
                         outer_w, rounding, "x");
            inner_fillet([0, outer_y - wall - rounding, box_h + floor - rounding],
                         outer_w, rounding, "x", true);
            inner_fillet([wall, 0, box_h + floor - rounding],
                         outer_y, rounding, "y");
            inner_fillet([outer_w - wall - rounding, 0, box_h + floor - rounding],
                         outer_y, rounding, "y", true);
        }
}

// --- Lid (over-fit: grid top plate, skirt pointing up) ---
grid_bar = 2;         // rib width
grid_border = 4;      // solid border around edge
grid_nx = 5;          // number of cutouts in X
grid_ny = 3;          // number of cutouts in Y

module lid() {
    difference() {
        // Solid top plate
        translate([rounding, rounding, 0])
            minkowski() {
                cube([lid_full_w - 2*rounding,
                      lid_full_y - 2*rounding,
                      lid_top - 0.01]);
                cylinder(r = rounding, h = 0.01, $fn = 40);
            }

        // Grid cutouts
        grid_area_w = lid_full_w - 2 * grid_border;
        grid_area_y = lid_full_y - 2 * grid_border;
        cell_w = (grid_area_w - (grid_nx - 1) * grid_bar) / grid_nx;
        cell_y = (grid_area_y - (grid_ny - 1) * grid_bar) / grid_ny;
        for (ix = [0 : grid_nx - 1], iy = [0 : grid_ny - 1])
            translate([grid_border + ix * (cell_w + grid_bar),
                       grid_border + iy * (cell_y + grid_bar),
                       -0.1])
                cube([cell_w, cell_y, lid_top + 0.2]);
    }

    // Skirt (hollow rectangle hanging down from top plate)
    translate([0, 0, lid_top])
        difference() {
            // Outer skirt
            translate([rounding, rounding, 0])
                minkowski() {
                    cube([lid_full_w - 2*rounding,
                          lid_full_y - 2*rounding,
                          lip_h - 0.01]);
                    cylinder(r = rounding, h = 0.01, $fn = 40);
                }
            // Inner cutout
            translate([lid_wall, lid_wall, -0.1])
                cube([lid_outer_w, lid_outer_y, lip_h + 0.2]);
        }

    // Snap bumps on skirt inner face (left and right)
    for (x = [lid_wall, lid_full_w - lid_wall])
        translate([x, lid_full_y / 2,
                   lid_top + lip_h - 2 * snap_r])
            sphere(snap_r, $fn = 20);
}

// --- Ghost contents (translucent cards + device) ---
module ghost_contents() {
    card_colors = ["red", "green", "blue", "orange"];
    per_slot = total_card_thick / num_categories;
    for (i = [0 : num_categories - 1]) {
        x_shift = (i % 2 == 0) ? -slot_offset/2 : slot_offset/2;
        color(card_colors[i], 0.4)
            translate([wall + (inner_w - slot_w) / 2 + x_shift
                       + (slot_w - card_h) / 2,
                       wall + i * (slot_thick + divider)
                       + (slot_thick - per_slot) / 2,
                       floor + card_shelf])
                cube([card_h, per_slot, card_w]);
    }
    // Device
    color("purple", 0.4)
        translate([wall + (inner_w - dev_w) / 2,
                   wall + num_categories * (slot_thick + divider)
                   + clearance / 2,
                   floor])
            cube([dev_w, dev_thick, dev_h]);
}

// --- Render ---
if (part == "both" || part == "box" || part == "assembled") {
    color(box_color) box();
    color(text_color) labels();
    ghost_contents();
}
if (part == "box_only") color(box_color) box();
if (part == "text") color(text_color) labels();
if (part == "both" || part == "lid")
    translate([part == "both" ? outer_w + spacing : 0, 0, 0])
        lid();
if (part == "assembled") {
    // Flip lid (printed skirt-up) so skirt points down over box
    translate([-(lid_tol + lid_wall), -(lid_tol + lid_wall),
               box_h + floor + lid_top])
        mirror([0, 0, 1])
            lid();
    ghost_contents();
}
