.PHONY : all

CHECKER=./checker/extract
SERVICE=steng

CHECKER_SRC=extract.cpp sng.cpp stego.cpp
SERVICE_SRC=steng.cpp sng.cpp stego.cpp storage.cpp sockets.cpp excHandler.cpp

all: $(CHECKER) $(SERVICE)

$(CHECKER): Makefile $(CHECKER_SRC)
	g++ -std=c++11 -o $(CHECKER) $(CHECKER_SRC)

$(SERVICE): Makefile $(SERVICE_SRC)
	g++ -std=c++11 -pthread -o $(SERVICE) $(SERVICE_SRC)

