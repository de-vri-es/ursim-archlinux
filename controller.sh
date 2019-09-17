#!/bin/bash

ROBOT_TYPE="UR5"
[[ "$1" == "UR10" ]] && ROBOT_TYPE="UR10"
[[ "$1" == "UR3"  ]] && ROBOT_TYPE="UR3"

export LD_LIBRARY_PATH=$(dirname $(readlink -f $0))/lib:$LD_LIBRARY_PATH
URSIM_ROOT="$(dirname $(readlink -f $0))/$ROBOT_TYPE"

cd $URSIM_ROOT

function cleanup {
	echo "Killing $controller_pid"
	kill $controller_pid;
	wait
}

function on_sigint {
	echo "Killing on interrupt"
	cleanup
	exit 0;
}

trap on_sigint SIGINT

#Start the controller
HOME="$URSIM_ROOT" ../URControl &
controller_pid=$!
sleep 1

nc localhost 30001 > /dev/null << EOF
set teach button enabled True
set real
sec set_controller_state():
  set_tcp(p[0.0,0.0,0.0,0.0,0.0,0.0])
  set_payload(0.0)
  set_standard_analog_input_domain(0, 1)
  set_standard_analog_input_domain(1, 1)
  set_tool_analog_input_domain(0, 1)
  set_tool_analog_input_domain(1, 1)
  set_analog_outputdomain(0, 0)
  set_analog_outputdomain(1, 0)
  set_tool_voltage(0)
  set_standard_digital_input_action(0, "default")
  set_standard_digital_input_action(1, "default")
  set_standard_digital_input_action(2, "default")
  set_standard_digital_input_action(3, "default")
  set_standard_digital_input_action(4, "default")
  set_standard_digital_input_action(5, "default")
  set_standard_digital_input_action(6, "default")
  set_standard_digital_input_action(7, "default")
  set_tool_digital_input_action(0, "default")
  set_tool_digital_input_action(1, "default")
  set_tcp(p[0.0,0.0,0.0,0.0,0.0,0.0])
  set_payload(0.0)
  set_gravity([0.0, 0.0, 9.82])
end
confirm user safety parameters
EOF

wait $controller_pid
cleanup
