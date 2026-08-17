# Unified SKS-94 State Machine Script

# NPP Zvezda SKS-94 Sequential Extraction Script
# Unified State Machine Edition - Fixed Variable Scope Execution Path
# Tracks properties sequentially to coordinate animations, locks, and camera snapping.

# GLOBAL PERSISTENT VARIABLES (Moved to file scope to prevent async reference errors)

var ejection_triggered = 0;var impact_timer = nil;
var ejection_state = 0;
var max_seconds = 30.0;
var elapsed_seconds = 0.0;
var ac_lat = 0.0;
var ac_lon = 0.0;
var ac_alt = 0.0;

# PILOT FORCE JERK CONSTANTS

var static_pitch_pull = 0.85;
var static_roll_snap  = -0.45;
var static_rudder_kick = 0.25; 

# Helper function to dynamically modify specific view availability parameters

var set_view_enabled = func(target_id, state) {
    var views = props.globals.getNode("/sim").getChildren("view");
    foreach (var v; views) {
        var config = v.getNode("config");
        var val = nil;
        
        if (config != nil and config.getNode("view-number") != nil) {
            val = config.getNode("view-number").getValue();
        } else {
            var id_node = v.getNode("view-number-raw") or v.getNode("id");
            if (id_node != nil) {
                val = id_node.getValue();
            } else {
                val = v.getIndex();
            }
        }
        
        if (val == target_id) {

            v.getNode("enabled", 1).setBoolValue(state);
        }
    }
};

# Dynamically resolves and updates view properties to target the active parachutist

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
    
    if (found_p2_index != nil) {
        target_node_index = found_p2_index;
    } elsif (found_p1_index != nil) {
        target_node_index = found_p1_index;
    } else {
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
                }
                elsif (view_id == 104 or view_id == 105) {
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

var trigger_sks94 = func {
    if (ejection_triggered) return;

    var pilot_ejected = getprop("/controls/seat/eject/ejected");
    if (!pilot_ejected) {
        ejection_triggered = 1;
        ejection_state = 0; 
        max_seconds = 45.0;
        elapsed_seconds = 0.0;
        print("SKS-94 EVENT 1: Handles pulled. Initializing view and control lockout configurations.");

        # Capture drone tripod coordinates immediately at origin location
        ac_lat = getprop("/position/latitude-deg") or 0.0;
        ac_lon = getprop("/position/longitude-deg") or 0.0;
        ac_alt = getprop("/position/altitude-ft") or 0.0;

        # Force initial camera array permissions open
        set_view_enabled(102, 1);
        set_view_enabled(103, 1);
        set_view_enabled(104, 1);
        set_view_enabled(105, 1);
        

        # Disable manual view cycling controls
        setprop("sim/view/enabled", 0);

        # Natively step views immediately until View 102 (Cockpit Exit) locks
        var max_steps = 30;
        var current_raw = getprop("/sim/current-view/view-number-raw");
        while (current_raw != 102 and max_steps > 0) {
            view.stepView(1);
            var next_raw = getprop("/sim/current-view/view-number-raw");
            if (next_raw == current_raw) { break; }
            current_raw = next_raw;
            max_steps = max_steps - 1;
        }

        print("SKS-94 EVENT 2: Pyros fired. Seat moving out, forcing a single force input jolt.");
        interpolate("/controls/seat/eject/eject-norm", 1.0, 1.0);
        
        # Check co-pilot presence and handle smoke logic triggers
        var copilot_visible = getprop("/sim/multiplay/generic/bool");

        if (copilot_visible) {
            setprop("/controls/seat/eject/copilot-ejected", 1); 
            setprop("/controls/seat/eject/smoke-rate-rear", 1.0);
            settimer(func { setprop("/controls/seat/eject/smoke-rate-rear", 0.0); }, 0.85);
        }
        setprop("/controls/seat/eject/smoke-rate-front", 1.0);
        settimer(func { setprop("/controls/seat/eject/smoke-rate-front", 0.0); }, 1.45);

        # ======================================================================
        # CENTRAL SEQUENTIAL EVENT LOOP STATE MACHINE ENGINE (0.1s Intervals)
        # ======================================================================
        impact_timer = maketimer(0.1, func {
            elapsed_seconds = elapsed_seconds + 0.1;
            
            # Continuously enforce stick lock metrics to block user joystick inputs
            setprop("/controls/flight/elevator", static_pitch_pull);
            setprop("/controls/flight/aileron", static_roll_snap);
            setprop("/controls/flight/rudder", static_rudder_kick);
            setprop("/controls/engines/engine/throttle", 0.0);

            setprop("/autopilot/locks/heading", "");
            setprop("/autopilot/locks/altitude", "");

            # ------------------------------------------------------------------
            # STATE 0: WATCHING SEAT MOVEMENT (Waiting for eject-norm to hit 1.0)
            # ------------------------------------------------------------------
            if (ejection_state == 0) {
                var eject_norm = getprop("/controls/seat/eject/eject-norm") or 0.0;
                if (eject_norm >= 0.99) {
                    ejection_state = 1; 
                    print("SKS-94 EVENT 3: Seat at max extension. Removing cockpit pilots & triggering submodels.");
                    
                    setprop("/controls/seat/eject/pilot-ejected", 1);
                    setprop("/controls/seat/eject/ejected", 1); 
                    
                    # Resolve active parachutist index paths inside the tree
                    update_ejection_view_targets();

                    # Inject captured origin coordinates into drone storage parameters

                    setprop("/sim/current-view/ejection-cam/eye-lat-deg", ac_lat);
                    setprop("/sim/current-view/ejection-cam/eye-lon-deg", ac_lon);
                    setprop("/sim/current-view/ejection-cam/eye-alt-ft", ac_alt);
                    globals.screen.log.write((sprintf("Ejected, send rescue chopper to: %.2f", ac_lat)) ~ (sprintf(" , %.2f", ac_lon)), 1, 1, 0);

                    # ONE-WAY PERMANENT COCKPIT LOCKOUT
                    set_view_enabled(0, 0);   
                    set_view_enabled(100, 0);
                    set_view_enabled(101, 0);

                    # Read configuration view integer choice settings
                    var view_type = getprop("/controls/seat/eject/view-type") or 0;
                    var target_raw = 103;
                    if (view_type == 1) { target_raw = 104; }
                    elsif (view_type == 2) { target_raw = 105; }
                    
                    # Natively step view engines to snap straight to choice 103, 104, or 105
                    var loop_limit = 30;
                    var cur_loop_raw = getprop("/sim/current-view/view-number-raw");

                    while (cur_loop_raw != target_raw and loop_limit > 0) {
                        view.stepView(1);
                        var nxt_loop_raw = getprop("/sim/current-view/view-number-raw");
                        if (nxt_loop_raw == cur_loop_raw) { break; }
                        cur_loop_raw = nxt_loop_raw;
                        loop_limit = loop_limit - 1;
                    }

                    print("SKS-94 EVENT 4: Routing view complete. Launching Stage 1 Parachute Streamer.");
                    interpolate("/controls/seat/eject/chute-norm", 1.0, 2.5);
                }
            }

            # ------------------------------------------------------------------
            # STATE 1: WATCHING PARACHUTE EXTENSION (Waiting for chute-norm to hit 1.0)
            # ------------------------------------------------------------------
            elsif (ejection_state == 1) {
                var chute_norm = getprop("/controls/seat/eject/chute-norm") or 0.0;
                if (chute_norm >= 0.99) {

                    ejection_state = 2; 
                    print("SKS-94 EVENT 5: Lines taut. Launching Stage 2 Canopy Inflation Phase.");
                    interpolate("/controls/seat/eject/chute-inflate-norm", 1.0, 1.8);
                }
            }

            # ------------------------------------------------------------------
            # STATE 2: ACTIVE DESCENT & CRASH TERMINATION MONITOR
            # ------------------------------------------------------------------
            elsif (ejection_state == 2) {
                var agl_ft = getprop("/position/altitude-agl-ft");
                var sim_crashed_node = getprop("/sim/crashed");
                
                if (agl_ft == nil) { agl_ft = 9999.0; }
                if (sim_crashed_node == nil) { sim_crashed_node = 0; }
                
                # CRASH EVENT CONDITIONAL METRICS CRITERIA DETECTED
                if (agl_ft <= 3.0 or sim_crashed_node or elapsed_seconds >= max_seconds) {
                    ejection_state = 3; 

                    print("SKS-94 EVENT 6 & 7: Wreckage impact confirmed. Processing post-crash environment cleanup.");
                    
                    # Stop loop timer calculation loops completely
                    if (impact_timer != nil) { impact_timer.stop(); }
                    
                    # RELEASE FLIGHT CONTROL LINES BACK TO NEUTRAL
                    setprop("/controls/flight/elevator", 0.0);
                    setprop("/controls/flight/aileron", 0.0);
                    setprop("/controls/flight/rudder", 0.0);
                    setprop("/sim/crashed", 1);
                    
                    # HARD DE-AUTHORIZATION
                    set_view_enabled(102, 0);
                    set_view_enabled(103, 0);
                    set_view_enabled(104, 0);
                    set_view_enabled(105, 0);
                    
                    # RESTORE FLIGHT DECK VIEWS
                    set_view_enabled(0, 1);

                    set_view_enabled(100, 1);
                    set_view_enabled(101, 1);
                    setprop("sim/view/enabled", 1);
                    
                    # Natively step view engine straight onto Tail View 100 for crash wreckage inspection
                    var post_loop = 30;
                    while (getprop("/sim/current-view/view-number-raw") != 100 and post_loop > 0) {
                        view.stepView(1);
                        post_loop = post_loop - 1;
                    }
                }
            }
        });
        
        # Launch the unified event loop immediately
        impact_timer.start();
    }
};


var init_views = func {
    set_view_enabled(102, 0);
    set_view_enabled(103, 0);
    set_view_enabled(104, 0);
    set_view_enabled(105, 0);
    
    set_view_enabled(0, 1);
    set_view_enabled(100, 1);
    set_view_enabled(101, 1); 
    setprop("sim/view/enabled", 1);
    
    setprop("/controls/seat/eject/smoke-rate-front", 0.0);
    setprop("/controls/seat/eject/smoke-rate-rear", 0.0);
    setprop("/controls/seat/eject/ejected", 0);
    setprop("/controls/seat/eject/pilot-ejected", 0);
    setprop("/controls/seat/eject/copilot-ejected", 0);
    setprop("/controls/seat/eject/eject-norm", 0.0);
    setprop("/controls/seat/eject/chute-norm", 0.0);
    setprop("/controls/seat/eject/chute-inflate-norm", 0.0);

    var view_type = getprop("/controls/seat/eject/view-type") or 0;
    setprop("/controls/seat/eject/view-type", view_type);
    setprop("/sim/gui/dialogs/config/eject-view-0", view_type == 0);
    setprop("/sim/gui/dialogs/config/eject-view-1", view_type == 1);
    setprop("/sim/gui/dialogs/config/eject-view-2", view_type == 2);
    
    if (impact_timer != nil) { impact_timer.stop(); }
    ejection_triggered = 0;
    ejection_state = 0;
};

setlistener("/sim/signals/fdm-initialized", func {
    init_views();
});
