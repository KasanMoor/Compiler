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
    if(DEBUG)
    {
        printf("inserting symbol: %s\n", newSymbol->name);
    }
    if(symbolExistsInScope(newSymbol->name))
    {
        printf("error: %s already declared\n", newSymbol->name);
        return 0;
    }
    int hashValue = hash(newSymbol->name);
    Symbol *bucketHead = currentScope->hashTable[hashValue];
    newSymbol->next = bucketHead;
    currentScope->hashTable[hashValue] = newSymbol;
    return 1;
}

// TODO make this recursive over all nested scopes
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

Scope *newScope(char *name)
{
    Scope *newScope = (Scope *)malloc(sizeof(Scope));
    newScope->name = name;
    newScope->next = NULL;
    return newScope;
}

Symbol *newSymbol(char *type, Tree *parseTree)
{
    Symbol *newSymbol = (Symbol *)malloc(sizeof(Symbol));
    newSymbol->name = findName(parseTree);
    newSymbol->type = type;
    newSymbol->next = NULL;
    if(DEBUG) {
        printf("newSymbol: %s %s\n", parseTree->prodrule, newSymbol->name);
    }
    return newSymbol;
}


/* find the name of a symbol thats being referenced
 * we end up here when we define a new symbol from a 
 * parse tree containing the symbol name as the only
 * prodrule Identifier
 */
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
    pushScope(newScope(parseTree->prodrule));
    if(!strcmp(currentScope->name, "translation_unit")) {
        Tree *mainTree = newTree("mainTree");
        //Token *mainToken = (Token *)malloc(sizeof(Token));
	//mainToken->text = "main";
	//mainTree->leaf = mainToken;
	mainTree->nkids = 0;
	Symbol *mainSymbol = (Symbol *)malloc(sizeof(Symbol));
	mainSymbol->name = "main";
	mainSymbol->type = "int";
	mainSymbol->next = NULL;
        insertSymbol(mainSymbol);
    }
    int scanResult = scanTree(parseTree);
    popScope();
    return scanResult;
}

/* the three states we can spect to encounter
 * when scanning the tree for symbols are
 * find a new scope
 * find a declaration
 * find symbol reference
 */
int scanTree(Tree *parseTree)
{
    /* debuging information */
    if(DEBUG) {
        printf("%s\n", parseTree->prodrule);
        if(parseTree->leaf) 
        {
            printf("%s\n", parseTree->leaf->text);
        }
    }

    /* check for new nested scope 
     * this includes
     * class definition
     * function definition
     * */
    if(isNewScope(parseTree))
    {
	/*mangle the prod rule so we dont enter a recursive loop*/
	if(DEBUG) {
	    printf("pushing new symbol table\n");
	}
	parseTree->prodrule = "mangled";
	return buildSymbolTable(parseTree);
    }

    /* Declaring a new symbol:
     * find the type
     * find all symbol names
     * insert into symbol table
     */
    if(isDeclaration(parseTree))
    {
        if(DEBUG) {
            printf("found new declaration %s\n", 
	        parseTree->prodrule);
	}
        return insertSymbols(parseTree);
    }

    /* found symbol reference
     * see if symbol exists
     * typecheck
     */
    else if(isSymbolReference(parseTree))
    {
        if(DEBUG) {
            printf("found Symbol reference\n");
	}
        int returnCode = symbolExistsInScope(parseTree->leaf->text);
	if(returnCode == 0) 
	{
            printf("At line %d, Error: %s has not been declared\n", 
	        parseTree->leaf->lineNumber,
		parseTree->leaf->text);
	    return 0;
	} else {
	    if(DEBUG) {
	        printf("success: Symbol exists in scope");
	    }
	}
  }
    int i;
    for(i=0; i<parseTree->nkids; i++)
    {
        Tree **kids = parseTree->kids;
	if(kids[i] != NULL)
	{
            scanTree(kids[i]);
	}
    }
    return 0;
}

int insertSymbols(Tree *parseTree)
{
    // scan for type and store
    char *type = findType(parseTree);
    // scan for names
    /* to find names need to find
     * init_declarator
     * member_declarator
     * class_head
     */
     return findAndInsertSymbols(type, parseTree);
}

int findAndInsertSymbols(char *type, Tree *parseTree)
{
    if(isNewSymbol(parseTree->prodrule))
    {
        Symbol *symbol = newSymbol(type, parseTree);
        if(!insertSymbol(symbol))
            // If we find a symbol that is already defined
	    return 3;
    }
    int i;
    for(i=0; i<parseTree->nkids; i++)
    {
        Tree** kids = parseTree->kids;
	if(kids[i] != NULL)
	{
	    findAndInsertSymbols(type, kids[i]);
	}
    }
}

int isNewSymbol(char *prodrule)
{
    if( !strcmp(prodrule, "init_declarator") ||
        !strcmp(prodrule, "member_declarator") ||
        !strcmp(prodrule, "class_head") 
        )
    {
        return 1;
    } else
    {
        return 0;
    }
}

char *findType(Tree *parseTree)
{
    /* search for simple_type_specifier */
    Tree *type = findProdRule(parseTree, "simple_type_specifier");
    return type->kids[0]->leaf->text;
}

Tree *findProdRule(Tree *parseTree, char *prodrule)
{
    if(!strcmp(prodrule, parseTree->prodrule))
    {
        return parseTree;
    }
    int i;
    for(i=0; i<parseTree->nkids; i++)
    {
        Tree **kids = parseTree->kids;
        if(kids[i] != NULL)
	{
	    Tree *returnTree =
	        findProdRule(kids[i], prodrule);
            if(returnTree);
	        return returnTree;
	}
    }  
    return NULL;
}

int isDeclaration(Tree *parseTree)
{
    /* decl_specifier includes type and all included decls
     * this includes:
     * int one, two
     * int hi
     * int main()
     * class hello
     */
    if(
        !strcmp(parseTree->prodrule, "declaration_statement") ||
	!strcmp(parseTree->prodrule, "simple_declaration") ||
	!strcmp(parseTree->prodrule, "decl_specifier")
        )
    {
        return 1;
    }
    return 0;
}

int isNewScope(Tree *parseTree)
{
    if(
        !strcmp(parseTree->prodrule, "function_body") || 
        !strcmp(parseTree->prodrule, "class_body")
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
