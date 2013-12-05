#include <string>
#include <list>
#include <vector>
#include <iostream>
#include <sstream>
#include <iterator>
#include <algorithm>
#include <cstdlib>
#include <thread>
#include "sockets.h"
#include "storage.h"
#include "stego.h"
#include "sng.h"

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ":" << p.y;
	return os;
}

std::vector <std::string> split (const std::string s, char delim) {
	std::istringstream is (s);
	std::vector <std::string> v;
	std::string x;

	while (std::getline (is, x, delim))
		v.push_back (x);

	return v;
}

void client_thread (client & c) {
	std::vector <std::string> op = split (c.receiveString (), ' ');
	if (op.empty ()) {
		c.sendString ("ERROR\n");
		return;
	}

	std::ostringstream os;
	
	if (op [0] == "list") {
		if (op.size () != 1) {
			c.sendString ("ERROR\n");
			return;
		}

		const std::list <std::string> & items = sng_storage::instance ()->get_all_items ();

		for (std::list <std::string>::const_iterator it = items.begin (); it != items.end (); ++ it)
			os << * it << std::endl;

		c.sendString (os.str ());
	}
	else if (op [0] == "getpic") {
		if (op.size () < 2) {
			c.sendString ("ERROR\n");
			return;
		}

		try {
			sng pic = sng_storage::instance ()->get_item (op [1]);

			std::string password = pic.private_ ("PASW");
			if (! password.empty () && (op.size () != 3 || password != op [2])) {
				c.sendString ("ERROR\n");
				return;
			}

			os << pic << std::endl;
			c.sendString (os.str ());
		}
		catch (sng_storage::not_found_exception &) {
			c.sendString ("ERROR\n");
		}
		catch (sng_storage::read_exception &) {
			c.sendString ("ERROR\n");
		}
	}
	else if (op [0] == "putpic") {
		sng pic (c.receiveAll ());

		if (op.size () == 2) {
			std::vector <pixel> v = put (pic, op [1]);
			if (v.empty ()) {
				c.sendString ("ERROR\n");
				return;
			}

			try {
				os << sng_storage::instance ()->put_item (pic) << ";";
				std::copy (v.begin (), v.end (), std::ostream_iterator <pixel> (os, " "));
				os << std::endl;

				c.sendString (os.str ());
			}
			catch (sng_storage::write_exception &) {
				c.sendString ("ERROR\n");
				return;
			}
		}
		else if (op.size () == 3) {
			pic.private_ ("PASW", op [2]);
			pic.keyword ("flag");
			pic.text (op [1]);

			try {
				os << sng_storage::instance ()->put_item (pic) << std::endl;
				c.sendString (os.str ());
			}
			catch (sng_storage::write_exception &) {
				c.sendString ("ERROR\n");
				return;
			}
		}
		else
			c.sendString ("ERROR\n");

	}
	else {
		c.sendString ("ERROR\n");
	}
}

int main () {	
	try {
		server s;

		while (true) {
			client c = s.acceptConnection ();
			std::thread (client_thread, c).detach ();
		}
	}
	catch (excHandler & e) {
		std::cerr << "ERROR: " << e.getFuncName () << std::endl;
		return 1;
	}

	return 0;
}

