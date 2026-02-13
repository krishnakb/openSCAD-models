// --- DIMENSIONS FOR P1S MAX PRINT ---
total_length = 70;     // Max safe height for P1S
insertion_depth = 30;   
wall_thickness = 2.5;   

wide_od = 35.6;
wide_id = 30.6; // ADJUST THIS after your test print

narrow_od = 29.9; 
narrow_id = 25.2;

$fn = 100;

difference() {
    union() {
        cylinder(h = insertion_depth, d = wide_od);
        translate([0, 0, insertion_depth])
            cylinder(h = total_length - (insertion_depth * 2), d1 = wide_od, d2 = narrow_od);
        translate([0, 0, total_length - insertion_depth])
            cylinder(h = insertion_depth, d = narrow_od);
    }

    union() {
        // Female Socket Hole
        translate([0, 0, -1]) 
            cylinder(h = insertion_depth + 1, d = wide_id);
        
        // Internal "Stop" / Transition
        translate([0, 0, insertion_depth - 0.1])
            cylinder(h = total_length - (insertion_depth * 2) + 0.2, d1 = narrow_od - 2, d2 = narrow_id);
        
        // Male Tip Hole
        translate([0, 0, total_length - insertion_depth])
            cylinder(h = insertion_depth + 1, d = narrow_id);
    }
}