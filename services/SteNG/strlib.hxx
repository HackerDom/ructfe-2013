#ifndef _STRLIB_HXX_
#define _STRLIB_HXX_

#include <string>
#include <vector>
#include <sstream>
#include <iterator>

std::vector <std::string> split (const std::string & s, char delim);

template <typename T>
std::string join (typename T::const_iterator begin, typename T::const_iterator end, const std::string & delim) {
	std::ostringstream os;

	if (begin != end)
		os << * begin ++;

	while (begin != end)
		os << delim << * begin ++;

	return os.str ();
}

template <typename T>
std::string join (const T & cont, const std::string & delim) {
	return join <T> (std::begin (cont), std::end (cont), delim);
}

std::string replace (const std::string & s, const char * chars, char symbol);

int count_lines (const std::string & s);

#endif
