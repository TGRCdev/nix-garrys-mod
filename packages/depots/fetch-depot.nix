{ stdenvNoCC, lib, depotdownloader }:
{
  name,
  appId,
  depotId,
  manifestId,
  outputHash,
  ...
}@args: let
  rest = builtins.removeAttrs args [
    "name"
    "appId"
    "depotId"
    "manifestId"
    "outputHash"
  ];
in stdenvNoCC.mkDerivation ({
  inherit name outputHash;
  outputHashMode = "recursive";
  phases = [ "buildPhase" ];
  nativeBuildInputs = [ depotdownloader ];
  buildPhase = ''
    mkdir $out -p
    mkdir ./depot
    export HOME=$PWD
    ${depotdownloader}/bin/DepotDownloader \
      -dir ./depot \
      -app ${builtins.toString appId} \
      -depot ${builtins.toString depotId} \
      -manifest ${builtins.toString manifestId} \
      -os linux \
      -osarch 32
    cp -r ./depot/* $out/
  '';
} // rest)