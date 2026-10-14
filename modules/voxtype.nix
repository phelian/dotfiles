{pkgs, ...}: let
  # VOXTYPE_UPDATE_START - Do not edit manually, use update_voxtype.sh
  voxtypeVersion = "1.1.0";
  voxtypeDmgHash = "sha256-MRwSyATchqc7dErK34n1pIixJWeIfoGk8RVfwL16IcU=";
  voxtypeSrcHash = "sha256-zw7Up84IdNv6p8Ae7VnBDuCC/smYHCpMB7C2aN1ZXyc=";
  voxtypeGitHashes = {
    "openvino-finder-0.11.0" = "sha256-nQWeHNdLlRk+owh3B6VpArAG2dr66HeBI2RHfDhyvvU=";
    "openvino-genai-0.11.0" = "sha256-nQWeHNdLlRk+owh3B6VpArAG2dr66HeBI2RHfDhyvvU=";
    "openvino-genai-sys-0.11.0" = "sha256-nQWeHNdLlRk+owh3B6VpArAG2dr66HeBI2RHfDhyvvU=";
    "openvino-sys-0.11.0" = "sha256-nQWeHNdLlRk+owh3B6VpArAG2dr66HeBI2RHfDhyvvU=";
  };
  # VOXTYPE_UPDATE_END
  voxtypeSrc = pkgs.fetchFromGitHub {
    owner = "peteonrails";
    repo = "voxtype";
    tag = "v${voxtypeVersion}";
    hash = voxtypeSrcHash;
  };
  voxtype-bin = pkgs.rustPlatform.buildRustPackage {
    pname = "voxtype-bin";
    version = voxtypeVersion;
    src = voxtypeSrc;
    patches = [
      ./patches/voxtype-macos-extended-keys.patch
      ./patches/voxtype-macos-multiple-hotkeys.patch
    ];
    cargoLock = {
      lockFile = "${voxtypeSrc}/Cargo.lock";
      outputHashes = voxtypeGitHashes;
    };
    nativeBuildInputs = with pkgs; [cmake pkg-config git rustPlatform.bindgenHook];
    buildInputs = with pkgs; [onnxruntime openssl];
    buildFeatures = ["gpu-metal" "cohere"];
    cargoBuildFlags = ["--bin" "voxtype"];
    env.ORT_LIB_LOCATION = "${pkgs.onnxruntime}/lib";
    env.ORT_PREFER_DYNAMIC_LINK = "1";
    dontUseCmakeConfigure = true;
    doCheck = false;
  };
  voxtype = pkgs.stdenvNoCC.mkDerivation {
    pname = "voxtype";
    version = voxtypeVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${voxtypeVersion}/voxtype-${voxtypeVersion}-macos-universal.dmg";
      hash = voxtypeDmgHash;
    };
    nativeBuildInputs = [pkgs._7zz];
    unpackPhase = ''
      7zz x -snld "$src"
    '';
    installPhase = ''
      mkdir -p "$out/Applications" "$out/bin"
      cp -R "$(find . -name Voxtype.app -maxdepth 3 -type d | head -1)" "$out/Applications/"
      chmod -R u+w "$out/Applications/Voxtype.app"
      cp ${voxtype-bin}/bin/voxtype "$out/Applications/Voxtype.app/Contents/MacOS/voxtype-bin"
      ln -s "/Applications/Nix Apps/Voxtype.app/Contents/MacOS/voxtype-bin" "$out/bin/voxtype"
    '';
    dontFixup = true;
  };
  marker = "/tmp/voxtype/spotify-paused";
  voxtype-media-pause = pkgs.writeShellScriptBin "voxtype-media-pause" ''
    state=$(/usr/bin/osascript -e 'if application "Spotify" is running then tell application "Spotify" to return player state as string' 2>/dev/null)
    if [ "$state" = "playing" ]; then
      /usr/bin/osascript -e 'tell application "Spotify" to pause'
      touch ${marker}
    fi
  '';
  voxtype-media-resume = pkgs.writeShellScriptBin "voxtype-media-resume" ''
    if [ -e ${marker} ]; then
      rm -f ${marker}
      /usr/bin/osascript -e 'tell application "Spotify" to play'
    fi
  '';
in {
  environment.systemPackages = [voxtype voxtype-media-pause voxtype-media-resume];
}
