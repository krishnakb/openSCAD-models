// --- THE "NO-FAIL" OVERNIGHT WAND (240mm) ---
total_length = 240;      
insertion_depth = 45;   

// Wide End (Hose Side)
wide_od = 36.5; 
wide_id_entrance = 31.2; // Slightly wider entrance
wide_id_bottom = 30.4;   // Slightly wider bottom for guaranteed fit

// Narrow End (Floor Tool Side)
narrow_tip_od = 30.0;   
narrow_base_od = 32.2;  

narrow_id = 25.2;

$fn = 100;

difference() {
    union() {
        cylinder(h = insertion_depth, d = wide_od);
        translate([0, 0, insertion_depth])
            cylinder(h = total_length - (insertion_depth * 2), d1 = wide_od, d2 = narrow_base_od);
        translate([0, 0, total_length - insertion_depth])
            cylinder(h = insertion_depth, d1 = narrow_base_od, d2 = narrow_tip_od);
    }
    union() {
        translate([0, 0, -1]) 
            cylinder(h = insertion_depth + 1, d1 = wide_id_entrance, d2 = wide_id_bottom);
        translate([0, 0, insertion_depth - 0.1])
            cylinder(h = total_length - insertion_depth + 1, d1 = wide_id_bottom - 1, d2 = narrow_id);
    }
}
