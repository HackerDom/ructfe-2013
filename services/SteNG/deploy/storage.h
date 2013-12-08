#ifndef _STORAGE_H_
#define _STORAGE_H_

#include <list>
#include <string>
#include <memory>
#include "sng.h"

class sng_storage {
	static std::unique_ptr <sng_storage> self;

	std::list <std::string> items;
	int max_id;

protected:
	sng_storage ();

public:

	class init_exception { };
	class not_found_exception { };
	class read_exception { };
	class write_exception { };

	static sng_storage * instance ();

	const std::list <std::string> & get_all_items () const;
	sng get_item (const std::string & id) const;
	std::string put_item (const sng & pic);
};

#endif

