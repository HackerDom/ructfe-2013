name := "Hammer-checker"

version := "0.9"

libraryDependencies ++= Seq(
	"org.scalatest" %% "scalatest" % "2.+",
  "org.seleniumhq.selenium" % "selenium-java" % "2.+",
  "commons-codec" % "commons-codec" % "1.8",
  "org.skife.com.typesafe.config" % "typesafe-config" % "0.3.0",
  "net.databinder.dispatch" %% "dispatch-core" % "0.11.0",
  "org.slf4j" % "slf4j-api" % "1.7.5",
  "org.slf4j" % "slf4j-nop" % "1.7.5"
)