{
  ...
}:
{
  services.udev.extraHwdb = ''
    evdev:input:b*v05F3p00FF*
      KEYBOARD_KEY_90001=f14
      KEYBOARD_KEY_90002=f15
      KEYBOARD_KEY_90003=f16
  '';
}
