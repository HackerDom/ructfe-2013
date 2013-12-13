#!/bin/bash

home=`dirname $0`
jar="$home/target/scala-2.10/hammer-checker.jar"

[[ -e "$jar" ]] || "$home/sbt" assembly

export DISPLAY=:10
java -Dhammer.port=8080 -client -jar "$jar" $* 1>&2

exit $?;
