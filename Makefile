TARGET = parser
CC = gcc -std=c11 -o
LEX = lex
YACC = yacc -d -v
OBJs = Symbol.h SymbolTable.h CSymbolTableStack.h lex.yy.c y.tab.c
HEADER = y.tab.h

all:
	$(YACC) parser.y
	$(LEX) scanner.l
	$(CC) $(TARGET) $(OBJs) -ly -ll
	

clean:
	rm -f $(TARGET) $(OBJs) $(HEADER)

