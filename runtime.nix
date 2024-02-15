{ pkgs, pkgsi686Linux, lib }:
{
  fetchRuntime = {
    runtime,
    snapshot,
    filename,
    name ? runtime + "-" + snapshot + "-" + filename,
    hash,
    fetcher ? pkgs.fetchzip,
    fetcherArgs ? { stripRoot = false; },
    ...
  }@args:
    assert builtins.elem runtime [ "heavy" "scout" "sniper" "soldier" ];
  let
    rest = builtins.removeAttrs args [
      "snapshot"
      "filename"
      "runtime"
      "name"
      "hash"
      "fetcher"
    ];
    repo-url = "https://repo.steampowered.com/";
  in fetcher ({
      inherit name hash;
      url = lib.concatStrings [
        repo-url
        "/steamrt-images-" runtime
        "/snapshots/"
        snapshot "/"
        filename
      ];
    } // rest);
}