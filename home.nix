{
  pkgs,
  lib,
  username,
  ...
}:

{

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.05";

  stylix.enable = true;
  stylix.base16Scheme = {
    scheme = "muted";
    base00 = "141312";
    base01 = "211f1e";
    base02 = "333130";
    base03 = "494746";
    base04 = "696765";
    base05 = "b3b1af";
    base06 = "ceccca";
    base07 = "e6e4e2";
    base08 = "78605c";
    base09 = "786c5c";
    base0A = "6c785c";
    base0B = "5c7860";
    base0C = "5c6e78";
    base0D = "5c6078";
    base0E = "6e5c78";
    base0F = "5c5c5c";
  };
  stylix.targets = {
    ghostty.enable = false;
    helix.enable = false;
    kitty.enable = false;
    bat.enable = true;
    fish.enable = true;
    fzf.enable = true;
    zellij.enable = true;
  };
  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/${username}/main.jpg"'
  '';

  home.packages = with pkgs; [
    fastfetch
    fd
    ripgrep
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "osxkeychain";
    };
  };

  programs.zellij = {
    enable = true;
    settings.default_layout = "compact";
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./cfg/kitty/theme.conf;
    keybindings = {
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";
    };
  };

  home.file.".aerospace.toml".source = ./cfg/aerospace/aerospace.toml;
  home.file.".config/skhd/skhdrc".source = ./cfg/skhd/skhdrc;

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "moonfly";
      keybind = [
        "alt+1=goto_tab:1"
        "alt+2=goto_tab:2"
        "alt+3=goto_tab:3"
        "alt+4=goto_tab:4"
        "alt+5=goto_tab:5"
        "alt+6=goto_tab:6"
        "alt+7=goto_tab:7"
        "alt+8=goto_tab:8"
        "alt+9=goto_tab:9"
      ];
    };
    themes.moonfly = {
      background = "#080808";
      foreground = "#bdbdbd";
      selection-background = "#b2ceee";
      selection-foreground = "#080808";
      cursor-color = "#9e9e9e";
      cursor-text = "#080808";
      palette = [
        "0=#323437"
        "1=#ff5454"
        "2=#8cc85f"
        "3=#e3c78a"
        "4=#80a0ff"
        "5=#cf87e8"
        "6=#79dac8"
        "7=#c6c6c6"
        "8=#949494"
        "9=#ff5189"
        "10=#36c692"
        "11=#c6c684"
        "12=#74b2ff"
        "13=#ae81ff"
        "14=#85dc85"
        "15=#e4e4e4"
      ];
    };
  };

  programs.helix = {
    enable = true;
#    package = pkgs.evil-helix;
    settings = {
      theme = "moonfly";
      editor.evil = true;
      keys.normal."$" = "goto_line_end";
    };
    themes.moonfly = ''
      "attribute" = "turquoise"
      "keyword" = "violet"
      "keyword.control.conditional" = "violet"
      "keyword.control.repeat" = "violet"
      "keyword.control.import" = "cranberry"
      "keyword.control.return" = "violet"
      "keyword.control.exception" = "crimson"
      "keyword.operator" = "cranberry"
      "keyword.directive" = "cranberry"
      "keyword.function" = "violet"
      "keyword.storage" = "violet"
      "keyword.storage.type" = "violet"
      "keyword.storage.modifier" = "violet"
      "type" = "emerald"
      "type.builtin" = "lime"
      "operator" = "cranberry"
      "namespace" = "turquoise"
      "function" = { fg = "sky", modifiers = ["bold"] }
      "function.builtin" = { fg = "green", modifiers = ["bold"] }
      "function.method" = { fg = "sky", modifiers = ["bold"] }
      "function.macro" = { fg = "green", modifiers = ["bold"] }
      "function.special" = { fg = "cranberry", modifiers = ["bold"] }
      "tag" = "lime"
      "markup.heading" = "blue"
      "markup.heading.marker" = "orange"
      "markup.list" = "blue"
      "markup.bold" = { fg = "yellow", modifiers = ["bold"] }
      "markup.italic" = { fg = "violet", modifiers = ["italic"] }
      "markup.url.link" = { fg = "purple", modifiers = ["underlined"] }
      "markup.url.text" = "white"
      "markup.quote" = "khaki"
      "comment" = "grey246"
      "comment.block.documentation" = "khaki"
      "constant" = "blue"
      "constant.builtin.boolean" = "coral"
      "constant.character" = "purple"
      "constant.character.escape" = "cranberry"
      "constant.numeric" = "orange"
      "constructor" = "sky"
      "variable.builtin" = "emerald"
      "variable.parameter" = "khaki"
      "variable.other.member" = "turquoise"
      "label" = "yellow"
      "punctuation" = "cranberry"
      "punctuation.delimiter" = "white"
      "punctuation.bracket" = "blue"
      "punctuation.special" = "cranberry"
      "string" = "khaki"
      "string.regexp" = "turquoise"
      "string.special" = "cranberry"

      "diff.plus" = "green"
      "diff.minus" = "red"
      "diff.delta" = "crimson"
      "diff.delta.moved" = "sky"

      "ui.background" = { bg = "black" }
      "ui.cursor" = { fg = "grey247", bg = "blue" }
      "ui.cursor.match" = { fg = "yellow" }
      "ui.linenr" = { fg = "grey247", bg = "black" }
      "ui.linenr.selected" = { bg = "grey234", fg = "blue" }
      "ui.statusline" = { bg = "grey236", fg = "white" }
      "ui.statusline.normal" = { bg = "blue", fg = "grey234" }
      "ui.statusline.inactive" = { bg = "grey236", fg = "grey247" }
      "ui.statusline.insert" = { bg = "emerald", fg = "grey234" }
      "ui.statusline.select" = { bg = "purple", fg = "grey234" }
      "ui.popup" = { fg = "grey246", bg = "grey237" }
      "ui.window" = { fg = "grey236", bg = "grey236" }
      "ui.help" = { fg = "grey247", bg = "grey237" }
      "ui.text" = { fg = "grey249" }
      "ui.text.focus" = { fg = "white", bg = "grey237" }
      "ui.text.info" = { fg = "white" }
      "ui.virtual.whitespace" = { fg = "grey237" }
      "ui.virtual.ruler" = { bg = "black" }
      "ui.menu" = { fg = "white", bg = "black" }
      "ui.menu.selected" = { bg = "blue", fg = "black" }
      "ui.selection" = { bg = "grey0" }
      "ui.cursorline" = { bg = "grey234" }
      "warning" = { fg = "orange" }
      "error" = { fg = "red", modifiers = ["bold"] }
      "info" = { fg = "sky", modifiers = ["bold"] }
      "hint" = { fg = "white", modifiers = ["italic"] }
      "diagnostic" = { fg = "red", modifiers = ["underlined"] }
      "diagnostic.error" = { fg = "red", modifiers = ["underlined"] }
      "diagnostic.warning" = { fg = "yellow", modifiers = ["underlined"] }
      "diagnostic.info" = { fg = "sky", modifiers = ["underlined"] }
      "diagnostic.hint" = { fg = "white", modifiers = ["underlined"] }

      [palette]
      black = '#080808'
      white = '#c6c6c6'
      grey0 = '#323437'
      grey254 = '#e4e4e4'
      grey249 = '#b2b2b2'
      grey247 = '#9e9e9e'
      grey246 = '#949494'
      grey244 = '#808080'
      grey241 = '#626262'
      grey238 = '#444444'
      grey237 = '#3a3a3a'
      grey236 = '#303030'
      grey235 = '#262626'
      grey234 = '#1c1c1c'
      grey233 = '#121212'
      khaki = '#c2c292'
      yellow = '#e3c78a'
      orange = '#de935f'
      coral = '#f09479'
      lime = '#85dc85'
      green = '#8cc85f'
      emerald = '#36c692'
      blue = '#80a0ff'
      sky = '#74b2ff'
      turquoise = '#79dac8'
      purple = '#ae81ff'
      cranberry = '#e2637f'
      violet = '#d183e8'
      crimson = '#ff5189'
      red = '#ff5454'
      spring = '#00875f'
    '';
  };

  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "type": "small" },
      "display": { "separator": "  " },
      "modules": ["title", "os", "host", "kernel", "uptime", "packages", "shell", "terminal", "cpu", "gpu", "memory"]
    }
  '';

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_add_path --move --prepend /run/current-system/sw/bin
      set -gx EDITOR hx
      set -gx VISUAL hx
    '';
    shellAliases = {
      v = "hx";
      lg = "lazygit";
      rebuild = "darwin-rebuild switch --flake /etc/nixos#darwin";
      nixclean = "nix-collect-garbage -d && nix store optimise";
    };
  };

  home.file.".config/skhd/README.md".text = ''
    skhd mirrors the old labwc workflow as closely as macOS allows.

    W/Super from labwc is mapped to cmd.
    Alt bindings are mapped to alt.
    App focus-or-open bindings use `open -a` because macOS owns app activation.
    Window tiling and movement are delegated to AeroSpace.
  '';
}
