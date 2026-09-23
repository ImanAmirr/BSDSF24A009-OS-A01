CC = gcc
CFLAGS = -Wall -Iinclude

OBJ = obj/mystrfunctions.o obj/myfilefunctions.o obj/main.o

LIB = lib/libmyutils.a
SHARED_LIB = lib/libmyutils.so

TARGET = bin/client
STATIC_TARGET = bin/client_static
DYNAMIC_TARGET = bin/client_dynamic

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)

$(LIB): obj/mystrfunctions.o obj/myfilefunctions.o
	ar rcs $(LIB) obj/mystrfunctions.o obj/myfilefunctions.o
	ranlib $(LIB)

$(STATIC_TARGET): obj/main.o $(LIB)
	$(CC) obj/main.o -Llib -lmyutils -o $(STATIC_TARGET)

$(SHARED_LIB): obj/mystrfunctions.o obj/myfilefunctions.o
	$(CC) -shared -o $(SHARED_LIB) obj/mystrfunctions.o obj/myfilefunctions.o

$(DYNAMIC_TARGET): obj/main.o $(SHARED_LIB)
	$(CC) obj/main.o -Llib -lmyutils -o $(DYNAMIC_TARGET)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

static: $(STATIC_TARGET)

dynamic: $(DYNAMIC_TARGET)

clean:
	rm -f obj/*.o $(TARGET) $(STATIC_TARGET) $(DYNAMIC_TARGET) $(LIB) $(SHARED_LIB)
