# PAM module that enables simultaneous fingerprint + password authentication.
# Upstream: https://gitlab.com/mishakmak/pam-fprint-grosshack
{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  glib,
  libfprint,
  linux-pam,
  polkit,
  dbus,
  systemd,
  perl,
  libxslt,
  libxml2,
  libpam-wrapper,
}:
stdenv.mkDerivation rec {
  pname = "pam-fprint-grosshack";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "mishakmak";
    repo = "pam-fprint-grosshack";
    rev = "v${version}";
    hash = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    perl
    libxslt
  ];

  buildInputs = [
    glib
    libfprint
    linux-pam
    polkit
    dbus
    systemd
    libxml2
    libpam-wrapper
  ];

  mesonFlags = [
    "-Dpam=true"
    "-Dman=false"
    "-Dsystemd=false"
    "-Dgtk_doc=false"
    "-Dpam_modules_dir=${placeholder "out"}/lib/security"
  ];

  meta = with lib; {
    description = "PAM module for simultaneous fingerprint and password authentication";
    homepage = "https://gitlab.com/mishakmak/pam-fprint-grosshack";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
