#include "sockets.h"

void connectionHandler(client connection)
{
        std::string text;
        connection.receiveString(text);
        std::cout << text << std::endl;
        connection.sendString(text);
	//for test
	connection.closeSocket();
}

int main()
{
        server serv;
        if (!serv.allOk())
        {
                std::cout << "class server constructor return error" << std::endl;
                return -1;
        }

        while (serv.allOk())
        {
                client currentConnection = serv.acceptConnection();
                std::thread (connectionHandler, currentConnection).detach();
        }

        return 0;
}

