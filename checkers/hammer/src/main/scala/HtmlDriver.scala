import com.gargoylesoftware.htmlunit.util.WebConnectionWrapper
import com.gargoylesoftware.htmlunit.WebClient
import org.openqa.selenium.htmlunit.HtmlUnitDriver
import org.scalatest.selenium.HtmlUnit


object JSFilter extends WebConnectionWrapper {

}

class HtmlDriver extends HtmlUnitDriver(true) {
  override def modifyWebClient(client: WebClient) = {
    client.getOptions.setCssEnabled(false)
    new WebConnectionWrapper(client) {
      override def getResponse(Req) {

      }
    }

  }
}
