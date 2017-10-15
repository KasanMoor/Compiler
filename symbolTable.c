#include "symbolTable.h"

void pushScope(Scope *newScope)
{
    newScope->next = currentScope;
    currentScope = newScope;
}

void popScope()
{
    Scope *scopeToBeDeleted = currentScope;
    currentScope = currentScope->next;
    free(scopeToBeDeleted);
}

int hash(Symbol symbol)
{
    char* hashString = strdup(symbol->name);
    int i, hashValue=0;
    for(i=0; hashString[i]; i++)
    {
        hashValue += hashString[i];
    }
    return hashValue;
}

int insertSymbol(Symbol newSymbol)
{
    if(symbolExistsInScope(currentScope, newSymbol))
    {
        return 1;
    }
    int hashValue = hash(newSymbol);
    Symbol *bucketHead = currentScope->hashTable[hashValue];
    newSymbol->next = bucketHead;
    currentScope->hashTable[hashValue] = newSymbol;
    return 0;
}

int symbolExistsInScope(Symbol symbol)
{
    int hashValue = hash(symbol);
    Symbol *currentSymbol = currentScope->hashTable[hashValue];
    while(currentSymbol)
    {
        if(!strcmp(currentSymbol->name, symbol->name)) 
	{
	    return 1;
	}
	currentSymbol = currentSymbol->next;
    }
    return 0;
}

Scope *newScope(char *scopeID)
{
    Scope *newScope = malloc(sizeof(Scope));
    newScope->next = NULL;
    return newScope;
}

Symbol *newSymbol(char *name, int category)
{
    Symbol *newSymbol = malloc(sizeof(Symbol));
    newSymbol->name = name;
    newSymbol->category = category;
    newSymbol->next = NULL;
    return newSymbol;
}
