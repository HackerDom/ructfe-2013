.PHONY : all

CHECKER=./checker/extract
SERVICE=steng
PACKER=packer

CHECKER_SRC=extract.cpp sng.cpp stego.cpp
SERVICE_SRC=steng.cpp sng.cpp stego.cpp storage.cpp sockets.cpp excHandler.cpp
PACKER_SRC=packer.cpp sng.cpp stego.cpp

all: $(CHECKER) $(SERVICE) $(PACKER)

$(CHECKER): Makefile $(CHECKER_SRC)
	g++ -std=c++11 -o $(CHECKER) $(CHECKER_SRC)

$(SERVICE): Makefile $(SERVICE_SRC)
	g++ -std=c++11 -pthread -o $(SERVICE) $(SERVICE_SRC)

$(PACKER): Makefile $(PACKER_SRC)
	g++ -std=c++11 -o $(PACKER) $(PACKER_SRC)

clean:
	rm -r *~ steng.db db/
