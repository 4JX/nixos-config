{ lib, pkgs, ... }:

let
  androidImages =
    versions:
    lib.flatten (
      lib.pipe versions [
        (builtins.map (v: builtins.toString v))
        (builtins.map (v: [
          "android-sdk-system-image-${v}-google_apis-arm64-v8a-system-image-${v}-google_apis-x86_64"
          "android-sdk-system-image-${v}-google_apis_playstore-arm64-v8a-system-image-${v}-google_apis_playstore-x86_64"
          "system-image-${v}-google_apis-x86_64"
          "system-image-${v}-google_apis-arm64-v8a"
          "system-image-${v}-google_apis_playstore-x86_64"
          "system-image-${v}-google_apis_playstore-arm64-v8a"
        ]))
      ]
    );
in
{
  local.allowedUnfree = [
    # android-studio-full
    "android-studio-stable"
    "android-sdk-cmdline-tools"
    "cmdline-tools"
    "android-sdk-platform-tools"
    "platform-tools"
    "android-sdk-tools"
    "tools"
    "android-sdk-emulator"
    "emulator"
    "android-sdk-build-tools"
    "build-tools"
    "android-sdk-platforms"
    "platforms"
    "android-sdk-ndk"
    "ndk"
    "cmake"
  ]
  ++ androidImages [
    32
    33
    34
    35
    36
    "36.1"
  ];

  nixpkgs.config = {
    # Give me my VMs
    android_sdk.accept_license = true;
  };
  environment.systemPackages = with pkgs; [
    httptoolkit
    frida-tools
  ];
}
