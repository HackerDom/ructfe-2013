#include "sockets.h"

bool socket_t::allOk()
{
	return (errors == 0);
}

void socket_t::closeSocket()
{
	if (close(sock) == -1)
        {
                std::cout << "Error on close() func call, error: " << errno << std::endl;
                errors = -1;
        }
}
/*
socket_t::~socket_t()
{
	if (close(sock) == -1)
	{
		std::cout << "Error on close() func call, error: " << errno << std::endl;
		errors = -1;
	}
}
*/
server::server()
{
	if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        {
        	std::cout << "Error on socket() func call, error: " << errno << std::endl;
                errors = -11;
        }
        else
                errors = 0;

        memset(&addr, 0, sizeof(sockaddr_in));
        addr.sin_family = family;
        addr.sin_addr.s_addr = address;
        addr.sin_port = port;

        if (bind(sock, (sockaddr *) &addr, sizeof(sockaddr_in)) == -1)
        {
        	std::cout << "Error on bind() func call, error: " << errno << std::endl;
                if (close(sock) == -1)
                	std::cout << "Error on close() func call, error: " << errno << std::endl;
        	errors = -12;
        }

        if (listen(sock, numberOfClients) == -1)
        {
        	std::cout << "Error on listen() func call, error: " << errno << std::endl;
                if (close(sock) == -1)
                	std::cout << "Error on close() func call, error: " << errno << std::endl;
		errors = -13;
        }
}

client server::acceptConnection()
{
	sockaddr clientAddr;
	memset(&clientAddr, 0, sizeof(sockaddr));
	socklen_t addrLen = sizeof(sockaddr);
	int client_sock;

	if ((client_sock = accept(sock, &clientAddr, &addrLen)) == -1)
	{
		std::cout << "Error on accept() func call, error: " << errno << std::endl;
		errors = -14;
	}

	return client(client_sock, clientAddr);
}

client::client(int sockNumber, sockaddr clientSock)
{
	sock = sockNumber;
	sclient = clientSock;

	if (sock == -1)
	{
		std::cout << "Error on accept() func call, error: " << errno << std::endl;
		errors = -21;
	}
	else
		errors = 0;
}

std::string client::receiveString()
{
	char letter;
	int received;
	std::string data;	

	while ((received = recv(sock, &letter, 1, 0)) != -1)
	{
		if ((letter == '\n') || (received == 0))
			return data;

		data += letter;
	}

	std::cout << "Error on recv() func call, error: " << errno << std::endl;
	return data;
}

void client::sendString(std::string data)
{
	if (send(sock, data.c_str(), data.size(), 0) == -1)
	{
		std::cout << "Error on send() func call, error: " << errno << std::endl;
		if (close(sock) == -1)
			std::cout << "Error on close() func call, error: " << errno << std::endl;
		errors = -23;
	}

	return;
}
