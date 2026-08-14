# NPP Zvezda SKS-94 Sequential Extraction Script. Update 14.08.2026

# ==============================================================================
# NPP ZVEZDA SKS-94 SEQUENTIAL EXTRACTION SYSTEM & DYNAMIC TRACKER
# ==============================================================================
# Features:
# 1. Incorporates checkbox view selection logic (View 103 vs View 104)
# 2. Handles automated dynamic view authorization locks
# 3. Induces dampened aerodynamic chaotic tumbling behaviors on empty airframe
# 4. Regulates property-driven particle generation values to circumvent culling glitches
# Fixes:
# 1. Scope Correction: Placed submodel target resolver into root script scope.
# 2. View Synch Fix: Realigned both view properties to force C++ matrix snaps.
# 3. Memory Cleanup: Added explicit lockout_timer termination handles upon ground impact.
# 4. Sanitation Handle: Substituted raw boot timers with an FDM listener signal.
# ==============================================================================

var ejection_triggered = 0;
var impact_timer = nil;
var lockout_timer = nil; # Tracks frame-rate control overrides globally

# Scaled-down chaotic control surfaces states to reduce violent jerking
var tumble_elevator = 0.35;
var tumble_aileron = -0.45;
var tumble_rudder = 0.25;

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

# ==============================================================================
# DYNAMIC SUBMODEL TARGET RESOLUTION ENGINE
# ==============================================================================
# Moved to root scope so it initializes reliably and can be invoked globally.
var update_ejection_view_targets = func {
    var target_node_index = nil;
    var found_p1_index = nil;
    var found_p2_index = nil;
    
    # Scan the first nodes under /ai/models/ to locate spawning parachutists
    var models = props.globals.getNode("/ai/models").getChildren();
    foreach (var m; models) {
        var name_node = m.getNode("name");
        if (name_node != nil) {

            var name_val = name_node.getValue();
            var idx = m.getIndex();
            
            if (name_val == "Parachutist 2") {
                found_p2_index = idx;
                break; # Priority target found, terminate early
            } elsif (name_val == "Parachutist 1") {
                found_p1_index = idx;
            }
        }
    }
    
    # Evaluate priority fallback rules
    if (found_p2_index != nil) {
        target_node_index = found_p2_index;
        print("SKS-94 Tracker: Found Parachutist 2 at index " ~ target_node_index);
    } elsif (found_p1_index != nil) {
        target_node_index = found_p1_index;
        print("SKS-94 Tracker: Parachutist 2 missing. Tracking Parachutist 1 at index " ~ target_node_index);

    } else {
        print("SKS-94 Tracker Warning: No parachutist submodels identified in the property tree!");
        return; 
    }
    
    # Construct explicit indexed paths
    var base_path = "/ai/models/ballistic[" ~ target_node_index ~ "]/";
    var lat_path  = base_path ~ "position/latitude-deg";
    var lon_path  = base_path ~ "position/longitude-deg";
    var alt_path  = base_path ~ "position/altitude-ft";
    var hdg_path  = base_path ~ "orientation/hdg-deg";
    
    # Inject paths dynamically into target camera definitions
    var sim_views = props.globals.getNode("/sim").getChildren("view");
# Re-route specific node parameter names dynamically inside the Nasal loop
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

# ==============================================================================
# MAIN EJECTION SEQUENCE TIMELINES
# ==============================================================================
var trigger_sks94 = func {
    if (ejection_triggered) return;
    
    var pilot_ejected = getprop("/controls/seat/eject/ejected");
    if (!pilot_ejected) {
        ejection_triggered = 1;

        print("SKS-94 Eject! Eject! Eject!");

        # CRITICAL VIEW SPEED FIX: Execute camera switches first to eliminate lag
        set_view_enabled(102, 1);
        set_view_enabled(103, 1);
        set_view_enabled(104, 1);
        
        # Dual-property mutation forces FlightGear to snap perspective vectors immediately
        setprop("/sim/current-view/view-number", 102); 
        setprop("/sim/current-view/view-number-raw", 102); # Instant Tail View lock
        
        # De-authorize standard cockpit views right behind it
        set_view_enabled(0, 0);   
        set_view_enabled(100, 0); 

        # Grab absolute geo-coordinates for rescue messages
        var ac_lat = getprop("/position/latitude-deg");
        var ac_lon = getprop("/position/longitude-deg");


        setprop("/controls/engines/engine/throttle", 0.0);
        setprop("/autopilot/locks/heading", "");
        setprop("/autopilot/locks/altitude", "");

        # FLIGHT CONTROLS LOCKOUT SYSTEMS (FOR TIED PROPERTIES)
        lockout_timer = maketimer(0.0, func {
            setprop("/controls/flight/elevator", tumble_elevator);
            setprop("/controls/flight/aileron", tumble_aileron);
            setprop("/controls/flight/rudder", tumble_rudder);
            setprop("/controls/engines/engine/throttle", 0.0);
        });
        lockout_timer.start();

        # Check co-pilot presence and trigger its unique submodel and particle properties
        var copilot_visible = getprop("/sim/multiplay/generic/bool");
        if (copilot_visible) {
            print("SKS-94: Instructor/Copilot detected. Launching rear seat first...");
            setprop("/controls/seat/eject/copilot-ejected", 1); 
            

            setprop("/controls/seat/eject/smoke-rate-rear", 1.0);
            settimer(func {
                print("SKS-94: Rear rocket engine burnout threshold reached.");
                setprop("/controls/seat/eject/smoke-rate-rear", 0.0);
            }, 0.85);
        } else {
            print("SKS-94: Solo flight configuration. Skipping rear cockpit submodel execution.");
        }
        
        setprop("/controls/seat/eject/ejected", 1); 
        interpolate("/controls/seat/eject/eject-norm", 1.0, 1);

        # PHASE 2 SEQUENCE: Fire the Front Pilot submodel and activate its smoke trail
        var delay = copilot_visible ? 0.6 : 0.0;
        settimer(func {
            print("SKS-94: Deploying front cockpit occupant clear space...");
            setprop("/controls/seat/eject/pilot-ejected", 1);
            
            setprop("/controls/seat/eject/smoke-rate-front", 1.0);

            settimer(func {
                print("SKS-94: Front rocket engine burnout threshold reached.");
                setprop("/controls/seat/eject/smoke-rate-front", 0.0);
            }, 0.85);
        }, delay);

        # PHASE 3 SEQUENCE: Evaluate dialog checkboxes, route views, and begin ground tracking
        settimer(func {
            print("SKS-94: Finalizing tracking trajectory path rules.");

            # Invoke target updater smoothly at runtime tracking initialization split point
            update_ejection_view_targets();

            globals.screen.log.write((sprintf("Ejected, send rescue chopper to: %.2f", ac_lat)) ~ (sprintf(" , %.2f", ac_lon)), 1, 1, 0);
            
            interpolate("/controls/seat/eject/chute-stream-norm", 1.0, 0.6);
            interpolate("/controls/seat/eject/chute-norm", 1.0, 2.5);
            
            settimer(func {

                print("SKS-94: Canopy lines taut. Inflating canopy volume panels...");
                interpolate("/controls/seat/eject/chute-inflate-norm", 1.0, 1.8);
            }, 0.5);
            
            setprop("sim/view/enabled", 0);
            
            var eject_pilot_view = getprop("/controls/seat/eject/pilot-view");
            if (eject_pilot_view) {
                print("SKS-94: Checkbox active. Routing to Close-Up Pilot View (103).");
                setprop("/sim/current-view/view-number", 103);
                setprop("/sim/current-view/view-number-raw", 103);
            } else {
                print("SKS-94: Checkbox inactive. Routing to Wide Cinematic View (104).");
                setprop("/sim/current-view/view-number", 104);
                setprop("/sim/current-view/view-number-raw", 104);
            }

            # PHASE 4 SEQUENCE: Ground radar tracking loop
            print("SKS-94: Initiating ground proximity tracking scanner loop.");

            var max_seconds = 30.0;
            var elapsed_seconds = 0.0;
            
            impact_timer = maketimer(0.1, func {
                elapsed_seconds = elapsed_seconds + 0.1;
                var agl_ft = getprop("/position/altitude-agl-ft");
                
                # Mutating global control surface bounds; lockout_timer reflects these instantly
                tumble_elevator = 0.20 + rand() * 0.15;
                tumble_aileron = -0.25 - rand() * 0.20;
                tumble_rudder = 0.10 + rand() * 0.15;
                
                if ((agl_ft != nil and agl_ft <= 3.0) or getprop("/sim/crashed") or elapsed_seconds >= max_seconds) {
                    print("SKS-94: Impact registered. Invoking crash flag mechanics.");
                    setprop("sim/crashed", 1);
                    set_view_enabled(0, 1);
                    set_view_enabled(100, 1);
                    
                    # CRITICAL FIX: Kill high-frequency frame loop timers to free CPU overhead 

                    # and unlock input bindings for clean flight reboots/resets.
                    if (lockout_timer != nil) { lockout_timer.stop(); }
                    if (impact_timer != nil) { impact_timer.stop(); }
                }
            });
            
            impact_timer.start();
        }, 2.5);
    }
};

# ==============================================================================
# INITIALIZATION SANITIZATION BINDINGS
# ==============================================================================
var init_views = func {
    set_view_enabled(102, 0);
    set_view_enabled(103, 0);
    set_view_enabled(104, 0);
    

    set_view_enabled(0, 1);
    set_view_enabled(100, 1);
    
    setprop("/controls/seat/eject/smoke-rate-front", 0.0);
    setprop("/controls/seat/eject/smoke-rate-rear", 0.0);
    setprop("/controls/seat/eject/ejected", 0);
    
    ejection_triggered = 0;
    print("SKS-94 View Security System: Views clean-boot synchronization finalized.");
};

# Standard secure handle ensuring the script won't run calculations before FDM properties instantiate
setlistener("/sim/signals/fdm-initialized", func {
    init_views();
    
    setlistener("/controls/seat/eject/trigger", func(n) {
        if (n.getBoolValue()) {
            trigger_sks94();
        }

    }, 0, 0);
});