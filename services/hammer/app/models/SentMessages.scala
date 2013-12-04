package models

import components.Chaos
import models._

import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._
import java.sql.Timestamp


object SentMessage {
  def create(to: User, message: Message, read: Boolean = false) = {
    SentMessage(to.id.get, message.id.get, read)
  }
}

case class SentMessage(
    //id: Int,
    user_id: Int,
    message_id: Int,
    read: Boolean = false
  )

object SentMessages extends Table[SentMessage]("MESSAGES_TO_USERS"){
  //def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def user_id = column[Int]("USER_ID", O.NotNull)
  def message_id = column[Int]("MESSAGE_ID", O.NotNull)
  def read = column[Boolean]("READ", O.NotNull)

  def user = foreignKey("USER_FK", user_id, Users)(_.id)
  def message = foreignKey("MESSAGE_FK", message_id, Messages)(_.id)

  def x = primaryKey("SENTMESSAGES_PK", (user_id, message_id))

  def * = user_id ~ message_id ~ read <> (SentMessage.apply _, SentMessage.unapply _)
}
