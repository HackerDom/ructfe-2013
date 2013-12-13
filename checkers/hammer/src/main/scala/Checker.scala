import org.apache.commons.logging.LogFactory
import org.scalatest._
import org.apache.commons.codec.digest.DigestUtils
import com.typesafe.config.ConfigFactory
import java.util.logging.Level

object CheckUsage extends Exception

object Checker {
  val OK = 101
  val CORRUPT = 102
  val MUMBLE = 103
  val DOWN = 104
  val ERROR = 110

  val conf = ConfigFactory.load

  val port = conf.getInt("hammer.port")
  val salt = conf.getString("hammer.salt")

  val adminLogin = conf.getString("hammer.admin.login")
  val adminName  = conf.getString("hammer.admin.name")

  def do_check(args: Array[String]):Unit = {
    if (args.length < 2) {
      throw CheckUsage
    }
    val Array(mode, host) = args.slice(0,2)
    val checkerClass = Class.forName(conf.getString("hammer.checker.type"))
    
    val checker:Checker = checkerClass.getDeclaredConstructor(classOf[String], classOf[Int]).newInstance(host, port.asInstanceOf[Object]).asInstanceOf[Checker]

    checker.doAction(mode, args.slice(2,4))
  }

  def prepend = {
    LogFactory.getFactory().setAttribute("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.NoOpLog");

    java.util.logging.Logger.getLogger("com.gargoylesoftware.htmlunit").setLevel(Level.OFF);
    java.util.logging.Logger.getLogger("org.apache.commons.httpclient").setLevel(Level.OFF);
    java.util.logging.Logger.getLogger("org").setLevel(Level.OFF);
    java.util.logging.Logger.getLogger("com").setLevel(Level.OFF);
    java.util.logging.Logger.getLogger("sun").setLevel(Level.OFF);
    java.util.logging.Logger.getLogger("net").setLevel(Level.OFF)


  }

	def main(args: Array[String]): Unit = {
    //println("Running with: " + args.mkString(","))

    prepend

    try {
      do_check(args)
      System.exit(OK)
    }
    catch {
      case CheckUsage|(_:ArrayIndexOutOfBoundsException) => {

        System.err.println("Please check usage of this checker")
        System.err.println("./checker {mode} {host} [{id} {flag}]")
        System.exit(ERROR)
      }
      case error:Throwable => {
        System.err.println("Unknown error in checker, please talk to  orgs")
        error.printStackTrace(System.err)
        System.exit(ERROR)
      }
    }
  }

  def userLogin(id:String) = id
  def userPass(id:String)  = DigestUtils.md5Hex(Checker.salt+id)
  def userName(id:String)  = id
}

abstract class Checker (host:String, port:Int)  {

  def baseUrl = s"http://$host:$port/"

  def adminName = Checker.adminName
  def adminLogin = Checker.adminLogin
  lazy val adminPassword = DigestUtils.md5Hex(Checker.salt + host)

  def doAction(action:String, args:Array[String]) = {
    action match {
      case "put" => put(args(0), args(1))
      case "get" => get(args(0), args(1))
      case "check" => check()
      case _ => throw CheckUsage
    }
  }

  def put(id: String, flag: String)
  def get(id: String, flag: String)
  def check()

}