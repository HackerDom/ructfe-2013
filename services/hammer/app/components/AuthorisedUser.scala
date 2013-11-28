package components

abstract class AuthorisedUser {
  def isAuth = true
}
object Guest extends AuthorisedUser {
  override def isAuth = false
}
