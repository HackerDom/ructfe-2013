.PHONY : all

CXX=g++
OPTS=-std=c++11

SERVICE=steng

SERVICE_SRC=strlib.cpp sng.cpp stego.cpp steng.cpp storage.cpp sockets.cpp 

all: Makefile $(SERVICE_SRC) 
	$(CXX) $(OPTS) -pthread -o $(SERVICE) $(SERVICE_SRC)


