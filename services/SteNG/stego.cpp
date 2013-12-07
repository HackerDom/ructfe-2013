#include "stego.h"

#include <set>
#include <cstdlib>
#include <ctime>

bool operator < (const pixel & lhs, const pixel & rhs) {
	if (lhs.x < rhs.x) return true;
	if (lhs.x > rhs.x) return false;
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
	std::srand (time (NULL));

	std::vector <pixel> r;
	std::set <pixel> x;

	long w = pic.width ();
	long h = pic.height ();

	if ((s.length () << 1) > w * h)
		return std::vector <pixel> ();

	for (std::string::const_iterator it = s.begin (); it != s.end (); ++ it) {
		pixel p = get_next (x, w, h);
		x.insert (p);

		pcolor cl = pic.pixel (p.x, p.y);
		unsigned char c = * it;
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

	for (std::vector <pixel>::const_iterator it = vec.begin (); it != vec.end (); ++ it) {
		pcolor x = pic.pixel (it->x, it->y);

		r.push_back (((x.r & ((1 << 2) - 1)) << ((1 << 2) | (1 << 1))) | ((x.g & ((1 << 2) - 1)) << (1 << 2)) | (x.b & ((1 << 4) - 1)));
	}
	
	return r;
}

