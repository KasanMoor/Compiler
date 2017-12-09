#ifndef TYPECHECKING
#define TYPECHECKING

//enum types {char_type, int_type, double_type, void_type, charpointer_type}
typedef struct TypesStruct
{
    //enum types type;
    char *type;
    struct TypesStruct *next;
} TypeList;

TypeList *typeList;

int typeCheckTree(Tree *tree);
void findAllTypes(Tree *tree);
int compareTypes(TypeList *typeList);
Scope *isScope(Tree *tree);
Symbol *findSymbol(char *symbolName);
void pushType(TypeList *type);
TypeList *newType(char *type);

#endif
