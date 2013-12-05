import time
import BaseHTTPServer

from Crypto.Cipher import AES

HOST_NAME = '0.0.0.0'
PORT_NUMBER = 4369

class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    messages = {}

    def do_GET(self):
        try:
            if self.path == "/list":
                result = list(self)
            elif self.path == "/get":
                result = get(self)
            elif self.path == "/put":
                result = put(self)
            else:
                self.send_response(404)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                return

            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()

            self.wfile.write(result)

        except Exception as e:
            self.send_response(500)
            self.send_header("Content-type", "text/plain")
            self.end_headers()

            self.wfile.write("Exception!\n")
            self.wfile.write(e) 
            return 



    def list(self):
        return self.path

    def get(self):
        return self.path

    def put(self):
        with open("/proc/random", "rb") as f:
            key = f.read(32)
        return self.path

class CryptoHelper:

    IV = 'S3cr3t_IV TRY_ME'

    @staticmethod
    def encrypt(message, key):
        message = CryptoHelper.padPKCS7(message)
        aes = AES.new(key, AES.MODE_CBC, CryptoHelper.IV)
        ciphertext = aes.encrypt(message)
        return ciphertext

    @staticmethod
    def padPKCS7(message):
        length = 16 - (len(message) % 16)
        message += chr(length)*length
        return message

    @staticmethod
    def decrypt(ciphertext, key):
        aes = AES.new(key, AES.MODE_CBC, CryptoHelper.IV)
        message = aes.decrypt(ciphertext)
        message = CryptoHelper.unpadPKCS7(message)
        return message

    @staticmethod
    def unpadPKCS7(message):
        if len(message)%16 or not message:
            raise ValueError("Invalid message len")
        padlen = ord(message[-1])
        if padlen > 16:
            raise ValueError("Invalid padding")
        for i in range(padlen):
            if ord(message[-(i + 1)]) != padlen:
                raise ValueError("Invalid padding")
        return message[:-padlen]

if __name__ == '__main__':
    httpd = BaseHTTPServer.HTTPServer((HOST_NAME, PORT_NUMBER), MyHandler)
    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)
