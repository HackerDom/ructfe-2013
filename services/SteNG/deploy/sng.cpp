#include "sng.h"
#include "strlib.hxx"

#include <sstream>
#include <iterator>
#include <iomanip>
#include <cctype>
#include <algorithm>

std::string _ (const std::string & s) {
	if (! s.empty () && (s.back () == ':' || s.back () == ';'))
		return s.substr (0, s.length () - 1);

	return s;
}

template <typename T>
T get_num (std::istringstream & is) {
	long long x;
	is >> x;

	return static_cast <T> (x);
}

sng_IHDR::sng_IHDR () :
	width (0),
	height (0),
	depth (0), 
	color (false),
	palette (false),
	alpha (false) { }

sng_IHDR parse_IHDR (const std::string & s) {
	sng_IHDR r;

	std::istringstream is (s);
	std::string field;
	while (is >> field) {
		field = _ (field);

		if (field == "height")
			r.height = get_num <long> (is);
		else if (field == "width")
			r.width = get_num <long> (is);
		else if (field == "bitdepth")
			r.depth = get_num <unsigned char> (is);
		else if (field == "using") {
			std::string opt;

			while (is >> opt) {
				opt = _ (opt);

				if (opt == "color")
					r.color = true;
				else if (opt == "palette")
					r.palette = true;
				else if (opt == "alpha")
					r.alpha = true;
			}
		}
	}

	return r;
}

sng_gAMA::sng_gAMA () :
	value (1.0) { }

sng_gAMA parse_gAMA (const std::string & s) {
	sng_gAMA r;
	
	std::istringstream is (s);
	is >> r.value;

	return r;
}

sng_PLTE::sng_PLTE () :
	colors (0) { }


pcolor::pcolor () :
	r (0),
	g (0),
	b (0),
	a (0) { }

pcolor::pcolor (int r, int g, int b, int a) :
	r (r),
	g (g),
	b (b),
	a (a) { }

bool operator == (const pcolor & lhs, const pcolor & rhs) {
	return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b && lhs.a == rhs.a;
}

sng_PLTE parse_PLTE (const std::string & s) {
	sng_PLTE r;

	std::istringstream is (replace (s, "(),", ' '));

	int pr, pg, pb;
	while (is >> pr >> pg >> pb)
		r.colors.push_back (pcolor (pr, pg, pb, 0));

	return r;
}

sng_hIST::sng_hIST () :
	values (0) { }

sng_hIST parse_hIST (const std::string & s) {
	sng_hIST r;	

	std::istringstream is (_ (s));
	r.values.assign (std::istream_iterator <short> (is), std::istream_iterator <short> ());

	return r;
}

sng_tIME::sng_tIME () :
	year (1970),
	month (1),
	day (1),
	hour (0),
	minute (0),
	second (0) { }

sng_tIME::sng_tIME (short year, unsigned char month, unsigned char day, unsigned char hour, unsigned char minute, unsigned char second) :
	year (year),
	month (month),
	day (day),
	hour (hour),
	minute (minute),
	second (second) { }

sng_tIME parse_tIME (const std::string & s) {
	sng_tIME r;

	std::istringstream is (s);
	std::string field;
	while (is >> field) {
		field = _ (field);

		if (field == "year")
			r.year = get_num <short> (is);
		else if (field == "month")
			r.month = get_num <unsigned char> (is);
		else if (field == "day")
			r.day = get_num <unsigned char> (is);
		else if (field == "hour")
			r.hour = get_num <unsigned char> (is);
		else if (field == "minute")
			r.minute = get_num <unsigned char> (is);
		else if (field == "second")
			r.second = get_num <unsigned char> (is);
	}

	return r;
}

sng_tEXt::sng_tEXt () :
	keyword (""),
	text ("") { }

sng_tEXt parse_tEXt (const std::string & s) {
	sng_tEXt r;

	std::istringstream is (s);
	std::string field;
	while (is >> field) {
		field = _ (field);

		if (field == "keyword")
			is >> r.keyword;
		else if (field == "text")
			std::getline (is, r.text);
	}

	return r;
}

sng_IMAGE::sng_IMAGE () :
	pixels (0) { }

int hex2byte (std::string::const_iterator & it, const std::string::const_iterator & end, unsigned char depth) {
	auto r = 0;
	for (auto i = 0; i < (depth >> 2); ++ i) {
		r <<= 4;

		if (it != end) {
			r += std::isdigit (* it) ? (* it - '0') : (* it - 'a' + 10);
			++ it;
		}
	}

	return r;
}

color_t hex2color (const std::string & s, unsigned char depth) {
	color_t c;

	auto it = std::begin (s);
	auto e = std::end (s);

	c.c.r = hex2byte (it, e, depth);
	c.c.g = hex2byte (it, e, depth);
	c.c.b = hex2byte (it, e, depth);
	if (it != e)
		c.c.a = hex2byte (it, e, depth);

	return c;
}

color_t::color_t () :
	c (0, 0, 0, 0) { }

color_t::color_t (unsigned char idx) :
	idx (idx) { }

sng_IMAGE parse_IMAGE (const std::string & s, unsigned char depth, bool has_palette) {
	sng_IMAGE r;

	std::istringstream is (s);
	std::string line;
	while (std::getline (is, line)) {
		if (line.empty () || line.find ("pixels hex") != std::string::npos)
			continue;

		r.pixels.push_back (std::vector <color_t> ());
		if (has_palette) {
			std::string::const_iterator it = std::begin (line);
			std::string::const_iterator e = std::end (line);

			while (it != e)
				r.pixels.back ().push_back (color_t (hex2byte (it, e, 8)));
		}
		else {
			std::istringstream iss (line);
			std::string c;
			while (iss >> c)
				r.pixels.back ().push_back (hex2color (c, depth));
		}
	}

	return r;
}

void check_pos (std::string::size_type p) {
	if (p == std::string::npos)
		throw sng::parse_error ();
}

void parse_private (sng_private & r, const std::string & s, const std::string & chunk) {
	auto tag_begin = chunk.find_first_not_of (" \t");
	auto tag_end = chunk.find_last_not_of (" \t");
	check_pos (tag_begin);
	check_pos (tag_end);

	auto data_begin = s.find_first_of ("\"");
	check_pos (data_begin);

	auto data_end = s.find_first_of ("\"", data_begin + 1);
	check_pos (data_end);

	r.data [chunk.substr (tag_begin, tag_end - tag_begin + 1)] = s.substr (data_begin + 1, data_end - data_begin - 1);
}

sng::sng (const std::string & s) {
	std::string::size_type it = 0;

	auto has_palette = false;
	auto has_ihdr = false;
	while (it != std::string::npos) {
		it = s.find_first_not_of (" \n\t", it);

		if (it != std::string::npos) {
			auto tag_begin = it;
			auto tag_end = s.find_first_of (" \n\t{", it);
			check_pos (tag_end);

			auto tag = _ (s.substr (tag_begin, tag_end - tag_begin));

			auto fields_begin = s.find_first_of ('{', tag_end);
			auto fields_end = s.find_first_of ('}', fields_begin);
			check_pos (fields_begin);
			check_pos (fields_end);

			auto fields = s.substr (fields_begin + 1, fields_end - fields_begin - 1);
			it = fields_end + 1;

			if (fields.empty ())
				continue;

			if (tag == "IHDR") {
				m_IHDR = parse_IHDR (fields);
				has_ihdr = true;
			}
			else if (tag == "gAMA")
				m_gAMA = parse_gAMA (fields);
			else if (tag == "PLTE") {
				m_PLTE = parse_PLTE (fields);
				has_palette = true;
			}
			else if (tag == "hIST")
				m_hIST = parse_hIST (fields);
			else if (tag == "tIME")
				m_tIME = parse_tIME (fields);
			else if (tag == "tEXt")
				m_tEXt = parse_tEXt (fields);
			else if (tag == "IMAGE")
				m_IMAGE = parse_IMAGE (fields, m_IHDR.depth, has_palette);
			else if (tag == "private")
				parse_private (m_private, fields, s.substr (tag_end, fields_begin - tag_end));
		}
	}

	if (! has_ihdr)
		throw sng::parse_error ();

	if (m_IMAGE.pixels.size () != m_IHDR.height)
		throw sng::parse_error ();

	for (const auto & it : m_IMAGE.pixels)
		if (it.size () != m_IHDR.width)
			throw sng::parse_error ();
}

long sng::width () const throw () {
	return m_IHDR.width;
}

long sng::height () const throw () {
	return m_IHDR.height;
}

pcolor sng::pixel (unsigned int x, unsigned int y) const throw () {
	if (x >= width () || y >= height ())
		return pcolor ();

	color_t r = m_IMAGE.pixels [y] [x];
	return m_IHDR.palette ? m_PLTE.colors [r.idx] : r.c;
}

void sng::pixel (unsigned int x, unsigned int y, pcolor c) throw () {
	if (x >= width () || y >= height ())
		return;

	if (m_IHDR.palette) {
		auto it = std::find (std::begin (m_PLTE.colors), std::end (m_PLTE.colors), c);

		if (it == m_PLTE.colors.end ()) {
			if (m_PLTE.colors.size () == 255)
				return;

			m_IMAGE.pixels [y] [x].idx = m_PLTE.colors.size ();
			m_PLTE.colors.push_back (c);
		}
		else
			m_IMAGE.pixels [y] [x].idx = std::distance (std::begin (m_PLTE.colors), it);
	}
	else
		m_IMAGE.pixels [y] [x].c = c;
}

std::string sng::keyword () const throw () {
	return m_tEXt.keyword;
}

void sng::keyword (const std::string & s) throw () {
	m_tEXt.keyword = s;
}

std::string sng::text () const throw () {
	return m_tEXt.text;
}

void sng::text (const std::string & s) throw () {
	m_tEXt.text = s;
}

std::string sng::time () const throw () {
	std::ostringstream os;
	os << static_cast <int> (m_tIME.month) << "/" << static_cast <int> (m_tIME.day) << "/" << m_tIME.year << " " <<
		static_cast <int> (m_tIME.hour) << ":" << static_cast <int> (m_tIME.minute) << ":" << static_cast <int> (m_tIME.second);

	return os.str ();
}

void sng::time (short y, unsigned char m, unsigned char d, unsigned char hh, unsigned char mm, unsigned char ss) throw () {
	m_tIME = sng_tIME (y, m, d, hh, mm, ss);
}

std::string sng::private_ (const std::string & chunk) const throw () {
	if (! m_private.data.count (chunk))
		return "";

	return m_private.data.at (chunk);
}

void sng::private_ (const std::string & chunk, const std::string & text) throw () {
	if (chunk.empty ()) {
		m_private.data.erase (chunk);
		return;
	}

	m_private.data [chunk] = text;
}

std::string sng::to_raw_string () const throw () {
	std::ostringstream os;

	os << "IHDR {" << std::endl <<
		"\twidth: " << m_IHDR.width << std::endl <<
		"\theight: " << m_IHDR.height << std::endl <<
		"\tbitdepth: " << static_cast <int> (m_IHDR.depth) << std::endl;
	
	if (m_IHDR.alpha || m_IHDR.palette || m_IHDR.color) {
		os << "\tusing ";

		if (m_IHDR.alpha) os << "alpha ";
		if (m_IHDR.color) os << "color ";
		if (m_IHDR.palette) os << "palette ";
		
		os << std::endl;
	}

	os << "}" << std::endl << "gAMA { " << std::fixed << std::setprecision (2) << m_gAMA.value << " }" << std::endl <<
		"tIME {" << std::endl <<
		"\tyear " << m_tIME.year << std::endl <<
		"\tmonth " << static_cast <int> (m_tIME.month) << std::endl <<
		"\tday " << static_cast <int> (m_tIME.day) << std::endl <<
		"\thour " << static_cast <int> (m_tIME.hour) << std::endl <<
		"\tminute " << static_cast <int> (m_tIME.minute) << std::endl <<
		"\tsecond " << static_cast <int> (m_tIME.second) << std::endl <<
		"}" << std::endl;

	if (! m_hIST.values.empty ()) {
		os << "PLTE {" << std::endl;
		for (const auto & it : m_PLTE.colors)
			os << "\t(" << std::setw (3) << it.r << "," << std::setw (3) << it.g << "," << std::setw (3) << it.b << ")" << std::endl;
		os << "}" << std::endl << "hIST {" << std::endl << "\t" << join (m_hIST.values, " ") << std::endl << "}" << std::endl;
	}

	if (! m_tEXt.keyword.empty ())
		os << "tEXt {" << std::endl <<
		"\tkeyword: " << m_tEXt.keyword << std::endl <<
		"\ttext: " << m_tEXt.text << std::endl <<
		"}" << std::endl;

	os << "IMAGE {" << std::endl << "\tpixels hex" << std::endl;
	int w = m_IHDR.depth >> 2;
	if (m_hIST.values.empty ()) {
		for (const auto & it : m_IMAGE.pixels) {
			for (const auto & jt : it) {
				os << std::setfill ('0') << std::setw (w) << std::hex << jt.c.r <<
				      std::setfill ('0') << std::setw (w) << jt.c.g <<
				      std::setfill ('0') << std::setw (w) << jt.c.b;

				if (m_IHDR.alpha)
					os << std::setfill ('0') << std::setw (w) << jt.c.a;

				os << " ";
			}

			os << std::endl;
		}
	}
	else {
		for (const auto & it : m_IMAGE.pixels) {
			for (const auto & jt : it)
				os << std::setfill ('0') << std::setw (2) << std::hex << static_cast <int> (jt.idx);

			os << std::endl;
		}
	}
	os << "}" << std::endl;

	if (! m_private.data.empty ()) {
		for (const auto & it : m_private.data)
			os << "private " << it.first << " {" << std::endl <<
				"\t\"" << it.second << "\"" << std::endl <<
				"}" << std::endl;
	}

	return os.str ();
}

