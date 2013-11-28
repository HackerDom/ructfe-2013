package models

import components.Chaos
import models._

import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._
import java.sql.Timestamp



object Message {
  def create(message:String)(implicit author: User): Message = {
    create(message, None)
  }
  def create(message:String, secret:Option[String])(implicit author: User): Message = {
    val now = new Timestamp(new java.util.Date().getTime())
    Message(None, message, secret, Chaos.makeMark(message+secret), Some(now), author.id.get)
  }
}

case class Message(
                    id: Option[Int],
                    message: String,
                    secret: Option[String],
                    mark: Array[Byte],
                    created: Option[Timestamp],
                    author_id: Int
                    ) {

}


object Messages extends Table[Message]("MESSAGES") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def message = column[String]("MESSAGE", O.NotNull)
  def secret  = column[Option[String]]("SECRET", O.Nullable)
  def mark    = column[Array[Byte]]("MARK", O.NotNull)
  def created = column[Timestamp]("CREATED", O.NotNull)
  def author_id = column[Int]("AUTHOR_ID", O.NotNull)

  def author = foreignKey("AUTHOR_FK", author_id, Users)(_.id)

  def * = id.? ~ message ~ secret ~ mark ~ created.? ~ author_id <> (Message.apply _, Message.unapply _)

}