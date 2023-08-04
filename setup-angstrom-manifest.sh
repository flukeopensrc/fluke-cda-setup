#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 ANGSTROM_BRANCH" >&2
    exit 1
fi

ANGSTROM_BRANCH="$1"
MAN_DIR="${ANGSTROM_BRANCH}-manifest"

if [ -d $MAN_DIR ]; then
    echo "$MAN_DIR exists"
    exit 1
fi

REPO_PATH=""
if command -v repo &> /dev/null
then
    echo "Google repo found"
    REPO_PATH="$(command -v repo)"
else
    echo "Google repo NOT found"
    # the version of repo in Ubuntu 18.04.6 LTS is broken (maybe not anymore?), so try to
    # bootstrap up to a working version.
    mkdir -p bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
    chmod a+rx bin/repo
    REPO_PATH="./bin/repo"
fi


mkdir $MAN_DIR
cd $MAN_DIR

echo "Using repo from: ${REPO_PATH}"
${REPO_PATH} init -u https://github.com/flukeopensrc/cda-manifest -b ${ANGSTROM_BRANCH} ||
    ${REPO_PATH} init -u https://github.com/flukeopensrc/cda-manifest -b ${ANGSTROM_BRANCH}
${REPO_PATH} sync

MACHINE=fluke-cda-nighthawk source ./setup-environment ""

# Change download and cache dirs
sed -i "s/DL_DIR.*/DL_DIR = \"\$\{TOPDIR\}\/..\/${ANGSTROM_BRANCH}-manifest-downloads\/\"/" conf/site.conf
sed -i "s/SSTATE_DIR.*/SSTATE_DIR = \"\$\{TOPDIR\}\/..\/${ANGSTROM_BRANCH}-manifest-sstate-cache\/\"/" conf/site.conf

cat <<EndOfFile >> conf/site.conf
#uncomment to generate source tarballs under the deploy directory
#INHERIT += "archiver"
#ARCHIVER_MODE[src] = "patched"
EndOfFile
