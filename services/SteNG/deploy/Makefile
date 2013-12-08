.PHONY : all

SERVICE=steng

SERVICE_SRC=steng.cpp sng.cpp stego.cpp storage.cpp sockets.cpp excHandler.cpp

all: $(SERVICE)

$(SERVICE): Makefile $(SERVICE_SRC)
	g++ -std=c++11 -pthread -o $(SERVICE) $(SERVICE_SRC)

clean:
	rm -r *~ steng.db db/
