#include "strlib.hxx"
#include "sockets.h"
#include "storage.h"
#include "stego.h"
#include "sng.h"
#include "excHandler.h"

#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <iterator>
#include <cstdlib>
#include <ctime>
#include <thread>
#include <algorithm>
#include <signal.h>

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ":" << p.y;
	return os;
}

void send_list (std::shared_ptr <client> & c) {
	const std::list <std::string> & items = sng_storage::instance ()->get_all_items ();

	for (const auto & it : items)
		c->sendStringEndl (it);
}

void init_lcs (const std::string & s, const std::string & p) {
	const int m = s.length ();
	const int n = p.length ();
	int l [m + 1][n + 1];
	int i, j;

	for (i = 0; i <= m; ++ i)
	for (j = 0; j <= n; ++ j)
		l [i][j] = 0;
}

bool check_lcs (const std::string & s, const std::string & p) {
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

struct length_comparer : public std::binary_function <const std::string &, const std::string &, bool> {
	bool operator () (const std::string & l, const std::string & r) const {
		return l.length () < r.length ();
	}
};

void get_picture (std::shared_ptr <client> & c, const std::vector <std::string> & op) {
	if (op.size () < 2) {
		c->sendStringEndl ("ERROR(ARG)");
		return;
	}

	try {
		auto pic = sng_storage::instance ()->get_item (op [1]);

		auto password = pic.private_ ("PASW");
		if (! password.empty ()) {
			if (op.size () < 3) {
				c->sendStringEndl ("ERROR(PASSWORD)");
				return;
			}

			auto found = false;
			auto it = std::max_element (std::begin (op) + 2, std::end (op), length_comparer ());

			init_lcs (* it, password);
			for (it = std::begin (op) + 2; it != std::end (op); ++ it)
				if (check_lcs (* it, password)) {
					found = true;
					break;
				}

			if (! found) {
				c->sendStringEndl ("ERROR(PASSWORD)");
				return;
			}
		}

		c->sendString (pic.to_raw_string ());
	}
	catch (sng_storage::not_found_error &) {
		c->sendStringEndl ("ERROR(NOTFOUND)");
	}
	catch (sng_storage::read_error &) {
		c->sendStringEndl ("ERROR(DBREAD)");
	}
	catch (sng::parse_error &) {
		c->sendStringEndl ("ERROR(PARSE)");
	}
}

void init_time (sng & pic) {
	auto t = time (nullptr);

	auto t_ = gmtime (& t);
	pic.time (1900 + t_->tm_year, 1 + t_->tm_mon, t_->tm_mday, t_->tm_hour, t_->tm_min, t_->tm_sec);
}

void put_picture (std::shared_ptr <client> & c, const std::vector <std::string> & op) {
	try {
		sng pic (c->receiveAll ());

		switch (op.size ()) {
		case 2: {
			init_time (pic);

			auto v = stego::put (pic, op [1]);
			if (v.empty ()) {
				c->sendStringEndl ("ERROR(STEGO)");
				return;
			}

			try {
				c->sendString (sng_storage::instance ()->put_item (pic));
				c->sendStringEndl (std::string (";") + join (v, " "));
			}
			catch (sng_storage::write_error &) {
				c->sendStringEndl ("ERROR(DBWRITE)");
			}

			break;
		}

		case 3: {
			pic.private_ ("PASW", op [2]);
			pic.keyword ("flag");
			pic.text (op [1]);

			try {
				c->sendStringEndl (sng_storage::instance ()->put_item (pic));
			}
			catch (sng_storage::write_error &) {
				c->sendStringEndl ("ERROR(DBWRITE)");
			}

			break;
		}

		default:
			c->sendStringEndl ("ERROR(ARG)");
			break;
		}
	}
	catch (sng::parse_error &) {
		c->sendStringEndl ("ERROR(PARSE)");
	}
}

void client_thread (std::shared_ptr <client> c) {
	try {
		while (! c->isClosed ()) {
			auto s = c->receiveString ();
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
				c->sendStringEndl ("Unknown command");
		}
	}
	catch (excHandler &) { }
	catch (...) { }
}

int main () {
	signal (SIGPIPE, SIG_IGN);

	try {
		server s (18360, SOMAXCONN);

		while (true) {
			auto c = s.acceptConnection ();
			std::thread (client_thread, c).detach ();
		}
	}
	catch (excHandler & e) {
		std::cerr << "Socket error: " << e.getFuncName () << std::endl;
		return 1;
	}

	return 0;
}

