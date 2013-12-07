#include <iostream>
#include <sstream>
#include <algorithm>
#include <string>
#include <vector>
#include <iterator>
#include "sng.h"
#include "stego.h"

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ':' << p.y;
	return os;
}

int main (int argc, char ** argv) {
	if (argc != 2)
		return 1;

	std::string s, s0;
	while (std::getline (std::cin, s0)) {
		s.append (s0);
		s.push_back ('\n');
	}

	sng pic (s);
	std::vector <pixel> v = stego::put (pic, argv [1]);

	std::ostringstream os;
	os << pic;
	std::cout << os.str ();

	std::copy (v.begin (), v.end (), std::ostream_iterator <pixel> (std::cerr, " "));

	return 0;
}
