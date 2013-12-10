#ifndef _SNG_H_
#define _SNG_H_

#include <vector>
#include <string>
#include <iostream>
#include <map>

struct sng_IHDR {
	long height;
	long width;
	unsigned char depth;

	bool color;
	bool palette;
	bool alpha;

	sng_IHDR ();
};

struct sng_gAMA {
	float value;

	sng_gAMA ();
};

struct sng_hIST {
	std::vector <short> values;

	sng_hIST ();
};

struct sng_tIME {
	short year;
	unsigned char month;
	unsigned char day;
	unsigned char hour;
	unsigned char minute;
	unsigned char second;

	sng_tIME ();
	sng_tIME (short year, unsigned char month, unsigned char day, unsigned char hour, unsigned char minute, unsigned char second);
};

struct sng_tEXt {
	std::string keyword;
	std::string text;

	sng_tEXt ();
};

struct pcolor {
	int r, g, b, a;

	pcolor ();
	pcolor (int r, int g, int b, int a);
};

struct sng_PLTE {
	std::vector <pcolor> colors;

	sng_PLTE ();
};

union color_t {
	unsigned char idx;
	pcolor c;

	color_t ();
	color_t (unsigned char idx);
};

struct sng_IMAGE {
	std::vector <std::vector <color_t>> pixels;

	sng_IMAGE ();
};

struct sng_private {
	std::map <std::string, std::string> data;
};

class sng {
	sng_IHDR m_IHDR;
	sng_gAMA m_gAMA;
	sng_PLTE m_PLTE;
	sng_hIST m_hIST;
	sng_tIME m_tIME;
	sng_tEXt m_tEXt;
	sng_IMAGE m_IMAGE;
	sng_private m_private;

public:
	class parse_error { };

	sng (const std::string & s);

	long height () const throw ();
	long width () const throw ();

	pcolor pixel (unsigned int x, unsigned int y) const throw ();
	void pixel (unsigned int x, unsigned int y, pcolor c) throw ();

	std::string keyword () const throw ();
	void keyword (const std::string & s) throw ();

	std::string text () const throw ();
	void text (const std::string & s) throw ();

	std::string time () const throw ();
	void time (short y, unsigned char m, unsigned char d, unsigned char hh, unsigned char mm, unsigned char ss) throw ();

	std::string private_ (const std::string & chunk) const throw ();
	void private_ (const std::string & chunk, const std::string & text) throw ();

	std::string to_raw_string () const throw ();
};

#endif

