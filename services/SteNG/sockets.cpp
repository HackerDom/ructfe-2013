#include "sockets.h"

bool socket_t::allOk()
{
	return (errors == 0);
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

void client::receive(std::string& data)
{
	char* buffer;
	buffer = new char [512];
	memset(buffer, 0, 512);
	const int len = 512;

	if (recv(sock, buffer, len, 0) == -1)
	{
		std::cout << "Error on recv() func call, error: " << errno << std::endl;
		if (close(sock) == -1)
			std::cout << "Error on close() func call, error: " << errno << std::endl;
		errors = -22;
		return;
	}

	data = std::string(buffer);

	return;
}

void client::sendOut(std::string data)
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
