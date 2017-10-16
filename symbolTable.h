#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE

#include "tree.h"

#define TABLE_SIZE 20

typedef struct symbolStruct
{
    char *name;
    int category;
    struct symbolStruct *next;
} Symbol;

typedef struct scopeStruct
{
    Symbol *hashTable[TABLE_SIZE];
    struct scopeStruct *next;
} Scope;

/* the global stack vairable for all scopes */
Scope *currentScope;

void pushScope(Scope *newScope);
void popScope();

int hash(char *symbolName);
/* returns 0 on successful insertion 1 if symbol already exists */
int insertSymbol(Symbol *newSymbol);
/* returns 1 if symbol exists in scope 0 if not */
int symbolExistsInScope(char *symbolName);

Scope *newScope();
Symbol *newSymbol(Tree *parseTree);
char *findName(Tree *parseTree);

int buildSymbolTable(Tree *parseTree);

int isDeclaration(Tree *parseTree);
int isNewScope(Tree *parseTree);
int isSymbolReference(Tree *parseTree);

#endif
