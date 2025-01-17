{ lib
, gcc9Stdenv
, fetchFromGitHub
, autoreconfHook
, cmake
, ncurses6
, runtimeShell
}:

let
  savesDir = "~/.umoria/";
in
gcc9Stdenv.mkDerivation rec {
  pname = "umoria";
  version = "5.7.15";

  src = fetchFromGitHub {
    owner = "dungeons-of-moria";
    repo = "umoria";
    rev = "v${version}";
    sha256 = "sha256-1j4QkE33UcTzM06qAjk1/PyK5uNA7E/kyDe3bZcFKUM=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ncurses6 ];
  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/data $out/bin
    cp -r umoria/data/* $out/data
    cp umoria/umoria $out/.umoria-unwrapped

    mkdir -p $out/bin
    cat <<EOF >$out/bin/umoria
    #! ${runtimeShell} -e

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR
    }

    trap cleanup EXIT

    cd \$RUNDIR
    mkdir data

    for i in $out/data/*; do
      ln -s \$i "data/\$(basename \$i)"
    done

    mkdir -p ${savesDir}
    [[ ! -f ${savesDir}/scores.dat ]] && touch ${savesDir}/scores.dat
    ln -s ${savesDir}/scores.dat scores.dat

    $out/.umoria-unwrapped
    EOF

    chmod +x $out/bin/umoria

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://umoria.org/";
    description = "The Dungeons of Moria - the original roguelike";
    longDescription = ''
      The Dungeons of Moria is a single player dungeon simulation originally written
      by Robert Alan Koeneke, with its first public release in 1983.
      The game was originally developed using VMS Pascal before being ported to the C
      language by James E. Wilson in 1988, and released a Umoria.
    '';
    platforms = platforms.unix;
    badPlatforms = [ "aarch64-darwin" ];
    maintainers = [ maintainers.aciceri ];
    license = licenses.gpl3Plus;
  };
}
