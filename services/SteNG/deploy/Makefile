.PHONY : all

SERVICE=steng

SERVICE_SRC=strlib.cpp steng.cpp sng.cpp stego.cpp storage.cpp sockets.cpp excHandler.cpp

all: $(SERVICE)

$(SERVICE): Makefile $(SERVICE_SRC)
	g++ -std=c++11 -pthread -o $(SERVICE) $(SERVICE_SRC)

