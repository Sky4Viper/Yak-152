# maintenance.nas
print("Loading Maintenance Logic (Airframe Only)...");

var rm_root = "/sim/maintenance"; 
var airframe_load_speed = 60; 

var rm_loop = func {
    var dt = 1.0; 
    airframe_load(dt); 
    airframe_hours();
};

var service = func {
    var wow0 = getprop("/gear/gear/wow") or 0;
    var wow1 = getprop("/gear/gear/wow") or 0;
    var wow2 = getprop("/gear/gear/wow") or 0;
    var gs   = getprop("/velocities/groundspeed-kt") or 0.0;

    if (wow0 and wow1 and wow2 and (gs < 2)) {
        setprop(rm_root ~ "/airframe-seconds", 0.0);
        setprop(rm_root ~ "/airframe-hours", 0.0);
        setprop(rm_root ~ "/engine/operating-seconds", 0.0);
        setprop(rm_root ~ "/engine/operating-hours", 0.0);
        setprop("yak152/effect/rust-outside", 0);
        setprop("yak152/effect/rust-factor", 0.0);
        screen.log.write("Aircraft has been serviced", 1, 0.6, 0.1);
    } else {
        screen.log.write("You must be completely stopped on the ground to service!", 1, 0.6, 0.1);
    }
};

var airframe_hours = func {
    var current_seconds = getprop(rm_root ~ "/airframe-seconds") or 0.0;
    var hrs = current_seconds / 3600.0;
    setprop(rm_root ~ "/airframe-hours", hrs);
    
    if (hrs > 0.1) {
        setprop("yak152/effect/rust-outside", 1);
        setprop("yak152/effect/rust-factor", hrs * 0.0025);
    }
};

var airframe_load = func(dt) {
    var airspeed = getprop("/velocities/airspeed-kt") or 0.0;
    
    if (airspeed > airframe_load_speed) {
        var current_seconds = getprop(rm_root ~ "/airframe-seconds") or 0.0;
        var speedup = getprop("/sim/speed-up") or 1.0;
        
        # FIXED: Points cleanly to the shared 'maintenance' namespace memory block
        var diff_factor = maintenance.difficulty_factor;
        
        var added_seconds = dt * speedup * diff_factor;
        setprop(rm_root ~ "/airframe-seconds", current_seconds + added_seconds);
    }
};
    
var report = func {
    var af_hrs = getprop(rm_root ~ "/airframe-hours") or 0.0;
    var eng_hrs = getprop(rm_root ~ "/engine/operating-hours") or 0.0;
    return sprintf("Airframe Hours: %5.1f | Engine Hours: %5.1f", af_hrs, eng_hrs);
};
