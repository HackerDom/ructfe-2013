import org.openqa.selenium.htmlunit.HtmlUnitDriver
import org.scalatest._
import org.scalatest.concurrent.Eventually._
import org.scalatest.time.{Seconds, Span, Second}
import scala.collection.convert.DecorateAsScala
import selenium._
import org.openqa.selenium._
import org.openqa.selenium.chrome.ChromeDriver
import org.apache.commons.codec.digest.DigestUtils
import org.scalatest.OptionValues._
import com.typesafe.config.ConfigFactory

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

class Checker (host:String, port:Int) extends FlatSpec with Firefox with Matchers with DecorateAsScala   {

  def baseUrl = s"http://$host:$port/"

  def adminName = Checker.adminName
  def adminLogin = Checker.adminLogin
  lazy val adminPassword = DigestUtils.md5Hex(Checker.salt + host)

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
        System.err.println("Repacking exception")
        throw e.cause.getOrElse(e)
      }
    }
    finally {
      quit()
    }
  }

  def goBase = if (currentUrl != baseUrl) go to baseUrl
  def goSite = if (currentUrl.contains(baseUrl)) go to baseUrl



  def goToMessage(msgId: Int) = {
    goSite
    click on partialLinkText("Austropat")
    val links = findAll(cssSelector ("warp-td-mark")).filter { elem =>
      elem.attribute("id").exists({ id =>
        s"warp-td-mark-$msgId".equalsIgnoreCase(id)
      })
    }
    clickOn(links.toSeq(0))
}

  def checkLoggedOn() = find(partialLinkText("Logout")).isDefined

  def doLoginOrNothing(login: String, password: String) = {
    goBase
    find(partialLinkText("Logout")).map { _=> doLogin(login, password)}
  }

  def doLogout = {
    goBase
    find(partialLinkText("Logout")).map(click on _)
  }

  def doRegister(login: String, password: String, name: String) = {
    goBase
    click on linkText("Registration")

    val registrationUrl = currentUrl

    click on "login"
    enter(login)
    click on "password_main"
    enter(password)
    click on "password_confirm"
    enter(password)
    click on "name"
    enter(name)

    submit()

    eventually {
      Thread.sleep(100)
      currentUrl shouldNot be(registrationUrl)
      currentUrl shouldNot include("register")
    }
  }

  def doLogin(login: String, password: String) = {
    goBase
    click on "login"
    enter (login)
    click on "password"
    enter (password)
    submit()

    eventually {
      Thread.sleep(500)
      currentUrl shouldNot include("register")
      find(partialLinkText("Logout")) shouldNot be(None)
    }
  }

  def doLoginOrRegister(login:String, password:String):Any = doLoginOrRegister(login, password, login)

  def doLoginOrRegister(login:String, password:String, name:String):Any = {
    goBase
    doLogout

    try {
      doLogin(login, password)
    }
    catch { case _:exceptions.TestFailedException =>
      doRegister(login, password, name)
    }
  }

  def doCreate(pub:String, priv:Option[String]) = {
    goSite
    click on partialLinkText("Create")

    // Cheat
    eventually {
//      Thread.sleep(100)
      click on(cssSelector("a[data-wysihtml5-action=change_view]"))
    }(PatienceConfig(timeout = Span(10, Seconds)))
    click on("public")
    enter(pub)

//    executeScript(s"return $$('#public-text').value='$pub';")
//    execute_script()
    priv.map { secret =>
      click on "private"
      enter(secret)
    }
    submit()


    eventually {
      Thread.sleep(100)
      if(priv.isDefined) {
        find("warp-decrypt").value.text should be(pub)
        find("warp-secret").value.text should be(priv.get)
      } else {
        find("warp-public").value.text should be(pub)
      }
    }

    Integer.parseInt(find("warp-id").get.text)
  }

  def doSend(msg: Int, name: String) = {
    if(!pageTitle.equalsIgnoreCase(s"Message $msg")) {
      goToMessage(msg)
    }

    val option = find(cssSelector("#warp-sender-select option[data-name=\"" + name + "\"]"))

    option should not be('empty)

    singleSel("warp-sender-select").value = option.get.attribute("value").get
    click on partialLinkText("Send")

    eventually {
      find(cssSelector(".alert-success")) should be('defined)
    }(PatienceConfig(timeout = Span(10, Seconds)))
  }

  def put(id: String, flag: String) = {
    goBase
    doLogout

    val login = Checker.userLogin(id)
    val password = Checker.userPass(id)
    val name = Checker.userName(id)

    doRegister(login, password, name)
    doLogout

    doLoginOrRegister(adminLogin, adminPassword, adminName)
    val msgid = doCreate(flag, Some(DigestUtils.sha256Hex(Checker.salt + id).substring(0,24)))
    doSend(msgid, name)
  }

  def doCheckMessageFrom(name: String, flag: String) = {
    click on partialLinkText("Incoming")
    click on partialLinkText("All")

    val messagesFrom = findAll(cssSelector(".warp-td-author")).toArray//.filter(_.text == name)


    println(messagesFrom.map(_.text).mkString(" "))

    messagesFrom.length should be > (0)

    messagesFrom.map({ message =>
      val id = Integer.parseInt(message.attribute("data-id").get)
      find(cssSelector(s"#warp-td-id-$id a")).get.attribute("href").get
    }).exists({ link =>
      go to link
      find("warp-decrypt").map(_.text == flag).getOrElse(false)
    }) should be(true)
  }

  def get(id: String, flag: String) = {
    goBase
    doLogout

    val login = Checker.userLogin(id)
    val password = Checker.userPass(id)
    val name = Checker.userName(id)

    doLogin(login, password)

    doCheckMessageFrom(adminName, flag)
  }

  def check() = {
    doRegister("123123123", "awe123123", "qweqe123")
  }

  def test() = {
   try {
     val host = "http://google.com/"
     goBase
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