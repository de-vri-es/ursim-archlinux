#!/bin/sh

log_exec() {
	echo "$@"
	"$@"
}

# test for patchelf existence
if ! type patchelf > /dev/null 2>&1; then
	echo >&2 "Patching requires the patchelf tool, please install it."
	exit 1
fi

if ! log_exec patchelf --set-rpath "$PWD/lib" ./URControl; then
	echo "Failed to set ./URControl rpath. Please fix manually."
fi

if ! log_exec sudo setcap CAP_NET_BIND_SERVICE=ep ./URControl; then
	echo "Failed to set CAP_NET_BIND_SERVICE=ep on ./URControl. Please Fix manually."
fi
