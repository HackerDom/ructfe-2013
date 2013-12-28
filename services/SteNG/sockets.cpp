#include "sockets.h"

#include <sys/types.h>
#include <poll.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <cstring>
#include <iostream>
#include <cstdlib>

tcp_socket::tcp_socket (int sock) :
	sock (sock),
	closed (false) { }

bool tcp_socket::is_alive () const throw () {
	return ! closed;
}

void tcp_socket::close () throw (socket_error) {
	if (closed)
		return;

	if (! shutdown (sock, SHUT_RDWR)) {
		closed = true;
		return;
	}

	throw socket_error ();
}

tcp_socket::~tcp_socket () {
	close ();
}


tcp_client::tcp_client (int sock) :
	tcp_socket (sock),
	read_to (1000),
	write_to (1000),
	buf_pos (0),
	buf_end (0),
	buf_size (1024) {
	buffer = static_cast <char *> (std::malloc (buf_size * sizeof (char)));
}

void tcp_client::poll_wait (int events, int timeout) {
	pollfd fds;

	fds.fd = sock;
	fds.events = events;
	fds.revents = 0;

	if (poll (& fds, 1, timeout) < 0)
		throw tcp_socket::socket_error ();
}

size_t tcp_client::read_sock (char * buf, size_t n, int timeout) {
	poll_wait (POLLERR | POLLIN, timeout);
	size_t pos = 0;

	while (pos < n) {
		ssize_t res = read (sock, buf + pos, n - pos);

		switch (res) {
			case -1:
				if (errno == EINTR || errno == EAGAIN) {
					if (pos)
						return pos;

					continue;
				}

				return 0;

			case 0:
				return pos;

			default:
				pos += res;
		}
	}

	return pos;
}

bool tcp_client::receive (char & c) {
	if (buf_pos == buf_end) {
		if (closed)
			throw tcp_socket::socket_error ();
	
		buf_pos = 0;
		buf_end = read_sock (buffer, buf_size, read_to);

		if (! buf_end) {
			closed = true;
			return false;
		}
	}

	c = buffer [buf_pos ++];

	return true;
}

std::string tcp_client::receive (int n) throw (tcp_socket::socket_error) {
	std::string data;

	char c;
	for (int i = 0; i < n; ++ i)
		if (receive (c))
			data.push_back (c);
		else
			return data;

	return data;
}

std::string tcp_client::receive_line (char delim) throw (tcp_socket::socket_error) {
	std::string data;

	char c;
	while (receive (c)) {
		if (c == delim)
			return data;

		data.push_back (c);
	}

	return data;
}

std::string tcp_client::receive_lines (int n, char delim) throw (tcp_socket::socket_error) {
	std::string data;

	char c;
	int i = 0;
	while (i < n) {
		if (! receive (c))
			return data;

		if (c == delim)
			++ i;

		data.push_back (c);
	}

	return data;
}

int tcp_client::read_timeout () const throw () {
	return read_to;
}

void tcp_client::read_timeout (int timeout) throw () {
	read_to = timeout;
}

int tcp_client::write_timeout () const throw () {
	return write_to;
}

void tcp_client::write_timeout (int timeout) throw () {
	write_to = timeout;
}

size_t tcp_client::buffer_size () const throw () {
	return buf_size;
}

void tcp_client::buffer_size (size_t size) throw () {
	if (size <= buf_size)
		return;

	char * new_buffer = static_cast <char *> (std::realloc (buffer, size));
	if (! new_buffer)
		return;

	buffer = new_buffer;
	buf_size = size;
}

size_t tcp_client::write_sock (const char * buf, size_t n, int timeout) {
	size_t pos = 0;

	while (pos < n) {
		poll_wait (POLLOUT | POLLERR, timeout);
		ssize_t res = write (sock, buf + pos, n - pos);

		switch (res) {
			case -1:
				if (errno == EINTR || errno == EAGAIN)
					continue;

				return 0;

			case 0:
				return pos;

			default:
				pos += res;
		}
	}

	return pos;
}

void tcp_client::send (const std::string & data) throw (tcp_socket::socket_error) {
	if (closed)
		return;

	const char * buf = data.c_str ();
	size_t n = data.length ();

	if (! write_sock (buf, n, write_to))
		closed = true;
}

void tcp_client::send_line (const std::string & data) throw (tcp_socket::socket_error) {
	send (data);
	send ("\n");
}

tcp_client::~tcp_client () {
	std::free (buffer);
}


tcp_server::tcp_server (int port, int max_clients)
	: tcp_socket (0) {
	sock = socket (AF_INET, SOCK_STREAM, 0);
	if (sock == -1)
		throw tcp_socket::socket_error ();

	int on = 1;
	if (setsockopt (sock, SOL_SOCKET, SO_REUSEADDR, & on, sizeof (on)) == -1)
		throw tcp_socket::socket_error ();

	sockaddr_in addr;
	std::memset (& addr, 0, sizeof (sockaddr_in));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl (INADDR_ANY);
	addr.sin_port = htons (port);

	if (bind (sock, reinterpret_cast <sockaddr *> (& addr), sizeof (sockaddr_in)) == -1)
		throw tcp_socket::socket_error ();

	if (listen (sock, max_clients) == -1)
		throw tcp_socket::socket_error ();
}

std::shared_ptr <tcp_client> tcp_server::accept () {
	sockaddr client;
	std::memset (& client, 0, sizeof (sockaddr));

	socklen_t addr_len = sizeof (sockaddr);

	int client_sock = ::accept (sock, & client, & addr_len);
	if (client_sock == -1)
		throw tcp_socket::socket_error ();

	int flags = fcntl (client_sock, F_GETFL);
	fcntl (client_sock, F_SETFL, flags | O_NONBLOCK);

	return std::make_shared <tcp_client> (client_sock);
}

