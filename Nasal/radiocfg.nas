## Radio channels presets

print("*** LOADING YAK-152 RADIOCFG.nas ... ***");

var COMM_channel = 0;
var COMM_channel_1 = 0;
var COMM_channel_2 = 0;
var COMM_channel_3 = 0;
var COMM_channel_4 = 0;
var COMM_channel_5 = 0;
var COMM_channel_6 = 0;
var COMM_channel_7 = 0;
var COMM_channel_8 = 0;
var COMM_channel_9 = 0;

var ARC_channel = 0;
var ARC_channel_1 = 0;
var ARC_channel_2 = 0;
var ARC_channel_3 = 0;
var ARC_channel_4 = 0;
var ARC_channel_5 = 0;
var ARC_channel_6 = 0;
var ARC_channel_7 = 0;
var ARC_channel_8 = 0;
var ARC_channel_9 = 0;

var RSBN_channel = 0;
var RSBN_channel_1 = 0;
var RSBN_channel_2 = 0;
var RSBN_channel_3 = 0;
var RSBN_channel_4 = 0;
var RSBN_channel_5 = 0;
var RSBN_channel_6 = 0;
var RSBN_channel_7 = 0;
var RSBN_channel_8 = 0;
var RSBN_channel_9 = 0;

var PRMG_channel = 0;
var PRMG_channel_1 = 0;
var PRMG_channel_2 = 0;
var PRMG_channel_3 = 0;
var PRMG_channel_4 = 0;
var PRMG_channel_5 = 0;
var PRMG_channel_6 = 0;
var PRMG_channel_7 = 0;
var PRMG_channel_8 = 0;
var PRMG_channel_9 = 0;

var COMM_channel_handler = func{
  var COMM_channel = getprop("/yak152/instrumentation/COMM/channel");
  var COMM_channel_1 = getprop("/yak152/instrumentation/COMM/channel-1");
  var COMM_channel_2 = getprop("/yak152/instrumentation/COMM/channel-2");
  var COMM_channel_3 = getprop("/yak152/instrumentation/COMM/channel-3");
  var COMM_channel_4 = getprop("/yak152/instrumentation/COMM/channel-4");
  var COMM_channel_5 = getprop("/yak152/instrumentation/COMM/channel-5");
  var COMM_channel_6 = getprop("/yak152/instrumentation/COMM/channel-6");
  var COMM_channel_7 = getprop("/yak152/instrumentation/COMM/channel-7");
  var COMM_channel_8 = getprop("/yak152/instrumentation/COMM/channel-8");
  var COMM_channel_9 = getprop("/yak152/instrumentation/COMM/channel-9");

#For storing COM frequencies
  if (COMM_channel == 1) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_1); }
  if (COMM_channel == 2) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_2); }
  if (COMM_channel == 3) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_3); }
  if (COMM_channel == 4) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_4); }
  if (COMM_channel == 5) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_5); }
  if (COMM_channel == 6) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_6); }
  if (COMM_channel == 7) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_7); }
  if (COMM_channel == 8) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_8); }
  if (COMM_channel == 9) { setprop("/instrumentation/comm/frequencies/standby-mhz", COMM_channel_9); }
  if (COMM_channel == 10) { print("P :)"); }
}

var ARC_channel_handler = func{
  var ARC_channel = getprop("/yak152/instrumentation/ARC-15/channel");
  var ARC_channel_1 = getprop("/yak152/instrumentation/ARC-15/channel-1");
  var ARC_channel_2 = getprop("/yak152/instrumentation/ARC-15/channel-2");
  var ARC_channel_3 = getprop("/yak152/instrumentation/ARC-15/channel-3");
  var ARC_channel_4 = getprop("/yak152/instrumentation/ARC-15/channel-4");
  var ARC_channel_5 = getprop("/yak152/instrumentation/ARC-15/channel-5");
  var ARC_channel_6 = getprop("/yak152/instrumentation/ARC-15/channel-6");
  var ARC_channel_7 = getprop("/yak152/instrumentation/ARC-15/channel-7");
  var ARC_channel_8 = getprop("/yak152/instrumentation/ARC-15/channel-8");
  var ARC_channel_9 = getprop("/yak152/instrumentation/ARC-15/channel-9");

#For storing ADF frequencies

  if (ARC_channel == 1) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_1); }
  if (ARC_channel == 2) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_2); }
  if (ARC_channel == 3) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_3); }
  if (ARC_channel == 4) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_4); }
  if (ARC_channel == 5) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_5); }
  if (ARC_channel == 6) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_6); }
  if (ARC_channel == 7) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_7); }
  if (ARC_channel == 8) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_8); }
  if (ARC_channel == 9) { setprop("/instrumentation/adf/frequencies/standby-khz", ARC_channel_9); }
  if (ARC_channel == 10) { print("P :)"); }
}

var RSBN_channel_handler = func{
  var RSBN_channel = getprop("/yak152/instrumentation/RSBN/channel");
  var RSBN_channel_1 = getprop("/yak152/instrumentation/RSBN/channel-1");
  var RSBN_channel_2 = getprop("/yak152/instrumentation/RSBN/channel-2");
  var RSBN_channel_3 = getprop("/yak152/instrumentation/RSBN/channel-3");
  var RSBN_channel_4 = getprop("/yak152/instrumentation/RSBN/channel-4");
  var RSBN_channel_5 = getprop("/yak152/instrumentation/RSBN/channel-5");
  var RSBN_channel_6 = getprop("/yak152/instrumentation/RSBN/channel-6");
  var RSBN_channel_7 = getprop("/yak152/instrumentation/RSBN/channel-7");
  var RSBN_channel_8 = getprop("/yak152/instrumentation/RSBN/channel-8");
  var RSBN_channel_9 = getprop("/yak152/instrumentation/RSBN/channel-9");

#For storing NAV frequencies
  if (RSBN_channel == 1) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_1); }
  if (RSBN_channel == 2) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_2); }
  if (RSBN_channel == 3) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_3); }
  if (RSBN_channel == 4) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_4); }
  if (RSBN_channel == 5) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_5); }
  if (RSBN_channel == 6) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_6); }
  if (RSBN_channel == 7) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_7); }
  if (RSBN_channel == 8) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_8); }
  if (RSBN_channel == 9) { setprop("/instrumentation/nav/frequencies/standby-mhz", RSBN_channel_9); }
  if (RSBN_channel == 10) { print("P :)"); }
}

var PRMG_channel_handler = func{
  var PRMG_channel = getprop("/yak152/instrumentation/PRMG/channel");
  var PRMG_channel_1 = getprop("/yak152/instrumentation/PRMG/channel-1");
  var PRMG_channel_2 = getprop("/yak152/instrumentation/PRMG/channel-2");
  var PRMG_channel_3 = getprop("/yak152/instrumentation/PRMG/channel-3");
  var PRMG_channel_4 = getprop("/yak152/instrumentation/PRMG/channel-4");
  var PRMG_channel_5 = getprop("/yak152/instrumentation/PRMG/channel-5");
  var PRMG_channel_6 = getprop("/yak152/instrumentation/PRMG/channel-6");
  var PRMG_channel_7 = getprop("/yak152/instrumentation/PRMG/channel-7");
  var PRMG_channel_8 = getprop("/yak152/instrumentation/PRMG/channel-8");
  var PRMG_channel_9 = getprop("/yak152/instrumentation/PRMG/channel-9");

#For storing PRMG frequencies
  if (PRMG_channel == 0) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_0); }
  if (PRMG_channel == 1) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_1); }
  if (PRMG_channel == 2) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_2); }
  if (PRMG_channel == 3) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_3); }
  if (PRMG_channel == 4) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_4); }
  if (PRMG_channel == 5) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_5); }
  if (PRMG_channel == 6) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_6); }
  if (PRMG_channel == 7) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_7); }
  if (PRMG_channel == 8) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_8); }
  if (PRMG_channel == 9) { setprop("/instrumentation/nav[1]/frequencies/standby-mhz", PRMG_channel_9); }
  if (PRMG_channel == 10) { print("P :)"); }
}

var COM_init = func{
  setprop("/yak152/instrumentation/COMM/channel", 1);

  setlistener("/yak152/instrumentation/COMM/channel", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-1", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-2", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-3", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-4", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-5", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-6", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-7", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-8", COMM_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/COMM/channel-9", COMM_channel_handler,0,0 );
#  screen.log.write("COM set", 1, 0.6, 0.1);
setprop("/instrumentation/comm/frequencies/selected-mhz", getprop("/yak152/instrumentation/COMM/channel-1"));
setprop("/instrumentation/comm/frequencies/standby-mhz", getprop("/yak152/instrumentation/COMM/channel-1"));
}

var ARC_init = func{
  setprop("/yak152/instrumentation/ARC-15/channel", 1);

  setlistener("/yak152/instrumentation/ARC-15/channel", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-1", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-2", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-3", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-4", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-5", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-6", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-7", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-8", ARC_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/ARC-15/channel-9", ARC_channel_handler,0,0 );

  setprop("/instrumentation/adf/frequencies/selected-khz", getprop("/yak152/instrumentation/ARC-15/channel-1"));
  setprop("/instrumentation/adf/frequencies/standby-khz", getprop("/yak152/instrumentation/ARC-15/channel-1"));
}

var RSBN_init = func{
  setprop("/yak152/instrumentation/RSBN/channel", 1);

  setlistener("/yak152/instrumentation/RSBN/channel", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-1", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-2", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-3", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-4", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-5", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-6", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-7", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-8", RSBN_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/RSBN/channel-9", RSBN_channel_handler,0,0 );
  #  screen.log.write("RSBN set", 1, 0.6, 0.1);
  setprop("/instrumentation/nav/frequencies/selected-mhz", getprop("/yak152/instrumentation/RSBN/channel-1"));
  setprop("/instrumentation/nav/frequencies/standby-mhz", getprop("/yak152/instrumentation/RSBN/channel-1"));

}

var PRMG_init = func{
  setprop("/yak152/instrumentation/PRMG/channel", 1);

  setlistener("/yak152/instrumentation/PRMG/channel", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-1", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-2", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-3", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-4", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-5", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-6", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-7", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-8", PRMG_channel_handler,0,0 );
  setlistener("/yak152/instrumentation/PRMG/channel-9", PRMG_channel_handler,0,0 );

  setprop("/instrumentation/nav[1]/frequencies/selected-mhz", getprop("/yak152/instrumentation/PRMG/channel-1"));
  setprop("/instrumentation/nav[1]/frequencies/standby-mhz", getprop("/yak152/instrumentation/PRMG/channel-1"));
}

# Create a listener to watch the radio power bus from Electrical.nas
setlistener("/systems/electrical/outputs/comm", func(node) {
    var voltage = node.getValue();

    var in_range = getprop("/instrumentation/nav/in-range");
    var direct_to = getprop("/instrumentation/nav/heading-deg") or 0.0;
    var auto_course = getprop("/yak152/instrumentation/RMU/auto-course-on") or 0;
    
    # Standard VHF radios need at least ~18-22V to operate on a 24V system
    if (voltage == nil or voltage < 18.0) {
        # Tell FlightGear's core radio engine that the device is unserviceable
        setprop("/instrumentation/comm/serviceable", 0);
        setprop("/instrumentation/adf/serviceable", 0);
        setprop("/instrumentation/nav[0]/serviceable", 0);
        setprop("/instrumentation/nav[1]/serviceable", 0);
        
        # OPTIONAL: If you have a custom display flag for your cockpit model
        setprop("/yak152/instrumentation/RMU/display-active", 0);
    } else {
        # Restore full operation when battery/generator power is sufficient
        setprop("/instrumentation/comm/serviceable", 1);
        setprop("/instrumentation/adf/serviceable", 1);
        setprop("/instrumentation/nav[0]/serviceable", 1);
        setprop("/instrumentation/nav[1]/serviceable", 1);
        setprop("/yak152/instrumentation/RMU/display-active", 1);

        #interpolate("/instrumentation/nav/radials/selected-deg", direct_to, 0.5);
        if (in_range and auto_course) {
            interpolate("/instrumentation/nav/radials/selected-deg", direct_to, 0.5);
        }

    }
}, 1, 0); # Run once initially, do not log internal script modifications

var populate_yak152_all_channels = func {
    var lat = getprop("/position/latitude-deg");
    var lon = getprop("/position/longitude-deg");
    
    if (lat == nil or lon == nil) {
        print("Yak-152: Aircraft position unavailable.");
        return;
    }

    var my_pos = geo.Coord.new().set_latlon(lat, lon);
    var search_radius_nm = 500;

    # ==========================================
    # 1. SCAN AND ROUTE COM FREQUENCIES
    # ==========================================
    var comms = [];
    var airports = findAirportsWithinRange(lat, lon, search_radius_nm);

    foreach (var apt; airports) {
        var apt_pos = geo.Coord.new().set_latlon(apt.lat, apt.lon);
        var dist = my_pos.distance_to(apt_pos);
        
        # FIXED: Using the native .comms() method instead of .frequencies()
        var airport_comms = apt.comms();
        if (airport_comms != nil) {
            foreach (var c; airport_comms) {
                if (c.frequency != nil) {
                    append(comms, { distance: dist, freq: c.frequency });
                }
            }
        }
    }

    # ==========================================
    # 2. SCAN AND ROUTE NAV FREQUENCIES
    # ==========================================
    var navaids = findNavaidsWithinRange(lat, lon, search_radius_nm);
    var vors = [];
    var ilses = [];
    var ndbs = [];
    
    foreach (var nav; navaids) {
        var nav_pos = geo.Coord.new().set_latlon(nav.lat, nav.lon);
        var dist = my_pos.distance_to(nav_pos);
        var item = { distance: dist, freq: nav.frequency };
        
        if (nav.type == "VOR") {
            append(vors, item);
        } elsif (nav.type == "ILS") {
            append(ilses, item);
        } elsif (nav.type == "NDB") {
            append(ndbs, item);
        }
    }

    # ==========================================
    # 3. PROXIMITY COMPARATOR & SORTING
    # ==========================================
    var sort_by_distance = func(a, b) {
        return a.distance < b.distance ? -1 : (a.distance > b.distance ? 1 : 0);
    };

    var sorted_comms = sort(comms, sort_by_distance);
    var sorted_vors  = sort(vors, sort_by_distance);
    var sorted_ilses = sort(ilses, sort_by_distance);
    var sorted_ndbs  = sort(ndbs, sort_by_distance);

    # ==========================================
    # 4. WRITING DIRECTLY TO THE PROPERTY TREE
    # ==========================================
    var save_channels = func(array, base_path, is_ndb, is_comm) {
        for (var i = 0; i < 9; i += 1) {
            var channel_num = i + 1;
            var prop_path = base_path ~ "/channel-" ~ channel_num;
            
            if (i < size(array)) {
                var raw_freq = array[i].freq;
                var final_freq = 0.0;
                
                if (is_comm) {
                    # COMM data is already a float representation (e.g., 122.8)
                    final_freq = raw_freq; 
                } elsif (is_ndb) {
                    # Safely handle localized formats for kHz
                    final_freq = (raw_freq > 2000) ? (raw_freq / 100.0) : raw_freq;
                } else {
                    # VOR and ILS integers map down (e.g., 10910 -> 109.10)
                    final_freq = raw_freq / 100.0;
                }
                
                setprop(prop_path, final_freq);
            } else {
                # Safety net fallback to prevent unassigned channels
                setprop(prop_path, 0.0);
            }
        }
    };

    # Fire output data bindings
    save_channels(sorted_comms, "/yak152/instrumentation/COMM",   0, 1); # COM
    COM_init();
    save_channels(sorted_vors,  "/yak152/instrumentation/RSBN",   0, 0); # VOR
    RSBN_init();
    save_channels(sorted_ilses, "/yak152/instrumentation/PRMG",   0, 0); # ILS
    PRMG_init();
    save_channels(sorted_ndbs,  "/yak152/instrumentation/ARC-15", 1, 0); # NDB
    ARC_init();

    print("Yak-152: Communication & Navigation matrices refreshed successfully.");
};

# Execute the auto-mapping routine once

setlistener("/sim/signals/fdm-initialized", func {
    setprop("instrumentation/rmu/unit/selected", 0.0);
    populate_yak152_all_channels();
});
