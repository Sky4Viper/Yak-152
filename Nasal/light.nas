var sbc1 = aircraft.light.new( "/sim/model/lights/sbc1", [0.5, 0.3] );
sbc1.interval = 0.1;
sbc1.switch( 1 );

var sbc2 = aircraft.light.new( "/sim/model/lights/sbc2", [0.2, 0.3], "/sim/model/lights/sbc1/state" );
sbc2.interval = 0;
sbc2.switch( 1 );

setlistener( "/sim/model/lights/sbc2/state", func(n) {
  var bsbc1 = sbc1.stateN.getValue();
  var bsbc2 = n.getBoolValue();
  var b = 0;
  if( bsbc1 and bsbc2 and getprop( "/controls/lighting/beacon") ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/beacon/enabled", b );

  if( bsbc1 and !bsbc2 and getprop( "/controls/lighting/strobe" ) ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "/sim/model/lights/strobe/enabled", b );
});

var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 0.05] );
beacon.interval = 0;

var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 0.05, 0.05, 1] );
strobe.interval = 0;

var warn_pattern = [0.25, 0.25]; 
aircraft.light.new("/sim/model/lights/warn_blink", warn_pattern);

# =========================================================================
# FIXED YAK-152 BLOCK: Targeted Lights Property Interlock
# =========================================================================
# ... (keep all your existing light.nas code at the top)

var nav_lt      = "/controls/lighting/nav-lights";
var strobe_lt   = "/controls/lighting/strobe";
var landing_lt  = "/controls/lighting/landing-lights";
var taxi_lt     = "/controls/lighting/taxi-light";
var sw_pos      = "/controls/lighting/switch-position";
var nav_sw_pos  = "/controls/lighting/nav-lights-sw";

# --- 1. NAV / STROBE SWITCH (3-Position: 0=Off, 1=Nav, 2=Both) ---

setlistener(nav_sw_pos, func(n) {
    var pos = n.getIntValue() or 0;
    
    # Directly set light states based on switch position
    var target_nav = (pos == 1 or pos == 2) ? 1 : 0;
    var target_strobe = (pos == 2) ? 1 : 0;
    
    if (getprop(nav_lt) != target_nav) setprop(nav_lt, target_nav);
    if (getprop(strobe_lt) != target_strobe) setprop(strobe_lt, target_strobe);
}, 1, 0); # Run-on-init ensures states sync at startup

# External overrides update the switch position safely without loops
setlistener(nav_lt, func(n) {
    if (!n.getBoolValue() and !getprop(strobe_lt)) {
        if (getprop(nav_sw_pos) != 0) setprop(nav_sw_pos, 0);
    } elsif (n.getBoolValue() and !getprop(strobe_lt)) {
        if (getprop(nav_sw_pos) != 1) setprop(nav_sw_pos, 1);
    }
}, 0, 0);

setlistener(strobe_lt, func(n) {
    if (n.getBoolValue()) {
        if (getprop(nav_sw_pos) != 2) setprop(nav_sw_pos, 2);
    } elsif (!n.getBoolValue() and !getprop(nav_lt)) {
        if (getprop(nav_sw_pos) != 0) setprop(nav_sw_pos, 0);
    }
}, 0, 0);

# --- 2. LANDING / TAXI SWITCH (3-Position: 0=Off, 1=Taxi, 2=Landing) ---

setlistener(sw_pos, func(n) {
    var pos = n.getIntValue() or 0;
    
    # Enforce mutual exclusivity instantly without timers
    var target_taxi = (pos == 1) ? 1 : 0;
    var target_landing = (pos == 2) ? 1 : 0;
    
    if (getprop(taxi_lt) != target_taxi) setprop(taxi_lt, target_taxi);
    if (getprop(landing_lt) != target_landing) setprop(landing_lt, target_landing);
}, 1, 0);

# External overrides update the switch position safely
setlistener(landing_lt, func(n) {
    if (n.getBoolValue() and getprop(sw_pos) != 2) setprop(sw_pos, 2);
    if (!n.getBoolValue() and !getprop(taxi_lt) and getprop(sw_pos) != 0) setprop(sw_pos, 0);
}, 0, 0);

setlistener(taxi_lt, func(n) {
    if (n.getBoolValue() and getprop(sw_pos) != 1) setprop(sw_pos, 1);
    if (!n.getBoolValue() and !getprop(landing_lt) and getprop(sw_pos) != 0) setprop(sw_pos, 0);
}, 0, 0);


