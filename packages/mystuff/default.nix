{ pkgs, ... }:
{
  # Miscellaneous:
  environment = {
    systemPackages = with pkgs; [

      firefox
      kate
      onlyoffice-bin
      libreoffice-fresh
      onedrive
      megasync
      wpsoffice
      thunderbird
      #gutenprint
      #gutenprintBin
      #foomatic-db-ppds
      #foomatic-db-ppds-withNonfreeDb
      #github-desktop
      rclone
      rclone-browser
      #cups-brother-hll3230cdw
      neofetch
      gparted
      isoimagewriter
      #bluemail
      vscodium

    ];
  };
}
