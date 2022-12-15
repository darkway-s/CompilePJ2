%{
# include <iostream>
# include "syntax_tree.h"
# include "lexer.c"
using namespace std;

struct Ast *ast_root = NULL;

%}

%union {
  struct Ast* node;
  double val;
}

%left <node> SEMI COLON COMMA SPOT ASSIGNOP
%left <node> BIGGER SMALLER EQUAL NSMALLER NBIGGER SQUARE
%left <node> OR
%left <node> AND
%left <node> ADD MINUS
%left <node> STAR DIVISON DIV MOD
%left <node> NOT
%left <node> UNARYOP /* 用来区分并给出一元运算符的优先级*/


%token <node> INTEGER REAL STRING
%token <node> PROGRAM IS MY_BEGIN VAR END WRITE 
%token <node> Lbracket Rbracket ID TYPE
%token <node> DO BY ARRAY ELSE ELSIF READ
%token <node> LSbracket RSbracket OF PROCEDURE
%token <node> RECORD
%token <node> Llimit Rlimit LCbracket RCbracket
%token <node> RETURN EXIT FOR LOOP WHILE IF THEN TO
%token <node> EOL T_EOF C_EOF

%type <node> program body declaration var-decl
%type <node> type-decl procedure-decl type component
%type <node> formal-params statement
%type <node> fp-section write-params write-expr
%type <node> expression lvalue actual-params comp-values
%type <node> array-values array-value number unary-op
%type <node> binary-op
%type <node> declaration_list statement_list
%type <node> var-decl_list type-decl_list procedure-decl_list
%type <node> COMMA_ID_list COLON_type_option
%type <node> component_list SEMI_fp-section_list
%type <node> COMMA_lvalue_list ELSIF_statement_list_list
%type <node> ELSE_statement_list_option BY_expression_option expression_option
%type <node> COMMA_expression_list COMMA_write-expr_list
%type <node> tmp_list_1
%type <node> COMMA_array-value_list


/*出现xxx_list/option会多写一个它的定义,其余按照PCAT语言参考指南的顺序*/
%%
program: {$$=newast("program", 0, -1);} /*没匹配到则默认创建的节点*/
  | PROGRAM IS body SEMI{$$=newast("program", 4, $1, $2, $3, $4); evalformat($$, 0);}
  ;
body: {$$=newast("body", 0, -1);}
  | declaration_list MY_BEGIN statement_list END{$$=newast("body", 4, $1, $2, $3, $4);}
  ;
declaration_list: {$$=newast("declaration_list",0,-1);}
  | declaration declaration_list {$$=newast("declaration_list", 2, $1, $2);}
  ;
statement_list: {$$=newast("statement_list",0,-1);}
  | statement statement_list{$$=newast("statement_list", 2, $1, $2);}
  ;
declaration: VAR var-decl_list{$$=newast("declaration", 2, $1, $2);}
  | TYPE type-decl_list{$$=newast("declaration", 2, $1, $2);}
  | PROCEDURE procedure-decl_list{$$=newast("declaration", 2, $1, $2);}
  ;
var-decl_list: {$$=newast("var-decl_list", 0, -1);}
  | error {yyclearin; yyerror("var declaration error", cols); yyerrok;} // error decl
  | var-decl var-decl_list{$$=newast("var-decl_list", 2, $1, $2);}
  ;
type-decl_list: {$$=newast("type-decl_list", 0, -1);}
  | type-decl type-decl_list{$$=newast("type-decl_list", 2, $1, $2);}
  ;
procedure-decl_list: {$$=newast("procedure-decl_list", 0, -1);}
  | procedure-decl procedure-decl_list{$$=newast("procedure-decl_list",2 , $1, $2);}
  ;
var-decl: ID COMMA_ID_list COLON_type_option ASSIGNOP expression SEMI{$$=newast("var-decl", 6, $1, $2, $3, $4, $5, $6);}
  ;
COMMA_ID_list: {$$=newast("COMMA_ID_list", 0, -1);}
  | COMMA ID COMMA_ID_list{$$=newast("COMMA_ID_list", 3, $1, $2, $3);}
  ;
COLON_type_option: {$$=newast("COLON_type_option", 0, -1);}
  | COLON type {$$=newast("COLON_type_option", 2, $1, $2);}
  ;
type-decl: ID IS type SEMI {$$=newast("type-decl", 4, $1, $2, $3, $4);}
  ;
procedure-decl: ID formal-params COLON_type_option IS body SEMI {$$=newast("procedure-decl", 6, $1, $2, $3, $4, $5, $6);}
  | ID formal-params COLON_type_option PROCEDURE {yyclearin;yyerror("procedure error:, wrong format?", cols - 5); yyerrok;}
  ;
type: ID {$$=newast("type", 1, $1);}
  | ARRAY OF type {$$=newast("type", 3, $1, $2, $3);}
  | RECORD component component_list END {$$=newast("type", 4, $1, $2, $3, $4);}
  ;
component_list: {$$=newast("component_list", 0, -1);}
  | component component_list{$$=newast("component_list", 2, $1, $2);}
  ;
component: ID COLON type SEMI {$$=newast("component", 4, $1, $2, $3, $4);}
  ;
formal-params: Lbracket fp-section SEMI_fp-section_list Rbracket {$$=newast("formal-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=newast("formal-params", 2, $1, $2);}
  ;
SEMI_fp-section_list: {$$=newast("SEMI_fp-section_list", 0, -1);}
  | SEMI fp-section SEMI_fp-section_list {$$=newast("SEMI_fp-section_list", 3, $1, $2, $3);}
  ;
fp-section: ID COMMA_ID_list COLON type {$$=newast("fp-section", 4, $1, $2, $3, $4);}
  ;
statement: lvalue ASSIGNOP expression SEMI {$$=newast("statement", 4, $1, $2, $3, $4);}
  | error WRITE{yyclearin; yyerror("statement error, lack semicolon?", cols - 9); yyerrok;}
  | ID actual-params SEMI {$$=newast("statement", 3, $1, $2, $3);}
  | READ Lbracket lvalue COMMA_lvalue_list Rbracket SEMI {$$=newast("statement",6, $1, $2, $3, $4, $5, $6);}
  | WRITE write-params SEMI {$$=newast("statement", 3, $1, $2, $3);}
  | IF expression THEN statement_list ELSIF_statement_list_list ELSE_statement_list_option END SEMI {$$=newast("statement", 8, $1, $2, $3, $4, $5, $6, $7, $8);}
  | WHILE expression DO statement_list END SEMI {$$=newast("statement", 6, $1, $2, $3, $4, $5, $6);}
  | LOOP statement_list END SEMI {$$=newast("statement", 4, $1, $2, $3, $4);}
  | FOR ID ASSIGNOP expression TO expression BY_expression_option DO statement_list END SEMI {$$=newast("statement", 11, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);}
  | EXIT SEMI {$$=newast("statement", 2, $1, $2);}
  | RETURN expression_option SEMI {$$=newast("statement", 3, $1, $2, $3);}
  ;
COMMA_lvalue_list: {$$=newast("COMMA_lvalue_list", 0, -1);}
  | COMMA lvalue COMMA_lvalue_list {$$=newast("COMMA_lvalue_list", 3, $1, $2, $3);}
  ;
ELSIF_statement_list_list: {$$=newast("ELSIF_statement_list_list", 0, -1);}
  | ELSIF expression THEN statement_list ELSIF_statement_list_list{$$=newast("ELSIF_statement_list_list", 5, $1, $2, $3, $4, $5);}
  ;
ELSE_statement_list_option: {$$=newast("ELSE_statement_list_option", 0, -1);}
  | ELSE statement_list {$$=newast("ELSE_statement_list_option", 2, $1, $2);}
  ;
BY_expression_option: {$$=newast("BY_expression_option", 0, -1);}
  | BY expression {$$=newast("BY_expression_option", 2, $1, $2);}
  ;
expression_option: {$$=newast("expression_option", 0, -1);}
  | expression {$$=newast("expression_option", 1, $1);}
  ;
write-params: Lbracket write-expr COMMA_write-expr_list Rbracket {$$=newast("write-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=newast("write-params", 2, $1, $2);}
  ;
COMMA_write-expr_list: {$$=newast("COMMA_write-expr_list", 0, -1);}
  | COMMA write-expr COMMA_write-expr_list {$$=newast("COMMA_write-expr_list", 3, $1, $2, $3);}
  ;
write-expr: STRING {$$=newast("write-expr", 1, $1);}
  | expression {$$=newast("write-expr", 1, $1);}
  ;
expression: number {$$=newast("expression", 1, $1);}
  | lvalue {$$=newast("expression", 1, $1);}
  | Lbracket expression Rbracket {$$=newast("expression", 3, $1, $2, $3);}
  | unary-op expression %prec UNARYOP {$$=newast("expression", 2, $1, $2);}
  | expression binary-op expression {$$=newast("expression", 3, $1, $2, $3);}
  | ID actual-params {$$=newast("expression", 2, $1, $2);}
  | ID comp-values {$$=newast("expression", 2, $1, $2);}
  | ID array-values {$$=newast("expression", 2, $1, $2);}
  ;
lvalue: ID {$$=newast("lvalue", 1, $1);}
  | lvalue LSbracket expression RSbracket {$$=newast("lvalue", 4, $1, $2, $3, $4);}
  | lvalue SPOT ID {$$=newast("lvalue", 3, $1, $2, $3);}
  ;
actual-params: Lbracket expression COMMA_expression_list Rbracket {$$=newast("actual-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=newast("actual-params", 2, $1, $2);}
  ;
COMMA_expression_list: {$$=newast("COMMA_expression_list", 0, -1);}
  | COMMA expression COMMA_expression_list {$$=newast("COMMA_expression_list", 3, $1, $2, $3);}
  ;
comp-values: LCbracket ID ASSIGNOP expression tmp_list_1 RCbracket {$$=newast("comp-values", 6, $1, $2, $3, $4, $5, $6);}
  ;
tmp_list_1: {$$=newast("tmp_list_1", 0, -1);}
  | SEMI ID ASSIGNOP expression tmp_list_1 {$$=newast("tmp_list_1", 5, $1, $2, $3, $4, $5);}
  ;
array-values: Llimit array-value COMMA_array-value_list Rlimit {$$=newast("array-values", 4, $1, $2, $3, $4);}
  ;
COMMA_array-value_list: {$$=newast("COMMA_expression_list", 0, -1);}
  | COMMA array-value COMMA_array-value_list {$$=newast("COMMA_array-value_list", 3, $1, $2, $3);}
  ;
array-value: expression {$$=newast("array-value", 1, $1);}
  | expression OF expression {$$=newast("array-value", 3, $1, $2, $3);}
  ;
number: INTEGER {$$=newast("number", 1, $1);}
  | REAL {$$=newast("number", 1, $1);}
  ;
unary-op: ADD | MINUS | NOT {$$=newast("unary-op", 1, $1);}
  ;
binary-op: ADD | MINUS | STAR | DIVISON | DIV | MOD | OR | AND | BIGGER | SMALLER | NBIGGER | NSMALLER | EQUAL | SQUARE {$$=newast("binary-op", 1, $1);}
  ;

%%
