package models



import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._

import org.apache.commons.codec.digest.DigestUtils
import scala.util.Random
import components.AuthorisedUser


object User {
  def create(login: String, password: String, name: String): User = {
    val salt = Random.nextString(16)
    val hashedPassword = hashPassword(salt, password)
    User(None, login, hashedPassword, salt, name)
  }

  def hashPassword(salt: String, password: String) =
    DigestUtils.sha512Hex(salt + password)
}

case class User( id: Option[Int],
                 login: String,
                 password: String,
                 salt: String,
                 name: String
                 ) extends AuthorisedUser {
  def checkPassword(password: String ) =
    User.hashPassword(salt, password) == this.password
}

object Users extends Table[User]("USERS") {
  def id = column[Int]("ID", O.PrimaryKey, O.AutoInc)
  def login = column[String]("LOGIN")
  def password = column[String]("PASSWORD", O.NotNull)
  def salt = column[String]("SALT", O.NotNull)
  def name = column[String]("NAME", O.NotNull)

  def * = id.? ~ login ~ password ~ salt ~ name <>
        (User.apply _, User.unapply _)

  def all = Query(Users)
  def haveNo(message: Message) = for {
    (user, msg) <- Users.all.leftJoin(SentMessages).on({(u, m) => (u.id === m.user_id).&&(m.message_id === message.id)}).filter(_._2.message_id.isNull)
  } yield user
  def byId(id: Int) = all.filter(_.id === id)


}
