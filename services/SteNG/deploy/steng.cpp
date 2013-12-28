#include "strlib.hxx"
#include "sockets.h"
#include "storage.h"
#include "stego.h"
#include "sng.h"

#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <iterator>
#include <cstdlib>
#include <ctime>
#include <thread>
#include <algorithm>
#include <functional>
#include <signal.h>

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ":" << p.y;
	return os;
}

std::string int_to_string (int v) {
	std::ostringstream os;
	os << v;

	return os.str ();
}

int string_to_int (const std::string & s) {
	return std::atoi (s.c_str ());
}

void send_list (std::shared_ptr <tcp_client> & c) {
	auto items = sng_storage::instance ()->get_all_items ();

	c->send_line (int_to_string (items.size ()));
	for (const auto & it : items)
		c->send_line (it);
}

void init (const std::string & s, const std::string & p) {
	const int m = s.length ();
	const int n = p.length ();
	int l [m + 1][n + 1];
	int i, j;

	for (i = 0; i <= m; ++ i)
	for (j = 0; j <= n; ++ j)
		l [i][j] = 0;
}

bool check_psw (const std::string & s, const std::string & p) {
	const int m = s.length ();
	const int n = p.length ();
	int l [m + 1][n + 1];
	int i, j;

	for (i = 0; i < m; ++ i)
		for (j = 0; j < n; ++ j)
			if (s [i] == p [j])
				l [i + 1][j + 1] = l [i][j] + 1;
			else
				l [i + 1][j + 1] = std::max (l [i + 1][j], l [i][j + 1]);

	return 4 * l [m][n] >= 3 * n;
}

void get_picture (std::shared_ptr <tcp_client> & c, const std::vector <std::string> & op) {
	if (op.size () < 2) {
		c->send_line ("ERROR(ARG)");
		return;
	}

	try {
		auto pic = sng_storage::instance ()->get_item (op [1]);

		auto password = pic.private_ ("PASW");
		if (! password.empty ()) {
			if (op.size () < 3) {
				c->send_line ("ERROR(PASSWORD)");
				return;
			}

			struct length_comparer : public std::binary_function <const std::string &, const std::string &, bool> {
				bool operator () (const std::string & l, const std::string & r) const {
					return l.length () < r.length ();
				}
			};

			auto found = false;
			auto it = std::max_element (std::begin (op) + 2, std::end (op), length_comparer ());

			init (* it, password);
			for (it = std::begin (op) + 2; it != std::end (op); ++ it)
				if (check_psw (* it, password)) {
					found = true;
					break;
				}

			if (! found) {
				c->send_line ("ERROR(PASSWORD)");
				return;
			}
		}

		auto p = pic.to_raw_string ();
		c->send_line (int_to_string (count_lines (p)));
		c->send (p);
	}
	catch (const sng_storage::not_found_error &) {
		c->send_line ("ERROR(NOTFOUND)");
	}
	catch (const sng_storage::read_error &) {
		c->send_line ("ERROR(DBREAD)");
	}
	catch (const sng::parse_error &) {
		c->send_line ("ERROR(PARSE)");
	}
}

void init_time (sng & pic) {
	auto t = time (nullptr);

	auto t_ = gmtime (& t);
	pic.time (1900 + t_->tm_year, 1 + t_->tm_mon, t_->tm_mday, t_->tm_hour, t_->tm_min, t_->tm_sec);
}

void put_picture (std::shared_ptr <tcp_client> & c, const std::vector <std::string> & op) {
	try {
		auto s = string_to_int (c->receive_line ());
		sng pic (c->receive_lines (s));

		switch (op.size ()) {
		case 2: {
			init_time (pic);

			auto v = stego::put (pic, op [1]);
			if (v.empty ()) {
				c->send_line ("ERROR(STEGO)");
				return;
			}

			try {
				c->send (sng_storage::instance ()->put_item (pic));
				c->send_line (std::string (";") + join (v, " "));
			}
			catch (const sng_storage::write_error &) {
				c->send_line ("ERROR(DBWRITE)");
			}

			break;
		}

		case 3: {
			pic.private_ ("PASW", op [2]);
			pic.keyword ("flag");
			pic.text (op [1]);

			try {
				c->send_line (sng_storage::instance ()->put_item (pic));
			}
			catch (const sng_storage::write_error &) {
				c->send_line ("ERROR(DBWRITE)");
			}

			break;
		}

		default:
			c->send_line ("ERROR(ARG)");
			break;
		}
	}
	catch (const sng::parse_error &) {
		c->send_line ("ERROR(PARSE)");
	}
}

void client_thread (std::shared_ptr <tcp_client> c) {
	try {
		c->buffer_size (8192);
		c->read_timeout (100);

		while (c->is_alive ()) {
			auto s = c->receive_line ();
			if (s.empty ())
				break;

			auto op = split (s, ' ');
			if (op.empty ())
				continue;

			if (op [0] == "list")
				send_list (c);
			else if (op [0] == "getpic")
				get_picture (c, op);
			else if (op [0] == "putpic")
				put_picture (c, op);
			else if (op [0] == "exit")
				break;
			else
				c->send_line ("Unknown command");
		}
	}
	catch (const tcp_socket::socket_error &) {
		std::cerr << "socket error" << std::endl;
	}
	catch (...) { }
}

int main () {
	signal (SIGPIPE, SIG_IGN);

	try {
		tcp_server s (18360);

		while (true) {
			auto c = s.accept ();
			std::thread (client_thread, c).detach ();
		}
	}
	catch (const tcp_socket::socket_error &) {
		std::cerr << "Socket error" << std::endl;
		return 1;
	}

	return 0;
}

