com.github.play2war.plugin.Play2WarPlugin.play2WarSettings

name := "Hammer"

version := "0.5"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  "com.typesafe.play" %% "play-slick" % "0.5.0.8",
  "commons-codec" % "commons-codec" % "1.8",
  "org.webjars" %% "webjars-play" % "2.2.1",
  "org.webjars" % "bootstrap" % "2.3.2"
)

com.github.play2war.plugin.Play2WarKeys.servletVersion := "3.0"

play.Project.playScalaSettings
