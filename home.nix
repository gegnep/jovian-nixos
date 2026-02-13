{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    (inputs.desktop-config + "/modules/home/programs/neovim.nix")
    (inputs.desktop-config + "/modules/home/shell")
  ];

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    stateVersion = "25.05";
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
  };

  catppuccin.alacritty.enable = true;
  catppuccin.kitty.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "pengeg";
      email = "noreply@pengeg.com";
    };
  };

  home.packages = with pkgs; [
    neofetch
    htop
    ripgrep
    jq
    eza
    alacritty
  ];

  xdg.desktopEntries.return-to-gaming = {
    name = "Return to Gaming Mode";
    exec = "return-to-gaming-mode";
    icon = "steam";
    terminal = false;
    categories = [ "System" ];
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.9;
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.9";
      font_size = 12;
    };
  };

  programs.home-manager.enable = true;
}
