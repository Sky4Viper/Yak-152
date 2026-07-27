## Radio channels presets

print("*** LOADING RADIOCFG.nas ... ***");

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
#1-Simferopol-UKFF-GND
  setprop("/yak152/instrumentation/COMM/channel-1", 119.000);
#2-Simferopol-UKFF-TWR
  setprop("/yak152/instrumentation/COMM/channel-2", 120.800);
#3-Simferopol-UKFF-ATIS
  setprop("/yak152/instrumentation/COMM/channel-3", 127.200);
#4-Simferopol-UKFF-RADAR1
  setprop("/yak152/instrumentation/COMM/channel-4", 119.300);
#5-Simferopol-UKFF-RADAR2
  setprop("/yak152/instrumentation/COMM/channel-5", 124.700);
#6-Rostov-na-Donu-URRR-TWR
  setprop("/yak152/instrumentation/COMM/channel-6", 119.700);
#7-Rostov-na-Donu-URRR-ATIS
  setprop("/yak152/instrumentation/COMM/channel-7", 121.700);
#8-Rostov-na-Donu-URRR-RADAR
  setprop("/yak152/instrumentation/COMM/channel-8", 121.200);
#9-Rostov-na-Donu-URRR-APP1
  setprop("/yak152/instrumentation/COMM/channel-9", 124.000);
#10-Rostov-na-Donu-URRR-APP2
  #setprop("/yak152/instrumentation/COMM/channel-10", 127.100);
#11-Rostov-na-Donu-URRR-APP3
  #setprop("/yak152/instrumentation/COMM/channel-11", 128.200);
#12-Kerch-URFK-TWR
  #setprop("/yak152/instrumentation/COMM/channel-12", 128.000);
#13-Odessa-UKOO-GND
  #setprop("/yak152/instrumentation/COMM/channel-13", 121.800);
#14-Odessa-UKOO-TWR
  #setprop("/yak152/instrumentation/COMM/channel-14", 125.500);
#15-Odessa-UKOO-ATIS
  #setprop("/yak152/instrumentation/COMM/channel-15", 124.800);
#16-Odessa-UKOO-RADAR1
  #setprop("/yak152/instrumentation/COMM/channel-16", 120.900);
#17-Odessa-UKOO-RADAR2
  #setprop("/yak152/instrumentation/COMM/channel-17", 127.700);
#18-Sochi-URSS-KRUG
  #setprop("/yak152/instrumentation/COMM/channel-18", 119.700);
#19-Sochi-URSS-TWR2
  #setprop("/yak152/instrumentation/COMM/channel-19", 118.300);
#20-Sochi-URSS-APP
  #setprop("/yak152/instrumentation/COMM/channel-20", 124.600);

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
setprop("/instrumentation/comm/frequencies/standby-mhz", getprop("/yak152/instrumentation/COMM/channel-1"));
}

var ARC_init = func{
  setprop("/yak152/instrumentation/ARC-15/channel", 1);
  setprop("/yak152/instrumentation/ARC-15/channel-1", 588.0);
  setprop("/yak152/instrumentation/ARC-15/channel-2", 285.0);
  setprop("/yak152/instrumentation/ARC-15/channel-3", 326.0);
  setprop("/yak152/instrumentation/ARC-15/channel-4", 395.0);
  setprop("/yak152/instrumentation/ARC-15/channel-5", 1175.0);
  setprop("/yak152/instrumentation/ARC-15/channel-6", 1175.0);
  setprop("/yak152/instrumentation/ARC-15/channel-7", 1175.0);
  setprop("/yak152/instrumentation/ARC-15/channel-8", 1175.0);
  setprop("/yak152/instrumentation/ARC-15/channel-9", 1175.0);

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

  setprop("/instrumentation/adf/frequencies/standby-khz", getprop("/yak152/instrumentation/ARC-15/channel-1"));
}

var RSBN_init = func{
  setprop("/yak152/instrumentation/RSBN/channel", 1);
#1-Simferopol-UKFF
  setprop("/yak152/instrumentation/RSBN/channel-1", 116.600);
#2-Krasnodar-URKK
  setprop("/yak152/instrumentation/RSBN/channel-2", 115.800);
#3-Sochi-URSS
  setprop("/yak152/instrumentation/RSBN/channel-3", 112.700);
#4-Odessa-UKOO
  setprop("/yak152/instrumentation/RSBN/channel-4", 113.950);
#5-Rostov-URRR
  setprop("/yak152/instrumentation/RSBN/channel-5", 114.700);
#6-Aviano-ITA
  setprop("/yak152/instrumentation/RSBN/channel-6", 113.400);
#7-Praha-CZE
  setprop("/yak152/instrumentation/RSBN/channel-7", 112.600);
#8-Bratislava-SLO
  setprop("/yak152/instrumentation/RSBN/channel-8", 110.800);
#9-Bassel Al Assad-Syria
  setprop("/yak152/instrumentation/RSBN/channel-9", 114.800);
#10-Shannon-IRL
  #setprop("/yak152/instrumentation/RSBN/channel-10", 113.300);
#1-Simferopol-UKFF
  #setprop("/yak152/instrumentation/RSBN/channel-11", 116.600);
#2-Krasnodar-URKK
  #setprop("/yak152/instrumentation/RSBN/channel-12", 115.800);
#3-Sochi-URSS
  #setprop("/yak152/instrumentation/RSBN/channel-13", 112.700);
#4-Odessa-UKOO
  #setprop("/yak152/instrumentation/RSBN/channel-14", 113.950);
#5-Rostov-URRR
  #setprop("/yak152/instrumentation/RSBN/channel-15", 114.700);
#6-Aviano-ITA
  #setprop("/yak152/instrumentation/RSBN/channel-16", 113.400);
#7-Praha-CZE
  #setprop("/yak152/instrumentation/RSBN/channel-17", 112.600);
#8-Bratislava-SLO
  #setprop("/yak152/instrumentation/RSBN/channel-18", 110.800);
#9-Bassel Al Assad-Syria
  #setprop("/yak152/instrumentation/RSBN/channel-19", 114.800);
#10-Shannon-IRL
  #setprop("/yak152/instrumentation/RSBN/channel-20", 113.300);

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
setprop("/instrumentation/nav/frequencies/standby-mhz", getprop("/yak152/instrumentation/RSBN/channel-1"));
}

var PRMG_init = func{
  setprop("/yak152/instrumentation/PRMG/channel", 1);
  setprop("/yak152/instrumentation/PRMG/channel-1", 109.10); # 
  setprop("/yak152/instrumentation/PRMG/channel-2", 109.20); # 
  setprop("/yak152/instrumentation/PRMG/channel-3", 109.30); # 
  setprop("/yak152/instrumentation/PRMG/channel-4", 109.40); # 
  setprop("/yak152/instrumentation/PRMG/channel-5", 109.50); # 
  setprop("/yak152/instrumentation/PRMG/channel-6", 109.60); # 
  setprop("/yak152/instrumentation/PRMG/channel-7", 109.70); # 
  setprop("/yak152/instrumentation/PRMG/channel-8", 109.80); # 
  setprop("/yak152/instrumentation/PRMG/channel-9", 109.90); # 

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

  setprop("/instrumentation/nav[1]/frequencies/standby-mhz", getprop("/yak152/instrumentation/PRMG/channel-1"));
}

