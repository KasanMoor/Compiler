#define DEFAULT_KID_SIZE 9

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

Tree *newTree();
Tree *newNonTerm(char *, int, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *, Tree *);
Token *newToken(int, char *, int);
void addKid(Tree *, Tree *);
int increaseKidSize(Tree *);
void printTree(Tree *);
