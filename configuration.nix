# MOTHERBOARD:  	Apple Motherboard Mac-6F01561E16C75D06
# MODEL:        	Apple MacBookPro9,2
# BIOS:         	Apple BIOS 226.0.0.0.0 04/16/2019
# CPU:          	Intel i5-3210M (4) @ 3.100GHz
# GPU:          	Intel 3rd Gen Core processor Graphics Controller
# RAM:          	RAM Module(s) 8GB SODIMM
# SATA:         	KINGSTON SKC400S37256G 256GB SSD
# NETWORK:      	Edimax EW-7811Un 802.11n Wireless Adapter [Realtek RTL8188CUS]
# BLUE-TOOTH:   	Apple Bluetooth USB Host Controller
#---------------------------------------------------------------------

{ config, desktop, pkgs, lib, username, ... }:

{

  #---------------------------------------------------------------------
  # Import snippet files
  #---------------------------------------------------------------------

  imports = [ # ##  ONLY UNCOMMENT THE ./hardware GPU YOU WANT  ###

    ./hardware/gpu/intel/intel-laptop/intel-acceleration.nix  # INTEL GPU with (Open-GL), tlp and auto-cpufreq
    # ./hardware/gpu/nvidia/nvidia-stable/nvidia-stable.nix     # NVIDIA stable for GT-710--
    ./hardware-configuration.nix
    #./hardware/gpu/nvidia/nvidia-opengl/nvidia-opengl.nix # NVIDIA with hardware acceleration (Open-GL) for GT-1030++
    ./nix
    ./packages
    ./programs
    ./services
    ./system

  ];

  #---------------------------------------------------------------------
  # Bootloader and System Settings
  #---------------------------------------------------------------------

  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #---------------------------------------------------------------------
  # Time Zone and Locale
  #---------------------------------------------------------------------

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # --------------------------------------------------------------------
  # Audio
  #---------------------------------------------------------------------

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  sound.enable = true;

  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  #---------------------------------------------------------------------
  # User Configuration
  #---------------------------------------------------------------------

  users.users.brianf = {
    homeMode = "0755";
    isNormalUser = true;
    description = "Brian Francisco";
    uid = 1000;
    extraGroups = [
      "adbusers"
      "audio"
      "corectrl"
      "disk"
      "input"
      "lp"
      "mongodb"
      "mysql"
      "network"
      "network"
      "networkmanager"
      "postgres"
      "power"
      "scanner"
      "sound"
      "systemd-journal"
      "users"
      "video"
      "wheel"
    ];
    packages = [ pkgs.home-manager ];
  };

  #---------------------------------------------------------------------  
  # Automatic system upgrades, automatically reboot after an upgrade if 
  # necessary
  #---------------------------------------------------------------------

  # system.autoUpgrade.allowReboot = true;  # Very annoying .
  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
  system.stateVersion = "23.05";
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

  #---------------------------------------------------------------------
  # Switch to most recent kernel available
  #---------------------------------------------------------------------

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
