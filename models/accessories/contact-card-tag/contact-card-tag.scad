// Contact Card Tag with Keychain Ring
// Multi-color: card body + text as separate parts for AMS printing
// All edges rounded for kid safety

// === PART SELECTION ===
part = "both"; // "card", "text", "both", "assembled"

// === PARAMETERS: Measurements ===
card_width = 70;
card_height = 40;
card_thickness = 3;

// === PARAMETERS: Ring ===
ring_outer_radius = 7;
ring_inner_radius = 3.5;
ring_y_offset = 5; // how far ring extends beyond card

// === PARAMETERS: Text ===
text_depth = 1.0;
text_size_name = 8;
text_size_detail = 5;
line_spacing = 10;
left_margin = 6;
font = "Helvetica Neue:style=Bold";

line1 = "Krishna";
line2 = "krishnakb@live.com";
line3 = "+46760651361";

// === PARAMETERS: Design ===
corner_radius = 3;
edge_round = 1.2;

// === PARAMETERS: Colors ===
card_color = "SteelBlue";
text_color = "White";

// === MODULES ===

module rounded_card(w, h, t, cr, er) {
    hull()
        for (x = [cr, w - cr], y = [cr, h - cr]) {
            translate([x, y, 0])
                cylinder(r = cr, h = t - er, $fn = 40);
            translate([x, y, t - er])
                resize([cr * 2, cr * 2, er * 2])
                    sphere(r = 1, $fn = 30);
        }
}

module ring_tab() {
    ring_center_y = card_height + ring_y_offset;
    translate([card_width / 2, ring_center_y, 0])
        difference() {
            hull() {
                for (a = [-1, 1])
                    translate([a * (ring_outer_radius - edge_round), 0, 0])
                        cylinder(r = edge_round, h = card_thickness - edge_round, $fn = 30);
                for (a = [-1, 1])
                    translate([a * (ring_outer_radius - edge_round), 0, card_thickness - edge_round])
                        sphere(r = edge_round, $fn = 30);
            }
            translate([0, 0, -1])
                cylinder(r = ring_inner_radius, h = card_thickness + 2, $fn = 40);
        }
}

// Bridge connecting card top edge to ring tab
module ring_bridge() {
    bridge_w = ring_outer_radius * 2;
    translate([card_width / 2 - bridge_w / 2, card_height - corner_radius, 0])
        cube([bridge_w, ring_y_offset + corner_radius, card_thickness]);
}

module card_body() {
    union() {
        rounded_card(card_width, card_height, card_thickness, corner_radius, edge_round);
        ring_bridge();
        ring_tab();
    }
}

module text_labels() {
    translate([left_margin, 0, card_thickness - 0.01]) {
        translate([0, card_height / 2 + line_spacing, 0])
            linear_extrude(text_depth)
                text(line1, size = text_size_name,
                     font = font, halign = "left", valign = "center", $fn = 40);

        translate([0, card_height / 2, 0])
            linear_extrude(text_depth)
                text(line2, size = text_size_detail,
                     font = font, halign = "left", valign = "center", $fn = 40);

        translate([0, card_height / 2 - line_spacing, 0])
            linear_extrude(text_depth)
                text(line3, size = text_size_detail,
                     font = font, halign = "left", valign = "center", $fn = 40);
    }
}

// === RENDER ===

if (part == "card") {
    color(card_color) card_body();
} else if (part == "text") {
    color(text_color) text_labels();
} else if (part == "both") {
    color(card_color) card_body();
    color(text_color) text_labels();
} else if (part == "assembled") {
    color(card_color) card_body();
    color(text_color) text_labels();
}
