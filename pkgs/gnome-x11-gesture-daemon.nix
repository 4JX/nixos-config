{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  udev,
  libinput,
}:

rustPlatform.buildRustPackage {
  pname = "gnome-x11-gesture-daemon";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "harshadgavali";
    repo = "gnome-x11-gesture-daemon";
    rev = "23349953b546920e7408931950c84bd23c68a249";
    sha256 = "sha256-qkcx7dobSc65+qwKsqm6qzXMQf2fmb+TypfGNOJf3sk=";
  };

  cargoHash = "sha256-JE639JZB/fOe3qz50cxoZPBVt9FPouQNRSkJJPOE7vs=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    udev
    libinput
  ];

  meta = with lib; {
    description = "Adds X11 compatibility for gnomeExtensions.gesture-improvements";
    homepage = "https://github.com/harshadgavali/gnome-x11-gesture-daemon";
    license = licenses.gpl3Only;
  };
}
