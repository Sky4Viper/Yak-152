# Universal FADEC Script
# Direct throttle-to-propeller ADVANCE schedule
# Leaving altitude behaviour to YASim for now;

var fadec_timer = nil;

var throttle_path = "/controls/engines/engine/throttle";
var advance_path = "/controls/engines/engine/propeller-pitch";

var clamp01 = func(value) {
    if (value == nil) { return 0.0; }
    if (value < 0.0) { return 0.0; }
    if (value > 1.0) { return 1.0; }
    return value;
}

var update_fadec = func {
    var throttle = clamp01(getprop(throttle_path));
    # Direct normalized power-lever schedule
    var advance = throttle;
    setprop(advance_path, advance);
    # Diagnostics properties
    setprop("/yak152/fadec/throttle-input", throttle);
    setprop("/yak152/fadec/advance-command", advance);
}

var init_fadec = func {
    print("Initializing Yak-152 FADEC System...");
    # Correct the inappropriate value immediately.
    setprop(advance_path, 0.0);
    fadec_timer = maketimer(0.1, update_fadec);
    fadec_timer.start();
}

# Auto-start on load
init_fadec();
