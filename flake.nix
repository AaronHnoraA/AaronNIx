{
  description = "AaronHC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
  };

	outputs = { self, nix-darwin, nixpkgs, ... }@inputs: {
    darwinConfigurations."AaronHC" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # 这里导入之前我们使用的 configuration.nix，
        # 这样旧的配置文件仍然能生效
        ./darwin-configuration.nix
      ];
    };
  };
}
