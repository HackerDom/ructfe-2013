package helpers

import views.html.helper.FieldConstructor

object BootstrapHelper {
  implicit val  bootstrapFileds = FieldConstructor(views.html.bootstrap.fieldconstructor.f)
}
