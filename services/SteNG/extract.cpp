#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <iterator>
#include "sng.h"
#include "stego.h"

std::istream & operator >> (std::istream & is, pixel & p) {
	char c;
	is >> p.x >> c >> p.y;

	return is;
}

int main (int argc, char ** argv) {
	if (argc != 2)
		return 1;

	std::istringstream is (argv [1]);
	std::vector <pixel> v ((std::istream_iterator <pixel> (is)), std::istream_iterator <pixel> ());

	std::string s, s0;
	while (std::getline (std::cin, s0)) {
		s.append (s0);
		s.push_back ('\n');
	}

	std::cout << get (sng (s), v);

	return 0;
}
