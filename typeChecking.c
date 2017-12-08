#include "tree.h"
#include "symbolTable.h"
#include "typeChecking.h"


int typeCheckTree(Tree *tree)
{
    //check if we have entered a new symbol table and add it to the symbol table stack if we have.
    Scope *newScope = isScope(tree);
    if(newScope)
    {
         pushScope(newScope);
    }
    // check for arithmetic statements
    if(!strcmp(tree->prodrule, "example statement prodrule"))
    {
        TypeList *typeList = findAllTypes(tree);
	return compareTypes(typeList);
    }
    int i;
    int returnCode = 0;
    for(i=0; i<tree->nkids; i++)
    {
       returnCode += typeCheckTree(tree->kids[i]); 
    }
    //TODO print all tokens in this tree
    if(returnCode)
    {
        printf("Error");
        //printAllTokens(tree);
    }
    popScope()
    return returnCode;
}

/* Type prodrules:
 * integer_literal
 * simple_type_specifier
 */
    //find all tokens and check if they are symbols in the symbolTable
TypeList *findAllTypes(Tree *tree)
{
    TypeList *typeList = NULL;
    if(!strcmp(tree->prodrule, "Identifier"))
    {
        Symbol *symbol = findSymbol(tree->leaf->text);
	if(symbol)
	{
            typeList = pushType(symbol->type);
	}
    }
    else if(!strcmp(tree->prodrule, "integer_literal"))
    {
    }
}

TypeList *pushType(TypeList *typeList, char *type)
{
    Typelist *typeItem = malloc(sizeof(TypeList));
    typeItem->next = typeList;
}

int compareTypes(TypeList *typeList)
{
    TypeList *type = typeList;
    while(type)
    {
        if(strcmp(type->type, type->next->type)
	{
	    return 1;
	}
	type = type->next;
    }
    return 0;
}

Scope *isScope(Tree *tree)
{
    Scope *scope = currentScope;
    while(scope)
    {
        if(scope->id == tree)
	{
	    return scope;
	}
	scope = scope->next;
    }
    return NULL;
}

Symbol *findSymbol(char *symbolName)
{
    int hashValue = hash(symbolName);
    Scope *scope = currentScope;
    while(scope)
    {
        Symbol *currentSymbol = scope->hashTable[hashValue];
	while(currentSYmbol)
	{
	    if(!strcmp(currentSymbol->name, symbolName))
	    {
	        return currentSymbol;
	    }
	    currentSymbol = currentSymbol->next;
	}
	scope = scope->next;
    }
    return NULL;
}
