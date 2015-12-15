#ifndef SYMBOL
#define SYMBOL

#include <stdio.h>

struct Symbol
{
	char* name;
	char* kind;
	int level;
	char* type;
	char* attribute;
};

struct Symbol Symbol(char* name, char* kind, int level, char* type, char* attribute)
{
	struct Symbol Symbol;
	Symbol.name = name;
	Symbol.kind = kind;
	Symbol.level = level;
	Symbol.type = type;
	Symbol.attribute = attribute;
	return Symbol;
}

void ShowSymbol(struct Symbol symbol)
{
	printf("%-33s",symbol.name);
	printf("%-11s",symbol.kind);
	if(symbol.level == 0)
	{
		printf("%d(global)  ",symbol.level);
	}
	else
	{
		printf("%d(local)   ",symbol.level);
	}
	printf("%-33s",symbol.type);
	printf("%-24s\n",symbol.attribute);
}

#endif