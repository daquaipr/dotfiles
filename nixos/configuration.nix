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
    inputs.chaotic.nixosModules.default
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
      enable32Bit = true;
    };
    cpu.intel = {
      updateMicrocode = true;
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;
      modesetting = {
        enable = true;
      };
      prime = {
        intelBusId = "PCI:0:2:0";
	nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = true;
	  enableOffloadCmd = true;
        };
      };
      nvidiaSettings = false;
      powerManagement = {
        enable = true;
	finegrained = true;
      };
    };
  };

  services = {
    bcachefs = {
      autoScrub = {
        enable = true;
      };
    };
    tlp = {
      enable = true;
      pd = {
        enable = true;
	};
      settings = {
        TLP_PROFILE_DEFAULT = "SAV";
        TLP_PROFILE_AC = "PRF";
        TLP_PROFILE_BAT = "SAV";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
	CPU_ENERGY_PERF_POLICY_ON_AC= "performance";
	CPU_BOOST_ON_BAT= "0";
        CPU_BOOST_ON_SAV= "0";
	CPU_SCALING_GOVERNOR_ON_AC = "performance";
	CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
	CPU_HWP_DYN_BOOST_ON_BAT= "0";
        CPU_HWP_DYN_BOOST_ON_SAV= "0";	
	PLATFORM_PROFILE_ON_BAT = "low-power";
	PLATFORM_PROFILE_ON_AC= "performance";
	RUNTIME_PM_ON_AC= "auto";
	START_CHARGE_THRESH_BAT1 = "75";
	STOP_CHARGE_THRESH_BAT1 = "80";
	INTEL_GPU_POWER_PROFILE_ON_AC = "base";
	INTEL_GPU_POWER_PROFILE_ON_BAT = "power_saving";
	INTEL_GPU_POWER_PROFILE_ON_SAV = "power_saving";
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
    scx = {
      enable = true;
    };
  };

  systemd = {
    oomd = {
      enable = true;
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    gamescope = {
      enable = true;
    };
  };

  zramSwap = {
    enable = true;
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
  };

  users = {
    users = {
      danish = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.nushell;
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
    rtkit = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
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
