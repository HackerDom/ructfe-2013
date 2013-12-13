com.github.play2war.plugin.Play2WarPlugin.play2WarSettings

name := "Hammer"

version := "0.8"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  "com.typesafe.play" %% "play-slick" % "0.5.0.8",
  "com.github.play2war.ext" %% "redirect-playlogger" % "1.0.1",
  "commons-codec" % "commons-codec" % "1.8",
  "org.webjars" %% "webjars-play" % "2.2.1",
  "org.webjars" % "bootstrap" % "2.3.2",
  "org.webjars" % "select2" % "3.4.4"
)

com.github.play2war.plugin.Play2WarKeys.servletVersion := "3.0"

play.Project.playScalaSettings
