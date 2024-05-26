D                       [0-9]
L                       [a-zA-Z_]

%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
extern int yylineno;
extern int yylval;



/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%option yylineno
%option noyywrap
%%
"else"                  { return ELSE ; }
"extern"                { return EXTERN ; }
"for"                   { return FOR ; }
"if"                    { return IF ; }
"int"                   { return INT ; }
"return"                { return RETURN ; }
"sizeof"                { return SIZEOF ; }
"struct"                { return STRUCT ; }
"void"                  { return VOID ; }
"while"                 { return WHILE ; }

{L}({L}|{D})*           { return IDENTIFIER ; } /* Identificateurs */

[1-9]{D}*               { return CONSTANT ; }

\/\*([^*]|\*[^/]|[\n])*?\*\/$       {} /* Commentaires ignorés */


"*"                     { return '*' }
"/"                     { return '/' }
"-"                     { return '-' }
"+"                     { return '+' }
"&"                     { return '&' }
"->"                    { return PTR_OP ; }
"*"                     { return '*' }
"&&"                    { return AND_OP ; }
"||"                    { return OR_OP ; }
"<"                     { return '<' }
">"                     { return '>' }
"<="                    { return LE_OP ; }
">="                    { return GE_OP ; }
"=="                    { return EQ_OP ; }
"!="                    { return NE_OP ; }

[ \t\v\f]               {} /* caractères d'échappement ignorés */
"\n"                    {yylineno++; }
.                       { printf("Error at line %d", yylineno);return yytext[0]; }
%%

int main(){
    yylex();
    return (0);
}