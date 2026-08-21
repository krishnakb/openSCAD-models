// ============================================================
// OpenGrid Wall Mount -- Stanley FMHT0-96230 Wire Stripper Hook
// ============================================================
// Self-contained, single-piece hook + board clip. No external
// libraries required (plain OpenSCAD only).
//
// The board-attachment geometry (rail_* parameters below) is
// measured from the official openGrid board design by David D,
// OpenSCAD port by BlackjackDuck / AndyLevesque
// (https://github.com/AndyLevesque/QuackWorks, CC-BY-NC-SA 4.0 --
// derivative works CC-BY 4.0). Only the board's rail dimensions
// are reused here; no original file content is included.
//
// !! NOT YET VALIDATED ON A PHYSICAL BOARD !!
// The rail's flared "barb" leaves very little clearance against
// the mirrored barb protruding from the tile on the other side of
// the 28mm gap -- by design the two nearly touch at full flare.
// clip_wall is kept deliberately thin for this reason. On your
// first print: check the clip slides fully onto the rail without
// binding on the neighboring tile, and that it grips firmly
// enough to resist being pulled straight off the wall. Tune
// rail_clearance (and reprint) before trusting it with the tool.

/* [Board Rail Geometry -- openGrid Lite (4mm) board] */
board_thickness  = 4;     // Lite board thickness (mm). Full-thickness (6.8mm) boards use a different, double-sided rail profile and are NOT supported by this design.
rail_neck        = 0.8;   // flush protrusion of the rail's back "neck" (mm)
rail_barb        = 1.5;   // protrusion of the flared barb the clip hooks behind (mm)
rail_neck_depth  = 1.6;   // depth of the neck section, measured from the wall (mm)
rail_ramp_depth  = 0.4;   // depth of each chamfer ramp between neck and barb (mm)
rail_barb_depth  = 1.6;   // depth of the flat barb "shelf" (mm)
// neck_depth + ramp + barb_depth + ramp == board_thickness (1.6+0.4+1.6+0.4 = 4.0)

/* [Mount Fit -- tune these first if the fit is wrong] */
rail_clearance = 0.15;  // gap added around the rail profile. Increase if the clip won't slide on; decrease if it's loose/rattly.
clip_wall      = 0.7;   // clip wall thickness beyond the rail profile. Kept thin on purpose -- see NOTES above.
clip_cap       = 2.5;   // solid wall in front of the board face, where the hook body attaches (mm)
clip_length    = 22;    // engagement length along the rail -- how far the clip slides onto it (mm)

/* [Hook Geometry -- sized generically for the FMHT0-96230's hang hole; verify against your actual tool] */
peg_diameter  = 6;    // diameter of the peg that passes through the tool's hang hole (mm)
peg_length    = 20;   // how far the peg projects out from the wall (mm)
peg_tip_up    = 7;    // height of the upturned hook at the peg tip, so the tool can't bounce off (mm)
arm_drop      = 16;   // vertical drop from the board clip down to the peg (mm)
arm_thickness = 5;    // thickness of the support arm / ledge (mm)
ledge_depth   = 16;   // how far out the ledge extends -- the tool's handle rests flat against it (mm)
hook_width    = 16;   // width of the arm/ledge/peg assembly along the rail (mm)

/* [Display] */
part = "assembled"; // [hook, assembled]
rounding = 1;

/* [Hidden] */
$fn = 40;

// ===== Calculated =====
clip_x = board_thickness + clip_cap;               // clip footprint, depth direction (into the wall)
clip_y = rail_barb + rail_clearance + clip_wall;    // clip footprint, protrusion direction (up, away from tile face)

// Rail cross-section (depth, protrusion), traced from the wall (depth=0)
// out to the board's front face (depth=board_thickness). Points are
// extended 0.1mm past depth=0 so the subtraction below cuts a clean
// face flush with the clip block.
rail_profile_pts = [
    [-0.1, rail_neck],
    [rail_neck_depth, rail_neck],
    [rail_neck_depth + rail_ramp_depth, rail_barb],
    [rail_neck_depth + rail_ramp_depth + rail_barb_depth, rail_barb],
    [board_thickness, 0],
    [-0.1, 0],
];

// ============================================================
// Board clip -- slides onto a horizontal rail from either open
// end (e.g. the edge of the board, or a gap left by a neighboring
// accessory) and is held on by friction along the slide axis.
// Pulling it straight off the wall is blocked by the barb.
// ============================================================
module board_clip() {
    difference() {
        cube([clip_x, clip_y, clip_length]);
        translate([0, 0, -1])
            linear_extrude(height = clip_length + 2)
                offset(r = rail_clearance)
                    polygon(rail_profile_pts);
    }
}

// ============================================================
// Hook body -- support arm, ledge, and retaining peg that the
// wire stripper hangs from by its hang hole.
// ============================================================

// 2D gusset + ledge profile, in the (depth, protrusion) plane --
// same plane as the rail profile above. Extruded along Z (the
// rail/travel axis) to give it width.
module hook_profile_2d() {
    hull() {
        translate([clip_x, 0]) circle(d = arm_thickness);
        translate([clip_x + ledge_depth - arm_thickness / 2, -arm_drop + arm_thickness / 2]) circle(d = arm_thickness);
    }
    translate([clip_x, -arm_drop]) square([ledge_depth, arm_thickness]);
}

module tool_hook() {
    z0 = clip_length / 2 - hook_width / 2;

    // support arm + ledge -- outer corners softened for comfort
    translate([0, 0, z0])
        linear_extrude(height = hook_width)
            offset(r = rounding)
                offset(r = -rounding)
                    hook_profile_2d();

    // peg: passes through the tool's hang hole, with an upturned,
    // rounded tip so the tool can't bounce off
    translate([clip_x + ledge_depth - peg_diameter / 2, -arm_drop + arm_thickness / 2, clip_length / 2])
        rotate([0, 90, 0])
            union() {
                cylinder(d = peg_diameter, h = peg_length);
                translate([0, 0, peg_length])
                    rotate([-90, 0, 0])
                        cylinder(d = peg_diameter, h = peg_tip_up);
                translate([0, peg_tip_up, peg_length])
                    sphere(d = peg_diameter);
            }
}

// ============================================================
// Ghost previews -- translucent, for visualization only. Not
// included in exportable parts.
// ============================================================
module ghost_board() {
    // flat slab standing in for the openGrid board panel itself
    board_w = 150;
    board_h = 150;
    color("SlateGray", 0.3)
        translate([0, clip_y / 2 - board_h / 2, clip_length / 2 - board_w / 2])
            cube([board_thickness, board_h, board_w]);
}

module ghost_tool() {
    // rough silhouette of the FMHT0-96230 (~250mm long, ~35mm wide
    // handles, ~12mm thick), hanging from the peg by its hang hole
    tool_len = 250;
    tool_w = 35;
    tool_thick = 12;
    hole_offset = 15; // distance from the tool's top end to its hang hole
    peg_base_x = clip_x + ledge_depth - peg_diameter / 2;
    peg_base_y = -arm_drop + arm_thickness / 2;
    color("Gold", 0.35)
        translate([peg_base_x - tool_thick / 2, peg_base_y + hole_offset - tool_len, clip_length / 2 - tool_w / 2])
            cube([tool_thick, tool_len, tool_w]);
}

// ============================================================
// Assembly
// ============================================================
module hook_only() {
    union() {
        board_clip();
        tool_hook();
    }
}

if (part == "hook") {
    hook_only();
} else if (part == "assembled") {
    hook_only();
    ghost_board();
    ghost_tool();
}
