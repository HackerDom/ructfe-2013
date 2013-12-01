#include <iostream>
#include <cstdlib>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <thread>
#include <unistd.h>
#include <memory>

#define PORT 18360
#define NUMBEROFCLIENTS 5

class socket_t
{
public:
	//~socket_t();
	//for test
	void closeSocket();

protected:
	int sock;
	const int family = AF_INET;
	const int address = htonl(INADDR_ANY);
	const int port = htons(PORT);
	const int numberOfClients = NUMBEROFCLIENTS;
};

class client : public socket_t
{
public:
	client(int sockNumber, sockaddr clientSock);
	
	bool needRead();
	std::string receiveString();
	std::string receiveAll();
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
