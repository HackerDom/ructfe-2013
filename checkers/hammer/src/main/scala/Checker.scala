import org.openqa.selenium.htmlunit.HtmlUnitDriver
import org.scalatest._
import org.scalatest.concurrent.Eventually._
import org.scalatest.time.{Seconds, Span, Second}
import selenium._
import org.openqa.selenium._
import org.openqa.selenium.chrome.ChromeDriver

object CheckUsage extends Exception

object Checker {
  val OK = 101
  val CORRUPT = 102
  val MUMBLE = 103
  val DOWN = 104
  val ERROR = 110

  val port = 9000

  def do_check(args: Array[String]):Unit = {
    if (args.length < 2) {
      throw CheckUsage
    }
    val Array(mode, host) = args.slice(0,2)
    val checker = new Checker(host, port)

    checker.doAction(mode, args.slice(2,4))
  }

	def main(args: Array[String]): Unit = {
    println("Running with: " + args.mkString(","))
    try {
      do_check(args)
      System.exit(OK)
    }
    catch {
      case CheckUsage|(_:ArrayIndexOutOfBoundsException) => {
        println("Please check usage of this checker")
        println("./checker {mode} {host} [{id} {flag}]")
        System.exit(ERROR)
      }
      case error:Throwable => {
        println("Unknown error in checker, please talk to  orgs")
        error.printStackTrace(System.err)
        System.exit(ERROR)
      }
    }
  }
}

class Checker (host:String, port:Int) extends Firefox with Matchers  {

  def baseUrl = s"http://$host:$port/"

  def doAction(action:String, args:Array[String]) = {
    try {
      action match {
        case "put" => put(args(0), args(1))
        case "get" => get(args(0), args(1))
        case "check" => check()
        case _ => throw CheckUsage
      }
    }
    catch {
      case e:exceptions.TestFailedException => {
        // Rethrowing original exception if any
        throw e.cause.getOrElse(e)
      }
    }
    finally {
      quit()
    }
  }

  def checkLoggedOn() = find(partialLinkText("Logout")).isDefined

  def doLoginOrNothing(login: String, password: String) = {
    go to baseUrl
    find(partialLinkText("Logout")).fold
      {}
      {_ => doLogin(login, password)}

  }

  def doRegister(login: String, password: String, name: String) = {
    go to baseUrl
    click on linkText("Registration")

    val registrationUrl = currentUrl

    click on "login"
    enter(login)
    click on "password_main"
    enter(password)
    click on "password_confirm"
    enter(password)
    click on "name"
    enter("name")

    submit()

    eventually {
      Thread.sleep(5000)
      currentUrl shouldNot be(registrationUrl)
      currentUrl shouldNot include("register")
    }
  }

  def doLogin(login: String, password: String) = {
    go to baseUrl
    click on "login"
    enter (login)
    click on "password"
    enter (password)
    submit()
  }

  def put(id: String, flag: String) = {

  }

  def get(id: String, flag: String) = {

  }

  def check() = {
    doRegister("123123123", "awe123123", "qweqe123")
  }

  def test() = {
   try {
     val host = "http://google.com/"
     go to host
     click on "q"
     pressKeys("Hooray!")
     submit()
     //      textField("q").value = "Hooray!"


     eventually {
       Thread.sleep(1000);
       println(s"Hello, ${pageTitle}!")
     }
     val links =  findAll( cssSelector(".r  a")).flatMap( _.attribute("href")).toList
     for (link <- links) {
       go to link
       println(s"At $link: $pageTitle")
       goBack()
     }

     close()
   }
   finally {
     close()
   }
 }
}