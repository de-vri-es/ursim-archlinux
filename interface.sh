#!/bin/bash

ROBOT_TYPE="UR5"
[[ "$1" == "UR10" ]] && ROBOT_TYPE="UR10"
[[ "$1" == "UR3"  ]] && ROBOT_TYPE="UR3"

URSIM_ROOT="$(dirname $(readlink -f $0))/$ROBOT_TYPE"
GUI_ROOT="$URSIM_ROOT/../GUI"
cd "$GUI_ROOT"

#Start the gui
HOME="$URSIM_ROOT" java \
	-Duser.home="$URSIM_ROOT" \
	-Dconfig.path="$URSIM_ROOT/.urcontrol" \
	-Durcontrol.path="/bin/true" \
	-Djava.library.path="$URSIM_ROOT/../GUI/bundle:/jre/lib/amd64:/usr/lib/jni" \
	-jar "$GUI_ROOT/bin/felix.jar"
