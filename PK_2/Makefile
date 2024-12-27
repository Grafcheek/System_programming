all: clean&run

clean:
	rm -f *.o

asm: main.asm
	fasm main.asm

build: asm 
	ld -o prog main.o -lncurses -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2

run: build prog
	./prog

clear:
	clear

clean&run: clean clear run