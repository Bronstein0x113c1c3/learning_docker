{ pkgs ? import <nixpkgs> { }}:
with pkgs;

let
    inherit (pkgs) lib;
    fs = lib.fileset;
    sourceFiles = ./.;
    rust_app = rustPlatform.buildRustPackage{
      name = "p";
      version = "1.0";
      src = fs.toSource {
        root = ./.;
        fileset = sourceFiles;
    };
      cargoHash = "sha256-EUwN7MI8Tbr1X2tdo+2Zkp/mT9Zs5EDqh93K9Bw0jbc=";
    };




#     go_app = stdenv.mkDerivation {
#         name = "something";
#         src = fs.toSource {
#         root = ./.;
#         fileset = sourceFiles;
#     };
#         nativeBuildInputs = [ pkg-config alsa-lib go gcc ];
#         unpackPhase = " ls  && go mod tidy && go build -o main ";
#         installPhase = "
#             mkdir -p $out/bin
#             cp hello $out/bin/
#         ";
#     };
in
#     rust_app

#     go_app
  dockerTools.buildImage {
  name = "my-rust-app-docker";
  tag = "latest";

  # Các gói cần có trong runtime environment
  contents = [
    rust_app
#     alsa-lib
    coreutils
    bashInteractive # Hữu ích để debug nếu cần
  ];

  config = {
    Cmd = [ "${rust_app}/bin/epoch_1" ];
    # ALSA thường yêu cầu truy cập vào /dev/snd,
    # hãy nhớ chạy container với flag --device /dev/snd
#     Env = [ "LD_LIBRARY_PATH=${alsa-lib}/lib" ];
  };
  }



