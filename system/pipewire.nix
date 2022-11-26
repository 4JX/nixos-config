{
  security.rtkit.enable = true;
  # TODO: Make pipewire not resample everything to 48Khz
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
}
