#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "120gram.h"

extern char *yytext;

Tree *newTerm(char *prodrule, Tree* leaf) {
    Tree *tree = (Tree *)newTree(prodrule);
    tree->leaf = leaf;
}

Tree *newNonTerm(char *prodrule, int nkids, Tree *kid0, Tree *kid1, Tree *kid2, Tree *kid3, Tree *kid4, Tree *kid5, Tree *kid6, Tree *kid7, Tree *kid8) {
    Tree *tree = newTree(prodrule);
    tree->nkids = nkids;
    tree->kids[0] = kid0;
    tree->kids[1] = kid1;
    tree->kids[2] = kid2;
    tree->kids[3] = kid3;
    tree->kids[4] = kid4;
    tree->kids[5] = kid5;
    tree->kids[6] = kid6;
    tree->kids[7] = kid7;
    tree->kids[8] = kid8;
    return tree;
}

Tree *newTree(char *prodrule) {
    Tree *tree = (Tree *)malloc(sizeof(Tree));
    tree->kids = (Tree *)malloc(DEFAULT_KID_SIZE * sizeof(Tree));
    tree->prodrule = prodrule;
    tree->nkids = 0;
    tree->maxKids = DEFAULT_KID_SIZE;
    tree->leaf = NULL;
    return tree;
}

Token *newToken(int returnCode,
                char *fileName,
		int lineNumber) {
    Token *token = (Token *)malloc(sizeof(Token));
    token->category = returnCode;
    token->text = strdup(yytext);
    token->fileName = fileName;
    token->lineNumber = lineNumber;
    return token;
}
/*
void addKid(Tree *tree, Tree *kid) {
    tree->nkids++;
    if(tree->nkids >= tree->maxKids) {
        tree->maxKids = increaseKidSize(tree);
    }
    tree->kids[tree->nkids] = kid;
}
*/
void printTree(int depth, Tree *tree) {
    int depth_i;
    for(depth_i = 0; depth_i < depth; depth_i++) {
        printf("%d ", depth_i);
    }
    printf("%s ", tree->prodrule);
    if(tree->leaf != NULL) {
        printf("%s", tree->leaf->text);
    }
    printf("\n");
    int i; 
    depth++;
    for(i=0; i<tree->nkids; i++) {
        Tree **kids = tree->kids;
	if(kids[i] != NULL )
	{
	    printTree(depth, kids[i]);
	}
    }
}
