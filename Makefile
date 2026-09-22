CC = gcc
CFLAGS = -Wall -Iinclude

OBJ = obj/mystrfunctions.o obj/myfilefunctions.o obj/main.o
LIB = lib/libmyutils.a

TARGET = bin/client
STATIC_TARGET = bin/client_static

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)

$(LIB): obj/mystrfunctions.o obj/myfilefunctions.o
	ar rcs $(LIB) obj/mystrfunctions.o obj/myfilefunctions.o
	ranlib $(LIB)

$(STATIC_TARGET): obj/main.o $(LIB)
	$(CC) obj/main.o -Llib -lmyutils -o $(STATIC_TARGET)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

static: $(STATIC_TARGET)

clean:
	rm -f obj/*.o $(TARGET) $(STATIC_TARGET) $(LIB)
