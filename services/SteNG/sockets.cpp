#include "sockets.h"
#include "excHandler.h"

void socket_t::closeSocket()
{
	if (close(sock) == -1)
        {
                std::cout << "Error on close() func call, error: " << errno << std::endl;
                
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
		throw excHandler("socket"); 

        memset(&addr, 0, sizeof(sockaddr_in));
        addr.sin_family = family;
        addr.sin_addr.s_addr = address;
        addr.sin_port = port;

        if (bind(sock, (sockaddr *) &addr, sizeof(sockaddr_in)) == -1)
	{
		close(sock);
		throw excHandler("bind");
	}

        if (listen(sock, numberOfClients) == -1)
	{
		close(sock);
		throw excHandler("listen");        
        }
}

client server::acceptConnection()
{
	sockaddr clientAddr;
	memset(&clientAddr, 0, sizeof(sockaddr));
	socklen_t addrLen = sizeof(sockaddr);
	int client_sock;

	if ((client_sock = accept(sock, &clientAddr, &addrLen)) == -1)
		excHandler("accept");

	return client(client_sock, clientAddr);
}

client::client(int sockNumber, sockaddr clientSock) : sclient(clientSock)
{
	sock = sockNumber;
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

	throw excHandler("recv");
}

std::string client::receiveAll()
{
	char buffer[1024];
	memset(&buffer, 0, 1024);
	int received;
	std::string data;

	while (needRead())
	{
		if ((received = recv(sock, &buffer, 1024, 0)) == -1)
			throw excHandler("recv");
		
		if (received == 0)
			return data;
		
		data += buffer;
		memset(&buffer, 0, 1024);
	}
		
	return data;
}

bool client::needRead()
{
	fd_set readset;
        FD_ZERO(&readset);
	FD_SET(sock, &readset);
	timeval timeout;
        timeout.tv_sec = 1;
        timeout.tv_usec = 5;

	if (select(1+sock, &readset, NULL, NULL, &timeout) == -1)
	{
		close(sock);
		throw excHandler("select");
	}
			
	if (FD_ISSET(sock, &readset))
		return true;

	return false;
}

void client::sendString(std::string data)
{
	if (send(sock, data.c_str(), data.size(), 0) == -1)
	{
		close(sock);
		throw excHandler("send");
	}
}