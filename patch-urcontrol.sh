#!/bin/sh
dir="$(dirname $(readlink -f $0))"
cd "$dir"

log_exec() {
	echo "$@"
	"$@"
}

if ! log_exec patchelf --set-rpath "$dir/lib" ./URControl; then
	echo "Failed to set ./URControl rpath. Please fix manually."
fi

if ! log_exec sudo setcap CAP_NET_BIND_SERVICE=ep ./URControl; then
	echo "Failed to set CAP_NET_BIND_SERVICE=ep on ./URControl. Please Fix manually."
fi
