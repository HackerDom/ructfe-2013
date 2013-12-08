#ifndef _EXCHANDLER_H_
#define _EXCHANDLER_H_

#include <string>

class excHandler
{
public:
	excHandler(const std::string& fName);
	std::string getFuncName() const;

private:
	std::string funcName;
};

#endif
