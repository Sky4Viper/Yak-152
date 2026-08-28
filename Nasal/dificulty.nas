# difficulty.nas
###
# Global internal tracking factor variables
var difficulty_factor = 1.0; 

###
# Property Roots
var rm_root   = "/sim/maintenance";
var acname    = "Yak-152 Trainer"; 

var main_loop_interval = 1;  
var aux_loop_interval = 60;  

# Enforce absolute types to clear up property browser issues at early boot
props.globals.initNode(rm_root ~ "/enabled", 1, "BOOL");
props.globals.initNode(rm_root ~ "/airframe-seconds", 0.0, "DOUBLE");
props.globals.initNode(rm_root ~ "/airframe-hours", 0.0, "DOUBLE");
props.globals.initNode(rm_root ~ "/engine/operating-seconds", 0.0, "DOUBLE");
props.globals.initNode(rm_root ~ "/engine/operating-hours", 0.0, "DOUBLE");

print("Loading " ~ acname ~ " Master Nasal ...done");

# Dynamic multiplier calculator updating internal RAM state variables directly
var update_degradation_factor = func {
    var m_enabled = props.globals.getNode(rm_root ~ "/enabled", 1).getBoolValue();
    if (m_enabled) {
        difficulty_factor = 1.0; 
    } else {
        difficulty_factor = 0.0; 
    }
}

var init = func {
    print("Init " ~ acname ~ " Master Nasal ...starting");
    
    # Add the fields you want to monitor (MUST BE FIRST)
    var savedata = [
        "sim/maintenance/enabled",
        "sim/maintenance/airframe-seconds",
        "sim/maintenance/airframe-hours",
        "sim/maintenance/engine/operating-seconds",
        "sim/maintenance/engine/operating-hours",
        "instrumentation/nav/power-btn",
        "instrumentation/nav/audio-btn",
        "instrumentation/nav/frequencies/selected-mhz",
        "instrumentation/nav/frequencies/standby-mhz",
        "instrumentation/comm/volume",
        "instrumentation/comm/frequencies/selected-mhz",
        "instrumentation/comm/frequencies/standby-mhz"
    ];
    aircraft.data.add(savedata);

    # Load the values from disk (MUST BE SECOND)
    aircraft.data.load();
    
    update_degradation_factor();

    # Dynamic Switch Listener tracks boolean changes safely
    setlistener(rm_root ~ "/enabled", func {
        update_degradation_factor();
    }, 0, 0);

    # Start loop timers
    mainloop.start();
    auxloop.start();
    
    print("\nInitial Startup Maintenance Status:\n===================================\n" ~ maintenance.report());
    print("Init " ~ acname ~ " Master Nasal ...completed successfully!");
};

var loops = {
    main: func {
        maintenance.rm_loop(); 
    },
    aux: func {
        aircraft.data.save();
    }
};

var mainloop = maketimer(main_loop_interval, loops.main);
var auxloop = maketimer(aux_loop_interval, loops.aux);

setlistener("sim/signals/fdm-initialized", func {
    settimer(init, 2);
});
