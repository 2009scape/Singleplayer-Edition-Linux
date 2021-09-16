#!/bin/bash

if [ -f gradlew ]
then
	chmod +x gradlew
	mkdir -p Single-Player

	echo Building Client...
	cd Client
	../gradlew jar
	cd ..
	cp Client/build/libs/client-1.0.0.jar Single-Player/client.jar
	echo

	echo Building Management-Server...
	cd Management-Server
	../gradlew jar
	cd ..
	cp Management-Server/build/libs/managementserver-1.0.0.jar Single-Player/ms.jar
	echo

	echo Building Server...
	cd Server
	../gradlew jar
	cd ..
	cp Server/build/libs/server-1.0.0.jar Single-Player/server.jar
	echo

	echo Copying server data...

	rm -rf Single-Player/data
	cp -R Server/data Single-Player/data
	cp -R Management-Server/managementprops Single-Player/managementprops
	cp Server/db_exports/*.sql Single-Player/data

	# Set Debug/Dev mode to false on single player server config

	cat Server/worldprops/default.json | sed -e 's/\"debug\": true/\"debug\": false/' | sed -e 's/\"dev\": true/\"dev\": false/' > Single-Player/worldprops/default.json


	# Replace Live server addresses with localhost

	cat Client/config.json | sed -e 's/play.2009scape.org/localhost/' > Single-Player/config.json

	echo

	echo Done!
else
	echo ERR: Run in 2009scape source directory to build
fi
