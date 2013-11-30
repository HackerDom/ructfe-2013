#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <iterator>
#include "sng.h"
#include "stego.h"

std::ostream & operator << (std::ostream & os, const pixel & p) {
	os << p.x << ":" << p.y;
	return os;
}

int main (int argc, char ** argv) {
	if (argc == 1)
		return 0;

	std::ifstream is (argv [1]);
	std::string s, s0;
	while (std::getline (is, s0))
		s += (s0 + "\n");
	is.close ();

	sng pic (s);
	std::vector <pixel> v = put (pic, argv [2]);

	std::cout << "< ";
	std::copy (v.begin (), v.end (), std::ostream_iterator <pixel> (std::cout, " "));
	std::cout << ">" << std::endl;

	std::string t = get (pic, v);
	std::cout << ":: '" << t << "'" << std::endl;

	return 0;
}

