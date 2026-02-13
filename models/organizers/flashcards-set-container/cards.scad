// --- Card & Device Measurements ---
card_w = 59;
card_h = 89;
total_card_thick = 37;
num_categories = 4;

dev_w = 105.5;
dev_thick = 20;
dev_h = 92;

// --- Box Design ---
wall = 2;
divider = 1.5;
floor = 2;
clearance = 1;
box_h = 95;
rounding = 3;

// --- Lid Design ---
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
inner_w = max(card_h, dev_w) + 4;  // card_h: cards sit wide-side-down
card_shelf = box_h - card_w;       // raised floor under card slots
lip_inset = lid_wall + lid_tol;    // keep slots clear of lid lip

outer_w = inner_w + 2 * wall;
outer_y = 2 * wall
         + 2 * lip_inset
         + num_categories * slot_thick
         + num_categories * divider
         + dev_thick + clearance;

lip_outer_w = inner_w - 2 * lid_tol;
lip_outer_y = outer_y - 2 * wall - 2 * lid_tol;

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
// flip = false: fillet toward +secondary/+z corner
// flip = true:  fillet toward origin corner
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
    // Front label (extrudes outward in -Y)
    translate([outer_w / 2, 0, (box_h + floor) / 2])
        rotate([90, 0, 0])
            linear_extrude(text_depth)
                text(label, size = text_size,
                     halign = "center", valign = "center");

    // Back label (extrudes outward in +Y)
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
                translate([wall + (inner_w - card_h) / 2 + rounding,
                           wall + lip_inset + i * (slot_thick + divider) + rounding,
                           floor + card_shelf + rounding])
                    minkowski() {
                        cube([card_h - 2*rounding,
                              slot_thick - 2*rounding,
                              box_h - card_shelf + 1 - 2*rounding]);
                        sphere(rounding, $fn = 30);
                    }
            }

            // Device slot (rounded edges)
            translate([wall + (inner_w - dev_w - clearance) / 2 + rounding,
                       wall + lip_inset + num_categories * (slot_thick + divider) + rounding,
                       floor + rounding])
                minkowski() {
                    cube([dev_w + clearance - 2*rounding,
                          dev_thick + clearance - 2*rounding,
                          box_h + 1 - 2*rounding]);
                    sphere(rounding, $fn = 30);
                }

            // Finger notch (interior only, rounded edges)
            translate([outer_w / 2, wall + rounding, box_h + floor])
                rotate([-90, 0, 0])
                    minkowski() {
                        cylinder(h = outer_y - 2 * wall - 2 * rounding,
                                 r = 15 - rounding, $fn = 60);
                        sphere(rounding, $fn = 30);
                    }

            // Snap grooves on left/right inner walls
            for (x = [wall, outer_w - wall])
                translate([x, outer_y / 2,
                           box_h + floor - lip_h + 2 * snap_r])
                    sphere(snap_r, $fn = 20);

            // Inner top edge fillets
            // Front wall
            inner_fillet([0, wall, box_h + floor - rounding],
                         outer_w, rounding, "x");
            // Back wall
            inner_fillet([0, outer_y - wall - rounding, box_h + floor - rounding],
                         outer_w, rounding, "x", true);
            // Left wall
            inner_fillet([wall, 0, box_h + floor - rounding],
                         outer_y, rounding, "y");
            // Right wall
            inner_fillet([outer_w - wall - rounding, 0, box_h + floor - rounding],
                         outer_y, rounding, "y", true);
        }

}

// --- Lid (print-ready: top plate on bed, lip pointing up) ---
module lid() {
    translate([rounding, rounding, 0])
        minkowski() {
            cube([outer_w - 2*rounding, outer_y - 2*rounding, lid_top - 0.01]);
            cylinder(r = rounding, h = 0.01, $fn = 40);
        }

    translate([(outer_w - lip_outer_w) / 2,
               (outer_y - lip_outer_y) / 2,
               lid_top])
        difference() {
            cube([lip_outer_w, lip_outer_y, lip_h]);
            translate([lid_wall, lid_wall, -0.1])
                cube([lip_outer_w - 2 * lid_wall,
                      lip_outer_y - 2 * lid_wall,
                      lip_h + 0.2]);
        }

    // Snap bumps on lip outer face (left and right walls)
    for (x = [(outer_w - lip_outer_w) / 2,
              (outer_w + lip_outer_w) / 2])
        translate([x, outer_y / 2, lid_top + lip_h - 2 * snap_r])
            sphere(snap_r, $fn = 20);
}

// --- Render ---
if (part == "both" || part == "box" || part == "assembled") {
    color(box_color) box();
    color(text_color) labels();
}
if (part == "box_only") color(box_color) box();
if (part == "text") color(text_color) labels();
if (part == "both" || part == "lid")
    translate([part == "both" ? outer_w + spacing : 0, 0, 0])
        lid();
if (part == "assembled") {
    color(box_color) box();
    color(text_color) labels();
    translate([0, 0, box_h + floor + lid_top])
        mirror([0, 0, 1])
            lid();
}
