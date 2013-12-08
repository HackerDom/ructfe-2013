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
	class init_error { };
	class not_found_error { };
	class read_error { };
	class write_error { };

	static sng_storage * instance ();

	const std::list <std::string> & get_all_items () const throw ();
	sng get_item (const std::string & id) const throw (not_found_error, read_error, sng::parse_error);
	std::string put_item (const sng & pic) throw (write_error);
};

#endif

