import org.openqa.selenium.htmlunit.HtmlUnitDriver
import org.scalatest._
import org.scalatest.concurrent.Eventually._
import org.scalatest.time.{Seconds, Span, Second}
import selenium._
import org.openqa.selenium._
import org.openqa.selenium.chrome.ChromeDriver

object Checker  extends Firefox {

	def main(args: Array[String]): Unit = {

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