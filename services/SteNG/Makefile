.PHONY : all

CXX=g++
OPTS=-std=c++11

CHECKER=extract
SERVICE=steng
PACKER=packer

COMMON=strlib.cpp sng.cpp stego.cpp

CHECKER_SRC=extract.cpp
SERVICE_SRC=steng.cpp storage.cpp sockets.cpp excHandler.cpp
PACKER_SRC=packer.cpp

all: $(CHECKER) $(SERVICE) $(PACKER)

$(CHECKER): Makefile $(CHECKER_SRC) $(COMMON)
	$(CXX) $(OPTS) -o $(CHECKER) $(COMMON) $(CHECKER_SRC)
	cp $(CHECKER) ./checker/

$(SERVICE): Makefile $(SERVICE_SRC) $(COMMON)
	$(CXX) $(OPTS) -pthread -o $(SERVICE) $(COMMON) $(SERVICE_SRC)

$(PACKER): Makefile $(PACKER_SRC) $(COMMON)
	$(CXX) $(OPTS) -o $(PACKER) $(COMMON) $(PACKER_SRC)

clean:
	rm -r *~ steng.db db/

