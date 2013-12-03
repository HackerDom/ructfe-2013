#include "stego.h"

#include <set>

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

std::vector <pixel> put (sng & pic, const std::string & s) {
	std::vector <pixel> r;
	std::set <pixel> x;

	long w = pic.width ();
	long h = pic.height ();

	if ((s.length () << 2) > w * h)
		return std::vector <pixel> ();

	for (std::string::const_iterator it = s.begin (); it != s.end (); ++ it) {
		pixel p1 = get_next (x, w, h); x.insert (p1);
		pixel p2 = get_next (x, w, h); x.insert (p2);

		pcolor c1 = pic.pixel (p1.x, p1.y);
		char c = (* it) >> 4;
		c1.r = (c1.r & ~1) | ((c >> 3) & 1);
		c1.g = (c1.g & ~1) | ((c >> 2) & 1);
		c1.b = (c1.b & ~3) | (c & 3);
		pic.pixel (p1.x, p1.y, c1);

		pcolor c2 = pic.pixel (p2.x, p2.y);
		c = (* it) & ((1 << 4) - 1);
		c2.r = (c2.r & ~1) | ((c >> 3) & 1);
		c2.g = (c2.g & ~1) | ((c >> 2) & 1);
		c2.b = (c2.b & ~3) | (c & 3);
		pic.pixel (p2.x, p2.y, c2);

		r.push_back (p1);
		r.push_back (p2);
	}

	return r;
}

std::string get (const sng & pic, const std::vector <pixel> & vec) {
	std::string r;

	unsigned char c = 0;
	int i = 0;
	for (std::vector <pixel>::const_iterator it = vec.begin (); it != vec.end (); ++ it) {
		pcolor x = pic.pixel (it->x, it->y);
		c = (c << 4) | ((x.r & 1) << 3) | ((x.g & 1) << 2) | (x.b & 3);

		if (! ((++ i) & 1))
			r.push_back (c);
	}
	
	return r;
}

