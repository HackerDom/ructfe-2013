package controllers

import play.api._
import play.api.mvc._
import models._
import components.Secured

import play.api.db.slick.Config.driver.simple._
import play.api.db.slick._
import play.api.Play.current

object Application extends Controller with Secured {

  def index = withAuthorisedUser { implicit user =>
    Action { implicit request =>
      Ok(views.html.index("Your new application is ready."))
    }
  }

  def users = withAuthorisedUser { implicit user =>
     DBAction { implicit request =>
        val users = Query(Users)
        Ok(views.html.users(users.list) )
     }
  }
}