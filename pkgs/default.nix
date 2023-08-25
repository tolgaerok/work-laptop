{ ... }:

{
  #---------------------------------------------------------------------  
  # Import default.nix from folders below
  #---------------------------------------------------------------------

  imports = [

    #---------------------------------------------------------------------
    # Editor
    #---------------------------------------------------------------------

    ./database
    ./dsctool
    # ./vscodium

    #---------------------------------------------------------------------
    # Basic
    #---------------------------------------------------------------------

    ./archiver
    ./config-pkgs

    #---------------------------------------------------------------------
    # Multimedia
    #---------------------------------------------------------------------

    ./audio-video
    ./image
    ./multi-media

    #---------------------------------------------------------------------
    # Programming
    #---------------------------------------------------------------------
    
    ./custom-pkgs     # My personal system-wide pkgs
    ./devlopment
    
    #---------------------------------------------------------------------
    # Desktop@id:bungcip.better-toml
    #---------------------------------------------------------------------

    # ./iwd
    ./internet
    ./networking
    ./office
    ./screensaver

    #---------------------------------------------------------------------
    # System tools
    #---------------------------------------------------------------------

    ./misc
    ./tools
    ./utilities

    #---------------------------------------------------------------------
    # Enable flatpak
    #---------------------------------------------------------------------

    ./flatpak

  ];

}
