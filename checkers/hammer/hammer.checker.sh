#!/bin/bash

[[ -e ./target/scala-2.10/hammer-checker.jar ]] || ./sbt assembly

export DISPLAY=:10
java -Dhammer.port=8080 -client -jar ./target/scala-2.10/hammer-checker.jar $* 1>&2

exit $?;
