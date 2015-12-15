#ifndef SYMBOLTABLE
#define SYMBOLTABLE

#include <stdio.h>
#include <stdlib.h>
#include "Symbol.h"

struct SymbolTable
{
	char* title;
	int symbolCount;
	struct Symbol symblos[20];
};
struct SymbolTable* NewSymbolTable()
{
	struct SymbolTable* symbolTable =  (struct SymbolTable*)malloc(sizeof(struct SymbolTable));
	symbolTable->title = "Name                             Kind       Level      Type                             Attribute               \n";
	symbolTable->symbolCount = 0;
	return symbolTable;
}
void DumpSymbolTable(struct SymbolTable* symbolTable)
{
	if(symbolTable != 0)
	{
		printf("================================================================================================================\n");
		printf("%s",symbolTable->title);
		printf("----------------------------------------------------------------------------------------------------------------\n");
		for(int i=0;i<symbolTable->symbolCount;i++)
		{
			ShowSymbol(symbolTable->symblos[i]);
		}
		printf("================================================================================================================\n");
	}
}
void AddSymbol(struct SymbolTable* table,struct Symbol symbol)
{
	table->symblos[table->symbolCount++] = symbol;
}

#endif