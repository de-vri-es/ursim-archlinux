#!/bin/sh
script_dir="$(dirname $(readlink -f $0))"

log_exec() {
	echo "$@"
	"$@"
}

defuse() {
	[ ! -f "$1" ] && return
	[ -e ".defused" ] || log_exec mkdir ".defused"
	log_exec chmod -x "$1"
	log_exec mv "$1" ".defused/$1"
}

setup_robot() {
	robot_type="$1"
	mkdir -p "$robot_type"
	mkdir -p "$robot_type/.urcontrol"
	log_exec touch "$robot_type/.urcontrol/safety.conf"
	mkdir -p "$robot_type/programs"
	log_exec rmdir programs.$robot_type

	for file in .urcontrol/*.conf; do
		basename="$(basename "$file")"
		log_exec ln -sf "../../.urcontrol/$basename" "$robot_type/.urcontrol/$basename"
	done

	for file in .urcontrol/*.conf."$robot_type"; do
		basename="$(basename "$file" ".$robot_type")"
		log_exec ln -sf "../../.urcontrol/$basename.$robot_type" "$robot_type/.urcontrol/$basename"
	done

	log_exec ln -sf "../ur-serial.$robot_type" "$robot_type/ur-serial"

  log_exec ln -sf "../metadata.n3" "$robot_type/metadata.n3"
}

extract_deb() {
	archive="$1"
	shift
	ar p "$archive" data.tar.gz | tar xz "$@"
}

install_dep() {
	log_exec extract_deb "ursim-dependencies/$1" -C lib --wildcards './opt/*/lib/*' --strip-components 4
}

echo "Setting up UR3."
setup_robot UR3
echo

echo "Setting up UR5."
setup_robot UR5
echo

echo "Setting up UR10."
setup_robot UR10
echo

echo "Disabling original launch scripts."
defuse "install.sh"
defuse "start-ursim.sh"
defuse "starturcontrol.sh"
defuse "stopurcontrol.sh"
echo

echo "Extracting libraries from dependencies."
log_exec mkdir -p lib
install_dep "libxmlrpc-c-ur_1.33.14_amd64.deb"
echo ""

echo "Copying run scripts."
log_exec cp "$script_dir/controller.sh" ./
log_exec cp "$script_dir/interface.sh" ./
echo

echo "Patching URControl."
"$script_dir/patch-urcontrol.sh"
echo
