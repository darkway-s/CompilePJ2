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
ELSIF ELSIF
VAR VAR
MY_BEGIN BEGIN
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
LCbracket \{
RCbracket \}

BIGGER >
SMALLER <
EQUAL =
NSMALLER >=
NBIGGER <=
SQUARE <>

Llimit \[<
Rlimit >\]

INTEGER [1-9]+[0-9]*|0 
REAL   [0-9]+\.[0-9]* 

SPACE [ \t\r]*
EOL \n

WS              [ \t]+
NEW_LINE        [\n]
LETTER		    [A-Z]|[a-z]
DIGIT           [0-9]
STRING          \"[^\"^\n]*\"
ID		        {LETTER}+({LETTER}|{DIGIT})*
UN_STRING       \"[^\"^\n]*\n

%x COMMENT

%%
{WS}                    {cols += yyleng; lcol += yyleng; }
{SPACE}                 {cols += yyleng; lcol += yyleng; }
{EOL}                   {cols = 1; lcol = 1; rows++; }
{SEMI}                  {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng;  return SEMI;}
{COLON}                 {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng;  return COLON;}
{COMMA}                 {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng;  return COMMA;}
{ASSIGNOP}              {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return ASSIGNOP;}
{Lbracket}                    {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng;  return Lbracket;}
{Rbracket}                     {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng;  return Rbracket;}
{ADD}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return ADD;}
{MINUS}                   {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return MINUS;}
{STAR}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return STAR;}
{DIVISON}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++;  return DIVISON;}
{PROGRAM}                 {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return PROGRAM;}
{IS}                      {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return IS;}
{AND}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return AND;}
{ARRAY}                   {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return ARRAY;}
{MY_BEGIN}                   {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return MY_BEGIN;}
{BY}                      {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return BY;}
{DIV}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return DIV;}
{DO}                      {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return DO;}
{ELSE}                    {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return ELSE;}
{ELSIF}                  {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return ELSIF;}
{VAR}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return VAR;}
{END}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return END;}
{WRITE}                   {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng;  return WRITE;} 
{STRING}                  {yylval.node=CreateAst("STRING",0,yylineno,cols); cols+=yyleng; tokens_num++;  return STRING;}
{INTEGER}			      {yylval.node=CreateAst("INTEGER",0,yylineno,cols); cols+=yyleng; tokens_num++; return INTEGER;}
{REAL}			      {yylval.node=CreateAst("REAL",0,yylineno,cols); cols+=yyleng; tokens_num++;  return REAL;}
{READ}                    {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return READ;}
{LSbracket}               {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return LSbracket;}
{RSbracket}               {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return RSbracket;}
{SPOT}                    {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return SPOT;}
{OF}                      {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return OF;}
{RECORD}                  {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return RECORD;}
{PROCEDURE}               {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return PROCEDURE;}
{TYPE}                    {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return TYPE;}
{NOT}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return NOT;}
{MOD}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return MOD;}
{OR}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return OR;}
{BIGGER}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return BIGGER;}
{SMALLER}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return SMALLER;}
{EQUAL}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return EQUAL;}
{NSMALLER}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return NSMALLER;}
{NBIGGER}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return NBIGGER;}
{SQUARE}                     {yylval.node=CreateAst("OPERATOR",0,yylineno,cols); cols+=yyleng; tokens_num++; return SQUARE;}
{Llimit}                     {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return Llimit;}
{Rlimit}                     {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return Rlimit;}
{LCbracket}                     {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return LCbracket;}
{RCbracket}                     {yylval.node=CreateAst("DELIMITER",0,yylineno,cols); cols+=yyleng; return RCbracket;}
{RETURN}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return RETURN;}
{EXIT}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return EXIT;}
{FOR}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return FOR;}
{LOOP}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return LOOP;}
{WHILE}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return WHILE;}
{IF}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return IF;}
{THEN}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return THEN;}
{TO}                     {yylval.node=CreateAst("KEYWORD",0,yylineno,cols); cols+=yyleng; return TO;}
{ID}                      {yylval.node=CreateAst("IDENTIFIER",0,yylineno,cols); cols+=yyleng; tokens_num++; return ID;}

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
