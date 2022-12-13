%{
#include "stdio.h"
#include "stdlib.h"
#include "yacc.h"
int tokens_num = 0;
int cols = 1;
int rows = 1;
int lcol = 1;
%}
%option yylineno

PROGRAM PROGRAM
IS IS
AND AND
ARRAY ARRAY
BY BY
DIV DIV
DO DO
ELSE ELSE
ELSEIF ELSIF
VAR VAR
BEGIN_1 BEGIN
END END
WRITE WRITE 
READ READ
OF OF
RECORD RECORD
PROCEDURE PROCEDURE
TYPE TYPE
NOT NOT
MOD MOD
OR OR
RETURN RETURN
EXIT EXIT
FOR FOR
LOOP LOOP
WHILE WHILE
IF IF
THEN THEN
TO TO

SEMI ;
COMMA ,
COLON :
ASSIGNOP :=
STAR \*
DIVISON \/
ADD \+
MINUS -
Lbracket \(
Rbracket \)
LSbracket \[
RSbracket \]
SPOT \.
LHbracket \{
RHbracket \}

BIGGER >
SMALLER <
EQUAL =
NSMALLER >=
NBIGGER <=
SQUARE <>

Llimit \[<
Rlimit >\]

INTEGER [1-9]+[0-9]*|0 
FLOAT   [0-9]+\.[0-9]* 

SPACE [ \t\r]*
EOL \n

WS              [ \t]+
NEW_LINE        [\n]
LETTER		    [A-Z]|[a-z]
DIGIT           [0-9]
STRING          \"[^\"^\n]*\"
TYPENAME        (INTEGER)|(REAL)
ID		        {LETTER}+({LETTER}|{DIGIT})*
UN_STRING       \"[^\"^\n]*\n

%x COMMENT

%%
{WS}                    {cols += yyleng; lcol += yyleng; }
{SPACE}                 {cols += yyleng; lcol += yyleng; }
{EOL}                   {cols = 1; lcol = 1; rows++; }
{TYPENAME}              {yylval.a=newast((char*)"TYPENAME",0,yylineno,cols); cols+=yyleng;  return TYPENAME;}
{SEMI}                  {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng;  return SEMI;}
{COLON}                 {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng;  return COLON;}
{COMMA}                 {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng;  return COMMA;}
{ASSIGNOP}              {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return ASSIGNOP;}
{Lbracket}                    {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng;  return Lbracket;}
{Rbracket}                     {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng;  return Rbracket;}
{ADD}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return ADD;}
{MINUS}                   {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return MINUS;}
{STAR}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return STAR;}
{DIVISON}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return DIVISON;}
{PROGRAM}                 {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return PROGRAM;}
{IS}                      {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return IS;}
{AND}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return AND;}
{ARRAY}                   {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return ARRAY;}
{BEGIN_1}                   {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return BEGIN_1;}
{BY}                      {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return BY;}
{DIV}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return DIV;}
{DO}                      {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return DO;}
{ELSE}                    {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return ELSE;}
{ELSEIF}                  {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return ELSEIF;}
{VAR}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return VAR;}
{END}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return END;}
{WRITE}                   {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng;  return WRITE;} 
{STRING}                  {yylval.a=newast((char*)"STRING",0,yylineno,cols); cols+=yyleng; tokens_num++;  return STRING;}
{INTEGER}			      {yylval.a=newast((char*)"INTEGER",0,yylineno,cols); cols+=yyleng; tokens_num++; return INTEGER;}
{FLOAT}			      {yylval.a=newast((char*)"REAL",0,yylineno,cols); cols+=yyleng; tokens_num++;  return FLOAT;}
{READ}                    {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return READ;}
{LSbracket}               {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return LSbracket;}
{RSbracket}               {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return RSbracket;}
{SPOT}                    {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return SPOT;}
{OF}                      {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return OF;}
{RECORD}                  {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return RECORD;}
{PROCEDURE}               {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return PROCEDURE;}
{TYPE}                    {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return TYPE;}
{NOT}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return NOT;}
{MOD}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return MOD;}
{OR}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return OR;}
{BIGGER}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return BIGGER;}
{SMALLER}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return SMALLER;}
{EQUAL}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return EQUAL;}
{NSMALLER}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return NSMALLER;}
{NBIGGER}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return NBIGGER;}
{SQUARE}                     {yylval.a=newast((char*)"OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return SQUARE;}
{Llimit}                     {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return Llimit;}
{Rlimit}                     {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return Rlimit;}
{LHbracket}                     {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return LHbracket;}
{RHbracket}                     {yylval.a=newast((char*)"DELIMITER",0,yylineno,cols); cols+=yyleng; return RHbracket;}
{RETURN}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return RETURN;}
{EXIT}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return EXIT;}
{FOR}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return FOR;}
{LOOP}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return LOOP;}
{WHILE}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return WHILE;}
{IF}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return IF;}
{THEN}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return THEN;}
{TO}                     {yylval.a=newast((char*)"KEYWORD",0,yylineno,cols); cols+=yyleng; return TO;}
{ID}                      {yylval.a=newast((char*)"IDENTIFIER",0,yylineno,cols); cols+=yyleng; tokens_num++; return ID;}

{UN_STRING}             {lcol = 1; return UTSTRING;}
.                       {return BADCHAR;}

"(*"                   {cols += 2; lcol += 2; BEGIN COMMENT;}
<COMMENT>\n            {cols = 1; rows++; lcol = 1;} 
<COMMENT>"*)"          {cols += 2; lcol += 2; BEGIN INITIAL;}
<COMMENT>.             {cols += yyleng; lcol += yyleng; }
<COMMENT><<EOF>>       return C_EOF;
%%
int yywrap()
{
    return 1;
}
