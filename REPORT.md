# Feature 2 — Multi-file Compilation, Makefile, Git Branching and Releases

### 1. Explain the linking rule in this part's Makefile: `$(TARGET): $(OBJ)`. How does it differ from a Makefile rule that links against a library?

The rule `$(TARGET): $(OBJ)` means that the final executable is created by linking all the object files directly.

In our Makefile, the rule is:

```makefile
$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)
```

Here, `$(OBJ)` contains:

```text
obj/mystrfunctions.o
obj/myfilefunctions.o
obj/main.o
```

The linker combines these object files to create the final `client` executable.

A Makefile rule that links against a library is different because the library is provided separately. For example, our static build uses:

```makefile
$(STATIC_TARGET): obj/main.o $(LIB)
	$(CC) obj/main.o -Llib -lmyutils -o $(STATIC_TARGET)
```

Here, `main.o` is linked with the `libmyutils.a` library. The `-Llib` option tells the linker where to find the library, while `-lmyutils` tells it to use `libmyutils`.

---

### 2. What is a git tag and why is it useful in a project? What is the difference between a simple tag and an annotated tag?

A Git tag is a name that points to a specific commit in a Git repository. It is useful for marking important versions or milestones of a project.

For example, we created:

```text
v0.1.1-multifile
```

for the multi-file build.

A **simple (lightweight) tag** is basically just a name pointing directly to a commit.

An **annotated tag** is a Git object that stores additional information such as the tag message, tagger, and date. We created annotated tags using:

```bash
git tag -a v0.1.1-multifile -m "Multifile build"
```

Annotated tags are useful for official project versions because they contain more information about the release.

---

### 3. What is the purpose of creating a "Release" on GitHub? What is the significance of attaching binaries (like your client executable) to it?

A GitHub Release provides a convenient way to publish a specific version of a project based on a Git tag.

For example, our `v0.1.1-multifile` release represents the multi-file version of the project.

Attaching a binary such as `client` allows users to download and run the already-built executable without having to compile the source code themselves.

GitHub also automatically provides the source code as ZIP and TAR files for a release.

---

# Feature 3 — Static Library Build

### 1. Compare the Makefile from Part 2 and Part 3. What are the key differences in the variables and rules that enable the creation of a static library?

The Part 2 Makefile mainly compiled the individual source files into object files and then directly linked those object files to create the `client` executable.

In Part 3, additional variables and rules were added for the static library:

```makefile
LIB = lib/libmyutils.a
STATIC_TARGET = bin/client_static
```

A rule was added to create the static library:

```makefile
$(LIB): obj/mystrfunctions.o obj/myfilefunctions.o
	ar rcs $(LIB) obj/mystrfunctions.o obj/myfilefunctions.o
	ranlib $(LIB)
```

Another rule was added to link the executable against the static library:

```makefile
$(STATIC_TARGET): obj/main.o $(LIB)
	$(CC) obj/main.o -Llib -lmyutils -o $(STATIC_TARGET)
```

Therefore, Part 3 adds the creation of `libmyutils.a` and the `client_static` executable, while Part 2 directly linked the object files.

---

### 2. What is the purpose of the `ar` command? Why is `ranlib` often used immediately after it?

The `ar` command is used to create and manage archive files. In our project, it creates the static library:

```bash
ar rcs lib/libmyutils.a obj/mystrfunctions.o obj/myfilefunctions.o
```

It combines the object files into `libmyutils.a`.

The options mean:

* `r` — insert or replace files in the archive
* `c` — create the archive if it does not exist
* `s` — create an index of the symbols

`ranlib` creates or updates the symbol index of the archive:

```bash
ranlib lib/libmyutils.a
```

This index helps the linker quickly find the required functions inside the static library.

---

### 3. When you run `nm` on your `client_static` executable, are the symbols for functions like `mystrlen` present? What does this tell you about how static linking works?

Yes. The functions from our static library are present in the final `client_static` executable.

For example, functions such as `mystrlen`, `mystrcpy`, `mystrncpy`, `mystrcat`, `wordCount`, and `mygrep` appear as symbols in the executable.

This shows that static linking copies the required library code into the final executable during the linking process. Therefore, `client_static` contains the library code itself and does not need `libmyutils.a` at runtime.

This is different from dynamic linking, where the executable depends on a separate `.so` shared library at runtime.

# Feature 4 — Dynamic/Shared Library

### 1. What is Position-Independent Code (`-fPIC`) and why is it a fundamental requirement for creating shared libraries?

Position-Independent Code (PIC) is code that can run correctly regardless of where it is loaded into memory.

The `-fPIC` option tells GCC to generate position-independent code:

```bash
gcc -Wall -fPIC -Iinclude -c src/mystrfunctions.c -o obj/mystrfunctions.o
```

Shared libraries can be loaded into different memory addresses by different programs. Therefore, the code inside a shared library should not depend on a fixed memory address.

We used `-fPIC` when compiling our source files before creating:

```text
lib/libmyutils.so
```

It allows the shared library to be loaded and used by the executable at runtime.

---

### 2. Explain the difference in file size between your static and dynamic clients. Why does this difference exist?

In our project, the sizes were:

```text
client_static   = 17K
client_dynamic  = 17K
libmyutils.a    = 5.4K
libmyutils.so   = 16K
```

The two client executables happened to have approximately the same displayed size, even though they use different linking methods.

With **static linking**, the required library code is copied into `client_static`. Therefore, the executable contains the functions from the static library.

With **dynamic linking**, the library code is kept separately in `libmyutils.so`. The `client_dynamic` executable contains references to the shared library rather than copying all of its code into the executable.

The exact file sizes can vary because of compiler options, ELF metadata, alignment, symbol tables, and other factors. Therefore, the displayed `17K` size of both clients does not mean that static and dynamic linking work in the same way.

---

### 3. What is the `LD_LIBRARY_PATH` environment variable? Why was it necessary to set it for your program to run, and what does this tell you about the responsibilities of the operating system's dynamic loader?

`LD_LIBRARY_PATH` is an environment variable that tells the Linux dynamic loader additional directories where it should search for shared libraries.

Initially, when we ran:

```bash
./bin/client_dynamic
```

the program produced:

```text
error while loading shared libraries: libmyutils.so:
cannot open shared object file: No such file or directory
```

This happened because `libmyutils.so` was stored in our project's `lib/` directory, which was not one of the loader's default library search locations.

We then used:

```bash
export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
```

After setting this variable, the program was able to find and load `libmyutils.so`.

We also verified the library being used with:

```bash
ldd bin/client_dynamic
```

which showed:

```text
libmyutils.so => /home/imanamir/BSDSF24A009-OS-A01/lib/libmyutils.so
```

This demonstrates that the dynamic loader is responsible for locating and loading the required shared libraries when the program starts. The executable does not automatically search every directory on the system, so the library must either be installed in a known library location or its location must be provided through mechanisms such as `LD_LIBRARY_PATH`.

