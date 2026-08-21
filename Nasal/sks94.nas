# NPP Zvezda SKS-94 Sequential Extraction Script v.24
# Modular Multi-Seat Architecture:
#   - eject_pilot()   -> Runs complete front seat sequence on /controls/seat/eject[0]/
#   - eject_copilot() -> Runs complete rear seat sequence on /controls/seat/eject[1]/

# =============================================================================
# GLOBAL STATE & CONSTANTS
# =============================================================================
var ejection_triggered = 0;
var impact_timer = nil;
var ac_lat = 0.0;
var ac_lon = 0.0;
var ac_alt = 0.0;

var static_pitch_pull  =  0.85;
var static_roll_snap   = -0.45;
var static_rudder_kick =  0.25;

# =============================================================================
# VIEW HELPER FUNCTIONS
# =============================================================================
var set_view_enabled = func(target_id, state) {
    var views = props.globals.getNode("/sim").getChildren("view");
    foreach (var v; views) {
        var config = v.getNode("config");
        var val = nil;
        if (config != nil and config.getNode("view-number") != nil) {
            val = config.getNode("view-number").getValue();
        } else {
            var id_node = v.getNode("view-number-raw") or v.getNode("id");
            val = (id_node != nil) ? id_node.getValue() : v.getIndex();
        }
        if (val == target_id) {
            v.getNode("enabled", 1).setBoolValue(state);
        }
    }
};

var update_ejection_view_targets = func {
    var target_node_index = nil;
    var found_p1_index = nil;
    var found_p2_index = nil;

    var models_root = props.globals.getNode("/ai/models");
    if (models_root == nil) return;

    var models = models_root.getChildren();
    foreach (var m; models) {
        var name_node = m.getNode("name");
        if (name_node != nil) {
            var name_val = name_node.getValue();
            var idx = m.getIndex();
            if (name_val == "Parachutist2") {
                found_p2_index = idx;
                break;
            } elsif (name_val == "Parachutist1") {
                found_p1_index = idx;
            }
        }
    }

    target_node_index = (found_p2_index != nil) ? found_p2_index : found_p1_index;
    if (target_node_index == nil) {
        print("SKS-94 Tracker Warning: No parachutist submodels identified!");
        return;
    }

    var base_path = "/ai/models/ballistic[" ~ target_node_index ~ "]/";
    var lat_path  = base_path ~ "position/latitude-deg";
    var lon_path  = base_path ~ "position/longitude-deg";
    var alt_path  = base_path ~ "position/altitude-ft";
    var hdg_path  = base_path ~ "orientation/hdg-deg";

    var sim_views = props.globals.getNode("/sim").getChildren("view");
    foreach (var v; sim_views) {
        var config = v.getNode("config");
        if (config != nil) {
            var val_node = config.getNode("view-number-raw") or config.getNode("view-number") or v.getNode("id");
            if (val_node != nil) {
                var view_id = val_node.getValue();
                if (view_id == 103) {
                    config.getNode("eye-lat-deg-path", 1).setValue(lat_path);
                    config.getNode("eye-lon-deg-path", 1).setValue(lon_path);
                    config.getNode("eye-alt-ft-path", 1).setValue(alt_path);
                    config.getNode("eye-heading-deg-path", 1).setValue(hdg_path);
                    config.getNode("eye-pitch-deg-path", 1).setValue(base_path ~ "orientation/pitch-deg");
                    config.getNode("eye-roll-deg-path", 1).setValue(base_path ~ "orientation/roll-deg");
                } elsif (view_id == 104 or view_id == 105) {
                    config.getNode("target-lat-deg-path", 1).setValue(lat_path);
                    config.getNode("target-lon-deg-path", 1).setValue(lon_path);
                    config.getNode("target-alt-ft-path", 1).setValue(alt_path);
                    config.getNode("target-heading-deg-path", 1).setValue(hdg_path);
                    config.getNode("at-model-idx", 1).setIntValue(target_node_index);
                }
            }
        }
    }
};

# =============================================================================
# SELF-CONTAINED SEAT SEQUENCES
# =============================================================================

# Reusable sequence for an individual seat (0 = Pilot, 1 = Copilot)
var eject_seat = func(seat_id) {
    var prefix = "/controls/seat/eject[" ~ seat_id ~ "]/";
    var seat_name = (seat_id == 0) ? "Pilot (Front)" : "Copilot (Rear)";

    print("SKS-94: " ~ seat_name ~ " pyros fired. Rail travel commencing...");

    # 1. Rocket ignition and rail travel (0.6s)
    setprop(prefix ~ "smoke-rate", 1.0);
    interpolate(prefix ~ "eject-norm", 1.0, 0.6);

    # 2. Rail apex separation -> trigger submodel and stop smoke
    settimer(func {
        print("SKS-94: " ~ seat_name ~ " cleared rails. Spawning submodel...");
        setprop(prefix ~ "ejected", 1);
        setprop(prefix ~ "smoke-rate", 0.0);

        # 3. Deploy drogue streamer (2.0s)
        interpolate(prefix ~ "chute-norm", 1.0, 2.0);

        # 4. Lines taut -> Inflate main parachute canopy (1.6s after drogue)
        settimer(func {
            print("SKS-94: " ~ seat_name ~ " lines taut. Inflating main canopy...");
            interpolate(prefix ~ "chute-inflate-norm", 1.0, 1.2);
            
            # If this is the main pilot in 1st-person view, perform the canopy opening head jerk
            if (seat_id == 0) {
                var view_type = getprop("/controls/seat/eject/view-type") or 0;
                if (view_type == 0) {
                    interpolate("/sim/current-view/pitch-offset-deg",
                        -85.0, 0.3,
                        -85.0, 0.7,
                        -65.0, 1.0
                    );
                }
            }
        }, 1.6);

    }, 0.6);
};

var eject_pilot = func {
    eject_seat(0);
};

var eject_copilot = func {
    eject_seat(1);
};

# =============================================================================
# MASTER EJECTION TRIGGER & COORDINATOR
# =============================================================================
var trigger_sks94 = func {
    if (ejection_triggered) return;
    ejection_triggered = 1;

    print("SKS-94: Ejection handles pulled. Initializing master sequence...");
    setprop("/controls/seat/eject/ejected", 1);

    # 1. Lock flight controls and kill throttle immediately
    setprop("/controls/flight/elevator", static_pitch_pull);
    setprop("/controls/flight/aileron", static_roll_snap);
    setprop("/controls/flight/rudder", static_rudder_kick);
    setprop("/controls/engines/engine/throttle", 0.0);
    setprop("/autopilot/locks/heading", "");
    setprop("/autopilot/locks/altitude", "");

    # 2. Capture GPS coordinates for rescue broadcast
    ac_lat = getprop("/position/latitude-deg") or 0.0;
    ac_lon = getprop("/position/longitude-deg") or 0.0;
    ac_alt = getprop("/position/altitude-ft") or 0.0;

    # 3. Setup ejection cameras and step to Exit View 102
    set_view_enabled(102, 1);
    set_view_enabled(103, 1);
    set_view_enabled(104, 1);
    set_view_enabled(105, 1);
    setprop("sim/view/enabled", 0);

    var max_steps = 30;
    var current_raw = getprop("/sim/current-view/view-number-raw");
    while (current_raw != 102 and max_steps > 0) {
        view.stepView(1);
        var next_raw = getprop("/sim/current-view/view-number-raw");
        if (next_raw == current_raw) break;
        current_raw = next_raw;
        max_steps = max_steps - 1;
    }

    # 4. Trigger Sequences: Copilot first (if present), then Pilot after 0.85s delay
    var copilot_visible = getprop("/sim/multiplay/generic/bool[0]") or 
                          getprop("/sim/multiplay/generic/bool") or 0;

    if (copilot_visible) {
        eject_copilot();
        settimer(func { eject_pilot(); }, 0.85);
    } else {
        eject_pilot();
    }

    # 5. Camera Transfer to Parachutist: Runs after pilot leaves the airframe
    var pilot_start_time = copilot_visible ? 0.85 : 0.0;
    var pilot_clear_time = pilot_start_time + 0.6 + 0.3; # Rail exit + 0.3s visual clearance

    settimer(func {
        print("SKS-94: Pilot clear. Transferring camera to parachutist...");
        update_ejection_view_targets();

        setprop("/sim/current-view/ejection-cam/eye-lat-deg", ac_lat);
        setprop("/sim/current-view/ejection-cam/eye-lon-deg", ac_lon);
        setprop("/sim/current-view/ejection-cam/eye-alt-ft", ac_alt);
        handle_ejection_broadcast(ac_lat, ac_lon);

        # Lock out cockpit views
        set_view_enabled(0, 0);
        set_view_enabled(100, 0);
        set_view_enabled(101, 0);

        # Step camera to selected view (103, 104, or 105)
        var view_type = getprop("/controls/seat/eject/view-type") or 0;
        var target_raw = (view_type == 1) ? 104 : ((view_type == 2) ? 105 : 103);
        
        var loop_limit = 30;
        var cur_loop_raw = getprop("/sim/current-view/view-number-raw");
        while (cur_loop_raw != target_raw and loop_limit > 0) {
            view.stepView(1);
            var nxt_loop_raw = getprop("/sim/current-view/view-number-raw");
            if (nxt_loop_raw == cur_loop_raw) break;
            cur_loop_raw = nxt_loop_raw;
            loop_limit = loop_limit - 1;
        }

        if (view_type == 0) {
            setprop("/sim/current-view/y-offset-m", -3.0);
            interpolate("/sim/current-view/y-offset-m", -0.54, 2.0);
        }
    }, pilot_clear_time);

    # 6. Descent & Crash Monitor Loop (0.1s)
    var elapsed_seconds = 0.0;
    impact_timer = maketimer(0.1, func {
        elapsed_seconds = elapsed_seconds + 0.1;

        # Keep controls locked during descent
        setprop("/controls/flight/elevator", static_pitch_pull);
        setprop("/controls/flight/aileron", static_roll_snap);
        setprop("/controls/flight/rudder", static_rudder_kick);

        var agl_ft = getprop("/position/altitude-agl-ft") or 9999.0;
        var sim_crashed = getprop("/sim/crashed") or 0;

        if (agl_ft <= 3.0 or sim_crashed or elapsed_seconds >= 45.0) {
            print("SKS-94: Aircraft impact confirmed. Resetting control surfaces and views.");
            if (impact_timer != nil) impact_timer.stop();

            setprop("/controls/flight/elevator", 0.0);
            setprop("/controls/flight/aileron", 0.0);
            setprop("/controls/flight/rudder", 0.0);
            setprop("/sim/crashed", 1);

            # Restore normal views
            set_view_enabled(102, 0);
            set_view_enabled(103, 0);
            set_view_enabled(104, 0);
            set_view_enabled(105, 0);

            set_view_enabled(0, 1);
            set_view_enabled(100, 1);
            set_view_enabled(101, 1);
            
            # forced switch to tail view after crash
            # setprop("sim/view/enabled", 1);
            # var post_loop = 30;
            # while (getprop("/sim/current-view/view-number-raw") != 100 and post_loop > 0) {
            #     view.stepView(1);
            #     post_loop = post_loop - 1;
            # }
        }
    });

    impact_timer.start();
};

# =============================================================================
# MULTIPLAYER BROADCAST
# =============================================================================
var handle_ejection_broadcast = func(ac_lat, ac_lon) {
    var callsign = getprop("/sim/multiplay/callsign") or "Pilot";
    var msg = sprintf("SOS! MAY DAY! - %s ejected! Send rescue chopper to: %.4f, %.4f", callsign, ac_lat, ac_lon);
    #globals.screen.log.write(msg, 1, 1, 0);
    print("SKS-94 MESSAGE: " ~ msg);
    setprop("/sim/multiplay/chat", msg);
};

# =============================================================================
# SYSTEM INITIALIZATION & RESET
# =============================================================================
var init_views = func {
    set_view_enabled(102, 0);
    set_view_enabled(103, 0);
    set_view_enabled(104, 0);
    set_view_enabled(105, 0);

    set_view_enabled(0, 1);
    set_view_enabled(100, 1);
    set_view_enabled(101, 1);
    setprop("sim/view/enabled", 1);

    # Reset Pilot seat [0]
    setprop("/controls/seat/eject[0]/ejected", 0);
    setprop("/controls/seat/eject[0]/eject-norm", 0.0);
    setprop("/controls/seat/eject[0]/smoke-rate", 0.0);
    setprop("/controls/seat/eject[0]/chute-norm", 0.0);
    setprop("/controls/seat/eject[0]/chute-inflate-norm", 0.0);

    # Reset Copilot seat [1]
    setprop("/controls/seat/eject[1]/ejected", 0);
    setprop("/controls/seat/eject[1]/eject-norm", 0.0);
    setprop("/controls/seat/eject[1]/smoke-rate", 0.0);
    setprop("/controls/seat/eject[1]/chute-norm", 0.0);
    setprop("/controls/seat/eject[1]/chute-inflate-norm", 0.0);

    var view_type = getprop("/controls/seat/eject/view-type") or 0;
    setprop("/controls/seat/eject/view-type", view_type);
    setprop("/sim/gui/dialogs/config/eject-view-0", view_type == 0);
    setprop("/sim/gui/dialogs/config/eject-view-1", view_type == 1);
    setprop("/sim/gui/dialogs/config/eject-view-2", view_type == 2);

    if (impact_timer != nil) impact_timer.stop();
    ejection_triggered = 0;

    print("SKS-94: Multi-seat indexed system initialized.");
};

setlistener("/sim/signals/fdm-initialized", func {
    init_views();
});