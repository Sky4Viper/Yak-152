# MFI boot controller

print("*** LOADING YAK-152 MFI.nas ... ***");

var mfi_boot_seconds = 2.0;
var mfi_shutdown_seconds = 0.5;
var boot_timer = nil;
var shutdown_timer = nil;
var boot_state = "off";

var mfi_generator_on = func() {
  var generator_switch = (getprop("/controls/electric/generator-switch") or 0) > 0;
  var engine_generator = (getprop("/controls/electric/engine[0]/generator") or 0) > 0;
  return generator_switch or engine_generator;
};

var mfi_source_available = func(idx) {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine[0]/running") or 0) > 0;

  return battery_on or (generator_on and engine_running);
};

var mfi_unit_available = func(idx) {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var mfi_output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine[0]/running") or 0) > 0;

  if (idx == 2 or idx == 4) {
    return mfi_output_on and generator_on and engine_running;
  }

  return mfi_output_on and (battery_on or (generator_on and engine_running));
};

var mfi_get_node = func(idx) {
  return props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]", 1);
};

var mfi_set_state = func(idx, page, subpage, booting, boot_complete, countdown) {
  var mfi_node = mfi_get_node(idx);
  mfi_node.getNode("booting", 1).setBoolValue(booting);
  mfi_node.getNode("boot-countdown", 1).setValue(countdown);
  mfi_node.getNode("boot-complete", 1).setBoolValue(boot_complete);
  mfi_node.getNode("page", 1).setValue(page);
  mfi_node.getNode("subpage", 1).setValue(subpage);
};

var mfi_reset_unit = func(idx) {
  mfi_set_state(idx, 0, 0, 0, 0, 0);
};

var mfi_activate_unit = func(idx) {
  if (idx == 1) {
    mfi_set_state(idx, 1, 0, 0, 1, 0);
  } elsif (idx == 2) {
    mfi_set_state(idx, 2, 1, 0, 1, 0);
  } elsif (idx == 3) {
    mfi_set_state(idx, 3, 0, 0, 1, 0);
  } elsif (idx == 4) {
    mfi_set_state(idx, 4, 0, 0, 1, 0);
  }
};

var mfi_show_standby = func(idx) {
  mfi_set_state(idx, 8, 0, 0, 0, 0);
};

var mfi_show_shutdown = func(idx) {
  mfi_set_state(idx, 9, 0, 0, 0, 0);
};

var mfi_handle_power_change = func {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine[0]/running") or 0) > 0;
  var left_source_ok = battery_on or (generator_on and engine_running);
  var right_source_ok = generator_on and engine_running;
  var left_power_ok = output_on and left_source_ok;
  var right_power_ok = output_on and right_source_ok;

  if (!left_source_ok and !right_source_ok) {
    if (boot_state != "off") {
      mfi_start_shutdown();
    }
    return;
  }

  if (boot_state == "running") {
    foreach (var idx; [1, 3]) {
      if (left_power_ok) {
        if (!props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]/boot-complete", 1).getBoolValue()) {
          mfi_activate_unit(idx);
        }
      } else {
        mfi_show_standby(idx);
      }
    }

    foreach (var idx; [2, 4]) {
      if (right_power_ok) {
        if (!props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ idx ~ "]/boot-complete", 1).getBoolValue()) {
          mfi_activate_unit(idx);
        }
      } else {
        mfi_show_standby(idx);
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
    if (!mfi_source_available(idx)) {
      mfi_reset_unit(idx);
      continue;
    }

    mfi_set_state(idx, 7, 0, 1, 0, mfi_boot_seconds);
  }

  boot_timer = maketimer(mfi_boot_seconds, func {
    foreach (var idx; [1, 2, 3, 4]) {
      if (!mfi_unit_available(idx)) {
        if (idx == 2 or idx == 4) {
          if (mfi_source_available(idx)) {
            mfi_show_standby(idx);
          } else {
            mfi_reset_unit(idx);
          }
        } else {
          mfi_reset_unit(idx);
        }
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
    mfi_show_shutdown(idx);
  }

  shutdown_timer = maketimer(mfi_shutdown_seconds, func {
    foreach (var idx; [1, 2, 3, 4]) {
      mfi_set_state(idx, 0, 0, 0, 0, 0);
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
    mfi_reset_unit(idx);
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

setlistener("/controls/electric/generator-switch", func(n) {
  mfi_handle_power_change();
}, 1, 0);

setlistener("/engines/engine[0]/running", func(n) {
  mfi_handle_power_change();
}, 1, 0);

mfi_reset();
