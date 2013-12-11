#ifndef _SOCKETS_H_
#define _SOCKETS_H_
#include <iostream>
#include <cstdlib>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <thread>
#include <unistd.h>
#include <memory>

class socket_t
{
public:
	socket_t();
	~socket_t();
	bool isClosed();

protected:
	int sock;
	bool closed;
};

class client : public socket_t
{
public:
	client(int sockNumber, sockaddr clientSock);
	
	bool canRead(int timeout = 10);
	std::string receiveString();
	std::string receiveAll(int n);
	void sendStringEndl(const std::string& data);
	void sendString(const std::string& data);
	
private:
	sockaddr sclient;
};

class server : public socket_t
{
public:
	server(int port = 18360,  int numberOfClients = 5);

	std::shared_ptr<client> acceptConnection();

private:
	sockaddr_in addr;
};

#endif

