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
