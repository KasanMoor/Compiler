/*
 * Grammar for 120++, a subset of C++ used in CS 120 at University of Idaho
 *
 * Adaptation by Clinton Jeffery, with help from Matthew Brown, Ranger
 * Adams, and Shea Newton.
 *
 * Based on Sandro Sigala's transcription of the ISO C++ 1996 draft standard.
 * 
 */

/*	$Id: parser.y,v 1.3 1997/11/19 15:13:16 sandro Exp $	*/

/*
 * Copyright (c) 1997 Sandro Sigala <ssigala@globalnet.it>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * ISO C++ parser.
 *
 * Based on the ISO C++ draft standard of December '96.
 */

%{
#include <stdio.h>
#include <string.h>

/* define symbols for non-terminals or grammar production rules */
//#include "nonterm.h"

/* define a syntax tree data type */
#include "tree.h"
#include "symbolTable.h"

extern FILE *yyin;
extern int lineno;
extern char *yytext;
#define YYDEBUG 0
int yydebug=0;
Tree *root;

static void yyerror(char *s);


%}

%define parse.error verbose

%union {
  Tree *t;
  char *text;
  int *n;
  }

%type < t > typedef_name
%type < t > namespace_name
%type < t > class_body
%type < t > original_namespace_name
%type < t > class_name
%type < t > enum_name
%type < t > template_name
%type < t > identifier
%type < t > literal
%type < t > integer_literal
%type < t > character_literal
%type < t > floating_literal
%type < t > string_literal
%type < t > boolean_literal
%type < t > translation_unit
%type < t > primary_expression
%type < t > id_expression
%type < t > unqualified_id
%type < t > qualified_id
%type < t > nested_name_specifier
%type < t > postfix_expression
%type < t > expression_list
%type < t > unary_expression
%type < t > unary_operator
%type < t > new_expression
%type < t > new_placement
%type < t > new_type_id
%type < t > new_declarator
%type < t > direct_new_declarator
%type < t > new_initializer
%type < t > delete_expression
%type < t > cast_expression
%type < t > pm_expression
%type < t > multiplicative_expression
%type < t > additive_expression
%type < t > shift_expression
%type < t > relational_expression
%type < t > equality_expression
%type < t > and_expression
%type < t > exclusive_or_expression
%type < t > inclusive_or_expression
%type < t > logical_and_expression
%type < t > logical_or_expression
%type < t > conditional_expression
%type < t > assignment_expression
%type < t > assignment_operator
%type < t > expression
%type < t > constant_expression
%type < t > statement
%type < t > labeled_statement
%type < t > expression_statement
%type < t > compound_statement
%type < t > statement_seq
%type < t > selection_statement
%type < t > condition
%type < t > iteration_statement
%type < t > for_init_statement
%type < t > jump_statement
%type < t > declaration_statement
%type < t > declaration_seq
%type < t > declaration
%type < t > block_declaration
%type < t > simple_declaration
%type < t > decl_specifier
%type < t > decl_specifier_seq
%type < t > storage_class_specifier
%type < t > function_specifier
%type < t > type_specifier
%type < t > simple_type_specifier
%type < t > type_name
%type < t > elaborated_type_specifier
%type < t > enum_specifier
%type < t > enumerator_list
%type < t > enumerator_definition
%type < t > enumerator
%type < t > namespace_definition
%type < t > named_namespace_definition
%type < t > original_namespace_definition
%type < t > extension_namespace_definition
%type < t > unnamed_namespace_definition
%type < t > namespace_body
%type < t > namespace_alias
%type < t > namespace_alias_definition
%type < t > qualified_namespace_specifier
%type < t > using_declaration
%type < t > using_directive
%type < t > asm_definition
%type < t > linkage_specification
%type < t > init_declarator_list
%type < t > init_declarator
%type < t > declarator
%type < t > direct_declarator
%type < t > ptr_operator
%type < t > cv_qualifier_seq
%type < t > cv_qualifier
%type < t > declarator_id
%type < t > type_id
%type < t > type_specifier_seq
%type < t > abstract_declarator
%type < t > direct_abstract_declarator
%type < t > parameter_declaration_clause
%type < t > parameter_declaration_list
%type < t > parameter_declaration
%type < t > function_definition
%type < t > function_body
%type < t > initializer
%type < t > initializer_clause
%type < t > initializer_list
%type < t > class_specifier
%type < t > class_head
%type < t > class_key
%type < t > member_specification
%type < t > member_declaration
%type < t > member_declarator_list
%type < t > member_declarator
%type < t > pure_specifier
%type < t > constant_initializer
%type < t > base_clause
%type < t > base_specifier_list
%type < t > base_specifier
%type < t > access_specifier
%type < t > conversion_function_id
%type < t > conversion_type_id
%type < t > conversion_declarator
%type < t > ctor_initializer
%type < t > mem_initializer_list
%type < t > mem_initializer
%type < t > mem_initializer_id
%type < t > operator_function_id
%type < t > operator
%type < t > template_declaration
%type < t > template_parameter_list
%type < t > template_parameter
%type < t > type_parameter
%type < t > template_id
%type < t > template_argument_list
%type < t > template_argument
%type < t > explicit_instantiation
%type < t > explicit_specialization
%type < t > try_block
%type < t > function_try_block
%type < t > handler_seq
%type < t > handler
%type < t > exception_declaration
%type < t > throw_expression
%type < t > exception_specification
%type < t > type_id_list
%type < t > declaration_seq_opt
%type < t > nested_name_specifier_opt
%type < t > expression_list_opt
%type < t > COLONCOLON_opt
%type < t > new_placement_opt
%type < t > new_initializer_opt
%type < t > new_declarator_opt
%type < t > expression_opt
%type < t > statement_seq_opt
%type < t > condition_opt
%type < t > enumerator_list_opt
%type < t > initializer_opt
%type < t > constant_expression_opt
%type < t > abstract_declarator_opt
%type < t > type_specifier_seq_opt
%type < t > direct_abstract_declarator_opt
%type < t > ctor_initializer_opt
%type < t > COMMA_opt
%type < t > member_specification_opt
%type < t > SEMICOLON_opt
%type < t > conversion_declarator_opt
%type < t > EXPORT_opt
%type < t > handler_seq_opt
%type < t > assignment_expression_opt
%type < t > type_id_list_opt 

%type < t > IDENTIFIER INTEGER FLOATING CHARACTER STRING
%type < t > TYPEDEF_NAME NAMESPACE_NAME CLASS_NAME ENUM_NAME TEMPLATE_NAME

%type < t > ELLIPSIS COLONCOLON DOTSTAR ADDEQ SUBEQ MULEQ DIVEQ MODEQ
%type < t > XOREQ ANDEQ OREQ SL SR SREQ SLEQ EQ NOTEQ LTEQ GTEQ ANDAND OROR
%type < t > PLUSPLUS MINUSMINUS ARROWSTAR ARROW
%type < t > ASM AUTO BOOL BREAK CASE CATCH CHAR CLASS CONST CONST_CAST CONTINUE
%type < t > DEFAULT DELETE DO DOUBLE DYNAMIC_CAST ELSE ENUM EXPLICIT EXPORT EXTERN
%type < t > FALSE FLOAT FOR FRIEND GOTO IF INLINE INT LONG MUTABLE NAMESPACE NEW
%type < t > OPERATOR PRIVATE PROTECTED PUBLIC REGISTER REINTERPRET_CAST RETURN
%type < t > SHORT SIGNED SIZEOF STATIC STATIC_CAST STRUCT SWITCH TEMPLATE THIS
%type < t > THROW TRUE TRY TYPEDEF TYPEID TYPENAME UNION UNSIGNED USING VIRTUAL
%type < t > VOID VOLATILE WCHAR_T WHILE

%type < t > '=' '+' '-' '_' ')' '(' '*' '&' '^' '%' '$' '#' '@' '!' '~'
%type < t > '[' ']' '\\' '\'' '{' '}' '|' ';' ':' '"' ',' '.' '/' '?' '<' '>' '0'


%token IDENTIFIER INTEGER FLOATING CHARACTER STRING
%token TYPEDEF_NAME NAMESPACE_NAME CLASS_NAME ENUM_NAME TEMPLATE_NAME

%token ELLIPSIS COLONCOLON DOTSTAR ADDEQ SUBEQ MULEQ DIVEQ MODEQ
%token XOREQ ANDEQ OREQ SL SR SREQ SLEQ EQ NOTEQ LTEQ GTEQ ANDAND OROR
%token PLUSPLUS MINUSMINUS ARROWSTAR ARROW

%token ASM AUTO BOOL BREAK CASE CATCH CHAR CLASS CONST CONST_CAST CONTINUE
%token DEFAULT DELETE DO DOUBLE DYNAMIC_CAST ELSE ENUM EXPLICIT EXPORT EXTERN
%token FALSE FLOAT FOR FRIEND GOTO IF INLINE INT LONG MUTABLE NAMESPACE NEW
%token OPERATOR PRIVATE PROTECTED PUBLIC REGISTER REINTERPRET_CAST RETURN
%token SHORT SIGNED SIZEOF STATIC STATIC_CAST STRUCT SWITCH TEMPLATE THIS
%token THROW TRUE TRY TYPEDEF TYPEID TYPENAME UNION UNSIGNED USING VIRTUAL
%token VOID VOLATILE WCHAR_T WHILE

%start translation_unit

%%

/*----------------------------------------------------------------------
 * Context-dependent identifiers.
 *----------------------------------------------------------------------*/

typedef_name:
	/* identifier */
	TYPEDEF_NAME { $$ = newNonTerm("typedef_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

namespace_name:
	original_namespace_name { $$ = newNonTerm("namespace_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

original_namespace_name:
	/* identifier */
	NAMESPACE_NAME { $$ = newNonTerm("original_namespace_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

class_name:
	/* identifier */
	CLASS_NAME { $$ = newNonTerm("class_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_id { $$ = newNonTerm("class_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

enum_name:
	/* identifier */
	ENUM_NAME { $$ = newNonTerm("enum_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

template_name:
	/* identifier */
	TEMPLATE_NAME { $$ = newNonTerm("template_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Lexical elements.
 *----------------------------------------------------------------------*/

identifier:
	IDENTIFIER { $$ = newNonTerm("identifier",1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

literal:
	integer_literal  { $$ = newNonTerm("literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| character_literal { $$ = newNonTerm("literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| floating_literal { $$ = newNonTerm("literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| string_literal { $$ = newNonTerm("literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| boolean_literal { $$ = newNonTerm("literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

integer_literal:
	INTEGER { $$ = newNonTerm("integer_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

character_literal:
	CHARACTER { $$ = newNonTerm("character_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

floating_literal:
	FLOATING { $$ = newNonTerm("floating_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

string_literal:
	STRING { $$ = newNonTerm("string_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

boolean_literal:
	TRUE { $$ = newNonTerm("boolean_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| FALSE { $$ = newNonTerm("boolean_literal", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Translation unit.
 *----------------------------------------------------------------------*/

translation_unit:
	declaration_seq_opt { $$ = newNonTerm("translation_unit",  1, $1, NULL, NULL , NULL, NULL, NULL, NULL, NULL, NULL);
                              root = $$;
                              printTree(0, root);
			      currentScope = NULL;
			      buildSymbolTable(root);}
	;

/*----------------------------------------------------------------------
 * Expressions.
 *----------------------------------------------------------------------*/

primary_expression:
	literal { $$ = newNonTerm("primary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| THIS { $$ = newNonTerm("primary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '(' expression ')' { $$ = newNonTerm("primary_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| id_expression { $$ = newNonTerm("primary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

id_expression:
	unqualified_id { $$ = newNonTerm("id_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| qualified_id { $$ = newNonTerm("id_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

unqualified_id:
	identifier { $$ = newNonTerm("unqualified_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| operator_function_id { $$ = newNonTerm("unqualified_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| conversion_function_id { $$ = newNonTerm("unqualified_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '~' class_name { $$ = newNonTerm("unqualified_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

qualified_id:
	nested_name_specifier unqualified_id { $$ = newNonTerm("qualified_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier TEMPLATE unqualified_id  { $$ = newNonTerm("qualified_id", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

nested_name_specifier:
	class_name COLONCOLON nested_name_specifier { $<t>$ = newNonTerm("nested_name_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	namespace_name COLONCOLON nested_name_specifier { $$ = newNonTerm("nested_name_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_name COLONCOLON { $$ = newNonTerm("nested_name_specifier",2 , $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| namespace_name COLONCOLON { $$ = newNonTerm("nested_name_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

postfix_expression:
	primary_expression { $$ = newNonTerm("postfix_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '[' expression ']' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '(' expression_list_opt ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| DOUBLE '(' expression_list_opt ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| INT '(' expression_list_opt ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| CHAR '(' expression_list_opt ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| BOOL '(' expression_list_opt ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '.' TEMPLATE COLONCOLON id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '.' TEMPLATE id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '.' COLONCOLON id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression '.' id_expression { $$ = newNonTerm("postfix_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression ARROW TEMPLATE COLONCOLON id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression ARROW TEMPLATE id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression ARROW COLONCOLON id_expression { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression ARROW id_expression  { $$ = newNonTerm("postfix_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression PLUSPLUS { $$ = newNonTerm("postfix_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| postfix_expression MINUSMINUS { $$ = newNonTerm("postfix_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DYNAMIC_CAST '<' type_id '>' '(' expression ')' { $$ = newNonTerm("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| STATIC_CAST '<' type_id '>' '(' expression ')' { $$ = newNonTerm("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| REINTERPRET_CAST '<' type_id '>' '(' expression ')' { $$ = newNonTerm("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| CONST_CAST '<' type_id '>' '(' expression ')' { $$ = newNonTerm("postfix_expression", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| TYPEID '(' expression ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| TYPEID '(' type_id ')' { $$ = newNonTerm("postfix_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

expression_list:
	assignment_expression { $$ = newNonTerm("expression_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| expression_list ',' assignment_expression { $$ = newNonTerm("expression_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

unary_expression:
	postfix_expression { $$ = newNonTerm("unary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| PLUSPLUS cast_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MINUSMINUS cast_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '*' cast_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '&' cast_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| unary_operator cast_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SIZEOF unary_expression { $$ = newNonTerm("unary_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SIZEOF '(' type_id ')' { $$ = newNonTerm("unary_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| new_expression { $$ = newNonTerm("unary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| delete_expression { $$ = newNonTerm("unary_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

unary_operator:
	  '+' { $$ = newNonTerm("unary_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '-' { $$ = newNonTerm("unary_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '!' { $$ = newNonTerm("unary_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '~' { $$ = newNonTerm("unary_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_expression:
	  NEW new_placement_opt new_type_id new_initializer_opt { $$ = newNonTerm("new_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON NEW new_placement_opt new_type_id new_initializer_opt{ $$ = newNonTerm("new_expression", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| NEW new_placement_opt '(' type_id ')' new_initializer_opt{ $$ = newNonTerm("new_expression", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| COLONCOLON NEW new_placement_opt '(' type_id ')' new_initializer_opt{ $$ = newNonTerm("new_expression", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	;

new_placement:
	'(' expression_list ')' { $$ = newNonTerm("new_placement", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_type_id:
	type_specifier_seq new_declarator_opt { $$ = newNonTerm("new_type_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_declarator:
	ptr_operator new_declarator_opt { $$ = newNonTerm("new_declarator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| direct_new_declarator { $$ = newNonTerm("new_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

direct_new_declarator:
	'[' expression ']' { $$ = newNonTerm("direct_new_declarator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| direct_new_declarator '[' constant_expression ']' { $$ = newNonTerm("direct_new_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

new_initializer:
	'(' expression_list_opt ')'  { $$ = newNonTerm("new_initializer", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

delete_expression:
	  DELETE cast_expression { $$ = newNonTerm("delete_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON DELETE cast_expression { $$ = newNonTerm("delete_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DELETE '[' ']' cast_expression { $$ = newNonTerm("delete_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON DELETE '[' ']' cast_expression { $$ = newNonTerm("delete_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

cast_expression:
	unary_expression { $$ = newNonTerm("cast_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '(' type_id ')' cast_expression { $$ = newNonTerm("cast_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

pm_expression:
	cast_expression { $$ = newNonTerm("pm_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| pm_expression DOTSTAR cast_expression { $$ = newNonTerm("pm_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| pm_expression ARROWSTAR cast_expression { $$ = newNonTerm("pm_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

multiplicative_expression:
	pm_expression { $$ = newNonTerm("multiplicative_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| multiplicative_expression '*' pm_expression { $$ = newNonTerm("multiplicative_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| multiplicative_expression '/' pm_expression { $$ = newNonTerm("multiplicative_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| multiplicative_expression '%' pm_expression { $$ = newNonTerm("multiplicative_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

additive_expression:
	multiplicative_expression { $$ = newNonTerm("additive_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| additive_expression '+' multiplicative_expression { $$ = newNonTerm("additive_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| additive_expression '-' multiplicative_expression { $$ = newNonTerm("additive_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

shift_expression:
	additive_expression { $$ = newNonTerm("shift_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| shift_expression SL additive_expression { $$ = newNonTerm("shift_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| shift_expression SR additive_expression { $$ = newNonTerm("shift_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

relational_expression:
	shift_expression { $$ = newNonTerm("relational_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| relational_expression '<' shift_expression { $$ = newNonTerm("relational_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| relational_expression '>' shift_expression { $$ = newNonTerm("relational_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| relational_expression LTEQ shift_expression { $$ = newNonTerm("relational_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| relational_expression GTEQ shift_expression { $$ = newNonTerm("relational_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

equality_expression:
	relational_expression { $$ = newNonTerm("equality_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| equality_expression EQ relational_expression { $$ = newNonTerm("equality_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| equality_expression NOTEQ relational_expression { $$ = newNonTerm("equality_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

and_expression:
	equality_expression { $$ = newNonTerm("and_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| and_expression '&' equality_expression { $$ = newNonTerm("and_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

exclusive_or_expression:
	and_expression { $$ = newNonTerm("and_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| exclusive_or_expression '^' and_expression { $$ = newNonTerm("and_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

inclusive_or_expression:
	exclusive_or_expression { $$ = newNonTerm("inclusive_or_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| inclusive_or_expression '|' exclusive_or_expression { $$ = newNonTerm("inclusive_or_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

logical_and_expression:
	inclusive_or_expression { $$ = newNonTerm("logical_and_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| logical_and_expression ANDAND inclusive_or_expression { $$ = newNonTerm("logical_and_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

logical_or_expression:
	logical_and_expression { $$ = newNonTerm("logical_or_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| logical_or_expression OROR logical_and_expression { $$ = newNonTerm("logical_or_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

conditional_expression:
	logical_or_expression { $$ = newNonTerm("conditional_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| logical_or_expression  '?' expression ':' assignment_expression
	;

assignment_expression:
	conditional_expression { $$ = newNonTerm("assignment_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| logical_or_expression assignment_operator assignment_expression { $$ = newNonTerm("assignment_expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| throw_expression { $$ = newNonTerm("assignment_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

assignment_operator:
	'=' { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MULEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DIVEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MODEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ADDEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SUBEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SREQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SLEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ANDEQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| XOREQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| OREQ { $$ = newNonTerm("assignment_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

expression:
	assignment_expression { $$ = newNonTerm("expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| expression ',' assignment_expression { $$ = newNonTerm("expression", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

constant_expression:
	conditional_expression { $$ = newNonTerm("constant_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Statements.
 *----------------------------------------------------------------------*/

statement:
	labeled_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| expression_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| compound_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| selection_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| iteration_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| jump_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| declaration_statement { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| try_block { $$ = newNonTerm("statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

labeled_statement:
	identifier ':' statement { $$ = newNonTerm("labeled_statement", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| CASE constant_expression ':' statement { $$ = newNonTerm("labeled_statement", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| DEFAULT ':' statement
	;

expression_statement:
	expression_opt ';' { $$ = newNonTerm("expression_statement", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

compound_statement:
	'{' statement_seq_opt '}' { $$ = newNonTerm("expression_statement", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

statement_seq:
	statement { $$ = newNonTerm("expression_statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| statement_seq statement { $$ = newNonTerm("expression_statement", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

selection_statement:
	IF '(' condition ')' statement { $$ = newNonTerm("selection_statement", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| IF '(' condition ')' statement ELSE statement { $$ = newNonTerm("selection_statement", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| SWITCH '(' condition ')' statement { $$ = newNonTerm("selection_statement", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

condition:
	expression { $$ = newNonTerm("condition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_specifier_seq declarator '=' assignment_expression { $$ = newNonTerm("condition", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

iteration_statement:
	WHILE '(' condition ')' statement { $$ = newNonTerm("iteration_statement", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| DO statement WHILE '(' expression ')' ';' { $$ = newNonTerm("iteration_statement", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	| FOR '(' for_init_statement condition_opt ';' expression_opt ')' statement { $$ = newNonTerm("iteration_statement", 8, $1, $2, $3, $4, $5, $6, $7, $8, NULL); }
	;

for_init_statement:
	expression_statement { $$ = newNonTerm("for_init_statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| simple_declaration { $$ = newNonTerm("for_init_statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

jump_statement:
	BREAK ';' { $$ = newNonTerm("jump_statement", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| CONTINUE ';' { $$ = newNonTerm("jump_statement", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| RETURN expression_opt ';'  { $$ = newNonTerm("jump_statement", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| GOTO identifier ';' { $$ = newNonTerm("jump_statement", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

declaration_statement:
	block_declaration { $$ = newNonTerm("declaration_statement", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Declarations.
 *----------------------------------------------------------------------*/

declaration_seq:
	declaration { $$ = newNonTerm("declaration_seq", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| declaration_seq declaration { $$ = newNonTerm("declaration_seq", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

declaration:
	block_declaration { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| function_definition { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_declaration { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| explicit_instantiation { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| explicit_specialization { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| linkage_specification { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| namespace_definition { $$ = newNonTerm("declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

block_declaration:
	simple_declaration { $$ = newNonTerm("block_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| asm_definition { $$ = newNonTerm("block_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| namespace_alias_definition { $$ = newNonTerm("block_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| using_declaration { $$ = newNonTerm("block_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| using_directive { $$ = newNonTerm("block_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

simple_declaration:
	  decl_specifier_seq init_declarator_list ';' { $$ = newNonTerm("simple_declaration", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	|  decl_specifier_seq ';' { $$ = newNonTerm("simple_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

decl_specifier:
	storage_class_specifier { $$ = newNonTerm("decl_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_specifier { $$ = newNonTerm("decl_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| function_specifier  { $$ = newNonTerm("decl_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| FRIEND { $$ = newNonTerm("decl_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| TYPEDEF { $$ = newNonTerm("decl_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

decl_specifier_seq:
	  decl_specifier { $$ = newNonTerm("decl_specifier_seq", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq decl_specifier { $$ = newNonTerm("decl_specifier_seq", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

storage_class_specifier:
	AUTO { $$ = newNonTerm("storage_class_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| REGISTER { $$ = newNonTerm("storage_class_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| STATIC { $$ = newNonTerm("storage_class_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| EXTERN { $$ = newNonTerm("storage_class_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MUTABLE { $$ = newNonTerm("storage_class_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

function_specifier:
	INLINE { $$ = newNonTerm("function_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| VIRTUAL { $$ = newNonTerm("function_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| EXPLICIT { $$ = newNonTerm("function_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_specifier:
	simple_type_specifier { $$ = newNonTerm("type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_specifier { $$ = newNonTerm("type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| enum_specifier { $$ = newNonTerm("type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| elaborated_type_specifier { $$ = newNonTerm("type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| cv_qualifier { $$ = newNonTerm("type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

simple_type_specifier:
	  type_name  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier type_name  { $$ = newNonTerm("simple_type_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON nested_name_specifier_opt type_name  { $$ = newNonTerm("simple_type_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| CHAR  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| WCHAR_T  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| BOOL  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SHORT  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| INT  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| LONG  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SIGNED  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| UNSIGNED  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| FLOAT  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DOUBLE  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| VOID  { $$ = newNonTerm("simple_type_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_name:
	class_name { $$ = newNonTerm("type_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| enum_name { $$ = newNonTerm("type_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| typedef_name { $$ = newNonTerm("type_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

elaborated_type_specifier:
	  class_key COLONCOLON nested_name_specifier identifier { $$ = newNonTerm("elaborated_type_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| class_key COLONCOLON identifier { $$ = newNonTerm("elaborated_type_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ENUM COLONCOLON nested_name_specifier identifier { $$ = newNonTerm("elaborated_type_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| ENUM COLONCOLON identifier { $$ = newNonTerm("elaborated_type_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ENUM nested_name_specifier identifier { $$ = newNonTerm("elaborated_type_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| TYPENAME COLONCOLON_opt nested_name_specifier identifier { $$ = newNonTerm("elaborated_type_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| TYPENAME COLONCOLON_opt nested_name_specifier identifier '<' template_argument_list '>' { $$ = newNonTerm("elaborated_type_specifier", 7, $1, $2, $3, $4, $5, $6, $7, NULL, NULL); }
	;

/*
enum_name:
	identifier { $$ = newNonTerm("enum_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;
*/

enum_specifier:
	ENUM identifier '{' enumerator_list_opt '}' { $$ = newNonTerm("enum_specifier", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

enumerator_list:
	enumerator_definition { $$ = newNonTerm("enumerator_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| enumerator_list ',' enumerator_definition { $$ = newNonTerm("enumerator_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

enumerator_definition:
	enumerator { $$ = newNonTerm("enumerator_definition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| enumerator '=' constant_expression { $$ = newNonTerm("enumerator_definition", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

enumerator:
	identifier { $$ = newNonTerm("enumerator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*
namespace_name:
	original_namespace_name { $$ = newNonTerm("namespace_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| namespace_alias { $$ = newNonTerm("namespace_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

original_namespace_name:
	identifier { $$ = newNonTerm("original_namespace_name", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;
*/

namespace_definition:
	named_namespace_definition { $$ = newNonTerm("namespace_definition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| unnamed_namespace_definition { $$ = newNonTerm("namespace_definition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

named_namespace_definition:
	original_namespace_definition { $$ = newNonTerm("named_namespace_definition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| extension_namespace_definition { $$ = newNonTerm("named_namespace_definition", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

original_namespace_definition:
	NAMESPACE identifier '{' namespace_body '}' { $$ = newNonTerm("original_namespace_definition", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

extension_namespace_definition:
	NAMESPACE original_namespace_name '{' namespace_body '}'  { $$ = newNonTerm("extension_namespace_definition", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

unnamed_namespace_definition:
	NAMESPACE '{' namespace_body '}' { $$ = newNonTerm("unnamed_namespace_definition", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

namespace_body:
	declaration_seq_opt { $$ = newNonTerm("namespace_body", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*
namespace_alias:
	identifier { $$ = newNonTerm("namespace_alias", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;
*/

namespace_alias_definition:
	NAMESPACE identifier '=' qualified_namespace_specifier ';' { $$ = newNonTerm("namespace_alias_definition", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

qualified_namespace_specifier:
	  COLONCOLON nested_name_specifier namespace_name { $$ = newNonTerm("qualified_namespace_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON namespace_name { $$ = newNonTerm("qualified_namespace_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier namespace_name { $$ = newNonTerm("qualified_namespace_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| namespace_name { $$ = newNonTerm("qualified_namespace_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

using_declaration:
	  USING TYPENAME COLONCOLON nested_name_specifier unqualified_id ';' { $$ = newNonTerm("using_declaration", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| USING TYPENAME nested_name_specifier unqualified_id ';' { $$ = newNonTerm("using_declaration", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| USING COLONCOLON nested_name_specifier unqualified_id ';' { $$ = newNonTerm("using_declaration", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| USING nested_name_specifier unqualified_id ';' { $$ = newNonTerm("using_declaration", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| USING COLONCOLON unqualified_id ';' { $$ = newNonTerm("using_declaration", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

using_directive:
	USING NAMESPACE COLONCOLON nested_name_specifier namespace_name ';' { $$ = newNonTerm("using_directive", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| USING NAMESPACE COLONCOLON namespace_name ';' { $$ = newNonTerm("using_directive", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| USING NAMESPACE nested_name_specifier namespace_name ';' { $$ = newNonTerm("using_directive", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| USING NAMESPACE namespace_name ';' { $$ = newNonTerm("using_directive", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

asm_definition:
	ASM '(' string_literal ')' ';' { $$ = newNonTerm("asm_definition", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

linkage_specification:
	EXTERN string_literal '{' declaration_seq_opt '}' { $$ = newNonTerm("linkage_specification", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| EXTERN string_literal declaration { $$ = newNonTerm("linkage_specification", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Declarators.
 *----------------------------------------------------------------------*/

init_declarator_list:
	init_declarator { $$ = newNonTerm("init_declarator_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| init_declarator_list ',' init_declarator { $$ = newNonTerm("init_declarator_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

init_declarator:
	declarator initializer_opt { $$ = newNonTerm("init_declarator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

declarator:
	direct_declarator { $$ = newNonTerm("declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ptr_operator declarator { $$ = newNonTerm("declarator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

direct_declarator:
	  declarator_id { $$ = newNonTerm("direct_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| direct_declarator '(' parameter_declaration_clause ')' cv_qualifier_seq exception_specification { $$ = newNonTerm("direct_declarator", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| direct_declarator '(' parameter_declaration_clause ')' cv_qualifier_seq  { $$ = newNonTerm("direct_declarator", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| direct_declarator '(' parameter_declaration_clause ')' exception_specification { $$ = newNonTerm("direct_declarator", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| direct_declarator '(' parameter_declaration_clause ')'  { $$ = newNonTerm("direct_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| CLASS_NAME '(' parameter_declaration_clause ')'  { $$ = newNonTerm("direct_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| CLASS_NAME COLONCOLON declarator_id '(' parameter_declaration_clause ')' { $$ = newNonTerm("direct_declarator", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| CLASS_NAME COLONCOLON CLASS_NAME '(' parameter_declaration_clause ')' { $$ = newNonTerm("direct_declarator", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| direct_declarator '[' constant_expression_opt ']'  { $$ = newNonTerm("direct_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| '(' declarator ')' { $$ = newNonTerm("direct_declarator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

ptr_operator:
	'*'  { $$ = newNonTerm("ptr_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '*' cv_qualifier_seq  { $$ = newNonTerm("ptr_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '&'  { $$ = newNonTerm("ptr_operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier '*'  { $$ = newNonTerm("ptr_operator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier '*' cv_qualifier_seq  { $$ = newNonTerm("ptr_operator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON nested_name_specifier '*'  { $$ = newNonTerm("ptr_operator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON nested_name_specifier '*' cv_qualifier_seq  { $$ = newNonTerm("ptr_operator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

cv_qualifier_seq:
	cv_qualifier { $$ = newNonTerm("cv_qualifier_seq", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| cv_qualifier cv_qualifier_seq { $$ = newNonTerm("cv_qualifier_seq", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

cv_qualifier:
	CONST { $$ = newNonTerm("cv_qualifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| VOLATILE { $$ = newNonTerm("cv_qualifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

declarator_id:
	  id_expression { $$ = newNonTerm("declarator_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON id_expression { $$ = newNonTerm("declarator_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON nested_name_specifier type_name { $$ = newNonTerm("declarator_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON type_name { $$ = newNonTerm("declarator_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_id:
	type_specifier_seq abstract_declarator_opt { $$ = newNonTerm("type_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_specifier_seq:
	type_specifier type_specifier_seq_opt { $$ = newNonTerm("type_specifier_seq", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

abstract_declarator:
	ptr_operator abstract_declarator_opt { $$ = newNonTerm("abstract_declarator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| direct_abstract_declarator { $$ = newNonTerm("abstract_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

direct_abstract_declarator:
	  direct_abstract_declarator_opt '(' parameter_declaration_clause ')' cv_qualifier_seq exception_specification { $$ = newNonTerm("direct_abstract_declarator", 6, $1, $2, $3, $4, $5, $6, NULL, NULL, NULL); }
	| direct_abstract_declarator_opt '(' parameter_declaration_clause ')' cv_qualifier_seq { $$ = newNonTerm("direct_abstract_declarator", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| direct_abstract_declarator_opt '(' parameter_declaration_clause ')' exception_specification { $$ = newNonTerm("direct_abstract_declarator", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| direct_abstract_declarator_opt '(' parameter_declaration_clause ')' { $$ = newNonTerm("direct_abstract_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| direct_abstract_declarator_opt '[' constant_expression_opt ']' { $$ = newNonTerm("direct_abstract_declarator", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| '(' abstract_declarator ')' { $$ = newNonTerm("direct_abstract_declarator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

parameter_declaration_clause:
	  parameter_declaration_list ELLIPSIS  { $$ = newNonTerm("parameter_declaration_clause", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| parameter_declaration_list { $$ = newNonTerm("parameter_declaration_clause", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ELLIPSIS  { $$ = newNonTerm("parameter_declaration_clause", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| { $$ = NULL; }
	| parameter_declaration_list ',' ELLIPSIS  { $$ = newNonTerm("parameter_declaration_clause", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

parameter_declaration_list:
	parameter_declaration { $$ = newNonTerm("parameter_declaration_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| parameter_declaration_list ',' parameter_declaration { $$ = newNonTerm("parameter_declaration_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

parameter_declaration:
	decl_specifier_seq declarator { $$ = newNonTerm("parameter_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq declarator '=' assignment_expression { $$ = newNonTerm("parameter_declaration", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq abstract_declarator_opt { $$ = newNonTerm("parameter_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq abstract_declarator_opt '=' assignment_expression { $$ = newNonTerm("parameter_declaration", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

function_definition:
	  declarator ctor_initializer_opt function_body { $$ = newNonTerm("function_definition", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq declarator ctor_initializer_opt function_body { $$ = newNonTerm("function_definition", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| declarator function_try_block { $$ = newNonTerm("function_definition", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq declarator function_try_block { $$ = newNonTerm("function_definition", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

function_body:
	compound_statement { $$ = newNonTerm("function_body", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

initializer:
	'=' initializer_clause { $$ = newNonTerm("initializer", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '(' expression_list ')' { $$ = newNonTerm("initializer", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

initializer_clause:
	assignment_expression { $$ = newNonTerm("initializer_clause", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '{' initializer_list COMMA_opt '}' { $$ = newNonTerm("function_body", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| '{' '}' { $$ = newNonTerm("function_body", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

initializer_list:
	initializer_clause { $$ = newNonTerm("initializer_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| initializer_list ',' initializer_clause { $$ = newNonTerm("initializer_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Classes.
 *----------------------------------------------------------------------*/

class_specifier:
	class_head '{' class_body '}' { $$ = newNonTerm("class_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

class_body:
        member_specification_opt { $$ = newNonTerm("class_body", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

class_head:
	  class_key identifier { $$ = newNonTerm("class_head", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_key identifier base_clause { $$ = newNonTerm("class_head", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_key nested_name_specifier identifier { $$ = newNonTerm("class_head", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_key nested_name_specifier identifier base_clause { $$ = newNonTerm("class_head", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

class_key:
	CLASS { $$ = newNonTerm("class_key", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| STRUCT { $$ = newNonTerm("class_key", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| UNION { $$ = newNonTerm("class_key", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

member_specification:
	member_declaration member_specification_opt { $$ = newNonTerm("member_specification", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| access_specifier ':' member_specification_opt { $$ = newNonTerm("member_specification", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

member_declaration:
	  decl_specifier_seq member_declarator_list ';' { $$ = newNonTerm("member_declaration", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| decl_specifier_seq ';' { $$ = newNonTerm("member_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| member_declarator_list ';' { $$ = newNonTerm("member_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ';' { $$ = newNonTerm("member_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| function_definition SEMICOLON_opt { $$ = newNonTerm("member_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| qualified_id ';' { $$ = newNonTerm("member_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| using_declaration { $$ = newNonTerm("member_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_declaration { $$ = newNonTerm("member_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

member_declarator_list:
	member_declarator { $$ = newNonTerm("member_declarator_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| member_declarator_list ',' member_declarator { $$ = newNonTerm("member_declarator_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

member_declarator:
	  declarator { $$ = newNonTerm("member_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| declarator pure_specifier { $$ = newNonTerm("member_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| declarator constant_initializer { $$ = newNonTerm("member_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| identifier ':' constant_expression { $$ = newNonTerm("member_declarator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }

/*
 * This rule need a hack for working around the ``= 0'' pure specifier.
 * 0 is returned as an ``INTEGER'' by the lexical analyzer but in this
 * context is different.
 */
pure_specifier:
	'=' '0' { $$ = newNonTerm("pure_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

constant_initializer:
	'=' constant_expression { $$ = newNonTerm("constant_initializer", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Derived classes.
 *----------------------------------------------------------------------*/

base_clause:
	':' base_specifier_list { $$ = newNonTerm("base_clause", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

base_specifier_list:
	base_specifier { $$ = newNonTerm("base_specifier_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| base_specifier_list ',' base_specifier { $$ = newNonTerm("base_specifier_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

base_specifier:
	  COLONCOLON nested_name_specifier class_name { $$ = newNonTerm("base_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON class_name { $$ = newNonTerm("base_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier class_name { $$ = newNonTerm("base_specifier", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_name { $$ = newNonTerm("base_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| VIRTUAL access_specifier COLONCOLON nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	| VIRTUAL access_specifier nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| VIRTUAL COLONCOLON nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| VIRTUAL nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| access_specifier VIRTUAL COLONCOLON nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| access_specifier VIRTUAL nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| access_specifier COLONCOLON nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| access_specifier nested_name_specifier_opt class_name { $$ = newNonTerm("base_specifier", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

access_specifier:
	PRIVATE { $$ = newNonTerm("access_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| PROTECTED { $$ = newNonTerm("access_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| PUBLIC { $$ = newNonTerm("access_specifier", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Special member functions.
 *----------------------------------------------------------------------*/

conversion_function_id:
	OPERATOR conversion_type_id { $$ = newNonTerm("conversion_function_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

conversion_type_id:
	type_specifier_seq conversion_declarator_opt { $$ = newNonTerm("conversion_type_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

conversion_declarator:
	ptr_operator conversion_declarator_opt { $$ = newNonTerm("conversion_declarator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

ctor_initializer:
	':' mem_initializer_list { $$ = newNonTerm("ctor_initializer", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

mem_initializer_list:
	mem_initializer { $$ = newNonTerm("mem_initializer_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| mem_initializer ',' mem_initializer_list { $$ = newNonTerm("mem_initializer_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

mem_initializer:
	mem_initializer_id '(' expression_list_opt ')' { $$ = newNonTerm("mem_initializer", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

mem_initializer_id:
	  COLONCOLON nested_name_specifier class_name { $$ = newNonTerm("mem_initializer_id", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| COLONCOLON class_name { $$ = newNonTerm("mem_initializer_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| nested_name_specifier class_name { $$ = newNonTerm("mem_initializer_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| class_name { $$ = newNonTerm("mem_initializer_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| identifier { $$ = newNonTerm("mem_initializer_id", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Overloading.
 *----------------------------------------------------------------------*/

operator_function_id:
	OPERATOR operator { $$ = newNonTerm("operator_function_id", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

operator:
	NEW { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DELETE { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| NEW '[' ']' { $$ = newNonTerm("operator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DELETE '[' ']' { $$ = newNonTerm("operator", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '+' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '_' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '*' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '/' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '%' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '^' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '&' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '|' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '~' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '!' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '=' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '<' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '>' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ADDEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SUBEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MULEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| DIVEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| MODEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| XOREQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ANDEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| OREQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SL { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SR { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SREQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| SLEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); } 
	| EQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| NOTEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| LTEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| GTEQ { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ANDAND { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| OROR { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| PLUSPLUS { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); } 
	| MINUSMINUS { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ',' { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); } 
	| ARROWSTAR { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); } 
	| ARROW { $$ = newNonTerm("operator", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '(' ')'  { $$ = newNonTerm("operator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| '[' ']' { $$ = newNonTerm("operator", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Templates.
 *----------------------------------------------------------------------*/

template_declaration:
	EXPORT_opt TEMPLATE '<' template_parameter_list '>' declaration { $$ = newNonTerm("template_declaration", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

template_parameter_list:
	template_parameter { $$ = newNonTerm("template_parameter_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_parameter_list ',' template_parameter { $$ = newNonTerm("template_parameter_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

template_parameter:
	type_parameter { $$ = newNonTerm("template_parameter", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| parameter_declaration { $$ = newNonTerm("template_parameter", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_parameter:
	  CLASS identifier { $$ = newNonTerm("type_parameter", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| CLASS identifier '=' type_id { $$ = newNonTerm("type_parameter", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| TYPENAME identifier { $$ = newNonTerm("type_parameter", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| TYPENAME identifier '=' type_id { $$ = newNonTerm("type_parameter", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| TEMPLATE '<' template_parameter_list '>' CLASS identifier { $$ = newNonTerm("type_parameter", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	| TEMPLATE '<' template_parameter_list '>' CLASS identifier '=' template_name { $$ = newNonTerm("type_parameter", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

template_id:
	template_name '<' template_argument_list '>' { $$ = newNonTerm("template_id", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

template_argument_list:
	template_argument { $$ = newNonTerm("template_argument_list", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_argument_list ',' template_argument { $$ = newNonTerm("template_argument_list", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

template_argument:
	assignment_expression { $$ = newNonTerm("template_argument", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_id { $$ = newNonTerm("template_argument", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| template_name { $$ = newNonTerm("template_argument", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

explicit_instantiation:
	TEMPLATE declaration { $$ = newNonTerm("explicit_instantiation", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

explicit_specialization:
	TEMPLATE '<' '>' declaration { $$ = newNonTerm("explicit_specialization", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Exception handling.
 *----------------------------------------------------------------------*/

try_block:
	TRY compound_statement handler_seq { $$ = newNonTerm("try_block", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

function_try_block:
	TRY ctor_initializer_opt function_body handler_seq { $$ = newNonTerm("function_try_block", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

handler_seq:
	handler handler_seq_opt { $$ = newNonTerm("handler_seq", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

handler:
	CATCH '(' exception_declaration ')' compound_statement { $$ = newNonTerm("handler", 5, $1, $2, $3, $4, $5, NULL, NULL, NULL, NULL); }
	;

exception_declaration:
	type_specifier_seq declarator { $$ = newNonTerm("exception_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_specifier_seq abstract_declarator { $$ = newNonTerm("exception_declaration", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_specifier_seq { $$ = newNonTerm("exception_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| ELLIPSIS { $$ = newNonTerm("exception_declaration", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

throw_expression:
	THROW assignment_expression_opt { $$ = newNonTerm("throw_expression", 2, $1, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

exception_specification:
	THROW '(' type_id_list_opt ')' { $$ = newNonTerm("throw_expression", 4, $1, $2, $3, $4, NULL, NULL, NULL, NULL, NULL); }
	;

type_id_list:
	type_id { $$ = newNonTerm("throw_expression", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	| type_id_list ',' type_id { $$ = newNonTerm("    ", 3, $1, $2, $3, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

/*----------------------------------------------------------------------
 * Epsilon (optional) definitions.
 *----------------------------------------------------------------------*/

declaration_seq_opt:
	/* epsilon */ { $$ = NULL; }
	| declaration_seq  { $$ = newNonTerm("declaration_seq_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

nested_name_specifier_opt:
	/* epsilon */ { $$ = NULL; }
	| nested_name_specifier { $$ = newNonTerm("nested_name_specifier_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

expression_list_opt:
	/* epsilon */ { $$ = NULL; }
	| expression_list { $$ = newNonTerm("expression_list_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

COLONCOLON_opt:
	/* epsilon */ { $$ = NULL; }
	| COLONCOLON { $$ = newNonTerm("COLONCOLON_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_placement_opt:
	/* epsilon */ { $$ = NULL; }
	| new_placement { $$ = newNonTerm("new_placement_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_initializer_opt:
	/* epsilon */ { $$ = NULL; }
	| new_initializer { $$ = newNonTerm("new_initializer_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

new_declarator_opt:
	/* epsilon */ { $$ = NULL; }
	| new_declarator { $$ = newNonTerm("new_declarator_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

expression_opt:
	/* epsilon */ { $$ = NULL; }
	| expression { $$ = newNonTerm("expression_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

statement_seq_opt:
	/* epsilon */ { $$ = NULL; }
	| statement_seq { $$ = newNonTerm("statement_seq_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

condition_opt:
	/* epsilon */ { $$ = NULL; }
	| condition { $$ = newNonTerm("condition_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

enumerator_list_opt:
	/* epsilon */ { $$ = NULL; }
	| enumerator_list { $$ = newNonTerm("enumerator_list_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

initializer_opt:
	/* epsilon */ { $$ = NULL; }
	| initializer { $$ = newNonTerm("initializer_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

constant_expression_opt:
	/* epsilon */ { $$ = NULL; }
	| constant_expression { $$ = newNonTerm("constant_expression_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

abstract_declarator_opt:
	/* epsilon */ { $$ = NULL; }
	| abstract_declarator { $$ = newNonTerm("abstract_declarator_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_specifier_seq_opt:
	/* epsilon */ { $$ = NULL; }
	| type_specifier_seq { $$ = newNonTerm("type_specifier_seq_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

direct_abstract_declarator_opt:
	/* epsilon */ { $$ = NULL; }
	| direct_abstract_declarator { $$ = newNonTerm("direct_abstract_declarator_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

ctor_initializer_opt:
	/* epsilon */ { $$ = NULL; }
	| ctor_initializer { $$ = newNonTerm("ctor_initializer_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

COMMA_opt:
	/* epsilon */ { $$ = NULL; }
	| ',' { $$ = newNonTerm("COMMA_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

member_specification_opt:
	/* epsilon */ { $$ = NULL; }
	| member_specification { $$ = newNonTerm("member_specification_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

SEMICOLON_opt:
	/* epsilon */ { $$ = NULL; }
	| ';' { $$ = newNonTerm("SEMICOLON_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

conversion_declarator_opt:
	/* epsilon */ { $$ = NULL; }
	| conversion_declarator { $$ = newNonTerm("conversion_declarator_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

EXPORT_opt:
	/* epsilon */ { $$ = NULL; }
	| EXPORT { $$ = newNonTerm("EXPORT_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

handler_seq_opt:
	/* epsilon */ { $$ = NULL; }
	| handler_seq { $$ = newNonTerm("handler_seq_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

assignment_expression_opt:
	/* epsilon */ { $$ = NULL; }
	| assignment_expression { $$ = newNonTerm("assignment_expression_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

type_id_list_opt:
	/* epsilon */ { $$ = NULL; }
	| type_id_list { $$ = newNonTerm("type_id_list_opt", 1, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL); }
	;

%%

static void
yyerror(char *s)
{
    fprintf(stderr, "At line %d: %s\n", lineno, s);
}

int main(int argc, char **argv) {
    root = newTree();
    // There at least one command line argument
    if(argc > 1)
        if(!strcmp(argv[1], "-g")) {
	    DEBUG = 1;
            yyin = fopen(argv[2], "r");
	}else if(!strcmp(argv[1], "-l")){
            LEX_DEBUG = 1;
            yyin = fopen(argv[2], "r");
	} else {
	    DEBUG = 0;
	    LEX_DEBUG = 0;
            yyin = fopen(argv[1], "r");
	}
    do {
        yyparse();
    } while(!feof(yyin));
}
