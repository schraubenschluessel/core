{ stdenv, fetchurl

# Build runit-init as a static binary
, static ? false
}:

stdenv.mkDerivation rec {
  pname = "runit";
  version = "2.1.2";

  src = fetchurl {
    url = "http://smarden.org/runit/${pname}-${version}.tar.gz";
    sha256 = "065s8w62r6chjjs6m9hapcagy33m75nlnxb69vg0f4ngn061dl3g";
  };

  patches = [
    ./fix-ar-ranlib.patch
  ];

  outputs = [ "out" "man" ];

  sourceRoot = "admin/${pname}-${version}";

  doCheck = true;

  postPatch = ''
    sed -i "s,\(#define RUNIT\) .*,\1 \"$out/bin/runit\"," src/runit.h
    # usernamespace sandbox of nix seems to conflict with runit's assumptions
    # about unix users. Therefor skip the check
    sed -i '/.\/chkshsgr/d' src/Makefile
  '';

  preBuild = ''
    cd src

    # Both of these are originally hard-coded to gcc
    echo cc > conf-cc
    echo cc > conf-ld
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -t $out/bin $(< ../package/commands)

    mkdir -p $man/share/man
    cp -r ../man $man/share/man/man8
  '';

}
