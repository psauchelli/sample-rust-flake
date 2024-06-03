{
/*
	The power of this flake is that it has a "dev shell" config which creates an execution runtime that
	contains all the dependencies for our code to run.  This means that your git tree for this project contains
	100% of the config you need to execute your code.  This is excellent for development (hence dev shell).
	You may hear the phrase "dev = test = prod" in reference to nix'd projects.  This comes from the fact that
	this dev shell contains everything you need to run this code regardless of where it's being executed, so 
        the dev shell functionally acts as a stand-alone, prod-ready runtime for the project.  You could 
	realistically ship this code with a deployment shell script which literally just runs "nix develop" and 
	executes the code. Your production code runs in the *exact same runtime context as your dev and test*
	through this mechanic and as a result, you don't have any friction between dev, test and code.

	There is also a "nix shell" command which serves a similar purpose.  It is meant to create a shell which
	brings the application binary into scope temporarily by adding it to $PATH.

	For nix-shell vs nix shell vs nix develop see:
	https://discourse.nixos.org/t/nix-shell-nix-shell-and-nix-develop/25964/10
	nix develop documentation:
	https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-develop
*/
	description = "Rust Flake";
	inputs = { # inputs represents a declaration of values and objects that we want to provide to the flake.
		# It can be something like the url of our nix packages repo, other repos we will need,
		# useful scripts that we want to import, as well as the OUTPUTS of OTHER FLAKES upon which
		# we want to build! <- this last one is where the power of Flakes really shines!
		# this is an { attribute set }; which is bascially a block of variable bindings
		# (see nix.dev/tutorials/nix-language.html#attribute-set for details)
		# here, we are binding the string "github:nixos/..." to the .url attribute of the nixpkgs object
		# nixpkgs is a sprawling corpus of nix-ified software packages. We will use this to do
		# stuff in the "outputs" section of this flake.
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		# you don't have to use the "unstable" version. In fact, it's smart to lock your version
		# once you are done developing.  Check out the nixpkgs repo to see the structure, we will
		# drill into that repo to get the packages we want later!
	};

	outputs = { self, nixpkgs, ... }@inputs: # Outputs is the part where the inputs are evaluated according to
		# the logic herein and returned for use by other flakes. This is where the package is built. 
		# this is a FUNCTION (nix.dev/tutorials/ix-langage.html#functions)
		# here we are taking an attrset as an argument and appending 
		# anything that we declared in inputs as args as well.  In this case, we only have nixpkgs in our 
		# inputs, so @inputs is redundant, but normally you'll have tons of stuff as inputs that you would 
		# want to add to the args here, so it's not harmful to add @inputs.
		let # this is a let ... in ... statement (nix.dev/tutorials/nix-language.html#let-in)
			# the let block binds variables for use in the "in" block.
			system = "x86_64-linux"; # declare what kind of system should be running this.
				# there are ways to generalize this so your flake can handle many
				# different system types!
			pkgs = nixpkgs.legacyPackages.${system}; # Here we drill into nixpkgs to get the specific
					# parts of it that pertain to our system. If you look at the code repo,
					# there is no "legacyPackages" directory. If you go to
					# github.com/NixOS/nixpkgs/blob/nixos-unstable/flake.nix,
					# you see that nixos-unstable is a FLAKE and the .legacyPackages
					# is a tweak to the way the repo is imported to prevent your system
					# from evaluating the whole corpus of pkgs when it inherits from the
					# nixos-unstable flake for use in YOUR flake.
		in # the "in" block actually uses the variables from the let block to evaluate some logic
		{ # this is an attr set where we bind a special nix "derivation" (mkshell) which builds a shell
		# by evaluating another attrset which references pkgs ("with pkgs;") and from that pulls our
		# specific dependencies out.
			devShells.${system}.default = pkgs.mkShell
			# if you go to github.com/NixOS/nixpkgs/blob/master/pkgs/build-support 
			# you will see there are a variety of special derivations to do common, 
			# important things in the flake build process.
			# if you navigate to ./mkshell/default.nix you can see the source code 
			# for mkshell if you're interested.
			{
				# nix.dev/tutorials/nix-language.html#with
				# we are using a with block to pull dependencies with matching names
				# from the pkgs repo.
				packages = with pkgs; [ rustc cargo ];
			};
			# effectively this says "go to nixpkgs, find rustc + cargo + all THEIR dependencies,
			# load them into a development shell, and bind ALL THAT to the .default attribute
			# of devShells.x86_64-linux. That way, when you type "nix develop" it will drop you
			# straight into a shell that can run all the code and dependencies of your flake/project.
		};
}
