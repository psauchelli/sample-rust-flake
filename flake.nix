{
/*
	This is the simplest flake I could come up with to simply import nixos config (configuration.nix)
	into a flake. Essentially the configuration.nix file is what tells NixOS how we want it set up.
	e.g. which software packages, toggles, and any other config of the os.  You can make that file as
	simple and generalized or as fully-loaded as you want.  If you want your config to be inherited by
	flakes, you have to set the nixosConfigurations.${hostname} value and import the configuration.nix
	file.  NixOS defaults this config file location to /etc/nixos/configuration.nix. However, you can put
	a config file anywhere and just point to that. This is super powerful because you can have the "base"
	config in /etc/nixos/ and then use an *entirely different* config for a specific project and contain it
	inside the git file tree for that project. If someone else clones that repo, they have the entire os
	config as well as any project-specific flakes which may inherit from it.  The purpose of this specific
	flake.nix file is to pull that configuration.nix into a flake environment, so it can be passed as an
	output to other flakes.
	Credit: 
	https://nixos-and-flakes.thiscute.worlld/nixos-with-flakes/nixos-with-flakes-enabled#switch-to-flake-nix
*/
  description = "NixOS Config Example"; # idk if this is required but it seems idiomatic at least

  inputs = { # the values we want to bind and pass to the evaluations contained in "outputs"
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.mysystem = nixpkgs.lib.nixosSystem {
	# For a plain-english explanation of the nunction nixpkgs.lib.nixosSystem:
	# https://www.reddit.com/r/NixOS/comments/13oat7j/what_does_the_function_nixpkgslibnixossystem_do/
	# best comment by u/OHotDawnThisIsMyJawn
      system = "x86_64-linux"; # hard-code the system we want to run this flake.
	# there are examples of flakes which generalize this value to support many systems!
	# I have no idea how they work (at the time of this writing) but they're out there.
      modules = [ # import configuration.nix as a module within the nixosSystem context.
	./nixos/configuration.nix
      ];
    };
  };

}
