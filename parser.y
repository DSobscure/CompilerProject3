%{
#include <stdio.h>
#include <stdlib.h>
#include "Symbol.h"
#include "SymbolTable.h"
#include "CSymbolTableStack.h"

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
extern int Opt_D;
struct CSymbolTableStack stack;
struct SymbolTable* symbolTable;

int yylex();
%}

%token Comma Semicolon Colon
%token LeftParenthese RightParenthese
%token LeftBracket RightBracket
%token Plus Minus Star Slash Mod Assign
%token LessThan LessThanEqual NotEqual GreaterThanEqual GreaterThan Equal And Or Not
%token Array Boolean Integer Real String
%token True False
%token Begin End Def Do While If Else For Of  Then To Return Var 
%token Print Read
%token Identifier ScientificValue FloatValue OctalValue IntegerValue StringValue

%left Semicolon
%left Or
%left And
%right Not
%left LessThan LessThanEqual Equal GreaterThanEqual GreaterThan NotEqual
%left Plus Minus    
%left Star Slash Mod 

%%

program: Identifier 
		{
			symbolTable = NewSymbolTable();
			Push(&stack, symbolTable);
		}
		Semicolon programbody 
		{
			if(Opt_D)
				DumpSymbolTable(Peek(&stack));
			Pop(&stack);
		}
		End Identifier;

programbody: declarations;

declarations: variable_constant_declarations  function_declarations compound_statement
            | function_declarations compound_statement
			| variable_constant_declarations compound_statement
			| compound_statement;

variable_constant_declarations: variable_constant_declaration variable_constant_declarations
                              | variable_constant_declaration;
			
variable_constant_declaration: variable_declaration
                             | constant_variable_declaration;
			
variable_declaration: Var identifier_list Colon scalar_type Semicolon
                    | Var identifier_list Colon array Semicolon;
					
constant_variable_declaration: Var identifier_list Colon literal_constant Semicolon;
		
identifier_list: Identifier Comma identifier_list
			   | Identifier;
		
scalar_type: Integer
           | Real
           | String
           | Boolean;

integer_constant: IntegerValue
                | OctalValue;

array: Array integer_constant To integer_constant Of type;

type: scalar_type
    | array;

literal_constant: True
                | False
                | IntegerValue
                | OctalValue
                | FloatValue
                | ScientificValue
                | StringValue;
				
function_declarations: function_declaration function_declarations
                     | function_declaration;

function_declaration: function_header compound_statement End Identifier;

function_header: Identifier LeftParenthese formal_arguments RightParenthese Colon type Semicolon
               | Identifier LeftParenthese formal_arguments RightParenthese Semicolon;
			   | Identifier LeftParenthese RightParenthese Colon type Semicolon
               | Identifier LeftParenthese RightParenthese Semicolon;			   

formal_arguments: formal_argument Semicolon formal_arguments
                | formal_argument;
					
formal_argument: identifier_list Colon type;

statements: statement statements
          | statement;

statement: compound_statement
         | simple_statement		
         | conditional_statement		
		 | while_statement	
		 | for_statement	
		 | return_statement	
		 | procedure_call_statement;	 

compound_statement: Begin variable_constant_declarations statements End
                  | Begin variable_constant_declarations End
				  | Begin statements End
				  | Begin End;

simple_statement: variable_reference Assign expression Semicolon
				| Print expression Semicolon
				| Read variable_reference Semicolon;

conditional_statement: If expression Then statements Else statements End If
                     | If expression Then Else statements End If
					 | If expression Then statements Else End If
					 | If expression Then Else End If
					 | If expression Then statements End If
					 | If expression Then End If;
					 
while_statement: While expression Do statements End Do
               | While expression Do End Do;
			   
for_statement: For Identifier Assign integer_constant To integer_constant Do statements End Do;
             | For Identifier Assign integer_constant To integer_constant Do End Do;
			 
return_statement: Return expression Semicolon;

function_invocation: Identifier LeftParenthese expression_parameters RightParenthese
                   | Identifier LeftParenthese RightParenthese;

procedure_call_statement: function_invocation Semicolon;

variable_reference: Identifier array_reference
                  | Identifier;
				  
array_reference: LeftBracket expression RightBracket array_reference
			   | LeftBracket expression RightBracket;

expression: LeftParenthese expression RightParenthese
          | Minus expression
		  | expression Star expression
		  | expression Slash expression
		  | expression Mod expression
		  | expression Plus expression
		  | expression Minus expression
		  | expression LessThan expression
		  | expression LessThanEqual expression
          | expression Equal expression
          | expression GreaterThanEqual expression
          | expression GreaterThan expression
          | expression NotEqual expression
          | Not expression
          | expression And expression
          | expression Or expression
		  | function_invocation
		  | variable_reference
          | literal_constant;

expression_parameters: expression Comma expression_parameters
                     | expression;

%%

int yyerror( char *msg )
{
    fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
    fprintf( stderr, "|--------------------------------------------------------------------------\n" );
    exit(-1);
}

int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	stack = CSymbolTableStack();
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	
	DestroyCSymbolTableStack(&stack);
	
	exit(0);
}

