package controllers

import play.api.mvc._
import models._

import play.api.db.slick.Config.driver.simple._
import play.api.db.slick._
import play.api.Play.current

import components.Secured

/**
 * Created by Last G on 22.11.13.
 */
object Warp extends Controller with Secured {
  def all = DBAction {
    NotImplemented("Lists all messages in da warp")
  }

  def create = withAuthorisedUser { implicit user =>
    DBAction {
      NotImplemented("Displays form for crating warp message")
    }
  }

  def do_create = DBAction {
    NotImplemented("Creates new warp message")
  }


  def show(messageId: Int) = DBAction {
    NotImplemented("Show message by id")
  }

  def delete(messageId: Int) = DBAction {
    NotImplemented("Deletes message by id")
  }

  def send(messageId:Int, userId:Int) = DBAction {
    NotImplemented("Sends already created message to users")
  }

  def own = DBAction {
    NotImplemented("Shows messages that i own")
  }

}
