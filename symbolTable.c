#include "symbolTable.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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

int hash(char *symbolName)
{
    char* hashString = strdup(symbolName);
    int i, hashValue=0;
    for(i=0; hashString[i]; i++)
    {
        hashValue += hashString[i];
    }
    hashValue = hashValue % TABLE_SIZE;
    return hashValue;
}

int insertSymbol(Symbol *newSymbol)
{
    if(symbolExistsInScope(newSymbol->name))
    {
        printf("error: %s already declared\n", newSymbol->name);
        return 1;
    }
    int hashValue = hash(newSymbol->name);
    Symbol *bucketHead = currentScope->hashTable[hashValue];
    newSymbol->next = bucketHead;
    currentScope->hashTable[hashValue] = newSymbol;
    return 0;
}

int symbolExistsInScope(char *symbolName)
{
    int hashValue = hash(symbolName);
    Symbol *currentSymbol = currentScope->hashTable[hashValue];
    while(currentSymbol)
    {
        if(!strcmp(currentSymbol->name, symbolName)) 
	{
	    return 1;
	}
	currentSymbol = currentSymbol->next;
    }
    return 0;
}

Scope *newScope()
{
    Scope *newScope = malloc(sizeof(Scope));
    newScope->next = NULL;
    return newScope;
}

Symbol *newSymbol(Tree *parseTree)
{
    Symbol *newSymbol = malloc(sizeof(Symbol));
    newSymbol->name = findName(parseTree);
    //newSymbol->category = category;
    newSymbol->next = NULL;
    return newSymbol;
}

char *findName(Tree *parseTree)
{
    if(!strcmp(parseTree->prodrule, "Identifier"))
    {
        return parseTree->leaf->text;
    }
    int i;
    for(i=0; i<parseTree->nkids; i++)
    {
        if(parseTree->kids[i] != NULL)
	{
	    char *result = NULL;
	    result = findName(parseTree->kids[i]);
	    if(result)
	        return result;
	}
    }
    return 0;
}

int buildSymbolTable(Tree *parseTree)
{
    pushScope(newScope());
    int scanResult = scanTree(parseTree);
    popScope();
}

int scanTree(Tree *parseTree)
{
    /* check for new nested scope */
    if(isNewScope(parseTree))
    {
	    /*mangle the prod rule so we dont enter a recursive loop*/
	parseTree->prodrule = "mangled";
	buildSymbolTable(parseTree);
    }
    if(isDeclaration(parseTree))
    {
        return insertSymbol(newSymbol(parseTree));
    }
    else if(isSymbolReference(parseTree))
    {
        int returnCode = symbolExistsInScope(parseTree->leaf->text);
	if(returnCode == 0) 
	{
            printf("error: %s has not been declared\n", parseTree->leaf->text);
	    return 0;
	}
    }
    int i;
    for(i=0; i<parseTree->nkids; i++)
    {
        Tree **kids = parseTree->kids;
	if(kids[i] != NULL)
	{
	    if(scanTree(kids[i]))
	    {
	        return 1;
	    }
	}
    }
    return 0;
}

int isDeclaration(Tree *parseTree)
{
    if(
        !strcmp(parseTree->prodrule, "declarator_id") || 
        !strcmp(parseTree->prodrule, "class_head")
	)
    {
        return 1;
    }
    return 0;
}

int isNewScope(Tree *parseTree)
{
    if(
        !strcmp(parseTree->prodrule, "function_definition") || 
        !strcmp(parseTree->prodrule, "member_specificatoin_opt")
	)
    {
        return 1;
    }
    return 0;
}

int isSymbolReference(Tree *parseTree)
{
    if(!strcmp(parseTree->prodrule, "Identifier"))
    {
        return 1;
    }
    return 0;
}
