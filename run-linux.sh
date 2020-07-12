#!/bin/bash

#Prompt user with options on what to do
echo "What would you like to do? (Type a number)"
echo "1. Run the game."
echo "2. Initialize the database. (Only has to be done once!)"
echo "3. Reset the database."
echo "4. Grant a player admin rights."
read -r playerChoice

initDB() {
  cd database
  bin/mysqld --console --skip-grant-tables --lc-messages-dir="./share/" --datadir="./data" &
  sleep 5
  echo | bin/mysql -u root -e "CREATE DATABASE server;"
  echo | bin/mysql -u root -e "CREATE DATABASE global;"
  echo | bin/mysql -u root server < ../data/server.sql
  echo | bin/mysql -u root global < ../data/global.sql
  sleep 10
  killall mysqld
  copy_cache
  sleep 3
  clear
  echo "Database initialized, you can now run the game!"
}

copy_cache(){
  # shellcheck disable=SC2164
  cd database
  if [ ! -d "$HOME/.runite_rs/runescape " ]; then
    mkdir "$HOME/.runite_rs"
    mkdir "$HOME/.runite_rs/runescape"
  fi
  cd ..
  pwd
  cp -f data/cache/* "$HOME"/.runite_rs/runescape/
}

run() {
# shellcheck disable=SC2164
cd database
bin/mysqld --console --skip-grant-tables --lc-messages-dir="./share/" --datadir="./data" &
sleep 5
cd ..
java -jar ms.jar &
sleep 1
java -cp server.jar core.Server default.xml &
sleep 20
java -jar client.jar
killall java
killall mysqld
sleep 5
clear
}

reset_db(){
  # shellcheck disable=SC2164
  cd database
  rm -fr data
  mkdir data
  cd ..
  initDB
}

set_Admin(){
  echo "Enter the username for the player: "
  read -r USERNAME
  cd database
  bin/mysqld --console --skip-grant-tables --lc-messages-dir="./share/" --datadir="./data" &
  sleep 5
  bin/mysql -u root -e "USE global; UPDATE members SET rights=2 WHERE username = '$USERNAME';"
  sleep 2
  killall mysqld
  sleep 3
  clear
}



if [ "$playerChoice" = "1" ] ; then
  run
fi

if [ "$playerChoice" = "2" ] ; then
  initDB
fi

if [ "$playerChoice" = "3" ]; then
  reset_db
fi

if [ "$playerChoice" = "4" ]; then
  set_Admin
fi

