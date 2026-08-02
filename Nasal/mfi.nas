# MFI boot controller

print("*** LOADING YAK-152 MFI.nas ... ***");

var mfi_boot_seconds = 2.0;
var mfi_shutdown_seconds = 0.5;
var boot_timer = nil;
var shutdown_timer = nil;
var boot_state = "off";

var mfi_unit_available = func(idx) {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var mfi_output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;

  if (idx == 2 or idx == 4) {
    var generator_on = (getprop("/controls/electric/engine[0]/generator") or 0) > 0;
    var engine_running = (getprop("/engines/engine[0]/running") or 0) > 0;
    return battery_on and mfi_output_on and generator_on and engine_running;
  }

  return battery_on and mfi_output_on;
};

var mfi_reset_unit = func(idx) {
  var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
  mfi_node.getNode("booting", 1).setBoolValue(0);
  mfi_node.getNode("boot-countdown", 1).setValue(0);
  mfi_node.getNode("boot-complete", 1).setBoolValue(0);
  mfi_node.getNode("page", 1).setValue(0);
  mfi_node.getNode("subpage", 1).setValue(0);
};

var mfi_activate_unit = func(idx) {
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
};

var mfi_handle_power_change = func {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;
  var generator_on = (getprop("/controls/electric/engine[0]/generator") or 0) > 0;
  var engine_running = (getprop("/engines/engine[0]/running") or 0) > 0;
  var left_power_ok = battery_on and output_on;
  var right_power_ok = left_power_ok and generator_on and engine_running;

  if (!battery_on or !output_on) {
    if (boot_state != "off") {
      mfi_start_shutdown();
    }
    return;
  }

  if (!right_power_ok) {
    if (boot_state == "running") {
      foreach (var idx; [2, 4]) {
        var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
        mfi_node.getNode("booting", 1).setBoolValue(0);
        mfi_node.getNode("boot-countdown", 1).setValue(0);
        mfi_node.getNode("boot-complete", 1).setBoolValue(0);
        mfi_node.getNode("page", 1).setValue(8);
        mfi_node.getNode("subpage", 1).setValue(0);
      }
    }
  }

  if (boot_state == "running") {
    if (right_power_ok) {
      foreach (var idx; [2, 4]) {
        if (!props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]/boot-complete", 1).getBoolValue()) {
          mfi_activate_unit(idx);
        }
      }
    }
    return;
  }

  if (boot_state != "booting") {
    mfi_start_boot();
  }
};

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
    if (!mfi_unit_available(idx)) {
      mfi_reset_unit(idx);
      continue;
    }

    mfi_node.getNode("booting", 1).setBoolValue(1);
    mfi_node.getNode("boot-countdown", 1).setValue(mfi_boot_seconds);
    mfi_node.getNode("boot-complete", 1).setBoolValue(0);
    mfi_node.getNode("page", 1).setValue(0);
    mfi_node.getNode("subpage", 1).setValue(0);
  }

  boot_timer = maketimer(mfi_boot_seconds, func {
    foreach (var idx; [1, 2, 3, 4]) {
      var mfi_node = props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
      if (!mfi_unit_available(idx)) {
        mfi_reset_unit(idx);
        continue;
      }

      mfi_activate_unit(idx);
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
  mfi_handle_power_change();
}, 1, 0);

setlistener("/systems/electrical/outputs/mfi", func(n) {
  mfi_handle_power_change();
}, 1, 0);

setlistener("/controls/electric/engine[0]/generator", func(n) {
  mfi_handle_power_change();
}, 1, 0);

setlistener("/engines/engine[0]/running", func(n) {
  mfi_handle_power_change();
}, 1, 0);

mfi_reset();
