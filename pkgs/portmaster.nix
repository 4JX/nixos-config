{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "portmaster";
  version = "1.0.14";

  src = fetchFromGitHub {
    owner = "safing";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-UmoGAAafP26LAJETJzpHYEgRVGYZmd6zLmRPIXT7if8=";
  };

  vendorHash = "sha256-qxI8GZHDq16vXj6AzDDY7oQ8/OJFcLj4IW+cKch3HoY=";

  ldflags = let t = "github.com/safing/portbase/info"; in
    [
      "-s"
      "-w"
      "-X ${t}.commit=${src.rev}"
      "-X ${t}.buildOptions=unknown"
      "-X ${t}.buildUser=nixbld"
      "-X ${t}.buildHost=nix"
      "-X ${t}.buildDate=01.01.1970"
      "-X ${t}.buildSource=${src.url}"
    ];

  # can't be run in the sandbox
  doCheck = false;

  meta = with lib; {
    description = "A free and open-source application firewall that does the heavy lifting for you";
    homepage = "https://safing.io";
    license = licenses.agpl3;
    maintainers = with maintainers; [ urandom ];
  };
}
