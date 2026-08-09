# =============================================================================
# INTEGRATED YAK-152 MFI CONTROLLER (STABLE POWER FSM WITH BRIGHTNESS INJECT)
# =============================================================================

print("*** LOADING YAK-152 MFI.nas ... ***");

var mfi_boot_seconds = 3.0;
var mfi_shutdown_seconds = 0.5;
var boot_timer = nil;
var shutdown_timer = nil;
var boot_state = "off";

# Brightness / Fade Configurations (Smooth 20Hz refresh interval)
var fade_dt = 0.05;
var fade_loop_active = 0;
var TARGET_ON = 0.8;
var TARGET_STANDBY = 0.4;
var TARGET_OFF = 0.0;

# -----------------------------------------------------------------------------
# SYSTEM UTILITIES & POWER MANAGEMENT 
# -----------------------------------------------------------------------------

var mfi_generator_on = func() {
  var generator_switch = (getprop("/controls/electric/generator-switch") or 0) > 0;
  var engine_generator = (getprop("/controls/electric/engine/generator") or 0) > 0;
  return generator_switch or engine_generator;
};

var mfi_source_available = func(idx) {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine/running") or 0) > 0;

  return battery_on or (generator_on and engine_running);
};

var mfi_unit_available = func(idx) {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var mfi_output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine/running") or 0) > 0;

  if (idx == 2 or idx == 4) {
    return mfi_output_on and generator_on and engine_running;
  }

  return mfi_output_on and (battery_on or (generator_on and engine_running));
};

var mfi_get_node = func(idx) {
  var s_idx = int(idx); # Safe scalar string parsing reinforcement
  return props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ s_idx ~ "]", 1);
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

# -----------------------------------------------------------------------------
# INDEPENDENT TYPE-SAFE BRIGHTNESS PROCESSING ENGINE (FADE MECHANISM)
# -----------------------------------------------------------------------------

var mfi_brightness_updater = func {
  var shifts_pending = 0;

  for (var i = 1; i <= 4; i += 1) {
    var mfi_node = mfi_get_node(i);
    var page = mfi_node.getNode("page", 1).getValue() or 0;
    var cur_brightness = mfi_node.getNode("brightness-norm", 1).getValue() or 0.0;
    var target = TARGET_OFF;

    if (page == 0) {
      target = TARGET_OFF;
    } elsif (page == 8) {
      target = TARGET_STANDBY;
    } else {
      target = TARGET_ON;
    }

    if (cur_brightness < target) {
      cur_brightness += (1.0 / mfi_boot_seconds) * fade_dt;
      if (cur_brightness > target) { cur_brightness = target; }
      mfi_node.getNode("brightness-norm", 1).setValue(cur_brightness);
      shifts_pending = 1;
    } elsif (cur_brightness > target) {
      cur_brightness -= (1.0 / mfi_shutdown_seconds) * fade_dt;
      if (cur_brightness < target) { cur_brightness = target; }
      mfi_node.getNode("brightness-norm", 1).setValue(cur_brightness);
      shifts_pending = 1;
    }
  }

  if (shifts_pending) {
    settimer(mfi_brightness_updater, fade_dt);
  } else {
    fade_loop_active = 0;
  }
};

var mfi_refresh_brightness = func {
  if (!fade_loop_active) {
    fade_loop_active = 1;
    mfi_brightness_updater();
  }
};

# -----------------------------------------------------------------------------
# CONTEXT-AWARE SOFTKEYS LOGIC (WITH AUTOMATIC TIMED RELEASE)
# -----------------------------------------------------------------------------

var mfi_button_pressed = func(idx, btn_id) {
  var mfi_node = mfi_get_node(idx);
  
  # 1. Instantly depress the physical 3D button
  mfi_node.getNode("btn[" ~ btn_id ~ "]", 1).setBoolValue(1);

  # 2. Schedule an automatic release independent of any mouse interactions
  # 0.12 seconds creates a clean, responsive physical animation loop
  settimer(func {
    mfi_node.getNode("btn[" ~ btn_id ~ "]", 1).setBoolValue(0);
  }, 0.12);

  var current_page = mfi_node.getNode("page", 1).getValue() or 0;
  var current_sub = mfi_node.getNode("subpage", 1).getValue() or 0;

  # If display is offline/booting, stop functionality but allow the click animation above
  if (current_page == 0 or current_page == 7 or current_page == 9) {
    return;
  }

  if (btn_id == 1) {
    mfi_node.getNode("page", 1).setValue(1);
    #mfi_node.getNode("subpage", 1).setValue(0);
    return;
  }
  if (btn_id == 2) {
    mfi_node.getNode("page", 1).setValue(2);
    #mfi_node.getNode("subpage", 1).setValue(0);
    return;
  }
  if (btn_id == 3) {
    mfi_node.getNode("page", 1).setValue(3);
    #mfi_node.getNode("subpage", 1).setValue(0);
    return;
  }
  if (btn_id == 4) {
    mfi_node.getNode("page", 1).setValue(4);
    #mfi_node.getNode("subpage", 1).setValue(0);
    return;
  }

  if (current_page == 2) {
    if (btn_id == 6) {
      if (current_sub == 1) {
        mfi_node.getNode("subpage", 1).setValue(2);
      } else {
        mfi_node.getNode("subpage", 1).setValue(1);
      }
      return;
    }
  }
};

# -----------------------------------------------------------------------------
# ORIGINAL STABLE FINITE STATE MACHINE (WITH SAFE MATH ENGINE ITERATORS)
# -----------------------------------------------------------------------------

var mfi_handle_power_change = func {
  var battery_on = (getprop("/controls/electric/battery-switch") or 0) > 0;
  var output_on = (getprop("/systems/electrical/outputs/mfi") or 0) > 0;
  var generator_on = mfi_generator_on();
  var engine_running = (getprop("/engines/engine/running") or 0) > 0;
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
    # Left Bus Unit scan (1 and 3) using arithmetic step counting
    for (var l_idx = 1; l_idx <= 3; l_idx += 2) {
      if (left_power_ok) {
        if (!props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ l_idx ~ "]/boot-complete", 1).getBoolValue()) {
          mfi_activate_unit(l_idx);
        }
      } else {
        mfi_show_standby(l_idx);
      }
    }

    # Right Bus Unit scan (2 and 4) using arithmetic step counting
    for (var r_idx = 2; r_idx <= 4; r_idx += 2) {
      if (right_power_ok) {
        if (!props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ r_idx ~ "]/boot-complete", 1).getBoolValue()) {
          mfi_activate_unit(r_idx);
        }
      } else {
        mfi_show_standby(r_idx);
      }
    }
    mfi_refresh_brightness();
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

  if (boot_timer != nil) { boot_timer.stop(); boot_timer = nil; }
  if (shutdown_timer != nil) { shutdown_timer.stop(); shutdown_timer = nil; }

  boot_state = "booting";

  for (var b_idx = 1; b_idx <= 4; b_idx += 1) {
    if (!mfi_source_available(b_idx)) {
      mfi_reset_unit(b_idx);
      continue;
    }
    mfi_set_state(b_idx, 7, 0, 1, 0, mfi_boot_seconds);
  }
  mfi_refresh_brightness();

  boot_timer = maketimer(mfi_boot_seconds, func {
    for (var bt_idx = 1; bt_idx <= 4; bt_idx += 1) {
      if (!mfi_unit_available(bt_idx)) {
        if (bt_idx == 2 or bt_idx == 4) {
          if (mfi_source_available(bt_idx)) {
            mfi_show_standby(bt_idx);
          } else {
            mfi_reset_unit(bt_idx);
          }
        } else {
          mfi_reset_unit(bt_idx);
        }
        continue;
      }
      mfi_activate_unit(bt_idx);
    }
    boot_state = "running";
    mfi_refresh_brightness();
    boot_timer.stop();
    boot_timer = nil;
  });
  boot_timer.start();
};

var mfi_start_shutdown = func {
  if (boot_state == "shutting_down" or boot_state == "off") {
    return;
  }

  if (boot_timer != nil) { boot_timer.stop(); boot_timer = nil; }
  if (shutdown_timer != nil) { shutdown_timer.stop(); shutdown_timer = nil; }

  boot_state = "shutting_down";

  for (var s_idx = 1; s_idx <= 4; s_idx += 1) {
    mfi_show_shutdown(s_idx);
  }
  mfi_refresh_brightness();

  shutdown_timer = maketimer(mfi_shutdown_seconds, func {
    for (var sd_idx = 1; sd_idx <= 4; sd_idx += 1) {
      mfi_set_state(sd_idx, 0, 0, 0, 0, 0);
    }
    boot_state = "off";
    mfi_refresh_brightness();
    shutdown_timer.stop();
    shutdown_timer = nil;
  });
  shutdown_timer.start();
};

var mfi_reset = func {
  if (boot_timer != nil) { boot_timer.stop(); boot_timer = nil; }
  if (shutdown_timer != nil) { shutdown_timer.stop(); shutdown_timer = nil; }

  boot_state = "off";

  for (var r_idx = 1; r_idx <= 4; r_idx += 1) {
    mfi_reset_unit(r_idx);
    props.globals.getNode("/controls/instrumentation/mfis/mfi[" ~ r_idx ~ "]/brightness-norm", 1).setValue(0.0);
  }
};

# -----------------------------------------------------------------------------
# LISTENERS
# -----------------------------------------------------------------------------

setlistener("/controls/electric/battery-switch", func(n) { mfi_handle_power_change(); }, 0, 0);
setlistener("/systems/electrical/outputs/mfi", func(n) { mfi_handle_power_change(); }, 0, 0);
setlistener("/controls/electric/engine/generator", func(n) { mfi_handle_power_change(); }, 0, 0);
setlistener("/controls/electric/generator-switch", func(n) { mfi_handle_power_change(); }, 0, 0);
setlistener("/engines/engine/running", func(n) { mfi_handle_power_change(); }, 0, 0);

settimer(func {
  mfi_reset();
  mfi_handle_power_change();
}, 0.5);
