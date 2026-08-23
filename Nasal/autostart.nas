# Track the current state (0 = stopped, 1 = running/starting)
var is_running = 0;

# Define the sequence of property paths for your switches
var startup_switches = [
    "/controls/lighting/beacon",
    "/controls/electric/battery-switch",
    "/controls/electric/engine/generator",
    "/controls/switches/starterkey-insert",
    "/yak152/controls/fuelswchcover1",      
    "BOTH_TANKS",                         # Select both tanks simultaneously
    "/controls/engines/engine/fuel-pump",
    "/controls/anti-ice/pitot-heat",
    "/yak152/controls/enginebtncover1",
    "/controls/engines/engine/starter",
    "/controls/lighting/nav-lights",
    "/controls/lighting/strobe",
    "/controls/lighting/taxi-light"
];

# Define the reverse sequence to safely shut down the aircraft
var shutdown_switches = [
    "/controls/lighting/taxi-light",
    "/controls/lighting/strobe",
    "/controls/lighting/nav-lights",
    "/controls/anti-ice/pitot-heat",
    "/controls/switches/starterkey-insert",
    "/controls/electric/engine/generator",
    "/controls/engines/engine/fuel-pump",
    "BOTH_TANKS",                         # Deselect both tanks simultaneously
    "/controls/electric/battery-switch",
    "/controls/lighting/beacon"  
];

# Dictionary mapping the strings to short, clean names
var prop_aliases = {
    "/controls/switches/starterkey-insert" : "ESUD",
    "/controls/electric/battery-switch"    : "Battery Master",
    "/controls/electric/engine/generator"  : "Generator",
    "/controls/lighting/beacon"            : "Beacon Lights",
    "/controls/lighting/nav-lights"        : "Navigation Lights",
    "/controls/lighting/strobe"            : "Strobe Lights",
    "/controls/lighting/taxi-light"        : "Taxi Light",
    "/controls/engines/engine/fuel-pump"   : "Fuel Pump",
    "/controls/anti-ice/pitot-heat"        : "Pitot Heat",
    "/yak152/controls/fuelswchcover1"      : "Fuel Switch Cover",
    "BOTH_TANKS"                           : "Fuel Tanks (Both)",
    "/yak152/controls/enginebtncover1"     : "Engine Start Button Cover",
    "/controls/engines/engine/starter"     : "Engine Starter"
};

# Helper function to get the clean name, falling back to full path if missing
var get_clean_name = func(prop) {
    if (contains(prop_aliases, prop)) {
        return prop_aliases[prop];
    }
    return prop; 
};

var string_contains = func(str, substr) {
    var len = size(str);
    var sublen = size(substr);
    if (sublen == 0) return 1;
    if (sublen > len) return 0;
    for (var i = 0; i <= len - sublen; i += 1) {
        var found = 1;
        for (var j = 0; j < sublen; j += 1) {
            if (str[i + j] != substr[j]) {
                found = 0;
                break;
            }
        }
        if (found) return 1;
    }
    return 0;
};

# Startup loop function
var activate_next_switch = func(index) {
    if (!is_running) return; 
    
    if (index >= size(startup_switches)) {
        setprop("/controls/instrumentation/mfis/mfi[1]/page", 1);
        gui.popupTip("Autostart Sequence Complete!");
        return;
    }

    var current_prop = startup_switches[index];

    # CUSTOM LOGIC: Handle simultaneous dual tank activation
    if (current_prop == "BOTH_TANKS") {
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
    } elsif (string_contains(current_prop, "starterkey-insert")) {
        setprop("/controls/switches/starterkey-insert", 1);
        setprop("/controls/engines/engine/magnetos", 3);
    } else {
        setprop(current_prop, 1);
        if (string_contains(current_prop, "enginebtncover1")) {
            var swcover_prop = current_prop;
            setprop("/controls/instrumentation/mfis/mfi[1]/page", 3);
            settimer(func { setprop(swcover_prop, 0); }, 2.2);
        }
        if (string_contains(current_prop, "fuelswchcover1")) {
            var swcover_prop = current_prop;
            settimer(func { setprop(swcover_prop, 0); }, 2.2); 
        } 
        if (string_contains(current_prop, "engine/starter")) {
            var starter_prop = current_prop;
            settimer(func { setprop(starter_prop, 0); }, 1.5); 
        }
    }

    gui.popupTip("Activating: " ~ get_clean_name(current_prop));
    setprop("/sim/model/lights/warn_blink/enabled", 1);
    settimer(func { activate_next_switch(index + 1); }, 1.0);
};

# Shutdown loop function
var deactivate_next_switch = func(index) {
    if (is_running) return; 

    if (index >= size(shutdown_switches)) {
        gui.popupTip("Autostop Sequence Complete!");
        setprop("/sim/model/lights/warn_blink/enabled", 0);
        return;
    }

    var current_prop = shutdown_switches[index];
    
    # CUSTOM LOGIC: Handle simultaneous dual tank deactivation
    if (current_prop == "BOTH_TANKS") {
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/consumables/fuel/tank[1]/selected", 0);
    } elsif (string_contains(current_prop, "starterkey-insert")) {
        setprop("/controls/switches/starterkey-insert", 0);
        setprop("/controls/engines/engine/magnetos", 0);
    } else {
        setprop(current_prop, 0);
    }

    gui.popupTip("Deactivating: " ~ get_clean_name(current_prop));
    settimer(func { deactivate_next_switch(index + 1); }, 1.0);
};

# Main Toggle Function (Call this on key press / button click)
var toggle_aircraft_state = func {
    if (is_running == 0) {
        # STARTUP PATH
        is_running = 1;
        gui.popupTip("Initiating Autostart...");

        # radiocfg.COM_init();
        # radiocfg.ARC_init();
        # radiocfg.PRMG_init();
        # radiocfg.RSBN_init();
        #gui.popupTip("Radio: Channel Presets Loaded");

        controls.startEngine(0,0);

        setprop("/controls/engines/engine/throttle", 0.1);
        gui.popupTip("Throttle 10%");

        settimer(func { activate_next_switch(0); }, 0.5);
    } else {
        # SHUTDOWN PATH
        is_running = 0;
        gui.popupTip("Initiating Autostop...");

        #controls.startEngine(0,0);
        setprop("/controls/engines/engine/throttle", 0.0);
        gui.popupTip("Fuel Cut Off: Throttle 0%, Fuel Isolated");

        settimer(func { deactivate_next_switch(0); }, 0.5);

        settimer(func {
            setprop("/yak152/controls/fuelswchcover1", 1);
            gui.popupTip("Opening: Fuel Switch Cover");
        }, 7.0);

        # UPDATED CLOSING DELAY: 
        # Shaved 1.0s off this timer (up from 2.7 to 8.7) because the tanks now execute in a single second.
        settimer(func { 
            setprop("/yak152/controls/fuelswchcover1", 0);
            gui.popupTip("Closing: Fuel Switch Cover");
        }, 8.7);
    }
};
