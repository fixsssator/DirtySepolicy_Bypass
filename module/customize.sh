#!/sbin/sh
# DirtySepolicy Bypass — experimental BakaSU / Zygisk Next installer

SKIPUNZIP=0

# Do not assume Magisk environment variables exist: KernelSU/BakaSU-based
# managers may not export MAGISK_VER_CODE or ZYGISK_ENABLED.
if [ -n "${MAGISK_VER_CODE:-}" ] && [ "$MAGISK_VER_CODE" -lt 24000 ]; then
  ui_print "! Magisk 24.0+ required when installing under Magisk (you have ${MAGISK_VER:-unknown})"
  abort "! Aborting"
fi

if [ "${ZYGISK_ENABLED:-}" != "true" ] && [ "${ZYGISK_ENABLED:-}" != "1" ]; then
  if [ -f /data/adb/magisk.db ] && command -v magisk >/dev/null 2>&1; then
    z=$(magisk --sqlite "SELECT value FROM settings WHERE key='zygisk'" 2>/dev/null | sed 's/.*=//')
    if [ "$z" != "1" ]; then
      ui_print "! Zygisk does not appear to be enabled in Magisk."
      ui_print "! Enable Zygisk and flash again."
      abort "! Aborting"
    fi
  else
    ui_print "- Manager does not expose Magisk Zygisk flags; continuing with payload checks."
  fi
fi

ui_print "- Installing DirtySepolicy Bypass (experimental BakaSU/Zygisk Next build)"
ui_print "- ABI: ${ARCH:-unknown} (${IS64BIT:-unknown}-bit)"

case "${ARCH:-}" in
  arm64)   ABI_LIB=arm64-v8a ;;
  arm)     ABI_LIB=armeabi-v7a ;;
  x64)     ABI_LIB=x86_64 ;;
  x86)     ABI_LIB=x86 ;;
  *)       abort "! Unsupported or unknown ABI: ${ARCH:-unset}" ;;
esac

if [ ! -f "$MODPATH/zygisk/$ABI_LIB.so" ]; then
  ui_print "! Missing zygisk/$ABI_LIB.so in module zip"
  abort "! Aborting"
fi

ui_print "! EXPERIMENTAL: installer compatibility does not guarantee that Zygisk Next applies the module's PLT hooks."
ui_print "! If detections remain, collect logcat -s DirtySepBypass and do not assume the bypass is active."

set_perm_recursive "$MODPATH" 0 0 0755 0644
ui_print "- Reboot to activate."
