# NPP Zvezda SKS-94 Sequential Extraction Script (v.21)
# Incorporates checkbox view selection logic (View 103 vs View 104)
# Handles automated dynamic view authorization locks
# Induces dampened aerodynamic chaotic tumbling behaviors on empty airframe
# Regulates property-driven particle generation values to circumvent culling glitches

var ejection_triggered = 0;
var impact_timer = nil;

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
    
    # Scan the first 20 nodes under /ai/models/ to locate spawning parachutists
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
                break; # Priority 1 found, stop searching early
            } elsif (name_val == "Parachutist1") {
                found_p1_index = idx;
            }
        }
    }
    
    # Implement priority fallback rules
    if (found_p2_index != nil) {
        target_node_index = found_p2_index;
        print("SKS-94 Tracker: Found Parachutist 2 at index " ~ target_node_index);
    } elsif (found_p1_index != nil) {
        target_node_index = found_p1_index;
        print("SKS-94 Tracker: Parachutist 2 missing. Tracking Parachutist 1 at index " ~ target_node_index);
    } else {
        print("SKS-94 Tracker Warning: No parachutist submodels identified in the property tree!");
        return; # Abort path rewriting to prevent feeding null pointers to the engine
    }
    
    # Construct the explicit indexed path strings
    var base_path = "/ai/models/ballistic[" ~ target_node_index ~ "]/";
    var lat_path  = base_path ~ "position/latitude-deg";
    var lon_path  = base_path ~ "position/longitude-deg";
    var alt_path  = base_path ~ "position/altitude-ft";
    var hdg_path  = base_path ~ "orientation/hdg-deg";
    
    # Inject these paths dynamically into the View 103 and 104 configurations
    var sim_views = props.globals.getNode("/sim").getChildren("view");
    foreach (var v; sim_views) {
        var config = v.getNode("config");
        if (config != nil) {
            var val_node = config.getNode("view-number-raw") or config.getNode("view-number") or v.getNode("id");
            if (val_node != nil) {
                var view_id = val_node.getValue();
                
                # First Person View uses eye paths
                if (view_id == 103) {
                    config.getNode("eye-lat-deg-path", 1).setValue(lat_path);
                    config.getNode("eye-lon-deg-path", 1).setValue(lon_path);
                    config.getNode("eye-alt-ft-path", 1).setValue(alt_path);
                    config.getNode("eye-heading-deg-path", 1).setValue(hdg_path);
                    config.getNode("eye-pitch-deg-path", 1).setValue(base_path ~ "orientation/pitch-deg");
                    config.getNode("eye-roll-deg-path", 1).setValue(base_path ~ "orientation/roll-deg");
                }
                # Cinematic tracker uses target paths
                elsif (view_id == 104) {
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
        print("SKS-94 Eject! Eject! Eject!");
 
        # ======================================================================
        # PHASE 1 SEQUENCE: INITIATION & INSTANT TAIL CAM SWITCH
        # ======================================================================
        # Authorise custom ejection cameras in memory
        set_view_enabled(102, 1);
        set_view_enabled(103, 1);
        set_view_enabled(104, 1);
        set_view_enabled(105, 1);
        
        # STATIC CAMERA SNAPSHOT: Grab positions at the exact microsecond of ejection
        var ac_lat = getprop("/position/latitude-deg");
        var ac_lon = getprop("/position/longitude-deg");
        var ac_alt = getprop("/position/altitude-ft");

        # Kill engine commands and release autopilot loops immediately
        setprop("/controls/engines/engine/throttle", 0.0);
        setprop("/autopilot/locks/heading", "");
        setprop("/autopilot/locks/altitude", "");

        # KEY-BINDING EMULATION: Cycles views natively until View 102 actively locks
        var max_steps = 30;
        var current_raw = getprop("/sim/current-view/view-number-raw");
        while (current_raw != 102 and max_steps > 0) {
            view.stepView(1);
            var next_raw = getprop("/sim/current-view/view-number-raw");
            if (next_raw == current_raw) {
                print("SKS-94 Error: view.stepView locked. Aborting Phase 1 loop.");
                break;
            }
            current_raw = next_raw;
            max_steps = max_steps - 1;
        }

        # ======================================================================
        # PHASE 2 SEQUENCE: MULTI-SEAT COCKPIT SEPARATION TIMELINES
        # ======================================================================
        # Evaluate configuration layout for secondary aircrew presence
        var copilot_visible = getprop("/sim/multiplay/generic/bool");
        if (copilot_visible) {
            print("SKS-94: Instructor/Copilot detected. Launching rear seat first...");
            setprop("/controls/seat/eject/copilot-ejected", 1); 
            
            # Ignite rear seat solid rocket propellant smoke emitter particles
            setprop("/controls/seat/eject/smoke-rate-rear", 1.0);
            settimer(func {
                print("SKS-94: Rear rocket engine burnout threshold reached.");
                setprop("/controls/seat/eject/smoke-rate-rear", 0.0);
            }, 0.85);
        } else {
            print("SKS-94: Solo flight configuration. Skipping rear cockpit submodel execution.");
        }
        
        # Deploy structural animation interpolation path timeline for the overall seat system
        setprop("/controls/seat/eject/ejected", 1); 
        interpolate("/controls/seat/eject/eject-norm", 1.0, 0.5);

        # Calculate safety clearance delay window before launching the forward pilot frame
        var delay = copilot_visible ? 0.6 : 0.0;
        settimer(func {
            print("SKS-94: Deploying front cockpit occupant clear space...");
            setprop("/controls/seat/eject/pilot-ejected", 1);
            
            # Ignite front seat solid rocket propellant smoke emitter particles
            setprop("/controls/seat/eject/smoke-rate-front", 1.0);
            settimer(func {
                print("SKS-94: Front rocket engine burnout threshold reached.");
                setprop("/controls/seat/eject/smoke-rate-front", 0.0);
            }, 0.85);
        }, delay);

        # PHASE 3 SEQUENCE: Evaluate dialog checkboxes, route views, and begin ground tracking
        settimer(func {
            print("SKS-94: Finalizing tracking trajectory path rules.");
            
            # Dynamically look up active parachutist objects inside /ai/models/
            update_ejection_view_targets();

            # Drone view coordinate capture
            setprop("/sim/current-view/ejection-cam/eye-lat-deg", ac_lat);
            setprop("/sim/current-view/ejection-cam/eye-lon-deg", ac_lon);
            setprop("/sim/current-view/ejection-cam/eye-alt-ft", ac_alt);

            handle_ejection_broadcast(ac_lat, ac_lon);
            
            # Trigger our two-stage property timelines smoothly
            interpolate("/controls/seat/eject/chute-norm", 1.0, 1.5);
            var view_type = getprop("/controls/seat/eject/view-type") or 0;
            if (view_type == 0) {
                        # moving view forward to avoid model clipping then back
                        #setprop("/sim/current-view/y-offset-m", -5.0);
                        #interpolate("/sim/current-view/y-offset-m", -0.54, 3.0);
                        interpolate("/sim/current-view/pitch-offset-deg", -65.0, 1.8); 
                        }
            
            settimer(func {
                print("SKS-94: Canopy lines taut. Inflating canopy volume panels...");
                interpolate("/controls/seat/eject/chute-inflate-norm", 1.0, 1.8);
            }, 1.5); # <-- CHANGE THIS from 0.5 to 1.5 or 2.0 seconds to delay canopy inflation
            
            # ONE-WAY PERMANENT COCKPIT LOCKOUT
            set_view_enabled(0, 0);   
            set_view_enabled(100, 0);
            set_view_enabled(101, 0); 
            setprop("sim/view/enabled", 0);
            
            # View 103 vs (104 or 105) cycling checks

            # Read the unified integer property (default to 0 if nil)
            var view_type = getprop("/controls/seat/eject/view-type") or 0;

            # Translate integer states directly to raw view IDs
            var target_raw = 103; # Fallback default (First Person View)
            
            if (view_type == 1) {
                target_raw = 104; # External View
            } elsif (view_type == 2) {
                target_raw = 105; # External Cinematic View
            }
            
            print("SKS-94: Selected view_type " ~ view_type ~ ". Routing to raw ID: " ~ target_raw);
           
            var loop_limit = 30;
            var current_loop_raw = getprop("/sim/current-view/view-number-raw");
            while (current_loop_raw != target_raw and loop_limit > 0) {
                view.stepView(1);
                var next_loop_raw = getprop("/sim/current-view/view-number-raw");
                if (next_loop_raw == current_loop_raw) { break; }
                current_loop_raw = next_loop_raw;
                loop_limit = loop_limit - 1;
            }

            # PHASE 4 CONFIGURATION: Construct the tracking loop structure
            var max_seconds = 30.0;
            var elapsed_seconds = 0.0;
            
            impact_timer = maketimer(0.1, func {
                elapsed_seconds = elapsed_seconds + 0.1;
                var agl_ft = getprop("/position/altitude-agl-ft");
                var sim_crashed_node = getprop("/sim/crashed");

                # Continuously enforce stick lock metrics to block user joystick inputs
                setprop("/controls/flight/elevator", static_pitch_pull);
                setprop("/controls/flight/aileron", static_roll_snap);
                setprop("/controls/flight/rudder", static_rudder_kick);
                setprop("/controls/engines/engine/throttle", 0.0);

                setprop("/autopilot/locks/heading", "");
                setprop("/autopilot/locks/altitude", "");
                
                if (agl_ft == nil) { agl_ft = 9999.0; }
                if (sim_crashed_node == nil) { sim_crashed_node = 0; }
                
                tumble_elevator = 0.20 + rand() * 0.15;
                tumble_aileron = -0.25 - rand() * 0.20;
                tumble_rudder = 0.10 + rand() * 0.15;
                
                if (agl_ft <= 3.0 or sim_crashed_node or elapsed_seconds >= max_seconds) {
                    print("SKS-94: Impact registered. Invoking crash flag mechanics.");
                    # RELEASE FLIGHT CONTROL LINES BACK TO NEUTRAL
                    setprop("/controls/flight/elevator", 0.0);
                    setprop("/controls/flight/aileron", 0.0);
                    setprop("/controls/flight/rudder", 0.0);
                    setprop("sim/crashed", 1);
                    set_view_enabled(0, 1);
                    set_view_enabled(100, 1);
                    set_view_enabled(101, 1);
                    setprop("sim/view/enabled", 1);
                    if (impact_timer != nil) { impact_timer.stop(); }
                }
            });
            
            # OPTIMIZATION SAFETY DELAY:
            # Instead of executing impact_timer.start(); right away, wrap it inside a 
            # safe settlement timer so the aircraft tumbles and the canopy inflates 
            # uninterrupted for 2.6 seconds first.
            settimer(func {
                print("SKS-94: Parachute fully deployed. Engaging ground proximity scanning tracking matrix.");
                impact_timer.start();
            }, 3.8);

        }, 1.2); # Your accelerated view-switch timing delay window

    }
};

# =============================================================================
# Multiplayer Ejection Broadcast System
# =============================================================================

    var handle_ejection_broadcast = func(ac_lat, ac_lon) {
    # 1. Retrieve the pilot's multiplayer callsign from the property tree
    # If the user is flying offline, fall back to a default identifier
    var callsign = getprop("/sim/multiplay/callsign");
    if (callsign == nil or callsign == "") {
    callsign = "Pilot";
    }

    # 2. Construct the unified notification string using standard sprintf formatting
    var msg = sprintf("SOS! MAY DAY! - %s ejected! Send rescue chopper to: %.4f, %.4f", callsign, ac_lat, ac_lon);

    # 3. Write the message to the local screen log (the on-screen text lines)
    # globals.screen.log.write(msg, 1, 1, 0);
    print("SKS-94 MESSAGE: " ~msg);

    # 4. Broadcast the string to all players over the multiplayer network
    # Setting this property triggers FlightGear's core MP subsystem to send a chat packet
    setprop("/sim/multiplay/chat", msg);
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

    setprop("/controls/seat/eject/chute-norm", 0.0);
    setprop("/controls/seat/eject/chute-inflate-norm", 0.0);

    var view_type = getprop("/controls/seat/eject/view-type") or 0;
    setprop("/controls/seat/eject/view-type", view_type);
    setprop("/sim/gui/dialogs/config/eject-view-0", view_type == 0);
    setprop("/sim/gui/dialogs/config/eject-view-1", view_type == 1);
    setprop("/sim/gui/dialogs/config/eject-view-2", view_type == 2);
    
    ejection_triggered = 0;
    
    print("SKS-94 View Security System: Views clean-boot synchronization finalized.");
};

# Structural hook ensuring configuration runs only when properties fully load
setlistener("/sim/signals/fdm-initialized", func {
    init_views();
});
