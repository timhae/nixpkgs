{
clangStdenv,
fetchFromGitHub,
clang-unwrapped,
cmake,
hwloc,
llvm,
lttng-ust,
ocl-icd,
pkgconfig
}:

clangStdenv.mkDerivation rec {
  name = "pocl";
  src = /home/tim/repos/pocl;
  skipUnpack = true;
#  src = fetchFromGitHub {
#    owner = "pocl";
#    repo = "pocl";
#    rev = "f522111b8bbd87462abade03d35a1c9c2ba56580";
#    sha256 = "08d3gdv65xhf6m9z4sq8mssnaqjhqybrnrs33q1g3fqshciccw6a";
#  };

  buildInputs = [
    clang-unwrapped
    cmake
    hwloc
    llvm
    lttng-ust
    ocl-icd
    pkgconfig
  ];

  nativeBuildInputs = [];

}
