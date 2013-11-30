package controllers

import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import models._

import play.api.Play.current
import play.api.db.slick._
import play.api.db.slick.Config.driver.simple._
import components.Secured

case class RegistrationData(
  login: String,
  password: String,
  password2: String,
  name: String
)

object Auth extends Controller with Secured {

  val registerForm:Form[User] = Form(
    mapping(
      "login" -> nonEmptyText,
      "password" -> tuple(
        "main" -> nonEmptyText(minLength = 6),
        "confirm" ->nonEmptyText(minLength = 6)
      ).verifying(
        "Passwords should match", passwords => passwords._1 == passwords._2
      ),
      "name"  -> nonEmptyText(minLength = 3)
    )
    {
      (login, passwords, name) => User.create(login, passwords._1, name)
    }
    {
      user => Some(user.login, ("", ""), user.name)
    }
  )
  def register = withAuthorisedUser { implicit user =>
    Action { implicit request =>
      Ok(views.html.register(registerForm))
    }
  }

  def do_register = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      registerForm.bindFromRequest().fold(
        {
          formWithErrors => BadRequest(views.html.register(formWithErrors))
        },
        {
          newUser => {
            if (Users.insert(newUser) > 0)  {
              Redirect(routes.Application.index()).withSession("login" -> newUser.login)
            }
            else {
              BadRequest(views.html.register(registerForm.bindFromRequest().withGlobalError("Can't add user")))
            }
          }
        }
      )
    }
  }

  def login = withAuthorisedUser { implicit user =>
    DBAction { implicit request =>
      val loginForm = Form(
        tuple( "login" -> nonEmptyText, "password" -> nonEmptyText)
      )

      loginForm.bindFromRequest().fold(
        {
          formWithErrors =>
            val errors = formWithErrors.errors.map(x => x.key ++ " " ++ x.message ).mkString("\n")
            Redirect(routes.Application.index).flashing( "error" -> errors )
        },
        {
          case  (login, password) => {
            Query(Users).filter(_.login === login).firstOption.filter(_.checkPassword(password)).fold {
                Redirect(routes.Application.index).flashing("error" -> "No such user or wrong password")
              }
              {
                user => Redirect(routes.Warp.own).flashing("success" -> s"Weclome, ${user.name}").withSession("login"->login)
              }

          }
        }
      )
    }
  }

  def logout = Action {
    Redirect(routes.Application.index).flashing("success" -> "Successfully logout").withNewSession
  }
}
