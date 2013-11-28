package models

import scala.slick.lifted._
import play.api.db.slick.Config.driver.simple._
import org.apache.commons.codec.digest.DigestUtils
import scala.util.Random
import components.AuthorisedUser

/**
 * Created by Last G on 21.11.13.
 */

object User {
  def newUser(login: String, password: String, name: String): User = {
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

}
