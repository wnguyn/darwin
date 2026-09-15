{
  pkgs,
  lib,
  username,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "darwin";
  time.timeZone = "America/Chicago";
  system.defaults = {
    NSGlobalDomain.NSWindowResizeTime = 0.001;
    CustomSystemPreferences."com.apple.Accessibility".ReduceMotionEnabled = 1;
  };
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    bat
    cargo
    feishin
    clang-tools
    cmake
    fd
    fish
    gleam
    erlang
    rebar3
    bun
    fzf
    gcc
    git
    git-credential-manager
    jq
    kitty
    lua-language-server
    nil
    nixd
    opencode
    pkg-config
    ripgrep
    rust-analyzer
    keepassxc
    rustc
    skhd
    tinymist
    typst
    wget
    zed-editor
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    iosevka-bin
    liberation_ttf
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  homebrew = {
    enable = false;
    onActivation = {
      autoUpdate = true;
      cleanup = "none";
      upgrade = true;
    };

    taps = [
      "can1357/tap"
      "nikitabobko/tap"
    ];

    brews = [
      "mas"
      "omp"
      "switchaudio-osx"

    ];

    casks = [
      "ghostty"
      "microsoft-teams"
      "aerospace"
      "cassette"
      "desktoppr"
      "helium-browser"
      "kde-connect"
      "jellyfin-media-player"
      "firefox"
      "cmux"
      "gimp"
      "kicad"
      # "okular" # installed manually; imperfect on macOS
      "kitty"
      "obsidian"
      "prismlauncher"
      "qbittorrent"
      "roblox"
      "raycast"
      "tailscale"
      "vesktop"
      "zed"
      "syncthing-app"
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./cfg/skhd/skhdrc;
  };

  environment.systemPath = lib.mkAfter [ "/Applications/AeroSpace.app/Contents/MacOS" ];

  system.activationScripts.aerospaceTCC.text = ''
        PROFILE="/Library/Managed Preferences/com.nikitabobko.AeroSpace.plist"
        if [ ! -f "$PROFILE" ]; then
          cat > "$PROFILE" << 'EOFMARKER'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>PayloadDescription</key>
    <string>Enables Accessibility access for AeroSpace window manager</string>
    <key>PayloadDisplayName</key>
    <string>AeroSpace Accessibility</string>
    <key>PayloadIdentifier</key>
    <string>com.nikitabobko.AeroSpace.accessibility</string>
    <key>PayloadRemovalDisallowed</key>
    <false/>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>AEROSPACE-0000-0000-0000-000000000001</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadContent</key>
    <array>
    <dict>
    <key>PayloadDescription</key>
    <string>Accessibility permission for AeroSpace</string>
    <key>PayloadDisplayName</key>
    <string>Accessibility</string>
    <key>PayloadIdentifier</key>
    <string>com.nikitabobko.AeroSpace.accessibility.payload</string>
    <key>PayloadType</key>
    <string>com.apple.TCC.configuration-profile-policy</string>
    <key>PayloadUUID</key>
    <string>AEROSPACE-0000-0000-0000-000000000002</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>Services</key>
    <dict>
    <key>Accessibility</key>
    <array>
    <dict>
    <key>Allowed</key>
    <true/>
    <key>CodeRequirement</key>
    <string>identifier "com.nikitabobko.AeroSpace" and anchor apple generic</string>
    <key>Identifier</key>
    <string>com.nikitabobko.AeroSpace</string>
    <key>IdentifierType</key>
    <string>bundleID</string>
    </dict>
    </array>
    </dict>
    </dict>
    </array>
    </dict>
    </plist>
    EOFMARKER
          /usr/bin/profiles -I -F "$PROFILE" 2>/dev/null || true
        fi
  '';

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 30;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
      tilesize = 36;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = username;
  system.stateVersion = 5;
}
