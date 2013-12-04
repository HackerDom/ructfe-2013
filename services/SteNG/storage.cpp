#include <fstream>
#include <iomanip>
#include <ios>
#include <sstream>
#include <algorithm>
#include <mutex>
#include <sys/stat.h>

#include "storage.h"

std::unique_ptr <sng_storage> sng_storage::self (nullptr);
const char * db_name = "./steng.db";

int extract_id (const std::string & s) {
	size_t ext = s.find ('.');
	std::string name = s.substr (0, ext);

	std::istringstream is (name);
	int r = 0;

	is >> std::hex >> r;
	return r;
}

sng_storage::sng_storage () : max_id (0) {
	std::ifstream db_index (db_name);
	if (! db_index.is_open ()) {
		std::ofstream ofs (db_name);

		if (! ofs.is_open ())
			throw sng_storage::init_exception ();

		ofs.close ();

		db_index.open (db_name);

		if (! db_index.is_open ())
			throw sng_storage::init_exception ();
	}

	struct stat st;
	if (stat ("./db", & st) == -1) {
		if (errno == ENOENT) {
			if (mkdir ("./db", S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == -1)
				throw sng_storage::init_exception ();
		}
		else
			throw sng_storage::init_exception ();
	}
	else if (! S_ISDIR (st.st_mode))
		throw sng_storage::init_exception ();

	std::string s;
	while (db_index >> s) {
		items.push_back (s);

		max_id = std::max (max_id, extract_id (s));
	}
}

sng_storage * sng_storage::instance () {
	if (! sng_storage::self)
		sng_storage::self.reset (new sng_storage ());

	return sng_storage::self.get ();
}

std::mutex mtx;

const std::list <std::string> & sng_storage::get_all_items () const {
	std::unique_lock <std::mutex> lock (mtx);

	return items;
}

std::string make_filename (const std::string & id) {
	return std::string ("./db/") + id;
}

sng sng_storage::get_item (const std::string & id) const {
	std::unique_lock <std::mutex> lock (mtx);

	std::string filename = make_filename (id);

	std::ifstream sng_file (filename);
	if (! sng_file.is_open ())
		throw sng_storage::not_found_exception ();

	std::string s, s0;
	while (std::getline (sng_file, s0)) {
		s += s0;
		s.push_back ('\n');
	}

	if (! sng_file.eof () && ! sng_file.good ())
		throw sng_storage::read_exception ();

	sng_file.close ();

	return sng (s);
}

std::string sng_storage::put_item (const sng & pic) {
	std::unique_lock <std::mutex> lock (mtx);

	std::ostringstream os;
	os << std::hex << (++ max_id);

	std::string id = os.str () + ".sng";

	std::string filename = make_filename (id);

	std::ofstream sng_file (filename);
	if (! sng_file.is_open ())
		throw sng_storage::write_exception ();

	sng_file << pic;
	sng_file.close ();

	std::ofstream db_index (db_name, std::ios_base::app);
	if (! db_index.is_open ())
		throw sng_storage::write_exception ();

	db_index << id << std::endl;
	db_index.close ();

	items.push_back (id);

	return id;
}

