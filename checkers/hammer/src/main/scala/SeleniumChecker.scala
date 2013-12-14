import java.util.logging.Level
import org.apache.commons.codec.digest.DigestUtils
import org.openqa.selenium.htmlunit.HtmlUnitDriver
import org.openqa.selenium.{WebElement, WebDriver}
import org.scalatest.concurrent.AbstractPatienceConfiguration
import org.scalatest.OptionValues._
import org.scalatest.concurrent.Eventually._
import org.scalatest.selenium.{HtmlUnit, WebBrowser, Firefox}
import org.scalatest.{ScreenshotCapturer, Matchers, FlatSpec, exceptions}
import org.scalatest.time.{Seconds, Span}
import scala.collection.convert.DecorateAsScala
import scala.Some
import scala.util.Random

abstract class SeleniumChecker(host: String,port:Int) extends Checker(host, port)  with WebBrowser with Matchers with DecorateAsScala{

  implicit val webDriver:WebDriver

  def generateReference(id: String) = "<a href=\"http://google.com/?q=" +id+ "\">report</a>"

  def goBase = if (currentUrl != baseUrl) go to baseUrl
  def goSite = if (currentUrl.contains(baseUrl)) go to baseUrl


  override def doAction(action:String, args:Array[String]) = {
    try {
      super.doAction(action, args)
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

  def getInnerHtml(id: String) = {
    val script = s"x=document.getElementById('${id}'); return x ? x.innerHTML : '';"
//    System.err.println(script)
    executeScript(script).asInstanceOf[String]
  }

  def doCreate(pub:String, priv:Option[String]) = {
    goSite
    click on partialLinkText("Create")

    doCreateCheat
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
      pageTitle should startWith("Message")
      if(priv.nonEmpty) {
        find("warp-decrypt").value.text should be(pub)
        find("warp-secret").value.text should be(priv.get)
      } else {
        getInnerHtml("warp-public") should startWith(pub.takeWhile(_ === '<'))
      }
    }

    Integer.parseInt(find("warp-id").get.text)
  }


  def doCreateCheat {
    // Cheat
    eventually {
      //      Thread.sleep(100)
      click on (cssSelector("a[data-wysihtml5-action=change_view]"))
    }(PatienceConfig(timeout = Span(10, Seconds)))
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


  def doCheckMessageFrom(name: String, flag: String) = {
    click on partialLinkText("Incoming")
    click on partialLinkText("All")

    eventually {
      val messages = findAll(cssSelector(".warp-td-author")).toArray
      System.err.println("Unread messages: " + messages.mkString(", "))
      val messagesFrom = messages.filter(_.text === name)

      messagesFrom.length should be > (0)
    }
    val messagesFrom = findAll(cssSelector(".warp-td-author")).toArray.filter(_.text === name)
    messagesFrom.map({ message =>
      val id = Integer.parseInt(message.attribute("data-id").get)

      val link = find(cssSelector(s"#warp-td-mark-$id > a")).get
      link.attribute("href").get
    }).exists({ link =>
      go to link
      find("warp-decrypt").exists(_.text === flag)
    }) should be(true)

    Integer.parseInt(find("warp-id").get.text)
  }

  def getUnreadMessagesLinks = {

    click on partialLinkText("Incoming")
    click on partialLinkText("Unread")

    findAll(cssSelector(".warp-td-mark > a")).toArray.map(_.attribute("href")).flatten

  }

  def walkAllLinks(links: Seq[String])(action: => Unit) = {
    links.foreach({ link =>
      go to link
      action
    })
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

  def get(id: String, flag: String) = {
    goBase
    doLogout

    val login = Checker.userLogin(id)
    val password = Checker.userPass(id)
    val name = Checker.userName(id)

    doLogin(login, password)

    doCheckMessageFrom(adminName, flag)
    doCreate("We've got your message, check out " + generateReference(id) + System.currentTimeMillis, None)
  }

  def check() = {
    goBase
    doLogout

    doLoginOrRegister(adminLogin, adminPassword, adminName)
    val links = getUnreadMessagesLinks
    walkAllLinks(links) {
      val extLinks = findAll(cssSelector(s"#warp-public a")).toArray.map({_.attribute("href")}).flatten
      System.err.println( "Checking links: " + extLinks.mkString(" "))
      walkAllLinks(extLinks) {
        Thread.sleep(10)
      }
    }
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

class FirefoxChecker(host: String,port:Int) extends SeleniumChecker(host, port) with Firefox
class HtmlUnitChecker(host: String,port:Int) extends SeleniumChecker(host, port) {
  override implicit val webDriver = new HtmlDriver()
  override def doCreateCheat = {}
}
