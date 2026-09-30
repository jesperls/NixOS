# Kernel

Pangu imports [kernel.nix](../modules/nixos/performance/kernel.nix), which uses
the pinned CachyOS LTO kernel. With the default build options it selects the
cached package. Changing the processor target, governor or BBR3 options
selects a custom kernel build. The `fallback` boot specialisation uses
the stock NixOS kernel with sched_ext disabled.
