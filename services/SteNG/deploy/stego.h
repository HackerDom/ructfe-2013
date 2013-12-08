#ifndef _STEGO_H_
#define _STEGO_H_

#include <vector>
#include <string>
#include "sng.h"

struct pixel {
	unsigned int x, y;
};

struct stego {
	static std::vector <pixel> put (sng & pic, const std::string & s);
	static std::string get (const sng & pic, const std::vector <pixel> & vec);
};

#endif

