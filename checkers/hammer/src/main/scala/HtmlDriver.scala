import com.gargoylesoftware.htmlunit.util.{NameValuePair, WebConnectionWrapper}
import com.gargoylesoftware.htmlunit._
import java.util.Collections
import org.openqa.selenium.htmlunit.HtmlUnitDriver


class RequestFilter(client:WebClient) extends WebConnectionWrapper(client) {

  def filterUrl(url: String): Boolean = {
    url.endsWith(".css") ||
      url.contains("wysihtml5") ||
      url.contains("googleusercontent") ||
      url.contains("googleapis") ||
//      url.contains("select2") ||
      url.endsWith("woff") ||
      url.endsWith("png")  ||
      url.endsWith("jpg")
  }

  override def getResponse(request: WebRequest) = {

    if(filterUrl(request.getUrl.toExternalForm)) {
      val data = new WebResponseData("".getBytes(), 200, "OK", Collections.emptyList[NameValuePair]);
      new WebResponse(data, request, (scala.util.Random.nextLong() % 1000) + 100)
      
    }
    else {
      super.getResponse(request)
    }
  }
}

class HtmlDriver extends HtmlUnitDriver(BrowserVersion.FIREFOX_17) {

  override def modifyWebClient(client: WebClient) = {
    client.getOptions.setCssEnabled(false)
    client.getOptions.setJavaScriptEnabled(true)
    client.getOptions.setThrowExceptionOnScriptError(false)
    client.getOptions.setTimeout(7000)
    client.setJavaScriptTimeout( 2000 );
    new RequestFilter(client)
    client

  }
}
