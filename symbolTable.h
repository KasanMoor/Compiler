typedef struct symbolStruct
{
    char *name;
    int category;
    Symbol next;
} Symbol;

typedef struct scopeStruct
{
    const int tableSize = 20;
    char *scopeID;
    Symbol *hashTable[tableSize];
    struct scopeStruct *next;
} Scope;

/* the global stack vairable for all scopes */
Scope currentScope;

void pushScope(Scope newScope);
void popScope();

int hash(Symbol symbol);
/* returns 0 on successful insertion 1 if symbol already exists */
int insertSymbol(Symbol newSymbol);
/* returns 1 if symbol exists in scope 0 if not */
int symbolExistsInScope(Symbol symbol);

Scope *newScope(char *scopeID);
Symbol *newSymbol();

