#ifndef TYPECHECKING
#define TYPECHECKING

//enum types {char_type, int_type, double_type, void_type, charpointer_type}
typedef struct TypesStruct
{
    //enum types type;
    char *type;
    struct TypesStruct *next;
} TypeList;

int typeCheckTree(Tree *tree);
TypeList *findAllTypes(Tree *tree);
int compareTypes(TypeList *typeList);
Scope *isScope(Tree *tree);
Symbol *findSymbol(char *symbolName);
Typelist *pushType(TypeList *typeList, char *type);

#endif
