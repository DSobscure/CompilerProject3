#ifndef CSYMBOLTABLESTACK
#define CSYMBOLTABLESTACK

#include "SymbolTable.h"
#include <stdlib.h>

struct CSymbolTableStack
{
	int stackTop;
	struct SymbolTable* stackContent[10];
};

struct CSymbolTableStack CSymbolTableStack()
{
	struct CSymbolTableStack stack;
	stack.stackTop = 0;
	return stack;
}
void Push(struct CSymbolTableStack* stack,struct SymbolTable* table)
{
    stack->stackContent[stack->stackTop++] = table;
}
void Pop(struct CSymbolTableStack* stack)
{
	free(stack->stackContent[--stack->stackTop]);
}
struct SymbolTable* Peek(struct CSymbolTableStack* stack)
{
	if(stack->stackTop > 0)
		return stack->stackContent[stack->stackTop-1];
	else
		return 0;
}
void DestroyCSymbolTableStack(struct CSymbolTableStack* stack)
{
	for(int i=0;i<stack->stackTop-1;i++)
	{
		free(stack->stackContent[i]);
	}
}
#endif