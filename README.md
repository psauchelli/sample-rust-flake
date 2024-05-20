Purpose: to write a dead-simple and practical/functioning rust project in nix. includes portable nixos config and packages to dev and run a simple rust api.

file structure: the top-level flake.nix imports nixos/configuration.nix and generates a flake with that. the flake in project/axum-project/flake.nix is a flake which generates a dev shell to develop and run the rust code for that project. the nixos config flake and rust flake are not linked in any way at the time of this writing. 
