# # { pkgs ? import <nixpkgs> { }}:
# # with pkgs;
# # let
# #      # Lấy stdenv và lib trực tiếp từ pkgs
# # #   inherit (pkgs) stdenv lib;
# # #     fs = lib.fileset;
# # #     sourceFiles = fs.unions [
# # #     ./go.mod
# # #     ./main.go
# # #     ./sound
# # #   ];
# #     go_app = stdenv.mkDerivation {
# #         name = "something";
# #         src = ./.;
# #         nativeBuildInputs = [ pkg-config alsa-lib go gcc ];
# #         buildPhase = "export GOCACHE=$TMPDIR/go-cache
# #     export GOPATH=$TMPDIR/go
# #
# #     # Nếu bạn cần fetch module (và đã lo liệu vendor/network)
# #      export GO111MODULE=on
# #         ls && echo $(pwd) && go mod vendor && go build -mod=vendor -o main  ";
# #         installPhase = "
# #             mkdir -p $out/bin
# #             cp main $out/bin/
# #         ";
# #     };
# # in
# #     go_app
# #
# # # { pkgs ? import <nixpkgs> {} }:
# # #
# # # pkgs.stdenv.mkDerivation {
# # #   pname = "local-package";
# # #   version = "0.1";
# # #
# # #   # This copies the current directory to the store
# # #   src = ./.;
# # #
# # #   buildPhase = ''
# # #     echo "Building from $src"
# # #     gcc -O3 main.c -o my-program
# # #   '';
# # #
# # #   installPhase = ''
# # #     mkdir -p $out/bin
# # #     cp my-program $out/bin/
# # #   '';
# # # }
#
#
# { pkgs ? import <nixpkgs> { }}:
# with pkgs;
# let
#     lib = pkgs.lib;
#     fs = lib.fileset;
#     sourceFiles = ./.;
# in
#
#     fs.trace sourceFiles
#
#     stdenv.mkDerivation {
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
#     }
#


{ pkgs ? import <nixpkgs> { }}:
with pkgs;

let
  inherit (pkgs) lib;
  fs = lib.fileset;
  sourceFiles = ./.;

  go_app = buildGoModule {
    pname = "my-go-app";
    version = "1.0.0";
    src = fs.toSource {
      root = ./.;
      fileset = sourceFiles;
    };
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ alsa-lib ];
    # Path to the generated gomod2nix.toml
    vendorHash = "sha256-y9xXZz9MOmScCoYcBvDcid7n92+TwxYSvpM/a87yOGY=";
  };
  in
#   go_app
  dockerTools.buildImage {
  name = "my-go-app-docker";
  tag = "latest";

  # Các gói cần có trong runtime environment
  contents = [
    go_app
#     alsa-lib
    coreutils
    bashInteractive # Hữu ích để debug nếu cần
  ];

  config = {
    Cmd = [ "${go_app}/bin/d4" ];
    # ALSA thường yêu cầu truy cập vào /dev/snd,
    # hãy nhớ chạy container với flag --device /dev/snd
    Env = [ "LD_LIBRARY_PATH=${alsa-lib}/lib" ];
  };
  }




# stdenv.mkDerivation {
#   name = "fileset";
#   src = fs.toSource {
#     root = ./.;
#     fileset = sourceFiles;
#   };
#   nativeBuildInputs = [ pkg-config alsa-lib go gcc ];
#   buildPhase = ''
#     export GOCACHE=$TMPDIR/go-cache
#     export GOPATH=$TMPDIR/go
#
#      # Nếu bạn cần fetch module (và đã lo liệu vendor/network)
#     export GO111MODULE=on
#     ls && go mod tidy && go build -o main
#   '';
#   postInstall = ''
#     mkdir $out
#     cp -r . $out
#   '';
# }



