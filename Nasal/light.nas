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

var warn_pattern = [0.5, 0.5, 0.5, 1.2]; 
aircraft.light.new("/sim/model/lights/warn_blink", warn_pattern);

# =========================================================================
# FIXED YAK-152 BLOCK: Targeted Lights Property Interlock
# =========================================================================
# ... (keep all your existing light.nas code at the top)

var landing_lt = "/controls/lighting/landing-lights";
var taxi_lt    = "/controls/lighting/taxi-light"; 
var sw_pos     = "/controls/lighting/switch-position"; # New unified animation tracking path

setlistener(landing_lt, func(n) {
    var is_landing_on = n.getBoolValue();
    var is_taxi_on = getprop(taxi_lt) or 0;
    
    if (is_landing_on) {
        setprop(sw_pos, 2); # State 2 = Landing Light Position
    } elsif (!is_landing_on and !is_taxi_on) {
        setprop(sw_pos, 0); # State 0 = Completely Off Position
    }

    if (is_landing_on and is_taxi_on) {
        settimer(func { setprop(taxi_lt, 0); }, 0);
    }
}, 0, 0);

setlistener(taxi_lt, func(n) {
    var is_taxi_on = n.getBoolValue();
    var is_landing_on = getprop(landing_lt) or 0;
    
    if (is_taxi_on) {
        setprop(sw_pos, 1); # State 1 = Taxi Light Position
    } elsif (!is_landing_on and !is_taxi_on) {
        setprop(sw_pos, 0); # State 0 = Completely Off Position
    }

    if (is_taxi_on and is_landing_on) {
        settimer(func { setprop(landing_lt, 0); }, 0);
    }
}, 0, 0);

