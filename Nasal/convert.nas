# ************************************************
# **** Yak-152 Instrumentation Conversion      ****
# **** Optimized for Single-Engine Diesel Systems ****
# ************************************************

var convert = func {
  # 1. Gather Basic Avionics Environmental Data
  var oat   = getprop("/environment/temperature-degc") or 15.0;
  var ias   = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0.0;
  var ialt  = getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0.0;
  var aglft = getprop("/position/altitude-agl-ft") or 0.0;
  var inHg  = getprop("/instrumentation/altimeter/setting-inhg") or 29.92;
  var dmekn = getprop("/instrumentation/dme/indicated-distance-nm") or 0.0;
  var winskt= getprop("/environment/wind-speed-kt") or 0.0;

  # 2. Process Unit Conversions (Imperial to Metric)
  var iaskm   = ias * 1.852;
  var ialtm   = ialt * 0.3048;
  var aglm    = aglft * 0.3048;
  var mmHg    = inHg * 25.401069519;
  var dmekm   = dmekn * 1.852;
  var winsms  = winskt / 1.944;

  # 3. Autopilot Target Unit Conversions
  var apalttgtft = getprop("/autopilot/settings/target-altitude-ft");
  var apalttgtm  = (apalttgtft != nil) ? (apalttgtft * 0.3048) : 0.0;

  var apagltgtft = getprop("/autopilot/settings/target-agl-ft");
  var apagltgtm  = (apagltgtft != nil) ? (apagltgtft * 0.3048) : 0.0;

  # 4. Engine 0 Auxiliary Instrument Updates (Oil Temperature F to C conversion only)
  var otf0 = getprop("/engines/engine[0]/oil-temperature-degf");
  if (otf0 != nil) {
    setprop("/engines/engine[0]/oil-temperature-degc", (otf0 - 32.0) * 5.0 / 9.0);
  }

  # 5. Process Calculated EGT to Fahrenheit for Secondary Cockpit Indicators
  var native_egt = getprop("/engines/engine[0]/egt-degc") or oat;
  setprop("/engines/engine[0]/egt-degf-calc", (native_egt * 9.0 / 5.0) + 32.0);

  # 6. Push Converted Metric Values to Instrument Dashboard Channels
  setprop("/instrumentation/airspeed-indicator/indicated-speed-km", iaskm);
  setprop("/instrumentation/altimeter/indicated-altitude-m", ialtm);
  setprop("/position/altitude-agl-m", aglm);
  setprop("/instrumentation/altimeter/setting-mmhg", mmHg);
  setprop("/instrumentation/dme/indicated-distance-km", dmekm);
  setprop("/autopilot/settings/target-altitude-m", apalttgtm);
  setprop("/autopilot/settings/target-agl-m", apagltgtm);
  setprop("/environment/wind-speed-ms", winsms);

  # 7. Safe Simulation Amperage Generation Profile
  var rpm0 = getprop("/engines/engine[0]/rpm") or 0.0;
  setprop("/systems/electrical/amp", rpm0 / 100.0);
}

### Master Loop Processing Framework ###
# FIXED: Converted to use a single locked 10Hz master timer loop object to avoid CPU spikes
var convert_loop_timer = maketimer(0.1, func { convert(); });

setlistener("/sim/signals/fdm-initialized", func {
  # Kickstart the telemetry converter smoothly
  convert_loop_timer.start();
});