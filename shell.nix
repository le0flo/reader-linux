{ pkgs ? import <nixpkgs> {} }:

let
  arch = "arm64";
  target = "aarch64-unknown-linux-gnu";

  crossPkgs = import <nixpkgs> {
    system = "x86_64-linux";
    crossSystem.config = target;
  };
in pkgs.mkShell {
  packages = with pkgs; [
    wget
    stdenv.cc
    ncurses.dev
    flex
    bison
    bc
    perl
    pkg-config
    diffutils
    elfutils.dev
    cpio
    findutils
    rsync
    openssl.dev
    syslinux
    cdrkit
    python313
    gmp
    mpfr
    libmpc
    isl
  ] ++ [
    crossPkgs.stdenv.cc.cc
    crossPkgs.stdenv.cc.bintools.bintools
  ];

  env = {
    ARCH = arch;
    CROSS_COMPILE = "${target}-";

    HOST_CC = "${pkgs.stdenv.cc}/bin/gcc";
    HOST_CXX = "${pkgs.stdenv.cc}/bin/g++";
  };

  hardeningDisable = [ "format" ];
}
