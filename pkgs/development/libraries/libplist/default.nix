{ lib, stdenv, autoreconfHook, fetchFromGitHub, pkg-config, enablePython ? false, python ? null, glib }:

stdenv.mkDerivation rec {
  pname = "libplist";
  version = "2019-04-04";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = pname;
    rev = "42bb64ba966082b440cb68cbdadf317f44710017";
    sha256 = "19yw80yblq29i2jx9yb7bx0lfychy9dncri3fk4as35kq5bf26i8";
  };

  outputs = ["bin" "dev" "out" ] ++ lib.optional enablePython "py";

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ] ++ lib.optionals enablePython [
    python
    python.pkgs.cython
  ];

  configureFlags = lib.optionals (!enablePython) [
    "--without-cython"
  ];

  propagatedBuildInputs = [ glib ];

  postFixup = lib.optionalString enablePython ''
    moveToOutput "lib/${python.libPrefix}" "$py"
  '';

  meta = with lib; {
    description = "A library to handle Apple Property List format in binary or XML";
    homepage = "https://github.com/libimobiledevice/libplist";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ infinisil ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
