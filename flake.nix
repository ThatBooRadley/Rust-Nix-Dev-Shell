{
  description = "Rust dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  outputs = {
    nixpkgs,
    fenix,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    devShells."x86_64-linux".default = pkgs.mkShell {
      buildInputs = [
        (with fenix.packages."x86_64-linux";
          with stable;
            combine [
              rustc
              cargo
              llvm-tools-preview
              targets.x86_64-unknown-linux-gnu.stable.rust-std
              rust-analyzer
              clippy
            ])
        pkgs.clang
      ];

      #adds mold to the compile system
      RUSTFLAGS = "-Clink-arg=-fuse-ld=${pkgs.mold}/bin/mold";

      #sets clang as the linker (for mold)
      CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "clang";

      #puts .cargo/ folder in the directory above
      CARGO_HOME = "../.cargo/";
    };
  };
}
