{ pkgs ? (import <nixpkgs> { 
    config.allowUnfree = true;
    config.segger-jlink.acceptLicense = true; 
  })
}:

(pkgs.mkShell.override { stdenv = pkgs.gcc11Stdenv; }) {
  buildInputs = [
    (pkgs.python3.withPackages (ps: [ ps.numpy ]))
    pkgs.virtualenv
    pkgs.cudatoolkit
    pkgs.ffmpeg
  ];
  shellHook = ''
    DIR="${builtins.toPath ./.}"
    VENV_DIR="$DIR/venv"
    SOURCE_DATE_EPOCH=$(date +%s) # required for python wheels
    virtualenv --no-setuptools "$VENV_DIR"
    export PYTHONPATH="$VENV_DIR/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$VENV_DIR/bin:$PATH"

    source venv/bin/activate
  '';
}
