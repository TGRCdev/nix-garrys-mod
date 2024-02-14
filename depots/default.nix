{ pkgs, pkgsi686Linux, lib, depotdownloader }:
{
  fetchDepot = {
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
  in pkgsi686Linux.stdenvNoCC.mkDerivation ({
    inherit name outputHash;
    outputHashMode = "recursive";
    phases = [ "buildPhase" ];
    nativeBuildInputs = [ depotdownloader ];
    buildPhase = ''
      mkdir $out -p
      export HOME=$PWD
      ${depotdownloader}/bin/DepotDownloader \
        -dir $out \
        -app ${builtins.toString appId} \
        -depot ${builtins.toString depotId} \
        -manifest ${builtins.toString manifestId} \
        -os linux \
        -osarch 32
      rm -rf $out/.DepotDownloader
    '';
  } // rest);
}