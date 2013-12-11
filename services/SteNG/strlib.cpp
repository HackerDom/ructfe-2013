#include "strlib.hxx"

#include <sstream>
#include <algorithm>
#include <functional>
#include <iterator>
#include <cstring>

std::vector <std::string> split (const std::string & s, char delim) {
	std::istringstream is (s);
	std::vector <std::string> v;
	std::string x;

	while (std::getline (is, x, delim))
		v.push_back (x);

	return v;
}

std::string replace (const std::string & s, const char * chars, char symbol) {
	std::string r;
	std::replace_copy_if (std::begin (s), std::end (s), std::back_inserter (r),
		std::bind1st (std::ptr_fun <const char *, int, const char *> (strchr), chars), symbol);

	return r;
}

int count_lines (const std::string & s) {
	return std::count (std::begin (s), std::end (s), '\n');
}

