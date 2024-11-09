all: clean&run

clean:
	rm -f *.o

queue: queue.asm
	fasm queue.asm

main: main.c
	gcc -c main.c -o main.o

build: queue main.c
	gcc -no-pie main.c queue.o -o prog

run: build prog
	./prog

clear:
	clear

clean&run: clean clear run