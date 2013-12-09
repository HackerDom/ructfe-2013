#include "stego.h"

#include <set>
#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <functional>
#include <iterator>

bool operator < (const pixel & lhs, const pixel & rhs) {
	if (lhs.x < rhs.x)
		return true;

	if (lhs.x > rhs.x)
		return false;

	return lhs.y < rhs.y;
}

pixel get_next (const std::set <pixel> & old, long w, long h) {
	pixel p;
	do {
		p.x = rand () % w;
		p.y = rand () % h;
	}
	while (old.count (p));

	return p;
}

std::vector <pixel> stego::put (sng & pic, const std::string & s) {
	std::srand (time (nullptr));

	std::vector <pixel> r;
	std::set <pixel> x;

	auto w = pic.width ();
	auto h = pic.height ();

	if ((s.length () << 1) > w * h)
		return std::vector <pixel> ();

	for (const auto & it : s) {
		pixel p = get_next (x, w, h);
		x.insert (p);

		pcolor cl = pic.pixel (p.x, p.y);
		const unsigned char c = it;
		cl.r = (cl.r & ~((1 << 2) - 1)) | ((c >> ((1 << 2) | (1 << 1))) & ((1 << 2) - 1));
		cl.g = (cl.g & ~((1 << 2) - 1)) | ((c >> (1 << 2)) & ((1 << 2) - 1));
		cl.b = (cl.b & ~((1 << 4) - 1)) | (c & ((1 << 4) - 1));

		pic.pixel (p.x, p.y, cl);
		r.push_back (p);
	}

	return r;
}

std::string stego::get (const sng & pic, const std::vector <pixel> & vec) {
	std::string r;
	std::transform (std::begin (vec), std::end (vec), std::back_inserter (r), [&](pixel p) -> char {
		pcolor x = pic.pixel (p.x, p.y);
		return (((x.r & ((1 << 2) - 1)) << ((1 << 2) | (1 << 1))) | ((x.g & ((1 << 2) - 1)) << (1 << 2)) | (x.b & ((1 << 4) - 1)));
	});

	return r;
}

