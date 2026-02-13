{ config, pkgs, lib, inputs, ... }:

{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "deck";
      desktopSession = "plasma";
    };
    
    devices.steamdeck = {
      enable = true;
      enableGyroDsuService = true;
      autoUpdate = false;
    };

    hardware.has.amd.gpu = true;

    decky-loader = {
      enable = true;
      user = "deck";
    };
  };

  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      Type = "oneshot";
      User = config.jovian.steam.user;
      ExecStart = "/bin/sh -c 'mkdir -p ~/.steam/steam && [! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      "quiet"
      "splash"
    ];
    
    plymouth.enable = true;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 1024 * 8; # 8 GB
  }];

  services.fstrim.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.etc."xdg/baloofilerc".text = ''
    [Basic Settings]
    Indexing-Enabled=false
  '';

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    btop
    protonup-qt

    papirus-icon-theme
    phinger-cursors

    kdePackages.kate
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.ark
    kdePackages.spectacle
    kdePackages.kcalc

    (catppuccin-kde.override {
      flavour = ["mocha"];
      accents = ["lavender"];
     })
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.hostName = "nixdeck";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [{ from = 27000; to = 27050; }];  # Steam
    allowedUDPPortRanges = [{ from = 27000; to = 27050; }];
  };

  time.timeZone = "America/Kentucky/Louisville";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.deck = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
  };

  programs.zsh.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
  };

  system.userActivationScripts.catppuccinFolders = ''
    ${pkgs.catppuccin-papirus-folders}/bin/papirus-folders -C cat-mocha-lavender --theme Papirus-Dark
  '';

  services = {
    flatpak.enable = true;
    udisks2.enable = true;
    blueman.enable = true;
   
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };

    syncthing = {
      enable = true;
      user = "deck";
      dataDir = "/home/deck";
      configDir = "/home/deck/.config/syncthing";
      openDefaultPorts = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 3";
    };
    flake = "/home/deck/nixos";
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.hack
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };

  system.stateVersion = "25.05";
}
