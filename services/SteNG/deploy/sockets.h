#ifndef _SOCKETS_H_
#define _SOCKETS_H_

#include <string>
#include <memory>
#include <sys/socket.h>

class tcp_socket {
private:
	tcp_socket (const tcp_socket &);
	tcp_socket & operator = (const tcp_socket &);

protected:
	int sock;
	bool closed;

	tcp_socket (int sock);

public:
	class socket_error { };

	bool is_alive () const throw ();
	virtual void close () throw (socket_error);

	virtual ~tcp_socket ();
};

class tcp_client : public tcp_socket {
	int read_to;
	int write_to;

	char * buffer;
	size_t buf_pos;
	size_t buf_end;
	size_t buf_size;

	void poll_wait (int events, int timeout);
	size_t read_sock (char * buf, size_t n, int timeout);
	size_t write_sock (const char * buf, size_t n, int timeout);

	bool receive (char & c);

public:
	tcp_client (int sock);

	std::string receive (int n) throw (tcp_socket::socket_error);
	std::string receive_line (char delim = '\n') throw (tcp_socket::socket_error);
	std::string receive_lines (int n, char delim = '\n') throw (tcp_socket::socket_error);

	int read_timeout () const throw ();
	void read_timeout (int timeout) throw ();

	int write_timeout () const throw ();
	void write_timeout (int timeout) throw ();

	size_t buffer_size () const throw ();
	void buffer_size (size_t size) throw ();

	void send (const std::string & data) throw (tcp_socket::socket_error);
	void send_line (const std::string & data) throw (tcp_socket::socket_error);

	virtual ~tcp_client ();
};

class tcp_server : public tcp_socket {
public:
	tcp_server (int port, int max_clients = SOMAXCONN);

	std::shared_ptr <tcp_client> accept ();
};

#endif

