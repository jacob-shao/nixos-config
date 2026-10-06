# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  system.stateVersion = "26.05"; # dont change this

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  ###############
  #### SETUP ####
  ###############

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #using btrfs
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      # Import your home-manager configuration
      potato = import ../home-manager/home.nix;
    };
  };

  # locale
  time.timeZone = "Asia/Tokyo";
  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  users.users.potato = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  ##################
  #### HARDWARE ####
  ##################

  # nvidia/graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    nvidia.open = true;
    nvidia.modesetting.enable = true;
  };

  # audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  boot.kernelParams = [ "usbcore.autosuspend=-1" ]; #fix keyboard (light) not working
  ##################
  #### SOFTWARE ####
  ##################
  # general
  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # auto login into hyprland
  services.getty.autologinUser = "potato";
  environment.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      start-hyprland
    fi
  '';

  # wayland stuff ?
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # fix cursors on nvidia
    NIXOS_OZONE_WL = "1"; # for chromium/electron apps
  };

  # desktop environment
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # add maybe xdg-desktop-portal-hyprland

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };
  };

  # Japanese IME
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      settings.addons.classicui.globalSection.PreferTextIcon = "True"; # switches tray icon to text
    };
  };

  ##################
  #### PROGRAMS ####
  ##################
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    extest.enable = true; # steam controller mouse input fix
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  environment.systemPackages = with pkgs; [
    kdePackages.breeze-icons # fixes fcitx5 missing icons on system tray
    vscodium
    vim
    wget
    kitty
    git
    osu-lazer-bin
    stow
    pear-desktop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

}
