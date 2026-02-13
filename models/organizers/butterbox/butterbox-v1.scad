// --- Butter Dimensions ---
butter_l = 124;
butter_w = 75;
butter_h = 57;

// --- Settings ---
assembled = false; // true = assembled view, false = print layout
part = "lid";      // "base", "base-text", "lid", or "all"
wall = 2.5;
play = 2.0;
tol = 0.5;
tray_h = 10;
base_grip_h = 7;
r = 5;
$fn = 30;

iL = butter_l + play;
iW = butter_w + play;
bL = iL + 4*wall;
bW = iW + 4*wall;

// Text centered on visible base wall face
text_z = (tray_h + wall + base_grip_h) / 2;

module rounded_cube(size, radius) {
    x = size[0]; y = size[1]; z = size[2];
    translate([radius, radius, 0])
    minkowski() {
        cube([max(0.1, x - 2*radius), max(0.1, y - 2*radius), z - 0.5]);
        cylinder(r = radius, h = 0.5);
    }
}

// --- 1. The Base Tray ---
if (part == "base" || part == "all") {
    difference() {
        union() {
            // Outer shell with chamfered bottom
            hull() {
                translate([1, 1, 0])
                    rounded_cube([bL - 2, bW - 2, 1], max(0.1, r - 1));
                translate([0, 0, 1])
                    rounded_cube([bL, bW, 1], r);
            }
            translate([0, 0, 1])
                rounded_cube([bL, bW, tray_h + wall + base_grip_h - 1], r);
        }
        translate([2*wall, 2*wall, wall])
            rounded_cube([iL, iW, tray_h + base_grip_h + 5], r-1);
        translate([wall - tol/2, wall - tol/2, tray_h])
            rounded_cube([iL + 2*wall + tol, iW + 2*wall + tol, base_grip_h + 10], r-0.5);
    }
    // Grip Texture — long sides only
    for (gx = [5 : 6 : bL - 5]) {
        for (gz = [5 : 6 : tray_h + base_grip_h - 3]) {
            translate([gx, 0, gz]) sphere(r = 1);
            translate([gx, bW, gz]) sphere(r = 1);
        }
    }
}

// --- 1b. Base Text (export separately for AMS) ---
if (part == "base-text" || part == "all") {
    // Base Side A (Front)
    translate([1.4, bW/2, text_z])
    rotate([90, 0, -90])
    linear_extrude(height = 1.5)
        text("UNSALTED", size = 4, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");

    // Base Side B (Back)
    translate([bL - 1.4, bW/2, text_z])
    rotate([90, 0, 90])
    linear_extrude(height = 1.5)
        text("UNSALTED", size = 4, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

// --- 2. The Stackable Lid ---
if (part == "lid" || part == "all")
translate(assembled ? [wall, wall, tray_h] : [0, bW + 20, 0]) {
    union() {
        color("White") {
            difference() {
                rounded_cube([iL + 2*wall, iW + 2*wall, butter_h + play + wall], r);
                translate([wall, wall, -1])
                    rounded_cube([iL, iW, butter_h + play + 1], r-wall);
            }
            // Grip Texture — long sides only
            for (gx = [5 : 6 : iL + 2*wall - 5]) {
                for (gz = [5 : 6 : butter_h - 5]) {
                    translate([gx, 0, gz]) sphere(r = 1);
                    translate([gx, iW + 2*wall, gz]) sphere(r = 1);
                }
            }
        }
    }
}