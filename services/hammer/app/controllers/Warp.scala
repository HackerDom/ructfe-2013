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
  val createForm = Form(
    tuple( "public" -> nonEmptyText, "private" -> optional(text))
  )


  def all = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      val query = for {
        (msg, author) <- Messages innerJoin Users on (_.author_id === _.id)
      } yield (msg,author)

      Ok(views.html.warp.list( query.list))
    }
  }

  def create = withUser { implicit user =>
    DBAction { implicit request =>
      val query = for {
        (mes, author) <- Messages innerJoin Users on (_.author_id === _.id)
      } yield (mes, author)

      Ok(views.html.warp.create( createForm))
    }
  }

  def do_create = withUser { implicit user =>
    DBAction { implicit request =>
      createForm.bindFromRequest().fold(
        {
          withErrors => BadRequest(views.html.warp.create(createForm.bindFromRequest().withGlobalError("Can't create warp")))
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


  def show(messageId: Int) = withUser { implicit user =>
    DBAction { implicit request =>
      Query(Messages).filter(_.id === messageId).innerJoin(Users).on(_.author_id === _.id).firstOption.map { case (msg:Message, author:User) =>

        val query = Query(SentMessages).filter(_.user_id === user.id.get).filter(_.message_id === msg.id.get)
        if(query.exists.run) {
          query.map(_.read).update(true)
        } else {
          SentMessages.insert(SentMessage.create(user, msg, true))
        }
        Ok(views.html.warp.show(msg, author))
      }.getOrElse(NotFound("No such message"))
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

        sent <- Some(SentMessage.create(to, message)) if message.canSend.run
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
        (msg,  author) <- Messages innerJoin Users on (_.author_id === _.id) if (msg.author_id === user.id)
      } yield (msg, author)
      Ok(views.html.warp.list(my.list()))
      //NotImplemented("Shows messages that i own")
    }
  }

  def forme = formeMode()
  def formeMode(mode:String = "all") = withUser { implicit user =>
    DBAction { implicit request =>
      var query = for {
        ((msg, author), sent) <- Messages innerJoin Users on (_.author_id === _.id) leftJoin SentMessages on (_._1.id === _.message_id) if sent.user_id === user.id.get
      } yield (msg, author, sent)
      val my = mode match {
        case "read" => query.filter(_._3.read === true)
        case "unread" => query.filter(_._3.read === false)
        case _ => query
      }
      Ok(views.html.warp.list(my.map({ t=> (t._1, t._2)}).list()))
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
