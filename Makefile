CC = gcc
CFLAGS = -Wall -Iinclude

OBJ = obj/mystrfunctions.o obj/myfilefunctions.o obj/main.o

TARGET = bin/client

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f obj/*.o $(TARGET)
