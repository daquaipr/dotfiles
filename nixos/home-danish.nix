{ pkgs, inputs, ... }:

{

  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home = {
    username = "danish";
    homeDirectory = "/home/danish";
    packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.zellij
      pkgs.ghostty
      pkgs.waybar
      pkgs.mangohud
      pkgs.heroic
      pkgs.xwayland-satellite
    ];
  };

  services = {
    flatpak = {
      enable = true;
      remotes = [{
        name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }];
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
  };

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Danish";
          email = "193341369+daquaipr@users.noreply.github.com";
	};
      };
    }; 
  };

  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
