#include <string>
#include <list>
#include <vector>
#include <iostream>
#include <sstream>
#include <iterator>
#include <algorithm>
#include <cstdlib>
#include <ctime>
#include <thread>
#include "sockets.h"
#include "storage.h"
#include "stego.h"
#include "sng.h"
#include "excHandler.h"

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ":" << p.y;
	return os;
}

std::vector <std::string> split (const std::string & s, char delim) {
	std::istringstream is (s);
	std::vector <std::string> v;
	std::string x;

	while (std::getline (is, x, delim))
		v.push_back (x);

	return v;
}

void send_list (std::shared_ptr <client> & c) {
	const std::list <std::string> & items = sng_storage::instance ()->get_all_items ();

	for (std::list <std::string>::const_iterator it = items.begin (); it != items.end (); ++ it)
		c->sendStringEndl (* it);
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
		sng pic = sng_storage::instance ()->get_item (op [1]);

		std::string password = pic.private_ ("PASW");
		if (! password.empty () && op.size () < 3) {
			c->sendStringEndl ("ERROR(PASSWORD)");
			return;
		}

		bool found = false;
		std::vector <std::string>::const_iterator it = std::max_element (op.begin () + 2, op.end (), length_comparer ());

		init_lcs (* it, password);
		for (it = op.begin () + 2; it != op.end (); ++ it)
			if (check_lcs (* it, password)) {
				found = true;
				break;
			}

		if (! found) {
			c->sendStringEndl ("ERROR(PASSWORD)");
			return;
		}

		std::ostringstream os;
		os << pic;

		c->sendString (os.str ());
	}
	catch (sng_storage::not_found_exception &) {
		c->sendStringEndl ("ERROR(NOTFOUND)");
	}
	catch (sng_storage::read_exception &) {
		c->sendStringEndl ("ERROR(DBREAD)");
	}
}

void init_time (sng & pic) {
	time_t t = time (NULL);

	struct tm * t_ = gmtime (& t);
	pic.time (t_->tm_year, t_->tm_mon, t_->tm_mday - 1, t_->tm_hour, t_->tm_min, t_->tm_sec);
}

void put_picture (std::shared_ptr <client> & c, const std::vector <std::string> & op) {
	sng pic (c->receiveAll ());

	switch (op.size ()) {
	case 2: {
		init_time (pic);

		std::vector <pixel> v = stego::put (pic, op [1]);
		if (v.empty ()) {
			c->sendStringEndl ("ERROR(STEGO)");
			return;
		}

		try {
			std::ostringstream os;

			os << sng_storage::instance ()->put_item (pic) << ";";
			std::copy (v.begin (), v.end (), std::ostream_iterator <pixel> (os, " "));
			os << std::endl;

			c->sendString (os.str ());
		}
		catch (sng_storage::write_exception &) {
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
		catch (sng_storage::write_exception &) {
			c->sendStringEndl ("ERROR(DBWRITE)");
		}

		break;
	}

	default:
		c->sendStringEndl ("ERROR(ARG)");
		break;
	}
}

void client_thread (std::shared_ptr <client> c) {
	try {
		while (! c->isClosed ()) {
			std::string s = c->receiveString ();
			if (s.empty ())
				break;

			std::vector <std::string> op = split (s, ' ');
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
	catch (...) { }
}

int main () {	
	try {
		server s;

		while (true) {
			std::shared_ptr <client> c = s.acceptConnection ();
			std::thread (client_thread, c).detach ();
		}
	}
	catch (excHandler & e) {
		std::cerr << "ERROR: " << e.getFuncName () << std::endl;
		return 1;
	}

	return 0;
}

