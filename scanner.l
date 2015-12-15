%{
#include <string.h>
#include "y.tab.h"

#define LIST strcat( buf, yytext )
#define token(t) { LIST; if (Opt_T) printf("<%s>\n", #t );}
#define tokenChar(t) { LIST; if (Opt_T) printf("<%c>\n", t );}
#define tokenInteger(t, i) { LIST; if (Opt_T) printf("<%s: %d>\n", t, i); }
#define tokenOctInteger(t, i) { LIST; if (Opt_T) printf("<%s: %s>\n", t, i); }
#define tokenFloat(t, i) { LIST; if (Opt_T) printf("<%s: %s>\n", t, i ); }
#define tokenScientific(t, s) { LIST; if ( Opt_T ) printf("<%s: %s>\n", t, s); }
#define tokenString(t, s) { LIST; if (Opt_T) printf("<%s: %s>\n", t, s); }


#define  MAX_LINE_LENG  256

int Opt_S = 1;				/* list source code option */
int Opt_T = 1;				/* list token option */
int Opt_D = 1;
int linenum = 1;			/* line number */
char buf[MAX_LINE_LENG];		/* source code line buffer */
char strContent[MAX_LINE_LENG];		/* string buffer */

void setPseudoComment( const char * );	/* pseudo comment option switch */
%}

whitespace [ \t]+
letter [A-Za-z]
digit [0-9]
integer 0|[1-9][0-9]*
octal 0[0-7]+
fraction 0|[0-9]*
float {integer}"."{fraction}
scientific ({integer}|{float}|{octal})[Ee][+-]?({integer}|{octal})
identifier ({letter})({letter}|{digit})*

 /* exclusive start conditions */
%x STR
%x COMMENT
%x COMMENT_CPP

%%

","				{ tokenChar(',');	return Comma; }
";"				{ tokenChar(';');	return Semicolon; }
":"				{ tokenChar(':');	return Colon; }
")"				{ tokenChar(')');	return RightParenthese; }
"("				{ tokenChar('(');	return LeftParenthese; }
"["				{ tokenChar('[');	return LeftBracket; }
"]"				{ tokenChar(']');	return RightBracket; }

"+"				{ tokenChar('+');	return Plus; }
"-"				{ tokenChar('-');	return Minus; }
"*"				{ tokenChar('*');	return Star; }
"/"				{ tokenChar('/');	return Slash; }
"mod"			{ token(mod);		return Mod; }
":="			{ token(:=);		return Assign; }
"<"				{ tokenChar('<');	return LessThan; }
"<="			{ token(<=);		return LessThanEqual; }
"<>"			{ token(<>);		return NotEqual; }
">="			{ token(>=);		return GreaterThanEqual; }
">"				{ tokenChar('>');	return GreaterThan; }
"="				{ tokenChar('=');	return Equal; }
"and"			{ token(and);		return And; }
"or"			{ token(or);		return Or; }
"not"			{ token(not);		return Not; }

"array"			{ token(KWarray);	return Array; }
"begin"			{ token(KWbegin);	return Begin; }
"boolean"		{ token(KWboolean);	return Boolean; }
"def"			{ token(KWdef);		return Def; }
"do"			{ token(KWdo);		return Do; }
"else"			{ token(KWelse);	return Else; }
"end"			{ token(KWend);		return End; }
"false"			{ token(KWfalse);	return False; }
"for"			{ token(KWfor);		return For; }
"integer"		{ token(KWinteger);	return Integer; }
"if"			{ token(KWif);		return If; }
"of"			{ token(KWof);		return Of; }
"print"			{ token(KWprint);	return Print; }
"read"			{ token(KWread);	return Read; }
"real"			{ token(KWreal);	return Real; }
"string"		{ token(KWstring);	return String; }
"then"			{ token(KWthen);	return Then; }
"to"			{ token(KWto);		return To; }
"true"			{ token(KWtrue);	return True; }
"return"		{ token(KWreturn);	return Return; }
"var"			{ token(KWvar);		return Var; }
"while"			{ token(KWwhile);	return While; }

{octal} 		{ tokenOctInteger("oct_integer",yytext);	return OctalValue; }
{identifier}	{ tokenString("id",yytext);					return Identifier; }
{integer}		{ tokenInteger("integer",atoi(yytext));		return IntegerValue; }
{float}			{ tokenFloat("float",yytext);				return FloatValue; }
{scientific}	{ tokenScientific("scientific", yytext);	return ScientificValue; }

"\""			{ /* begin string  */
				  LIST;
				  BEGIN STR; 
				}

<STR>([^"\n])*	{
				  LIST;
				  strcat( strContent, yytext );
				}

<STR>"\""		{ /* end of string or "" */
				  char c;
				  c = input();
				  if( c == '\"' )	/* "" */
				  {
					LIST;
					strcat( buf, "\"" );
					strcat( strContent, "\"" );
				  }
				  else			/* end of string */
				  {
					unput(c);
					strcat(buf,"\"");
					if (Opt_T)
						printf("<%s: %s>\n", "string", strContent );
					strContent[0] = '\0';
				  	BEGIN INITIAL;
					return StringValue;
				  }
				}
<STR>"\n"		{
				  /* error, cancel execution immediately!  */
				  fprintf( stdout, "error at line %d: string `%s` missing terminating \" character\n", linenum, strContent );
				  exit(-1);
				}

"//&"[A-Z][+-][^\n]*		{ /* pseudo comment */
				  LIST;
				  setPseudoComment( yytext );
				}
"//"			{ /* C++ stype comment */
				  LIST;
				  BEGIN COMMENT_CPP;
				}

<COMMENT_CPP>[^\n]+		{
				  LIST;
				}

<COMMENT_CPP>"\n"		{
				  LIST;
				  if( Opt_S )
				  	printf("%d: %s",  linenum,  buf);
				  linenum++;
				  buf[0] = '\0';
				  BEGIN INITIAL;
				}

"/*"			{ /* C-style comment */
				  LIST;
				  BEGIN COMMENT;
				}
<COMMENT>"*/"	{
				  LIST;
				  BEGIN INITIAL;
				}
<COMMENT>"\n"	{
				  LIST;
				  if  (Opt_S)
				  	printf("%d: %s",  linenum,  buf);
				  linenum++;
				  buf[0] = '\0';
				}
<COMMENT>.		{
				  LIST;
				}

{whitespace}	{ 
				  LIST; 
				}

\n 				{
				  LIST;
				  if  (Opt_S)
				  	printf("%d: %s",  linenum,  buf);
				  linenum++;
				  buf[0] = '\0';
		   		}

.				{
				  /* error */
				  printf("error at line %d: bad character \"%s\"\n", linenum, yytext );
				  exit(-1);
				}

%%
/*int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./scanner  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yylex();
	exit(0);
}*/

void setPseudoComment( const char *text )
{
	/* format : //&[A-Z][+-] */
	switch( text[3] ) {
	 case 'S':
		if( text[4] == '+' )
			Opt_S = 1;
		else if( text[4] == '-' )
			Opt_S = 0;
		break;
	 case 'T':
		if( text[4] == '+' )
			Opt_T = 1;
		else if( text[4] == '-' )
			Opt_T = 0;
	 	break;
	 case 'D':
		if( text[4] == '+' )
			Opt_D = 1;
		else if( text[4] == '-' )
			Opt_D = 0;
	 default:
	 	break;
	}

}