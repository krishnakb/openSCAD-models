// Snap-fit fork travel indicator — 2025 Ducati Panigale V2S front fork
// Replaces the classic "rubber O-ring on the fork tube" trick with a
// rigid two-piece ring that clips around the tube instead of needing
// to be stretched over the end of the fork leg.
//
// Fork: Showa BPF (Big Piston Front), 43mm USD fork.
// Fits around the exposed (moving) outer tube, just above the dust
// seal / lower fork leg. As the fork compresses, the dust seal wiper
// pushes the ring up the tube; the highest point it reaches shows the
// max travel used. Push it back down to the seal before every ride.
//
// MEASURE YOUR FORK TUBE WITH CALIPERS before printing — fork_tube_dia
// below is a starting point, not a guaranteed spec.

// --- Fork Measurements ---
fork_tube_dia = 43;    // Showa BPF outer tube OD (mm) — verify with calipers
id_clearance  = 0.6;   // total diametral clearance for a free-sliding fit (mm)

// --- Ring Design ---
wall        = 3;    // radial wall thickness of the band (mm)
band_height = 9;    // axial height of the band along the tube (mm)
edge_round  = 0.6;  // chamfer on all band edges — keeps sharp PLA off the fork's coated tube

// --- Friction Nibs (tune how freely the ring slides) ---
nib_count_per_half = 2;
nib_r          = 1;     // nib ball radius (mm)
nib_protrusion = 0.15;  // how far nibs poke past the nominal ID (mm) — sand down to loosen, build up (tape/paint) to tighten

// --- Tenon/Mortise Snap Joint (both split points) ---
tenon_len       = 2.2;
tenon_w         = wall * 0.55;
tenon_h         = band_height * 0.55;
joint_clearance = 0.2;
snap_r          = 0.6;

// --- Indicator Flag ---
flag_width  = 8;
flag_height = 11;
flag_thick  = 1.8;

// --- Rendering ---
part = "half"; // "half" (exportable, print x2), "both", "assembled"
$fn = 64;

// --- Calculated ---
id = fork_tube_dia + id_clearance;
od = id + 2 * wall;
mid_r = (id + od) / 4; // mean of the two RADII (id/2, od/2) — id/od here are diameters

module band_profile() {
    polygon([
        [id/2,              edge_round],
        [id/2 + edge_round, 0],
        [od/2 - edge_round, 0],
        [od/2,              edge_round],
        [od/2,              band_height - edge_round],
        [od/2 - edge_round, band_height],
        [id/2 + edge_round, band_height],
        [id/2,              band_height - edge_round],
    ]);
}

module tenon() {
    // Sits at the local angle-0 edge (+X), protrudes toward -Y into the gap.
    // Rooted root_overlap past y=0 so the union has real 3D overlap with the
    // band, not just a coincident face (which CGAL/slicers can leave unfused).
    root_overlap = 0.6;
    union() {
        translate([mid_r - tenon_w/2, -tenon_len, (band_height - tenon_h)/2])
            cube([tenon_w, tenon_len + root_overlap, tenon_h]);
        // Snap bumps centered on the peg's own side faces so each sphere is
        // always half-embedded in the peg — guaranteed fusion either way.
        for (sx = [-1, 1])
            translate([mid_r + sx * tenon_w/2, -tenon_len * 0.65, band_height/2])
                sphere(r = snap_r);
    }
}

module mortise() {
    // Cut at the local angle-180 edge (-X), recessed into the half's own body (+Y).
    entry_lead = 0.1; // start the cut a touch before y=0 to avoid a coincident-face cut
    translate([-mid_r - tenon_w/2 - joint_clearance, -entry_lead, (band_height - tenon_h)/2 - joint_clearance])
        cube([tenon_w + 2*joint_clearance, tenon_len + joint_clearance + 0.5 + entry_lead, tenon_h + 2*joint_clearance]);
    for (sx = [-1, 1])
        translate([-mid_r + sx * tenon_w/2, tenon_len * 0.65, band_height/2])
            sphere(r = snap_r + 0.15);
}

module friction_nibs() {
    for (i = [0 : nib_count_per_half - 1]) {
        theta = 180 * (i + 1) / (nib_count_per_half + 1);
        rotate([0, 0, theta])
            translate([id/2 - nib_protrusion + nib_r, 0, band_height/2])
                sphere(r = nib_r);
    }
}

module flag() {
    // Arc midpoint of this half — lands at global 90deg / 270deg once the
    // two halves are placed, giving one flag visible from each side of the bike.
    rotate([0, 0, 90])
    translate([od/2 - 0.5, 0, band_height])
        hull() {
            sphere(r = flag_thick/2);
            translate([flag_width, 0, flag_height])
                sphere(r = flag_thick * 0.35);
        }
}

module half_ring() {
    difference() {
        union() {
            rotate_extrude(angle = 180)
                band_profile();
            tenon();
            friction_nibs();
            flag();
        }
        mortise();
    }
}

module ghost_fork() {
    color("silver", 0.35)
        translate([0, 0, -30])
            cylinder(d = fork_tube_dia, h = 70);
    color("black", 0.45)
        translate([0, 0, -6])
            cylinder(d1 = fork_tube_dia + 14, d2 = fork_tube_dia + 4, h = 6);
}

if (part == "half") {
    half_ring();
} else if (part == "both") {
    translate([-od, 0, 0]) half_ring();
    translate([od, 0, 0]) half_ring();
} else if (part == "assembled") {
    ghost_fork();
    color("orangered") half_ring();
    color("black") rotate([0, 0, 180]) half_ring();
}
