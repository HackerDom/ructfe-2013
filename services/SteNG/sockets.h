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
	//~socket_t();

	bool allOk();

	//for test
	void closeSocket();

protected:
	int sock;
	int errors;
	const int family = AF_INET;
	const int address = htonl(INADDR_ANY);
	const int port = htons(18360);
	const int numberOfClients = 5;
};

class client : public socket_t
{
public:
	client(int sockNumber, sockaddr clientSock);
	
	std::string receiveString();
	void sendString(std::string data);
	
private:
	sockaddr sclient;
};

class server : public socket_t
{
public:
	server();

	client acceptConnection();

private:
	sockaddr_in addr;
};
