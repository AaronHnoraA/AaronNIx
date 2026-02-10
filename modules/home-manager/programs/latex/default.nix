
{ pkgs, lib, ... }:

let
  mkWrapperFromDir = dir: name: pkgs.writeShellScriptBin name ''
    exec ${dir}/${name} "$@"
  '';

  mkMacTeX = name: mkWrapperFromDir "/Library/TeX/texbin" name;

  # Linux: 用 Nix 提供 texlive（包含 latex/kpsewhich/dvisvgm）
  texLinux = pkgs.texliveBasic.withPackages (ps: with ps; [
    dvisvgm
    dvipng
  ]);
in
{
  home.packages =
    # macOS: 生成 ~/.nix-profile/bin/latex 等，转发到 MacTeX
    lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      (mkMacTeX "latex")
      (mkMacTeX "kpsewhich")
      (mkMacTeX "dvisvgm")
      (mkMacTeX "pdflatex")
      (mkMacTeX "xelatex")
      (mkMacTeX "lualatex")
    ]
    # Linux: 直接装 texlive（不需要 wrapper）
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      texLinux
    ];
}
