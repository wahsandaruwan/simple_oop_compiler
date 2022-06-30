%{
/* ---C declarations--- */

/* Common imports */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "lex.yy.c"

/* Prototypes for parsing */
void yyerror(const char *s);
int yylex();
int yywrap();

/* Prototypes for symbol table */
void add_symbol(char symbol_cat);
void insert_type();
int search_type(char *symbol);

/* Structure of the symbol table */
struct dataType {
    char *id_name;
    char *data_type;
    char *symbol_type;
    int line_no;
} symbol_table[40];

/* Variables for symbol table */
int count=0;
int query;
char type[10];
extern int countln;
%}

/* ---Yacc definitions--- */

%token VOID CLASS EXTENDS INTERFACE IMPLEMENTS CHARACTER PRINT INT DOUBLE CHAR STRING BOOL FOR WHILE BREAK NULL_VAL TRUE FALSE IF ELSE INT_NUM DOUBLE_NUM IDENT LE GE EQ NE GT LT AND OR NOT STR ADD MULTIPLY DIVIDE SUBTRACT MODULUS UNARY INCLUDE RETURN THIS NEW NEW_ARRAY READ_INTEGER READ_LINE

%left GE LE EQ NE GT LT
%left '+' '-'
%left '*' '/'

/* ---Descriptions of expected inputs | Corresponding actions--- */

%%
Program                                     : Decl
                                            ;
                                        
Decl                                        : VariableDecl 
                                            | FunctionDecl 
                                            | VariableDecl FunctionDecl
                                            | FunctionDecl VariableDecl
                                            | Decl Decl
                                            | ClassDecl 
                                            | InterfaceDecl
                                            ;

VariableDecl                                : Variable ';'
                                            | VariableDecl Variable ';'
                                            ;

Variable                                    : Type IDENT {add_symbol('V');} Init
                                            ;

Init                                        : '=' Expr
                                            |
                                            ;

Type                                        : INT { insert_type(); }
                                            | DOUBLE { insert_type(); }
                                            | BOOL { insert_type(); }
                                            | CHAR { insert_type(); }
                                            | STRING { insert_type(); }
                                            | VOID { insert_type(); }
                                            | IDENT { insert_type(); }
                                            | Type '[' INT_NUM ']' { insert_type(); }
                                            ;

FunctionDecl                                : Type IDENT {add_symbol('F');} '(' Formals ')' '{' StmtBlock '}'
                                            ;

Formals                                     : 
                                            | Variable
                                            | Formals ',' Variable
                                            ;

ClassDecl                                   : CLASS IDENT '{' Field '}'
                                            | CLASS IDENT EXTENDS {add_symbol('K');} IDENT '{' Field '}'
                                            | CLASS IDENT IMPLEMENTS {add_symbol('K');} ImplIdent '{' Field '}'
                                            ;

ImplIdent                                   : IDENT
                                            | ImplIdent ',' IDENT
                                            ;

Field                                       : VariableDecl
                                            | FunctionDecl
                                            | VariableDecl FunctionDecl
                                            | FunctionDecl VariableDecl
                                            | Field Field
                                            ;

InterfaceDecl                               : INTERFACE {add_symbol('K');} IDENT '{' Prototype '}'
                                            ;

Prototype                                   : Type IDENT '(' {add_symbol('P');} Formals ')' ';'
                                            | VOID IDENT '(' {add_symbol('P');} Formals ')' ';'
                                            | Prototype Type IDENT '(' Formals ')' ';'
                                            | Prototype VOID IDENT '(' Formals ')' ';'
                                            ;

StmtBlock                                   : 
                                            | StmtBlock VariableDecl
                                            | StmtBlock Stmt
                                            ;

Stmt                                        : Expr
                                            | IfStmt
                                            | WhileStmt
                                            | ForStmt
                                            | BreakStmt
                                            | ReturnStmt
                                            | PrintStmt
                                            | Stmt Stmt
                                            ;

IfStmt                                      : IF '(' Expr ')' '{' Stmt '}'
                                            | IF '(' Expr ')' '{' Stmt '}' ELSE {add_symbol('K');} '{' Stmt '}'
                                            ;

WhileStmt                                   : WHILE {add_symbol('K');} '(' Expr ')' '{' Stmt '}' {add_symbol('K');}
                                            ;

ForStmt                                     : FOR '(' Expr ';' Expr ';' Expr ')' '{' Stmt '}'
                                            | FOR '(' ';' Expr ';' Expr ')' '{' Stmt '}'
                                            | FOR '(' Expr ';' Expr ';' ')' '{' Stmt '}'
                                            | FOR '(' ';' Expr ';' ')' '{' Stmt '}'
                                            ;

BreakStmt                                   : BREAK {add_symbol('K');} ';'
                                            ;

ReturnStmt                                  : RETURN {add_symbol('K');} Expr ';'
                                            ;

PrintStmt                                   : PRINT {add_symbol('K');} '(' STR ')' ';'
                                            ;

Expr                                        : LValue '=' Expr
                                            | IDENT
                                            | Constant
                                            | Variable 
                                            | IDENT UNARY
                                            | LValue
                                            | THIS
                                            | Call
                                            | '(' Expr ')'
                                            | Expr ADD Expr
                                            | Expr SUBTRACT Expr
                                            | Expr MULTIPLY Expr
                                            | Expr DIVIDE Expr
                                            | Expr MODULUS Expr
                                            | SUBTRACT Expr
                                            | Expr LT Expr
                                            | Expr LE Expr
                                            | Expr GT Expr
                                            | Expr GE Expr
                                            | Expr EQ Expr
                                            | Expr NE Expr
                                            | Expr AND Expr
                                            | Expr OR Expr
                                            | NOT Expr
                                            | ReadInteger
                                            | ReadLine
                                            | New
                                            | NewArray
                                            ;

ReadInteger                                 : READ_INTEGER '(' ')'
                                            ;

ReadLine                                    : READ_LINE '(' ')'
                                            ;

New                                         : NEW '(' IDENT ')'
                                            ;

NewArray                                    : NEW_ARRAY '(' ')'
                                            ;

LValue                                      : IDENT
                                            | Expr '.' IDENT
                                            | Expr '[' Expr ']'
                                            ;

Call                                        : IDENT '(' Actuals ')'
                                            | Expr '.' IDENT '(' Actuals ')'
                                            ;

Actuals                                     : Expr ','
                                            | Actuals Expr ','
                                            ;

Constant                                    : INT_NUM {add_symbol('C');}
                                            | DOUBLE_NUM {add_symbol('C');}
                                            | TRUE {add_symbol('C');}
                                            | FALSE {add_symbol('C');}
                                            | STR {add_symbol('C');}
                                            | CHARACTER {add_symbol('C');}
                                            | NULL_VAL {add_symbol('C');}
                                            ;
%%

/* ---Functions--- */

/* Parse the input file */
int main() {
    yyparse();

    printf("\n\n");
	printf("LEXICAL ANALYSIS PART | SYMBOL TABLE \n");
	printf("\nSYMBOL   DATATYPE   SYMBOL TYPE   LINE NUMBER \n");
	printf("_____________________________________________\n\n");

	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t\t%s\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].symbol_type, symbol_table[i].line_no);
	}
    
	printf("\n\n");
}

/*  Search symbols */
int search_type(char *symbol) {
	int x;
	for(x=count-1; x>=0; x--) {
		if(strcmp(symbol_table[x].id_name, symbol)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

/* Adding the symbols to the symbol table */
void add_symbol(char symbol_cat){
    query = search_type(yytext);

    if(!query){
        if(symbol_cat == 'K') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("N/A");
			symbol_table[count].line_no=countln;
			symbol_table[count].symbol_type=strdup("Keyword\t");
			count++;
		}
		else if(symbol_cat == 'V') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countln;
			symbol_table[count].symbol_type=strdup("Variable");
			count++;
		}
		else if(symbol_cat == 'C') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("CONST");
			symbol_table[count].line_no=countln;
			symbol_table[count].symbol_type=strdup("Constant");
			count++;
		}
		else if(symbol_cat == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countln;
			symbol_table[count].symbol_type=strdup("Function");
			count++;
		}
        else if(symbol_cat == 'P') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countln;
			symbol_table[count].symbol_type=strdup("Prototype");
			count++;
		}
    }
}

/* Copy the data type of variables to the 'type' character array */
void insert_type() {
	strcpy(type, yytext);
}

/* Prints the errors that occur when we compile and execute our Yacc file */
void yyerror(const char* msg) {
    fprintf(stderr, "%s in line number %d\n", msg, yylineno);
}