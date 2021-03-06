YACC=yacc
LEX=flex
CC=gcc
CFLAGS=-g -Wall

all: 120

.c.o:
	$(CC) -g -c $<

120: 120gram.o 120lex.o tree.o symbolTable.o typeChecking.o
	cc $(CFLAGS) -o 120++ 120gram.o 120lex.o tree.o symbolTable.o typeChecking.o

120gram.c 120gram.h: 120gram.y
	$(YACC) -dt --verbose 120gram.y
	mv -f y.tab.c 120gram.c
	mv -f y.tab.h 120gram.h

120lex.c: 120lex.l
	$(LEX) -t 120lex.l >120lex.c

120lex.o: 120gram.h

tree.o: tree.h tree.c

typeChecking.o: typeChecking.h typeChecking.c

symbolTable.o: symbolTable.h symbolTable.c

clean:
	rm -f 120++ *.o
	rm -f 120lex.c 120gram.c 120gram.h
	rm -f y.output
