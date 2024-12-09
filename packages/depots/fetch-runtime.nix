{ lib, stdenv, fetchzip }:
{
  version,
  hash,
  ...
}@args: let
  rest = builtins.removeAttrs args [
    "hash"
  ];
in stdenv.mkDerivation ({
  pname = "steam-runtime";

  src = fetchzip {
    url = "https://repo.steampowered.com/steamrt-images-scout/snapshots/${version}/steam-runtime.tar.xz";
    inherit hash;
  };

  buildCommand = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';
} // rest)