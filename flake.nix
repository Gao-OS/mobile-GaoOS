{
  description = "Mobile GaoOS — NixOS, on your phone";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Plain nixpkgs without overlays — matches what pkgs.nix provides.
      # shell.nix, doc/default.nix, and the NixOS module system each apply
      # overlays themselves, so we must NOT pre-apply them here.
      pkgsFor = system: import nixpkgs { inherit system; };

      # Reuse the existing release-tools evaluation chain
      releaseToolsFor = system:
        import ./lib/release-tools.nix { pkgs = pkgsFor system; };

      # Build a device+example configuration using existing evalWith
      mkSystem = { device, exampleConfig, system ? "aarch64-linux" }:
        let
          rt = releaseToolsFor system;
        in
        rt.evalWith {
          inherit device;
          modules = [ exampleConfig ];
        };
    in
    {
      # --- Overlays ---
      overlays.default = nixpkgs.lib.composeManyExtensions [
        (import ./overlay/overlay.nix)
        (import ./overlay/mruby-builder/overlay.nix)
      ];

      # --- NixOS Modules (for external flake consumers) ---
      nixosModules.default = {
        imports = import ./modules/module-list.nix;
      };

      # --- Dev Shells ---
      devShells = forAllSystems (system: {
        default = import ./shell.nix { pkgs = pkgsFor system; };
      });

      # --- Packages (overlay packages exposed per-system) ---
      packages = forAllSystems (system:
        let
          pkgs = (pkgsFor system).appendOverlays [
            (import ./overlay/overlay.nix)
            (import ./overlay/mruby-builder/overlay.nix)
          ];
        in
        {
          default = pkgs.mobile-gaoos.autoport;
          autoport = pkgs.mobile-gaoos.autoport;
          mkbootimg = pkgs.mkbootimg;
          dtbTool = pkgs.dtbTool;
          docs = import ./doc { pkgs = pkgsFor system; };
        }
      );

      # --- NixOS Configurations (device + example combos) ---
      nixosConfigurations = {
        # OnePlus 6
        oneplus-enchilada-hello =
          mkSystem { device = "oneplus-enchilada"; exampleConfig = import ./examples/hello/configuration.nix; };
        oneplus-enchilada-phosh =
          mkSystem { device = "oneplus-enchilada"; exampleConfig = import ./examples/phosh/configuration.nix; };
        oneplus-enchilada-plasma-mobile =
          mkSystem { device = "oneplus-enchilada"; exampleConfig = import ./examples/plasma-mobile/configuration.nix; };

        # PinePhone Pro
        pine64-pinephonepro-hello =
          mkSystem { device = "pine64-pinephonepro"; exampleConfig = import ./examples/hello/configuration.nix; };
        pine64-pinephonepro-phosh =
          mkSystem { device = "pine64-pinephonepro"; exampleConfig = import ./examples/phosh/configuration.nix; };
        pine64-pinephonepro-plasma-mobile =
          mkSystem { device = "pine64-pinephonepro"; exampleConfig = import ./examples/plasma-mobile/configuration.nix; };
        pine64-pinephonepro-installer =
          mkSystem { device = "pine64-pinephonepro"; exampleConfig = import ./examples/installer/configuration.nix; };
      };

      # --- Hydra Jobs (reuse existing release.nix directly) ---
      hydraJobs = import ./release.nix {
        pkgs = pkgsFor "x86_64-linux";
        systems = supportedSystems;
      };
    };
}
