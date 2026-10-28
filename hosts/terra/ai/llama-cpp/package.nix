{ pkgs }:

(pkgs.llama-cpp.override {
  cudaSupport = true;
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/llama-mmap-sequential-env.patch
      ./patches/llama-mmap-phase-advice-env.patch
    ];

    # Terra has a fixed Ampere GPU. The nixpkgs default builds CUDA code for
    # ten architectures; the final flag wins and avoids compiling unused ones.
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DCMAKE_CUDA_ARCHITECTURES=86"
    ];
  })
