#ifndef _STEGO_H_
#define _STEGO_H_

#include <vector>
#include <string>
#include "sng.h"

struct pixel {
	unsigned int x, y;
};

std::vector <pixel> put (sng & pic, const std::string & s);
std::string get (const sng & pic, const std::vector <pixel> & vec);

#endif

