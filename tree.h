#ifndef TREE
#define TREE
#define DEFAULT_KID_SIZE 9

int LEX_DEBUG;

typedef struct TokenStruct {
    int category;
    char *text;
    int lineNumber;
    char *fileName;
    int ival;
    int *sval;
} Token;

typedef struct TreeStruct {
    char *prodrule;
    int nkids;
    int maxKids;
    struct TreeStruct **kids;
    Token *leaf;
} Tree;

int lexicalError;
int semanticError;
int syntaxError;

Tree *newTree();
Tree *newNonTerm(char *, int, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *);
Token *newToken(int, char *, int);
void printTree(int depth, Tree *);

#endif
