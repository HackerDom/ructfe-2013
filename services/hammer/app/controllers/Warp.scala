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
        (mes, author) <- Messages.all innerJoin Users
      } yield (mes, author)

      Ok(views.html.warp.list( query.list))
    }
  }

  def create = withUser { implicit user =>
    DBAction { implicit request =>
      val query = for {
        (mes, author) <- Messages innerJoin Users
      } yield (mes, author)

      Ok(views.html.warp.list( query.list))
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
      Query(Messages).filter(_.id === messageId).firstOption.map( msg => Ok(views.html.warp.show(msg)))
        .getOrElse(NotFound("No such message"))
    }
  }

  def delete(messageId: Int) = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      val query = Query(Messages).where(_.id === messageId)
      if (Query(query.length).first > 0) {
        query.delete
        Redirect(routes.Warp.own()).flashing("success" -> "Message was successfuly deleted")
      }
      else {
        Redirect(routes.Warp.show(messageId)).flashing("error" ->"Can't delete message")
      }
    }
  }

  def send(messageId:Int, userId:Int) = withUser { implicit user =>
    DBAction { implicit request =>
//      val message = Query(Messages).where(_.id === messageId).firstOption
//      val to = Query(Users).where(_.id === userId).firstOption

      val sent = for {
        message <- Query(Messages).where(_.id === messageId).firstOption
        to <- Query(Users).where(_.id === userId).firstOption

        sent <- Some(SentMessage.create(to, message)) if message.author_id == user.id.get
      } yield sent

      sent.map({ message =>
           SentMessages insert(message)
           Redirect(routes.Warp.show(messageId)).flashing("success" -> "Successfully sent")
        }).getOrElse(Redirect(request.headers.get(REFERER).getOrElse(routes.Warp.own().url)).flashing("error" -> "No such message, user or you do not have rights"))
    }
  }

  def own = withUser { implicit user =>
    DBAction { implicit request =>
      val my = for {
        (msg, sent) <- Messages leftJoin SentMessages if msg.author_id == user.id || sent.user_id == user.id
      } yield (msg, sent)
      NotImplemented("Shows messages that i own")
    }
  }

  def dummy(message: String) = withUser { implicit user =>
    DBAction { implicit request =>
      val msg = Message.create(message)
      Messages.insert(msg)
      Ok("Success!")
    }
  }
}
