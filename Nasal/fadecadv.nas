# Universal Intercept FADEC Script
var fadec_timer = nil;

var init_fadec = func {
    print("Initializing Universal Yak-152 FADEC System...");
    fadec_timer = maketimer(0.05, update_fadec);
    fadec_timer.start();
}

var update_fadec = func {
    # 1. Read the raw throttle input handled by any standard joystick/keyboard
    var raw_input = getprop("/controls/engines/engine/throttle");
    if (raw_input == nil) { raw_input = 0.0; }

    # 2. Get environment data
    var alt = getprop("/position/altitude-ft");
    if (alt == nil) { alt = 0.0; }

    # 3. Calculate target RPM (ADVANCE) based on raw throttle position
    var target_rpm = 0.1 + (raw_input * 0.9);
    var target_throttle = raw_input;

    # 4. FADEC Altitude Protection / De-rating
    if (alt > 10000) {
        var alt_loss = (alt - 10000) / 30000; 
        var max_allowed_throttle = 1.0 - alt_loss;
        if (target_throttle > max_allowed_throttle) {
            target_throttle = max_allowed_throttle;
        }
    }

    # 5. Overwrite the final active parameters safely at runtime
    # (Because this runs post-boot, YASim adapts dynamically without crashing)
    setprop("/controls/engines/engine/propeller-pitch", target_rpm);
    
    # We only apply alt-loss to avoid blocking the user's raw throttle position completely
    if (alt > 10000) {
        setprop("/controls/engines/engine/throttle", target_throttle);
    }
}

# Auto-start on load
init_fadec();
