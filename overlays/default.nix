{ inputs, ... }:
{
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Typst dev build (0.15-pre) — pinned to the commit otter-roam requires.
  # Remove once Typst 0.15 lands in nixpkgs-unstable.
  typst-dev = final: _prev:
    let
      src = final.fetchFromGitHub {
        owner = "typst";
        repo  = "typst";
        rev   = "64720d459129f4e5561c3bd0519bdfaef034b208";
        sha256 = "sha256-sGPlHS64zuKtMp5XqjLGUgDcnCe5sA1oMeNRLHLK0BE=";
      };
    in
    {
      typst = final.rustPlatform.buildRustPackage {
        pname   = "typst";
        version = "0.15-dev";
        inherit src;
        cargoLock = {
          lockFile = src + "/Cargo.lock";
          outputHashes = {
            "codex-0.2.0"           = "sha256-yPhL3yV9R9qUjJ3nqfUY99hoqwwGGdZ4HbpdcspXbrk=";
            "krilla-0.6.0"          = "sha256-DW0l6radzJ99JJPdE/O5RT747/BHH1bv94vtgBUO2N0=";
            "typst-assets-0.14.2"   = "sha256-rt/4/NAdfxfxMjzkAsDGCYofUz+dh92gOFdvHNcut8w=";
            "typst-dev-assets-0.14.2" = "sha256-2GGAoFVa87eO55MqahX+8Dg4hTwIqqIrnhZZcl9ACO4=";
          };
        };
        nativeBuildInputs = [ final.pkg-config ];
        buildInputs = [ final.openssl ]
          ++ final.lib.optionals final.stdenv.isDarwin [
            final.darwin.apple_sdk.frameworks.CoreServices
            final.darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
    };
}
