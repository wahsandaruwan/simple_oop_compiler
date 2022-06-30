%{
/* ---C declarations--- */

#include "parser.tab.h"

/* Keep track of the line number */
int countln = 0;
%}

/* Creates a scanner that stores a line number */
%option yylineno

/* ---Regular expressions--- */

ALPHA                   [a-zA-Z]
NUMBER                  [0-9]
UNARY                   "++"|"--"

/* ---Token specifications (Pattern -> Action)--- */
%%
"class"                         { return CLASS; }
"extends"                       { return EXTENDS; }
"interface"                     { return INTERFACE; }
"implements"                    { return IMPLEMENTS; }
"this"                          { return THIS; }
"print"                         { return PRINT; }
"int"                           { return INT; }
"double"                        { return DOUBLE; }
"char"                          { return CHAR; }
"string"                        { return STRING; }
"bool"                          { return BOOL; }
"void"                          { return VOID; }
"return"                        { return RETURN; }
"while"	                        { return WHILE; }
"for"	                        { return FOR; }
"if"	                        { return IF; }
"else"	                        { return ELSE; }
"break"	                        { return BREAK; }
"null"                          { return NULL_VAL; }
"true"                          { return TRUE; }
"false"                         { return FALSE; }
"New"                           { return NEW; }
"NewArray"                      { return NEW_ARRAY; }
"ReadInteger"                   { return READ_INTEGER; }
"ReadLine"                      { return READ_LINE; }
[-]?{NUMBER}+                   { return INT_NUM; }
[-]?{NUMBER}+\.{NUMBER}{1,15}   { return DOUBLE_NUM; }
{ALPHA}({ALPHA}|{NUMBER})*      { return IDENT; }
{UNARY}                         { return UNARY; }
"<="                            { return LE; }
">="                            { return GE; }
"=="                            { return EQ; }
"!="                            { return NE; }
">"	                            { return GT; }
"<"	                            { return LT; }
"&&"	                        { return AND; }
"||"	                        { return OR; }
"!"                             { return NOT; }
"+"                             { return ADD; }
"-"                             { return SUBTRACT; }
"/"                             { return DIVIDE; }
"*"                             { return MULTIPLY; }
"%"                             { return MODULUS; }
\/\/.*                          { ; }
\/\*(.*\n)*.*\*\/               { ; } 
[ \t]*                          { ; }
[\n]                            { countln++; }
.	                            { return *yytext; }
["].*["]                        { return STR; }
['].[']                         { return CHARACTER; }
%%

/* ---Functions--- */

/* Wrap up all */
int yywrap() {
    return 1;
}