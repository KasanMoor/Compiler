/*	$Id: lexer.l,v 1.2 1997/11/19 15:13:15 sandro Exp $	*/

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
 * ISO C++ lexical analyzer.
 *
 * Based on the ISO C++ draft standard of December '96.
 */

%{
#include <ctype.h>
#include <stdio.h>
#include "tree.h"
#include "120gram.h"

int lineno;
int saw_iostream, saw_string, saw_std;

static int yywrap(void);
static int token(int);
static void skip_until_eol(void);
static void skip_comment(void);
static int check_identifier(char *);
%}

intsuffix				([uU][lL]?)|([lL][uU]?)
fracconst				([0-9]*\.[0-9]+)|([0-9]+\.)
exppart					[eE][-+]?[0-9]+
floatsuffix				[fFlL]
chartext				([^'])|(\\.)
stringtext				([^"])|(\\.)

%%

"\n"					{ ++lineno; }
[\t\f\v\r ]+				{ /* Ignore whitespace. */ }

"/*"					{ skip_comment(); }
"//"					{ skip_until_eol(); }

"{"					{ return token('{'); }
"<%"					{ return token('{'); }
"}"					{ return token('}'); }
"%>"					{ return token('}'); }
"["					{ return token('['); }
"<:"					{ return token('['); }
"]"					{ return token(']'); }
":>"					{ return token(']'); }
"("					{ return token('('); }
")"					{ return token(')'); }
";"					{ return token(';'); }
":"					{ return token(':'); }
"..."					{ return token(ELLIPSIS); }
"?"					{ return token('?'); }
"::"					{ return token(COLONCOLON); }
"."					{ return token('.'); }
".*"					{ return token(DOTSTAR); }
"+"					{ return token('+'); }
"-"					{ return token('-'); }
"*"					{ return token('*'); }
"/"					{ return token('/'); }
"%"					{ return token('%'); }
"^"					{ return token('^'); }
"xor"					{ return token('^'); }
"&"					{ return token('&'); }
"bitand"				{ return token('&'); }
"|"					{ return token('|'); }
"bitor"					{ return token('|'); }
"~"					{ return token('~'); }
"compl"					{ return token('~'); }
"!"					{ return token('!'); }
"not"					{ return token('!'); }
"="					{ return token('='); }
"<"					{ return token('<'); }
">"					{ return token('>'); }
"+="					{ return token(ADDEQ); }
"-="					{ return token(SUBEQ); }
"*="					{ return token(MULEQ); }
"/="					{ return token(DIVEQ); }
"%="					{ return token(MODEQ); }
"^="					{ return token(XOREQ); }
"xor_eq"				{ return token(XOREQ); }
"&="					{ return token(ANDEQ); }
"and_eq"				{ return token(ANDEQ); }
"|="					{ return token(OREQ); }
"or_eq"					{ return token(OREQ); }
"<<"					{ return token(SL); }
">>"					{ return token(SR); }
"<<="					{ return token(SLEQ); }
">>="					{ return token(SREQ); }
"=="					{ return token(EQ); }
"!="					{ return token(NOTEQ); }
"not_eq"				{ return token(NOTEQ); }
"<="					{ return token(LTEQ); }
">="					{ return token(GTEQ); }
"&&"					{ return token(ANDAND); }
"and"					{ return token(ANDAND); }
"||"					{ return token(OROR); }
"or"					{ return token(OROR); }
"++"					{ return token(PLUSPLUS); }
"--"					{ return token(MINUSMINUS); }
","					{ return token(','); }
"->*"					{ return token(ARROWSTAR); }
"->"					{ return token(ARROW); }

"asm"					{ return token(ASM); }
"auto"					{ return token(AUTO); }
"bool"					{ return token(BOOL); }
"break"					{ return token(BREAK); }
"case"					{ return token(CASE); }
"catch"					{ return token(CATCH); }
"char"					{ return token(CHAR); }
"class"					{ return token(CLASS); }
"const"					{ return token(CONST); }
"const_cast"				{ return token(CONST_CAST); }
"continue"				{ return token(CONTINUE); }
"default"				{ return token(DEFAULT); }
"delete"				{ return token(DELETE); }
"do"					{ return token(DO); }
"double"				{ return token(DOUBLE); }
"dynamic_cast"				{ return token(DYNAMIC_CAST); }
"else"					{ return token(ELSE); }
"enum"					{ return token(ENUM); }
"explicit"				{ return token(EXPLICIT); }
"export"				{ return token(EXPORT); }
"extern"				{ return token(EXTERN); }
"false"					{ return token(FALSE); }
"float"					{ return token(FLOAT); }
"for"					{ return token(FOR); }
"friend"				{ return token(FRIEND); }
"goto"					{ return token(GOTO); }
"if"					{ return token(IF); }
"inline"				{ return token(INLINE); }
"int"					{ return token(INT); }
"long"					{ return token(LONG); }
"mutable"				{ return token(MUTABLE); }
"namespace"				{ return token(NAMESPACE); }
"new"					{ return token(NEW); }
"operator"				{ return token(OPERATOR); }
"private"				{ return token(PRIVATE); }
"protected"				{ return token(PROTECTED); }
"public"				{ return token(PUBLIC); }
"register"				{ return token(REGISTER); }
"reinterpret_cast"			{ return token(REINTERPRET_CAST); }
"return"				{ return token(RETURN); }
"short"					{ return token(SHORT); }
"signed"				{ return token(SIGNED); }
"sizeof"				{ return token(SIZEOF); }
"static"				{ return token(STATIC); }
"static_cast"				{ return token(STATIC_CAST); }
"struct"				{ return token(STRUCT); }
"switch"				{ return token(SWITCH); }
"template"				{ return token(TEMPLATE); }
"this"					{ return token(THIS); }
"throw"					{ return token(THROW); }
"true"					{ return token(TRUE); }
"try"					{ return token(TRY); }
"typedef"				{ return token(TYPEDEF); }
"typeid"				{ return token(TYPEID); }
"typename"				{ return token(TYPENAME); }
"union"					{ return token(UNION); }
"unsigned"				{ return token(UNSIGNED); }
"using"					{ return token(USING); }
"virtual"				{ return token(VIRTUAL); }
"void"					{ return token(VOID); }
"volatile"				{ return token(VOLATILE); }
"wchar_t"				{ return token(WCHAR_T); }
"while"					{ return token(WHILE); }

[a-zA-Z_][a-zA-Z_0-9]*			{ return check_identifier(yytext); }

"0"[xX][0-9a-fA-F]+{intsuffix}?		{ return token(INTEGER); }
"0"[0-7]+{intsuffix}?			{ return token(INTEGER); }
[0-9]+{intsuffix}?			{ return token(INTEGER); }

{fracconst}{exppart}?{floatsuffix}?	{ return token(FLOATING); }
[0-9]+{exppart}{floatsuffix}?		{ return token(FLOATING); }

"'"{chartext}*"'"			{ return token(CHARACTER); }
"L'"{chartext}*"'"			{ return token(CHARACTER); }

"\""{stringtext}*"\""			{ return token(STRING); }
"L\""{stringtext}*"\""			{ return token(STRING); }
"#include <iostream>"			{ saw_iostream = 1; }
"#include <string>"			{ saw_string = 1; }
"using namespace std;"			{ saw_std = 1;
		/*if (saw_string) typenametable_insert("string", CLASS_NAME);
		if (saw_iostream) {
			typenametable_insert("ifstream", CLASS_NAME);
			typenametable_insert("ofstream", CLASS_NAME);
			}
		*/}


.					{ fprintf(stderr, "%d: unexpected character `%c'\n", lineno, yytext[0]); }

%%

static int
yywrap(void)
{
	return 1;
}

/*
 * We use this routine instead a lex pattern because we don't need
 * to save the matched comment in the `yytext' buffer.
 */
static void
skip_comment(void)
{
	int c1, c2;

	c1 = input();
	c2 = input();

	while (c2 != EOF && !(c1 == '*' && c2 == '/')) {
		if (c1 == '\n')
			++lineno;
		c1 = c2;
		c2 = input();
	}
}

/*
 * See the previous comment for an explanation.
 */
static void
skip_until_eol(void)
{
	int c;

	while ((c = input()) != EOF && c != '\n')
		;
	++lineno;
}

static int
check_identifier(char *s)
{
    struct TreeStruct *tree = newTree("Identifier");
    Token *token = newToken(0, "file", lineno);
    tree->leaf = token;
    yylval.t = tree;
    return IDENTIFIER;
}

static int token(int cat)
{
   struct TreeStruct *tree = newTree("Token");
   Token *token = newToken(cat, "file", lineno);
   tree->leaf = token;
   yylval.t = tree;
   return cat;
}
