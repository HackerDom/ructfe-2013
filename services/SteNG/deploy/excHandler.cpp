#include "excHandler.h"

excHandler::excHandler(const std::string& fName) : funcName(fName)
{
}

std::string excHandler::getFuncName() const
{
	return funcName;
}
