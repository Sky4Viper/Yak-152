# MFI boot controller

print("*** LOADING YAK-152 MFI.nas ... ***");

var mfi_boot_seconds = 2.0;
var mfi_shutdown_seconds = 0.5;
var boot_timer = nil;
var shutdown_timer = nil;
var boot_state = "off";

var mfi_start_boot = func {
  if (boot_state == "booting" or boot_state == "running") {
    return;
  }

  if (boot_timer != nil) {
    boot_timer.stop();
    boot_timer = nil;
  }
  if (shutdown_timer != nil) {
    shutdown_timer.stop();
    shutdown_timer = nil;
  }

  boot_state = "booting";

  foreach (var idx; [1, 2, 3, 4]) {
    var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
    mfi_node.getNode("booting", 1).setBoolValue(1);
    mfi_node.getNode("boot-countdown", 1).setValue(mfi_boot_seconds);
    mfi_node.getNode("boot-complete", 1).setBoolValue(0);
    mfi_node.getNode("page", 1).setValue(0);
    mfi_node.getNode("subpage", 1).setValue(0);
  }

  boot_timer = maketimer(mfi_boot_seconds, func {
    foreach (var idx; [1, 2, 3, 4]) {
      var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
      mfi_node.getNode("booting", 1).setBoolValue(0);
      mfi_node.getNode("boot-countdown", 1).setValue(0);
      mfi_node.getNode("boot-complete", 1).setBoolValue(1);
      if (idx == 1) {
        mfi_node.getNode("page", 1).setValue(1);
        mfi_node.getNode("subpage", 1).setValue(0);
      } elsif (idx == 2) {
        mfi_node.getNode("page", 1).setValue(2);
        mfi_node.getNode("subpage", 1).setValue(1);
      } elsif (idx == 3) {
        mfi_node.getNode("page", 1).setValue(3);
        mfi_node.getNode("subpage", 1).setValue(0);
      } elsif (idx == 4) {
        mfi_node.getNode("page", 1).setValue(4);
        mfi_node.getNode("subpage", 1).setValue(0);
      }
    }
    boot_state = "running";
    boot_timer.stop();
    boot_timer = nil;
  });
  boot_timer.start();
};

var mfi_start_shutdown = func {
  if (boot_state == "shutting_down" or boot_state == "off") {
    return;
  }

  if (boot_timer != nil) {
    boot_timer.stop();
    boot_timer = nil;
  }
  if (shutdown_timer != nil) {
    shutdown_timer.stop();
    shutdown_timer = nil;
  }

  boot_state = "shutting_down";

  foreach (var idx; [1, 2, 3, 4]) {
    var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
    mfi_node.getNode("booting", 1).setBoolValue(0);
    mfi_node.getNode("boot-countdown", 1).setValue(0);
    mfi_node.getNode("boot-complete", 1).setBoolValue(0);
    mfi_node.getNode("page", 1).setValue(7);
    mfi_node.getNode("subpage", 1).setValue(0);
  }

  shutdown_timer = maketimer(mfi_shutdown_seconds, func {
    foreach (var idx; [1, 2, 3, 4]) {
      var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
      mfi_node.getNode("page", 1).setValue(0);
      mfi_node.getNode("subpage", 1).setValue(0);
    }
    boot_state = "off";
    shutdown_timer.stop();
    shutdown_timer = nil;
  });
  shutdown_timer.start();
};

var mfi_reset = func {
  if (boot_timer != nil) {
    boot_timer.stop();
    boot_timer = nil;
  }
  if (shutdown_timer != nil) {
    shutdown_timer.stop();
    shutdown_timer = nil;
  }

  boot_state = "off";

  foreach (var idx; [1, 2, 3, 4]) {
    var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
    mfi_node.getNode("booting", 1).setBoolValue(0);
    mfi_node.getNode("boot-countdown", 1).setValue(0);
    mfi_node.getNode("boot-complete", 1).setBoolValue(0);
    mfi_node.getNode("page", 1).setValue(0);
    mfi_node.getNode("subpage", 1).setValue(0);
  }
};

setlistener("/controls/electric/battery-switch", func(n) {
  if (n.getBoolValue()) {
    mfi_start_boot();
  } else {
    mfi_start_shutdown();
  }
}, 1, 0);

setlistener("/systems/electrical/outputs/mfi", func(n) {
  var output_on = (n.getValue() or 0) > 0;
  var battery_on = (getprop("/controls/electric/battery-switch") or 0);

  if (output_on and battery_on) {
    mfi_start_boot();
  } elsif (!output_on and boot_state == "running") {
    mfi_start_shutdown();
  }
}, 1, 0);

mfi_reset();
