CC = gcc
FLAGS = -no-pie
OBJS = main.s brainfuck.s
TARGET = main.o

default: compile

compile:
	$(CC) $(FLAGS) -o $(TARGET) $(OBJS)

clean:
	-rm -f *.o