# Yak-152 Single-Lever FADEC Governor Loop
var fadec_loop = func {
    # Match the explicit engine[0] array index from your YASim control-inputs
    var throttle = getprop("/controls/engines/engine[0]/throttle");
    if (throttle == nil) { throttle = 0.0; }

    var target_rpm_setting = 0.0;

    # RPM Profile Mapping Schedule
    if (throttle <= 0.15) {
        # Idle range: Command minimum governor speed floor
        target_rpm_setting = 0.0; 
    } else if (throttle <= 0.85) {
        # Cruise range: Linearly scale target up towards cruise RPM
        target_rpm_setting = 0.20 + ((throttle - 0.15) / 0.70) * 0.60;
    } else {
        # Takeoff range: Command maximum takeoff RPM limit
        target_rpm_setting = 0.80 + ((throttle - 0.85) / 0.15) * 0.20;
    }

    # Write securely to the exact engine[0] control node path
    setprop("/controls/engines/engine/propeller-pitch", target_rpm_setting);
}

# System Initialization
var init_fadec = func {
    print("Yak-152 FADEC System Initialized.");
    
    # Run the governor loop 20 times per second
    var fadec_timer = maketimer(0.05, fadec_loop);
    fadec_timer.start();
}

# Wait for FlightGear's property tree array structures to completely instantiate
settimer(init_fadec, 2.5);
