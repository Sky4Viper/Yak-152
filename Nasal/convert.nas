# ************************************************
# **** Skydive                       07/2026  ****
# **** Based on Helijah and 5H1N0B1 work 2013 ****
# ************************************************

var convert = func {
  var rpm0  = getprop("/engines/engine[0]/rpm");
  var cht0  = getprop("/engines/engine[0]/cht-degc");
  var egt0  = getprop("/engines/engine[0]/egt-degc");
  var mp0   = getprop("/engines/engine[0]/mp-osi");
  var run0  = getprop("/engines/engine[0]/running");
  var flow0 = getprop("/engines/engine[0]/fuel-flow-gph");
  var otf0  = getprop("/engines/engine[0]/oil-temperature-degf");
  var cylt0 = 0.0;

  var rpm1  = getprop("/engines/engine[1]/rpm");
  var cht1  = getprop("/engines/engine[1]/cht-degc");
  var egt1  = getprop("/engines/engine[1]/egt-degc");
  var mp1   = getprop("/engines/engine[1]/mp-osi");
  var run1  = getprop("/engines/engine[1]/running");
  var flow1 = getprop("/engines/engine[1]/fuel-flow-gph");
  var otf1  = getprop("/engines/engine[1]/oil-temperature-degf");
  var cylt1 = 0.0;

  var oat   = getprop("/environment/temperature-degc");
  var ias   = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
  var iaskm   = ias *1.852;
  var inHg   = getprop("/instrumentation/altimeter/setting-inhg");
  var mmHg   = inHg *25.401069519;
  var dmekn = getprop("instrumentation/dme/indicated-distance-nm");
  var dmekm = dmekn *1.852;

  var apalttgtft = getprop("/autopilot/settings/target-altitude-ft");
  #if (thrust>0.6) {thrust=1;}
  if (apalttgtft != nil) {apalttgtm = apalttgtft * 0.3048;} else {apalttgtm = 0;}
  var apagltgtft = getprop("/autopilot/settings/target-agl-ft");
  if (apagltgtft != nil) {apagltgtm = apagltgtft * 0.3048;} else {apagltgtm = 0;}

  # ---------------------------------------- Engine 0 ----------------------------------------
  if ( !mp0 ) {
    mp0  = 10
  }
  if ( mp0 < 10 ) {
    mp0  = 10;
  }
  if ( !rpm0 ) {
    rpm0 = 0
  }
  if (rpm0 > 100.0) {
    var fuel_pres0 = rpm0 / 125;
    var oil_pres0  = rpm0 / 25;
    var cart0      = cht0 / 20;
  } else {
    var fuel_pres0 = 0.0;
    var oil_pres0  = 0.0;
    var cart0      = 0.0;
  }
  if (run0) {
    cht0           = cht0 + (mp0 * 8 + oat - ias/3 - cht0) / 250;
    egt0           = egt0 + ((mp0 * 30 + cht0 * 2) * mp0 / (flow0 * 2 + 1) - egt0) / 100;
    cylt0          = egt0 / 1.5;
  } else {
    if ( !cht0  ) {
      cht0         = oat;
    }
    if ( !egt0  ) {
      egt0         = oat;
    }
    cht0           = cht0 + (oat - cht0)/100;
    egt0           = egt0 + (oat - egt0)/100;
    cylt0          = egt0 / 1.5;
  }
  setprop("/engines/engine[0]/oil-temperature-degc", convertTemp(otf0));
  setprop("/engines/engine[0]/cht-degc", cht0);
  setprop("/engines/engine[0]/egt-degc", egt0);
  setprop("/engines/engine[0]/egt-degf-calc", egt0 * 9/5 + 32);
  setprop("/engines/engine[0]/oil-pressure-psi", oil_pres0);
  setprop("/engines/engine[0]/fuel-pressure-psi", fuel_pres0);
  setprop("/engines/engine[0]/cyl-temp", cylt0);
  setprop("/engines/engine[0]/carb-temp-degc", cart0);
  setprop("/instrumentation/airspeed-indicator/indicated-speed-km", iaskm);
  setprop("/instrumentation/altimeter/setting-mmhg", mmHg);
  setprop("/instrumentation/dme/indicated-distance-km", dmekm);
  setprop("/autopilot/settings/target-altitude-m", apalttgtm);
  setprop("/autopilot/settings/target-agl-m", apagltgtm);
  # ---------------------------------------- Engine 1 ----------------------------------------
  if ( !mp1 ) {
    mp1  = 10
  }
  if (mp1 < 10) {
    mp1  = 10;
  }
  if ( !rpm1 ) {
    rpm1 = 0
  }
  if (rpm1 > 100.0) {
    var fuel_pres1 = rpm1 / 125;
    var oil_pres1  = rpm1 / 25;
    var cart1      = cht1 / 20;
  } else {
    var fuel_pres1 = 0.0;
    var oil_pres1  = 0.0;
    var cart1      = 0.0;
  }
  if (run1) {
    cht1           = cht1 + (mp1 * 8 + oat - ias/3 - cht1) / 250;
    egt1           = egt1 + ((mp1 * 30 + cht1 * 2) * mp1 / (flow1 * 2 + 1) - egt1) / 100;
    cylt1          = egt1 / 1.5;
  } else {
    if ( !cht1  ) {
      cht1         = oat;
    }
    if ( !egt1  ) {
      egt1         = oat;
    }
    cht1           = cht1 + (oat - cht1)/100;
    egt1           = egt1 + (oat - egt1)/100;
    cylt1          = egt1 / 1.5;
  }
  setprop("/engines/engine[1]/oil-temperature-degc", convertTemp(otf1));
  setprop("/engines/engine[1]/cht-degc", cht1);
  setprop("/engines/engine[1]/egt-degc", egt1);
  setprop("/engines/engine[1]/egt-degf-calc", egt1 * 9/5 + 32);
  setprop("/engines/engine[1]/oil-pressure-psi", oil_pres1);
  setprop("/engines/engine[1]/fuel-pressure-psi", fuel_pres1);
  setprop("/engines/engine[1]/cyl-temp", cylt1);
  setprop("/engines/engine[1]/carb-temp-degc", cart1);
  # ------------------------------------------------------------------------------------------
  setprop("/systems/electrical/amp", (rpm0 + rpm1) / 100 );
}

var convertTemp = func(degF) {
  var degC = 0;
  if ( degF != nil ) {
    degC = (degF - 32) * 5/9;
  }
  return degC;
}

###  Main loop ###
var update_convert = func {
  convert();
  settimer(update_convert, 0.01);
}
setlistener("/sim/signals/fdm-initialized", update_convert);
