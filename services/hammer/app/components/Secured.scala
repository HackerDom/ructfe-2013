package components

import play.api.mvc._
import play.api.mvc.Security
import play.api.mvc.Results._

import play.api.libs.iteratee._
import scala.concurrent.Future

import play.api.db.slick.Config.driver.simple._
import play.api.Play.current
import scala.slick.session.Session

import controllers.routes
import models._
import play.api.db.slick._
import play.api.libs.iteratee.Input

/**
 * Created by Last G on 23.11.13.
 */
trait Secured {
  def getLogin(request: RequestHeader) = request.session.get("login")
  def userFromLogin(login: String)(implicit session:Session): Option[User] = Query(Users).filter(_.login === login).firstOption
  def getUser(request: RequestHeader)(implicit session:Session):Option[User] = getLogin(request).flatMap(userFromLogin _)

  def onUnauthorized(request: RequestHeader):SimpleResult = Results.Forbidden

  def withUser(action: User => EssentialAction) = DB.withSession {
    implicit session:Session => Security.Authenticated(getUser(_), onUnauthorized )(action)
  }

  def withLogin(action: String => EssentialAction) = {
    Security.Authenticated(getLogin, onUnauthorized )(action)
  }

  def withAuthorisedUser(action: AuthorisedUser => EssentialAction) = DB.withSession {
    implicit session:Session => {
      val user = {request:RequestHeader => Some(getUser(request).getOrElse(Guest))}
      Security.Authenticated(user, onUnauthorized) (action)
    }
  }
}
