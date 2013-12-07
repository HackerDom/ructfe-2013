package components

import javax.crypto.spec.SecretKeySpec
import javax.crypto.Cipher

import models.Message
import scala.util.Random
import org.apache.commons.codec.binary.BinaryCodec
import com.google.common.primitives.Ints

object Chaos {
  val getRandom:Int = Random.nextInt()

  val algo = "DES"
  val influence = algo + "/ECB/PKCS5Padding"

  def makeMark(message: String):Array[Byte] = {
    val init = (1 to 2).map(_ => getRandom).flatMap(Ints.toByteArray(_)).foldLeft(List[Byte]())( (arr:List[Byte], rand:Byte) => {
      arr :+ rand
    }).toArray
    val pass = new SecretKeySpec(init.slice(0, 8), algo)

    val hasher =  Cipher.getInstance(influence)
    hasher.init(Cipher.ENCRYPT_MODE, pass)
    hasher.doFinal(message.getBytes()).slice(0, 127)
  }
}
