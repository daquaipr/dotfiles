{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    hostPlatform = {
      system = "x86_64-linux";
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      http-connections = 128;
      use-xdg-base-directories = true;
    };
  };

  fileSystems."/".options = [
    "discard=true"
    "noatime"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = [ "bcachefs" ];
    kernelParams = [
      "i915.force_probe=!7d67"
      "xe.force_probe=7d67"
    ];
    kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 100;
    };
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
    };
    initrd = {
      systemd = {
        enable = true;
      };
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      kernelModules = [ "xe" ];
    };
  };

  hardware = {
    graphics = {
      enable = true;
    };
    cpu.intel = {
      updateMicrocode = true;
    };
    nvidia = {
      open = true;
      modesetting = {
        enable = true;
      };
      nvidiaSettings = false;
      powerManagement = {
        enable = true;
      };
    };
  };

  services = {
    bcachefs = {
      autoScrub = {
        enable = true;
      };
    };
    flatpak = {
      enable = true;
    };
    xserver = {
      videoDrivers = [
        "nvidia" 
      ];
    };
    resolved = {
      enable = true;
    };
    pipewire = {
      enable = true;
    };
    dbus = { 
      implementation = "broker";
    };
    timesyncd = { 
      enable = false;
    };
    ntpd-rs = { 
      enable = true;
    };
  };

  systemd = {
    oomd = {
      enable = true;
    };
    services = {
      nvidia-suspend = {
        enable = true;
      };
      nvidia-hibernate = {
        enable = true;
      };
      nvidia-resume = {
        enable = true;
      };
    };
  };

  programs = {
    niri = {
      enable = true;
    };
    uwsm = {
      enable = true;
    };
    nano = {
      enable = false;
    };
    git = {
      enable = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  networking = {
    hostName = "nixbox";
    useNetworkd = true;
    wireless = {
      iwd = {
        enable = true;
      };
    };
    nftables = {
      enable = true;
    };
  };

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font ];
  };

  users = {
    users = {
      danish = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.nushell;
        packages = with pkgs; [
          tree
        ];
      };
    };
  }; 

  security = {
    sudo = {
      enable = false;
    };
    sudo-rs = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    waybar
    xwayland-satellite
    brightnessctl
  ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
    ];
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
