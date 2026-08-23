// Cable Port Cap for Rose Backroad FF
// Seals unused derailleur cable routing hole (wireless drivetrain)

// ── Part Selection ──────────────────────────────
part = "assembled"; // [cap, ghost, assembled]

// ── Measurements (measure your frame!) ──────────
hole_diameter = 5.8;    // mm - measured with calipers
frame_thickness = 3;    // mm - frame wall thickness at hole

// ── Design Parameters ───────────────────────────
clearance = -0.5;       // mm - 6.8mm plug to compensate FDM shrinkage
flange_overhang = 1;    // mm - minimum lip to prevent push-through
flange_thickness = 1.2; // mm - cap face thickness
plug_taper = 0.4;       // mm - taper at plug tip for easy insertion
rounding = 1;           // mm - edge rounding radius

// ── Colors ──────────────────────────────────────
cap_color = "DimGray";

// ── Calculations ────────────────────────────────
plug_diameter = hole_diameter - (clearance * 2);
plug_length = frame_thickness + 1; // 1mm extra for grip
flange_diameter = hole_diameter + (flange_overhang * 2);

// ── Modules ─────────────────────────────────────

module cap() {
    // Flange - rounded disc that sits flush against frame
    flange();

    // Plug - tapered cylinder that press-fits into hole
    translate([0, 0, -plug_length])
        plug();
}

module flange() {
    r = min(rounding, flange_thickness / 2);
    rotate_extrude($fn = 60)
        translate([0, 0, 0])
        hull() {
            // Bottom edge (flush against frame)
            translate([flange_diameter / 2 - r, 0])
                square([r, 0.01]);
            // Top outer edge (rounded)
            translate([flange_diameter / 2 - r, flange_thickness - r])
                circle(r, $fn = 30);
            // Top inner edge
            translate([0, flange_thickness - 0.01])
                square([0.01, 0.01]);
            // Bottom inner edge
            square([0.01, 0.01]);
        }
}

module plug() {
    // Tapered cylinder for easy insertion
    cylinder(
        h = plug_length,
        d1 = plug_diameter - plug_taper,  // tip (narrower)
        d2 = plug_diameter,                // base (full width)
        $fn = 60
    );
}

// ── Ghost Objects ───────────────────────────────

module ghost_hole() {
    color("SteelBlue", 0.3)
        translate([0, 0, -frame_thickness - 0.5])
        difference() {
            cylinder(h = frame_thickness, d = hole_diameter + 4, $fn = 60);
            translate([0, 0, -0.1])
                cylinder(h = frame_thickness + 0.2, d = hole_diameter, $fn = 60);
        }
}

// ── Part Rendering ──────────────────────────────

if (part == "cap") {
    cap();
} else if (part == "ghost") {
    ghost_hole();
} else if (part == "assembled") {
    color(cap_color) cap();
    ghost_hole();
}
