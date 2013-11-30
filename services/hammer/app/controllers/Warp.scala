package controllers

import play.api.mvc._
import models._

import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._

import components.{Guest, Secured}
import play.api.data.Form
import play.api.data.Forms._
import scala.Some


object Warp extends Controller with Secured {
  val registerForm = Form(
    tuple( "public" -> nonEmptyText, "private" -> optional(text))
  )


  def all = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      val query = for {
        (mes, author) <- Messages innerJoin Users
      } yield (mes, author)

      Ok(views.html.warp.list( query.list))
    }
  }

  def create = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      val query = for {
        (mes, author) <- Messages innerJoin Users
      } yield (mes, author)

      Ok(views.html.warp.list( query.list))
      NotImplemented
    }
  }

  def do_create = withUser { implicit user =>
    DBAction { implicit request =>
      registerForm.bindFromRequest().fold(
        {
          withErrors => BadRequest
        },
        {
          case (pub, priv ) => {
            val msg = Message.create(pub, priv)
            val id = Messages returning Messages.id insert msg
            Redirect(routes.Warp.show(id))
          }
        }
      )
    }
  }


  def show(messageId: Int) = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      NotImplemented("Show message by id")
    }
  }

  def delete(messageId: Int) = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      NotImplemented("Deletes message by id")
    }
  }

  def send(messageId:Int, userId:Int) = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      NotImplemented("Sends already created message to users")
    }
  }

  def own = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      NotImplemented("Shows messages that i own")
    }
  }

  def dummy(message: String) = withAuthorisedUser {
    case Guest => {Action(Forbidden("You should be logged in"))}
    case usr:User =>
      implicit val user = usr
      DBAction { implicit request =>
        val msg = Message.create(message)
        Messages.insert(msg)
        Ok("Success!")
      }
  }
}
