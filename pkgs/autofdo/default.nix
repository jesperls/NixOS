{ lib, stdenv, fetchurl, unzip, version ? "0.30.1" }:

stdenv.mkDerivation {
  pname = "autofdo";
  inherit version;

  src = fetchurl {
    url = "https://github.com/google/autofdo/releases/download/v${version}/create_llvm_prof-x86_64-v${version}.zip";
    sha256 = "sha256-jhBOa0iB6sZZY22uF6ZmivXQI6HY3+Atf1pN+CiDj7A=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 create_llvm_prof "$out/bin/create_llvm_prof"
    runHook postInstall
  '';

  meta = {
    description = "Google's AutoFDO tools, create_llvm_prof included";
    homepage = "https://github.com/google/autofdo";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "create_llvm_prof";
  };
}
