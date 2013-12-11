#include <fstream>
#include <iomanip>
#include <ios>
#include <sstream>
#include <algorithm>
#include <mutex>
#include <sys/stat.h>

#include "storage.h"

std::unique_ptr <sng_storage> sng_storage::self (nullptr);

auto db_name = "./steng.db";
auto db_dir = "./db";
auto ext = ".sng";

int extract_id (const std::string & s) {
	auto ext = s.find ('.');
	auto name = s.substr (0, ext);

	std::istringstream is (name);
	int r;

	is >> std::hex >> r;
	return r;
}

bool init_dir () {
	struct stat s;

	if (stat (db_dir, & s) == -1) {
		if (ENOENT == errno) 
			return mkdir (db_dir, S_IRWXU | S_IRWXG) != -1;

		return false;
	}
	
	return S_ISDIR (s.st_mode);
}

sng_storage::sng_storage () : max_id (0) {
	std::ifstream db_index (db_name);
	if (! db_index.is_open ()) {
		std::ofstream ofs (db_name);

		if (! ofs.is_open ())
			throw sng_storage::init_error ();

		ofs.close ();

		db_index.open (db_name);

		if (! db_index.is_open ())
			throw sng_storage::init_error ();
	}

	if (! init_dir ())
		throw sng_storage::init_error ();

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

const std::vector <std::string> & sng_storage::get_all_items () const throw () {
	std::lock_guard <std::mutex> lock (mtx);

	return items;
}

std::string make_filename (const std::string & id) {
	return std::string (db_dir) + '/' + id;
}

sng sng_storage::get_item (const std::string & id) const
	throw (sng_storage::not_found_error, sng_storage::read_error, sng::parse_error) {
	std::lock_guard <std::mutex> lock (mtx);

	auto filename = make_filename (id);

	std::ifstream sng_file (filename);
	if (! sng_file.is_open ())
		throw sng_storage::not_found_error ();

	std::string s, s0;
	while (std::getline (sng_file, s0)) {
		s += s0;
		s.push_back ('\n');
	}

	if (! sng_file.eof () && ! sng_file.good ())
		throw sng_storage::read_error ();

	sng_file.close ();

	return sng (s);
}

std::string sng_storage::put_item (const sng & pic) throw (sng_storage::write_error) {
	std::lock_guard <std::mutex> lock (mtx);

	std::ostringstream os;
	os << std::hex << (++ max_id);

	auto id = os.str () + ext;
	auto filename = make_filename (id);

	std::ofstream sng_file (filename);
	if (! sng_file.is_open ())
		throw sng_storage::write_error ();

	sng_file << pic.to_raw_string ();
	sng_file.close ();

	std::ofstream db_index (db_name, std::ios_base::app);
	if (! db_index.is_open ())
		throw sng_storage::write_error ();

	db_index << id << std::endl;
	db_index.close ();

	items.push_back (id);

	return id;
}

