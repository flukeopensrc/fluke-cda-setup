
## Setup Bitbake Enviornment

This will pull the manfest from cda-manfest repo and setup the yocto layers.

```bash
./setup-angstrom-manifest.sh <branch>
```

Three folders should be created as follow:
```
<branch>
<branch>-downloads
<branch>-sstate-cache
```
### Alternatives
Checkout latest stable manifest for the give yocto version.
Note: Check scripts to determine what branch name were used.
```bash
# Hardknott (Don't use, WIP)
./setup-angstrom-manifest-hardknott.sh

# Zeus
./setup-angstrom-manifest-zeus.sh

# Sumo
./setup-angstrom-manifest-sumo.sh

# Pyro
./setup-angstrom-manifest-pyro.sh
```

## Building with Bitbake
Once you have your bitbake enviornment setup

1. Change directory into primary folder
`cd <branch>`

2. Specify your target MACHINE and source your enviornment
`MACHINE=<machine> . /setup-enviornment`

3. Run bitbake to build your image
`bitbake full-fluke-image`