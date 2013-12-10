#include "sng.h"
#include "stego.h"
#include "strlib.hxx"

#include <iostream>
#include <sstream>
#include <algorithm>
#include <string>
#include <vector>
#include <iterator>
#include <set>
#include <cstdlib>
#include <ctime>

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ':' << p.y;
	return os;
}

void init_time (sng & pic) {
        auto t = time (nullptr);

        auto t_ = gmtime (& t);
        pic.time (1900 + t_->tm_year, 1 + t_->tm_mon, t_->tm_mday, t_->tm_hour, t_->tm_min, t_->tm_sec);
}

time_t parse_time (const sng & pic) {
	std::istringstream is (pic.time ());

	tm t_;
	char c;
	is >> t_.tm_mon >> c >> t_.tm_mday >> c >> t_.tm_year >> t_.tm_hour >> c >> t_.tm_min >> c >> t_.tm_sec;

	t_.tm_year -= 1900;
	t_.tm_mon -= 1;
	t_.tm_hour += 6;

	return std::mktime (& t_);
}

int main (int argc, char ** argv) {
	if (argc > 2)
		return 1;

	std::string s, s0;
	while (std::getline (std::cin, s0)) {
		s.append (s0);
		s.push_back ('\n');
	}

	sng pic (s);

	if (argc == 1) {
		if (! pic.private_ ("PASW").empty ()) {
			std::cout << pic.text () << std::endl;
			return 0;
		}

		std::srand (parse_time (pic));

		std::set <pixel> ps;
		pixel p;

		std::vector <pixel> v;
		for (auto i = 0; i < 32; ++ i) {
			do {
				p.x = rand () % pic.width ();
				p.y = rand () % pic.height ();
			}
			while (ps.count (p));

			v.push_back (p);
		}

		std::cout << stego::get (pic, v) << std::endl;
	}
	else {
		init_time (pic);
		auto v = stego::put (pic, argv [1]);

		std::cout << pic.to_raw_string ();

		std::cerr << join (v, " ");
	}

	return 0;
}

