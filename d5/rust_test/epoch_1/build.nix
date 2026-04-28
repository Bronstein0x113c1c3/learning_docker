# # # { pkgs ? import <nixpkgs> { }}:
# # # with pkgs;
# # #
# # # let
# # #     inherit (pkgs) lib;
# # #     fs = lib.fileset;
# # #     sourceFiles = ./.;
# # #
# # #     rust_app = rustPlatform.buildRustPackage {
# # #       name = "p";
# # #       version = "1.0";
# # #       src = fs.toSource {
# # #         root = ./.;
# # #         fileset = sourceFiles;
# # #       };
# # #
# # #       cargoHash = "sha256-XPXxhCnIYT2Z1jJmdRlEKhpIRoRk6KAmnACiPsCPv68=";
# # #
# # #       # Di chuyển pkg-config vào đây
# # #       nativeBuildInputs = [ pkg-config ];
# # #
# # #       # alsa-lib là thư viện liên kết (link), giữ nguyên ở buildInputs
# # #       buildInputs = [ alsa-lib libpulseaudio ];
# # #     };
# # # in
# # # #   rust_app
# # #   dockerTools.buildImage {
# # #   name = "my-rust-app-docker";
# # #   tag = "latest";
# # #
# # #   # Các gói cần có trong runtime environment
# # #   contents = [
# # # #     pulseaudio
# # # #     alsa-utils
# # #     rust_app
# # #     alsa-lib
# # #     coreutils
# # #     bashInteractive # Hữu ích để debug nếu cần
# # #   ];
# # #
# # #   config = {
# # #     Cmd = [ "${rust_app}/bin/epoch_1" ];
# # #     # ALSA thường yêu cầu truy cập vào /dev/snd,
# # #     # hãy nhớ chạy container với flag --device /dev/snd
# # #     Env = [ "LD_LIBRARY_PATH=${alsa-lib}/lib" ];
# # #   };
# # #   }
# #
# #
# # { pkgs ? import <nixpkgs> { }}:
# # let
# #   inherit (pkgs) lib dockerTools rustPlatform;
# #
# #   rust_app = rustPlatform.buildRustPackage {
# #     name = "p";
# #     version = "1.0";
# #     src = lib.fileset.toSource {
# #       root = ./.;
# #       fileset = ./.;
# #     };
# #     cargoHash = "sha256-XPXxhCnIYT2Z1jJmdRlEKhpIRoRk6KAmnACiPsCPv68=";
# #
# #     nativeBuildInputs = [ pkgs.pkg-config ];
# #     buildInputs = [ pkgs.alsa-lib pkgs.libpulseaudio ];
# #   };
# #
# # in
# # dockerTools.buildImage {
# #   name = "my-rust-app-docker";
# #   tag = "latest";
# #
# #   contents = [
# #     rust_app
# #     pkgs.alsa-lib
# #     pkgs.libpulseaudio
# #     pkgs.coreutils
# #     pkgs.bashInteractive
# # #     pkgs.cacert # Cần thiết nếu app có gọi HTTPS
# #   ];
# #
# #   # Tạo cấu trúc file hệ thống cần thiết
# #   extraCommands = ''
# #     # Tạo thư mục tạm
# #     mkdir -p tmp
# #
# #     # Tạo file group để Docker nhận diện được group 'audio' (GID 29 là chuẩn chung)
# #     mkdir -p etc
# #     echo "root:x:0:" > etc/group
# #     echo "audio:x:17:" >> etc/group
# #
# #     # Copy cấu hình ALSA mặc định để thư viện không bị crash
# #     mkdir -p etc/alsa
# #     cp -r ${pkgs.alsa-lib}/share/alsa/* etc/alsa/
# #   '';
# #
# #   config = {
# #     Cmd = [ "${rust_app}/bin/epoch_1" ];
# #     Env = [
# #       # Chỉ định đường dẫn thư viện cho Runtime
# #       "LD_LIBRARY_PATH=${pkgs.alsa-lib}/lib:${pkgs.libpulseaudio}/lib"
# #       # Chỉ định nơi tìm config ALSA
# #       "ALSA_CONFIG_PATH=/etc/alsa/alsa.conf"
# #     ];
# #   };
# # }
# #
#
# { pkgs ? import <nixpkgs> { }}:
# let
#   inherit (pkgs) lib dockerTools rustPlatform;
#
#   rust_app = rustPlatform.buildRustPackage {
#     name = "p";
#     version = "1.0";
#     src = lib.fileset.toSource {
#       root = ./.;
#       fileset = ./.;
#     };
#     cargoHash = "sha256-XPXxhCnIYT2Z1jJmdRlEKhpIRoRk6KAmnACiPsCPv68=";
#     nativeBuildInputs = [ pkgs.pkg-config ];
#     buildInputs = [ pkgs.alsa-lib pkgs.libpulseaudio ];
#   };
#
# in
# dockerTools.buildImage {
#   name = "my-rust-app-docker";
#   tag = "latest";
#
#   contents = [
#     rust_app
#     pkgs.alsa-lib
#     pkgs.coreutils
#     pkgs.bashInteractive
#   ];
#
#   extraCommands = ''
#     mkdir -p etc
#     # Tạo group audio (kiểm tra lại GID máy host bằng lệnh: getent group audio)
#     echo "root:x:0:" > etc/group
#     echo "audio:x:17:" >> etc/group
#
#     # QUAN TRỌNG: Cấu hình ALSA để nhận diện thiết bị mặc định
#     cat > etc/asound.conf <<EOF
# pcm.!default {
#     type hw
#     card 0
# }
# ctl.!default {
#     type hw
#     card 0
# }
# EOF
#   '';
#
#   config = {
#     Cmd = [ "${rust_app}/bin/epoch_1" ];
#     Env = [
#       "LD_LIBRARY_PATH=${pkgs.alsa-lib}/lib"
#       # Chỉ định ALSA đọc file config chúng ta vừa tạo
#       "ALSA_CONFIG_PATH=/etc/asound.conf"
#     ];
#   };
# }
#
#
{ pkgs ? import <nixpkgs> { }}:
let
  inherit (pkgs) lib dockerTools rustPlatform;

  rust_app = rustPlatform.buildRustPackage {
    name = "p";
    version = "1.0";
    src = ./.;
    cargoHash = "sha256-XPXxhCnIYT2Z1jJmdRlEKhpIRoRk6KAmnACiPsCPv68=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.alsa-lib ];
  };

in
dockerTools.buildImage {
  name = "my-rust-app-docker";
  tag = "latest";
  contents = [
    rust_app
    pkgs.alsa-lib
    pkgs.coreutils
    pkgs.bashInteractive
    ];
  extraCommands = ''
    mkdir -p etc
    mkdir list_songs
    ls
    echo "root:x:0:" > etc/group
    echo "audio:x:17:" >> etc/group # Thay 29 bằng GID máy bạn
  '';
  config = {
    Cmd = [ "${rust_app}/bin/epoch_1" ];
    Env = [ "LD_LIBRARY_PATH=${pkgs.alsa-lib}/lib" ];
  };
}
