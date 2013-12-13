import dispatch._
import Defaults._
import scala.collection.convert.DecorateAsScala
import scala.collection.JavaConversions._
import com.ning.http.client.Cookie

class HttpChecker(host: String,port:Int) extends Checker(host, port) {

  val baseReq  = url(baseUrl)

  def withCookie(action: Req => Future[Res]) = {
    val res = Http(baseReq).apply()
    val cookied = res.getCookies().foldLeft(baseReq)({case (req,cookie) => req.addCookie(cookie)})
    action(cookied)

  }

  def doRegister(login:String, password: String, name:String)(implicit req:Req) = {
    val postReq = req.POST
      .addParameter("login", login)
      .addParameter("password.main", password)
      .addParameter("password.confirmation", password)
      .addParameter("name", name)

    Http(postReq)
  }

  def doCreate(pub: String, priv: Option[String])(implicit req: Req):Future[Res] = ???
  def doSend(msgId:Int, userId: Int)(implicit req: Req):Future[Res] = ???

  override def put(id: String, flag: String) = {
    val pub = id
    val priv = flag

    val z = withCookie { implicit req =>
      doRegister(adminLogin, adminPassword, adminName).flatMap { _ =>
        doCreate(pub, Some(priv)).flatMap { res:Res =>
          val msgId = 1
          val userId = 1

          doSend(msgId, userId)
        }
      }
    }
    Thread.sleep(10000)
    z.apply()
  }

  override def get(id: String, flag: String): Unit = ???

  override def check(): Unit = ???
}
