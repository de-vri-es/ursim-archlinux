#!/bin/sh
dir="$(dirname $(readlink -f $0))"
cd "$dir"

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

./patch-urcontrol.sh
echo
