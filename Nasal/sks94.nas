# NPP Zvezda SKS-94 Sequential Extraction Script
# Incorporates checkbox view selection logic (View 103 vs View 104)
# Handles automated dynamic view authorization locks
# Induces dampened aerodynamic chaotic tumbling behaviors on empty airframe
# Prevents multi-session persistence bugs by explicitly resetting view states

var ejection_triggered = 0;
var impact_timer = nil;

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
        
        # Correct path traversal for standard and custom FlightGear views
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

var trigger_sks94 = func {
    if (ejection_triggered) return;
    
    var pilot_ejected = getprop("/controls/seat/eject/ejected");
    if (!pilot_ejected) {
        ejection_triggered = 1;
        print("SKS-94 Eject! Eject! Eject!");

        # 1. Grab absolute geo-coordinates for rescue messages
        var ac_lat = getprop("/position/latitude-deg");
        var ac_lon = getprop("/position/longitude-deg");

        # 2. Emergency Safety Throttle Cut
        setprop("/controls/engines/engine/throttle", 0.0);
        setprop("/autopilot/locks/heading", "");
        setprop("/autopilot/locks/altitude", "");

        # FLIGHT CONTROLS LOCKOUT SYSTEMS (Recursion-safe dampened aerodynamic tumble injection)
        setlistener("/controls/flight/elevator", func(n) {
            if (n.getValue() != tumble_elevator) n.setValue(tumble_elevator);
        });
        setlistener("/controls/flight/aileron", func(n) {
            if (n.getValue() != tumble_aileron) n.setValue(tumble_aileron);
        });
        setlistener("/controls/flight/rudder", func(n) {
            if (n.getValue() != tumble_rudder) n.setValue(tumble_rudder);
        });
        setlistener("/controls/engines/engine/throttle", func(n) {
            if (n.getValue() != 0.0) n.setValue(0.0);
        });

        # Force initial entry moment to decay aerodynamic stability smoothly
        setprop("/controls/flight/elevator", tumble_elevator);
        setprop("/controls/flight/aileron", tumble_aileron);
        setprop("/controls/flight/rudder", tumble_rudder);

        # 3. Check co-pilot presence and trigger its unique submodel property if visible
        var copilot_visible = getprop("/sim/multiplay/generic/bool[0]");
        if (copilot_visible) {
            print("SKS-94: Instructor/Copilot detected. Launching rear seat first...");
            setprop("/controls/seat/eject/copilot-ejected", 1); 
        } else {
            print("SKS-94: Solo flight configuration. Skipping rear cockpit submodel execution.");
        }
        
        # Always set master state node to flag that sequence has initiated
        setprop("/controls/seat/eject/ejected", 1); 

        # VIEW MANAGEMENT LOCKOUT: Authorize extraction tracking cameras and lock internal cockpits
        set_view_enabled(102, 1);
        set_view_enabled(103, 1);
        set_view_enabled(104, 1);
        set_view_enabled(0, 0);   # De-authorize standard Front Cockpit View
        set_view_enabled(100, 0); # De-authorize Instructor Seat View

        # 4. PHASE 1 VIEW: Switch to over-the-shoulder aircraft tail view immediately
        setprop("/sim/current-view/view-number-raw", 102);
        
        # Smooth harness lines expansion simulation
        interpolate("/controls/seat/eject/eject-norm", 1.0, 1);

        # 5. PHASE 2 SEQUENCE: Fire the Front Pilot submodel (0.6s delay if crew is present, 0.0s if solo)
        var delay = copilot_visible ? 0.6 : 0.0;
        settimer(func {
            print("SKS-94: Deploying front cockpit occupant clear space...");
            setprop("/controls/seat/eject/pilot-ejected", 1);
        }, delay);

        # 6. PHASE 3 SEQUENCE: Evaluate dialog checkboxes, route views, and begin ground tracking
        settimer(func {
            print("SKS-94: Finalizing tracking trajectory path rules.");
            
            # Print extraction coordinate message to the user screen logs
            globals.screen.log.write((sprintf("Ejected, send rescue chopper to: %.2f", ac_lat)) ~ (sprintf(" , %.2f", ac_lon)), 1, 1, 0);
            interpolate("/controls/seat/eject/chute-norm", 1.0, 3);
            
            # Lock cockpit inputs so manual look controls don't mess up the tracking tracking axis
            setprop("sim/view/enabled", 0);
            
            # CHECKBOX EVALUATION LOGIC: Route to close-up or fly-along track
            var eject_pilot_view = getprop("/controls/seat/eject/pilot-view");
            if (eject_pilot_view) {
                print("SKS-94: Checkbox active. Routing to Close-Up Pilot View (103).");
                setprop("/sim/current-view/view-number-raw", 103);
            } else {
                print("SKS-94: Checkbox inactive. Routing to Wide Cinematic View (104).");
                setprop("/sim/current-view/view-number-raw", 104);
            }

            # PHASE 4 SEQUENCE: Ground radar tracking loop and dampened chaos tumble engine
            print("SKS-94: Initiating ground proximity tracking scanner loop.");
            var max_seconds = 30.0;
            var elapsed_seconds = 0.0;
            
            impact_timer = maketimer(0.1, func {
                elapsed_seconds = elapsed_seconds + 0.1;
                var agl_ft = getprop("/position/altitude-agl-ft");
                
                # Constrained random variances to establish a smoother buffeting/drifting descent
                tumble_elevator = 0.20 + rand() * 0.15;   # Gentle pitching nose-down buffeting
                tumble_aileron = -0.25 - rand() * 0.20;  # Smooth, consistent wing-drop roll rate
                tumble_rudder = 0.10 + rand() * 0.15;    # Balanced asymmetric yaw deviation
                
                # Kick property tree updates to force listeners to activate smoothly
                setprop("/controls/flight/elevator", tumble_elevator);
                setprop("/controls/flight/aileron", tumble_aileron);
                setprop("/controls/flight/rudder", tumble_rudder);
                
                # Check target criteria conditions: AGL threshold, native crash flag, or safety timeout
                if ((agl_ft != nil and agl_ft <= 3.0) or getprop("/sim/crashed") or elapsed_seconds >= max_seconds) {
                    print("SKS-94: Impact registered or tracker timeout boundary reached. Invoking crash flag mechanics.");
                    setprop("sim/crashed", 1);
                    
                    # SESSION SAFETY RESET: Unlock cockpit views immediately upon impact
                    set_view_enabled(0, 1);
                    set_view_enabled(100, 1);
                    
                    impact_timer.stop();
                }
            });
            
            impact_timer.start();
        }, 2.5);
    }
};

# STARTUP RUNTIME CONDITIONS: Strip tracking cameras and initialize base configurations cleanly
var init_views = func {
    set_view_enabled(102, 0);
    set_view_enabled(103, 0);
    set_view_enabled(104, 0);
    
    # Anti-persistence guard: Force-unlock cockpit structures on model boot
    set_view_enabled(0, 1);
    set_view_enabled(100, 1);
    
    print("SKS-94 View Security System: Views clean-boot synchronization finalized.");
};

settimer(init_views, 0.5);
