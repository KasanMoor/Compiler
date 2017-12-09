#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE

#include "tree.h"

#define TABLE_SIZE 20

int DEBUG;

typedef struct symbolStruct
{
    char *name;
    char *type;
    struct symbolStruct *next;
} Symbol;

typedef struct scopeStruct
{
    Tree *id;
    Symbol *hashTable[TABLE_SIZE];
    struct scopeStruct *next;
    struct scopeStruct *last;
} Scope;

/* the global stack variable for all scopes */
Scope *currentScope;
Scope *oldScopesList;

void pushScope(Scope *newScope);
void popScope();

int hash(char *symbolName);
int insertSymbols(Tree *parseTree);
int symbolExistsInScope(char *symbolName);

Scope *newScope(Tree *id);
Symbol *newSymbol(char *type, Tree *parseTree);
char *findName(Tree *parseTree);

int buildSymbolTable(Tree *parseTree);

int isDeclaration(Tree *parseTree);
int isNewScope(Tree *parseTree);
int isSymbolReference(Tree *parseTree);
int scanTree(Tree * parseTree);
int findAndInsertSymbols(char *type, Tree *parseTree);
int isNewSymbol(char *prodrule);
char *findType(Tree *parseTree);
Tree *findProdRule(Tree *parseTree, char *prodrule);


#endif
