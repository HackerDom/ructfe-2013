#include "sockets.h"
#include "excHandler.h"

socket_t::socket_t() : closed(false)
{}

socket_t::~socket_t()
{
	closed = true;
	close(sock);
}

bool socket_t::isClosed()
{
	return closed;
}

server::server(int port, int numberOfClients)
{
	if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)
		throw excHandler("socket"); 
	
	int on = 1;
	if(setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on ,sizeof(on)) == -1)
		throw excHandler("setsockopt");

        memset(&addr, 0, sizeof(sockaddr_in));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons(port);

        if (bind(sock, (sockaddr *) &addr, sizeof(sockaddr_in)) == -1)
		throw excHandler("bind");

        if (listen(sock, numberOfClients) == -1)
		throw excHandler("listen");
}

std::shared_ptr<client> server::acceptConnection()
{
	sockaddr clientAddr;
	memset(&clientAddr, 0, sizeof(sockaddr));
	socklen_t addrLen = sizeof(sockaddr);
	int client_sock;

	if ((client_sock = accept(sock, &clientAddr, &addrLen)) == -1)
		excHandler("accept");

	return std::shared_ptr<client>(new client(client_sock, clientAddr));
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
		{
			if ((received == 0) && (canRead()))
				closed = true;
			return data;
		}

		data += letter;
	}

	throw excHandler("recv");
}

std::string client::receiveAll()
{
	char buffer[1025];
	int received;
	std::string data;

	while (canRead())
	{
		if ((received = recv(sock, buffer, 1024, 0)) == -1)
			throw excHandler("recv");
		
		if (received == 0)
		{
			if (data.length() == 0)
				closed = true;

			return data;
		}
		
		buffer[received] = '\0';
		data += buffer;
	}
		
	return data;
}

bool client::canRead(int timeout)
{
	fd_set readset;
        FD_ZERO(&readset);
	FD_SET(sock, &readset);
	timeval  stimeout;
        stimeout.tv_sec = timeout;
        stimeout.tv_usec = 0;

	if (select(1+sock, &readset, NULL, NULL, &stimeout) == -1)
		throw excHandler("select");
	
	if (FD_ISSET(sock, &readset))
		return true;

	return false;
}

void client::sendStringEndl(const std::string & data)
{
	sendString(data);
	sendString(std::string("\n"));
}

void client::sendString(const std::string & data)
{
	int c, offset = 0, size = data.length();
	const char* current = data.c_str();

	while (offset < size)
	{
		if ((c = send(sock, &current[offset], size-offset, 0)) == -1)
			throw excHandler("send");
		offset += c;
	}
}
