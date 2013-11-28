package helpers

import views.html.helper.FieldConstructor

/**
 * Created by Last G on 22.11.13.
 */
object BootstrapHelper {
  implicit val  bootstrapFileds = FieldConstructor(views.html.bootstrap.fieldconstructor.f)
}
