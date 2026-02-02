
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (python312.withPackages(ps: with ps; [
      jupyter
      jupyterlab
      notebook
      ipython
      # 添加其他 Python 包
      numpy
      pandas
      matplotlib
      scipy
    ]))
  ];
}
