{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    plugins = with pkgs.vimPlugins; [
      luasnip
      comment-nvim
      gitsigns-nvim
      kanagawa-nvim
      marks-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-web-devicons
      oil-nvim
      plenary-nvim
      telescope-file-browser-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-ui-select-nvim
    ];
  };

  home.packages = with pkgs; [
    cargo
    clang-tools
    fd
    gcc
    lua-language-server
    nil
    pkg-config
    ripgrep
    rust-analyzer
    rustc
    tinymist
    typst
  ];

  xdg.configFile."nvim".source = ./cfg/nvim;
}
