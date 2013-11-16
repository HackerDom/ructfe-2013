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
	
	void receive(std::string& data);
	void sendOut(std::string data);
	
private:
	sockaddr sclient;
};

class server : public socket_t
{
public:
	server()
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

	client acceptConnection();

private:
	sockaddr_in addr;
};

