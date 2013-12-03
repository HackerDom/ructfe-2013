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

	bool grayscale;
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
	unsigned char r, g, b, a;

	pcolor ();
	pcolor (int r, int g, int b, int a);
};

bool operator == (const pcolor & lhs, const pcolor & rhs);

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
	sng (const std::string & s);

	long height () const;
	long width () const;

	pcolor pixel (unsigned int x, unsigned int y) const;
	void pixel (unsigned int x, unsigned int y, pcolor c);	

	std::string keyword () const;
	void keyword (const std::string & s);

	std::string text () const;
	void text (const std::string & s);

	std::string time () const;
	void time (short y, unsigned char m, unsigned char d, unsigned char hh, unsigned char mm, unsigned char ss);

	std::string private_ (const std::string & chunk) const;
	void private_ (const std::string & chunk, const std::string & text);

	friend std::ostream & operator << (std::ostream & os, const sng & p);
};

std::ostream & operator << (std::ostream & os, const sng & p);

#endif

