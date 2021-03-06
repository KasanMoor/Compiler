#include "tree.h"
#include "symbolTable.h"
#include "typeChecking.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>


int typeCheckTree(Tree *tree)
{
    //check if we have entered a new symbol table and add it to the symbol table stack if we have.
    //printf("typeCheckTree\n");
    Scope *newScope = isScope(tree);
    if(newScope)
    {
         pushScope(newScope);
    }
    // check for arithmetic statements
    if(!strcmp(tree->prodrule, "expression"))
    {
        typeList = NULL;
        findAllTypes(tree);
	return compareTypes(typeList);
    }
    int i;
    int returnCode = 0;
    for(i=0; i<tree->nkids; i++)
    {
        if(tree->kids[i] != NULL)
	{
            returnCode += typeCheckTree(tree->kids[i]); 
	}
    }
    //TODO print all tokens in this tree
    if(returnCode)
    {
        //printf("Error");
        //printAllTokens(tree);
    }
    if(newScope)
    {
        popScope();
    }
    return returnCode;
}

/* Type prodrules:
 * integer_literal
 * simple_type_specifier
 */
    //find all tokens and check if they are symbols in the symbolTable
void findAllTypes(Tree *tree)
{
    //TODO free typelist
    if(!strcmp(tree->prodrule, "Identifier"))
    {
        Symbol *symbol = findSymbol(tree->leaf->text);
	if(symbol)
	{
            pushType(newType(symbol->type));
	}
    }
    else if(!strcmp(tree->prodrule, "integer_literal"))
    {
        pushType(newType("int"));
    }
    else if(!strcmp(tree->prodrule, "character_literal"))
    {
        pushType(newType("char"));
    }
    else if(!strcmp(tree->prodrule, "floating_literal"))
    {
        pushType(newType("double"));
    }
    int i;
    for(i=0; i<tree->nkids; i++)
    {
        if(tree->kids[i] != NULL)
	{
            findAllTypes(tree->kids[i]); 
	}
    }
}

TypeList *newType(char *type)
{
    TypeList *typeList = malloc(sizeof(TypeList));
    typeList->type = type;
    typeList->next = NULL;
    return typeList;
}

void pushType(TypeList *type)
{
    type->next = typeList;
    typeList = type;
}

int compareTypes(TypeList *typeList)
{
    TypeList *type = typeList;
    // iterate over the list of found types in the statement;
    while(type)
    {
        // if there are two items to compare, this and next
        if(type != NULL && type->next != NULL)
	{
	    // if they aren't equal (type mismatch);
            if(strcmp(type->type, type->next->type))
	    {
	        semanticError = 1;
	        printf("Error: type mismatch %s, %s\n", type->type, type->next->type);
	        return 1;
	    }
	}
	type = type->next;
    }
    return 0;
}

Scope *isScope(Tree *tree)
{
    /* walk through the old scope list to find if any scopes match the 
     * one we just entered (Assuming that any tree could be a scope)
     * We are painstakingly recreating the stack of scopes
     */
    Scope *scope = oldScopesList;
    while(scope)
    {
        /* if the pointer to the tree we just entered is the 
	 * tree that was used to create this scope in the 
	 * old scopes list (meaning this sub tree is a scope)
	 */
        if(scope->id == tree)
	{
	    if(scope->last) 
            {
	        // the scope is sandwiched
	        if(scope->next)
		{
	            scope->last->next = scope->next;
		    scope->next->last = scope->last;
		    scope->next = NULL;
		// the scope is last in the list
		} else
		{
		    scope->last->next = NULL;
		}
	    /* it must be the first one in the list or only 
	     * point next last to null 
	     */
	    } else 
	    {
	        if(scope->next)
		{
		    scope->next->last = NULL;
		}
	        oldScopesList = scope->next;
		scope->next = NULL;
	    }
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
	while(currentSymbol)
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
