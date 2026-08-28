# fadec.nas
var fadec_timer = nil;

var throttle_path = "/controls/engines/engine/throttle";
var advance_path = "/controls/engines/engine/propeller-pitch";

var engine_hrs_path = "/sim/maintenance/engine/operating-hours";
var engine_sec_path = "/sim/maintenance/engine/operating-seconds";
var maint_mode_path = "/sim/maintenance/enabled";

var MAX_WEAR_HOURS = 3000.0;     
var MIN_PERFORMANCE = 0.80;     

var clamp01 = func(value) {
    if (value == nil) { return 0.0; }
    if (value < 0.0) { return 0.0; }
    if (value > 1.0) { return 1.0; }
    return value;
}

# Processes dynamic environmental wear purely using local arguments
# Writes back to the property tree ONCE for aircraft-data tracking, then returns the fresh value
var update_fadec_wear = func(dt, current_seconds, current_egt) {
    var diff_factor = maintenance.difficulty_factor;
    var speedup = getprop("/sim/speed-up") or 1.0;
    
    var base_wear = dt * speedup; 
    
    # Accelerated degradation if pushing the diesel cylinders past standard operational thermal load
    if (current_egt > 750.0) { 
        base_wear = base_wear * 3.0; 
    }

    var final_seconds = current_seconds + (base_wear * diff_factor);
    
    # Update property tree coordinates strictly for the aircraft-data autosave module
    setprop(engine_sec_path, final_seconds);
    setprop(engine_hrs_path, final_seconds / 3600.0);
    
    return final_seconds;
}

# Calculates engine health multiplier purely in local memory (No Property Tree lookups)
var get_engine_efficiency = func(wear_enabled, hours) {
    if (!wear_enabled) {
        return 1.0; # Maintenance off: bypass curve and supply full engine capabilities
    }

    if (hours >= MAX_WEAR_HOURS) { 
        return MIN_PERFORMANCE; 
    }
    
    return 1.0 - ((hours / MAX_WEAR_HOURS) * (1.0 - MIN_PERFORMANCE));
}

var update_fadec = func {
    var dt = 0.1; # FADEC operates at 10Hz updates (0.1s delta step)
    
    # 1. Capture global conditions once at the beginning of the frame
    var wear_enabled = props.globals.getNode(maint_mode_path, 1).getBoolValue();
    var current_seconds = getprop(engine_sec_path) or 0.0;
    var rpm = getprop("/engines/engine/rpm") or 0.0;
    var mp  = getprop("/engines/engine/mp-inhg") or 29.92;
    var oat = getprop("/environment/temperature-degc") or 15.0;

    # =================================================================
    # DIESEL ENGINE EXHAUST GAS TEMPERATURE (EGT) MATHEMATICAL LAYER
    # =================================================================
    var calculated_egt = oat;

    if (rpm > 100.0) {
        # Modern aviation diesel engines (like the RED A03 V12) run high compression 
        # Base combustion heat builds directly from mechanical load (RPM and Manifold Pressure)
        var power_thermal_output = (rpm * 0.15) + (mp * 11.2);
        
        # Factor in ram air cooling over the engine exhaust manifolds based on airspeed
        var airspeed = getprop("/velocities/airspeed-kt") or 0.0;
        var ram_air_cooling = airspeed * 0.35;

        calculated_egt = power_thermal_output - ram_air_cooling;

        # Hard operational ceilings to mirror real-world compression-ignition thresholds
        if (calculated_egt < 250.0) { calculated_egt = 250.0; } # Hot idle combustion floor
        if (calculated_egt > 820.0) { calculated_egt = 820.0; } # Structural max thermal safety limit
    }

    # Instantly output the generated value back into the tree to satisfy instruments & scripts
    setprop("/engines/engine/egt-degc", calculated_egt);
    # =================================================================

    # 2. Accumulate running engine stress values natively if engine is running
    if (rpm > 100.0) { 
        current_seconds = update_fadec_wear(dt, current_seconds, calculated_egt); 
    }

    # 3. Process efficiency calculations entirely through internal memory arguments
    var current_hours = current_seconds / 3600.0;
    var efficiency = get_engine_efficiency(wear_enabled, current_hours);
    
    # 4. Map the scaled output straight to the hardware propeller pitch node
    var throttle = clamp01(getprop(throttle_path));
    setprop(advance_path, clamp01(throttle * efficiency));
}

var init_fadec = func {
    print("Initializing Yak-152 FADEC System with Thermal EGT Layer...");
    setprop(advance_path, 0.0);
    
    # Spin up 10Hz high-speed timer loop
    fadec_timer = maketimer(0.1, update_fadec);
    fadec_timer.start();
}

# Auto-start on file load
init_fadec();
