{ config, pkgs, ... }:

{
  # Laptop { various} 
  # Intel hardware video acceleration and 
  # VAAPI/VDPAU compatibility, which are more 
  # relevant for Intel and AMD GPU's 

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # --------------------------------------------------------------------- 
  # Enable Intel GPU in NixOS 
  # ---------------------------------------------------------------------
  services.xserver = {
    videoDrivers = [ "intel" ]; # Enable Intel graphics driver
  };

  # Hardware video acceleration and compatibility for Intel GPUs 
  # ---------------------------------------------------------------------
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Power management 
  # --------------------------------------------------------------------- 
  powerManagement.enable = true;

  # CPU performance scaling 
  # ---------------------------------------------------------------------
  services.thermald.enable = true;

  # Configure auto-cpufreq 
  # Comment all this out if there's a conflict with tlp or use one or the  
  # other (auto CPU or tlp) 
  # ---------------------------------------------------------------------
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };

    # Enable tlp 
    # ---------------------------------------------------------------------
   # services.tlp = {
   #   enable = false;
   #   settings = {
      #  CPU_SCALING_GOVERNOR_ON_AC = "performance";
      #  CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      #  CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      #  CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      #  CPU_MIN_PERF_ON_AC = 0;
      #  CPU_MAX_PERF_ON_AC = 50;
      #  CPU_MIN_PERF_ON_BAT = 0;
      #  CPU_MAX_PERF_ON_BAT = 20;

        # This enables tlp and sets the minimum and maximum frequencies 
        # for the CPU based on whether it is plugged into power or not. It also  
        # changes the CPU scaling governor based on this.

     # };
   # };

    # Use this instead if laptop runs HOT under tlp 
    # Tell tlp to always run in battery mode 
    # ---------------------------------------------------------------------

    #services.tlp = { 
    #  enable = true; 
    #  settings = { 
    #    TLP_DEFAULT_MODE = "BAT"; 
    #    TLP_PERSISTENT_DEFAULT = 1; 
    #  }; 
    #}; 

    # power management is auto-cpufreq which aims to replace tlp.  
    # When using auto-cpufreq it is therefore recommended to disable tlp as  
    # these tools are conflicting with each other. However, NixOS does allow  
    # for using both at the same time, and you therefore run them in tandem at your own risk.

  };

}
