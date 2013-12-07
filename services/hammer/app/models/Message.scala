package models

import components.{Guest, Chaos, AuthorisedUser}
import models._

import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._
import org.apache.commons.codec.binary.Hex
import java.sql.Timestamp
import scala.Some


object Message {
  def create(message:String)(implicit author: User): Message = {
    create(message, None)
  }
  def create(message:String, secret:Option[String])(implicit author: User): Message = {
    val now = new Timestamp(new java.util.Date().getTime())
    val pub = secret.map({crypt(message, _)}).getOrElse(message)
    Message(None, pub, secret, Chaos.makeMark(message+secret), Some(now), author.id.get)
  }

  def cipher(message: Seq[Byte], key:Seq[Byte]):Seq[Byte] = {

    message.zipWithIndex.map({case (b, i) =>
      (b ^ key(i % key.length)).toByte
    })
  }

  def crypt(message: String, key: String):String = {
    Hex.encodeHexString(cipher(message.getBytes(), key.getBytes()).toArray)
  }
  
  def decrypt(encoded: String, key:String):String = {
    new String(cipher(Hex.decodeHex(encoded.toArray), key.getBytes()).toArray)
  }
  def markFromHex(hex: String) = Hex.decodeHex(hex.to[Array])
}

case class Message(
                    id: Option[Int],
                    message: String,
                    secret: Option[String],
                    mark: Array[Byte],
                    created: Option[Timestamp],
                    author_id: Int
                    ) {

  lazy val isPublic = secret.isEmpty
  lazy val hexMark = Hex.encodeHexString(mark)

  lazy val cleanedMessage = message
  lazy val realMessage = if(isPublic) message else Message.decrypt(message, secret.get)

  val author = Query(Users).filter(_.id === this.author_id)
  val owners = Query(Users).filter(_.id === this.author_id) union Query(SentMessages).filter(_.message_id === this.id).innerJoin(Users).map({case (_, user) => user})


  def canRead(implicit user: User) = Messages.canRead.filter(_.id === id).exists
  def canSend(implicit user: User) = Messages.canSend.filter(_.id === id).exists

  def haveRead(implicit user: User) = Messages.haveRead.filter(_.id === id).exists

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

  val all = Query(Messages)
  val public = Query(Messages).filter(_.secret.isNull)

  def canRead(u: AuthorisedUser):Query[Messages.type, Message] = u match {
    case user:User => canRead(user)
    case _ => public
  }
  def canRead(implicit user: User) = canSend union public union all.innerJoin(SentMessages).filter(_._2.user_id === user.id).map(_._1)
  def canSend(implicit user: User) = all.filter(_.author_id === user.id)

  def haveRead(implicit user: User) = canRead.innerJoin(SentMessages).filter(_._2.read === true).map(_._1)
  def unread(implicit user: User) = canRead.innerJoin(SentMessages)
}