#include "../include/mystrfunctions.h"
#include "../include/myfilefunctions.h"
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char src[] = "Hello";
    char dest[50];

    printf("String Functions:\n");

    printf("Length of src: %d\n", mystrlen(src));

    mystrcpy(dest, src);
    printf("After mystrcpy: %s\n", dest);

    mystrncpy(dest, "Computer", 4);
    dest[4] = '\0';
    printf("After mystrncpy: %s\n", dest);

    mystrcpy(dest, "Hello ");
    mystrcat(dest, "World");
    printf("After mystrcat: %s\n", dest);

    FILE* file = fopen("test.txt", "r");

    if (file == NULL)
    {
        printf("Could not open test.txt\n");
        return 1;
    }

    int lines, words, chars;

    if (wordCount(file, &lines, &words, &chars) == 0)
    {
        printf("\nFile Statistics:\n");
        printf("Lines: %d\n", lines);
        printf("Words: %d\n", words);
        printf("Characters: %d\n", chars);
    }

    rewind(file);

    char** matches;
    int count = mygrep(file, "Hello", &matches);

    if (count >= 0)
    {
        printf("\nMatching Lines:\n");

        for (int i = 0; i < count; i++)
        {
            printf("%s", matches[i]);
            free(matches[i]);
        }

        free(matches);
    }

    fclose(file);

    return 0;
}
