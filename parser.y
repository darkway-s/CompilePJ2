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
program: {$$=CreateAst("program", 0, -1);ast_root = $$;} /*没匹配到则默认创建的节点*/
  | PROGRAM IS body SEMI{$$=CreateAst("program", 4, $1, $2, $3, $4); ast_root = $$; PrintAst($$, 0);}
  ;
body: {$$=CreateAst("body", 0, -1);}
  | declaration_list MY_BEGIN statement_list END{$$=CreateAst("body", 4, $1, $2, $3, $4);}
  ;
declaration_list: {$$=CreateAst("declaration_list",0,-1);}
  | declaration declaration_list {$$=CreateAst("declaration_list", 2, $1, $2);}
  ;
statement_list: {$$=CreateAst("statement_list",0,-1);}
  | statement statement_list{$$=CreateAst("statement_list", 2, $1, $2);}
  ;
declaration: VAR var-decl_list{$$=CreateAst("declaration", 2, $1, $2);}
  | TYPE type-decl_list{$$=CreateAst("declaration", 2, $1, $2);}
  | PROCEDURE procedure-decl_list{$$=CreateAst("declaration", 2, $1, $2);}
  ;
var-decl_list: {$$=CreateAst("var-decl_list", 0, -1);}
  | error {yyclearin; yyerror("unknown number", cols); yyerrok;} // error decl
  | var-decl var-decl_list{$$=CreateAst("var-decl_list", 2, $1, $2);}
  ;
type-decl_list: {$$=CreateAst("type-decl_list", 0, -1);}
  | type-decl type-decl_list{$$=CreateAst("type-decl_list", 2, $1, $2);}
  ;
procedure-decl_list: {$$=CreateAst("procedure-decl_list", 0, -1);}
  | procedure-decl procedure-decl_list{$$=CreateAst("procedure-decl_list",2 , $1, $2);}
  ;
var-decl: ID COMMA_ID_list COLON_type_option ASSIGNOP expression SEMI{$$=CreateAst("var-decl", 6, $1, $2, $3, $4, $5, $6);}
  ;
COMMA_ID_list: {$$=CreateAst("COMMA_ID_list", 0, -1);}
  | COMMA ID COMMA_ID_list{$$=CreateAst("COMMA_ID_list", 3, $1, $2, $3);}
  ;
COLON_type_option: {$$=CreateAst("COLON_type_option", 0, -1);}
  | COLON type {$$=CreateAst("COLON_type_option", 2, $1, $2);}
  ;
type-decl: ID IS type SEMI {$$=CreateAst("type-decl", 4, $1, $2, $3, $4);}
  ;
procedure-decl: ID formal-params COLON_type_option IS body SEMI {$$=CreateAst("procedure-decl", 6, $1, $2, $3, $4, $5, $6);}
  | ID formal-params COLON_type_option body SEMI{yyclearin;yyerror("expected IS", cols); yyerrok;}
  ;
type: ID {$$=CreateAst("type", 1, $1);}
  | ARRAY OF type {$$=CreateAst("type", 3, $1, $2, $3);}
  | RECORD component component_list END {$$=CreateAst("type", 4, $1, $2, $3, $4);}
  ;
component_list: {$$=CreateAst("component_list", 0, -1);}
  | component component_list{$$=CreateAst("component_list", 2, $1, $2);}
  ;
component: ID COLON type SEMI {$$=CreateAst("component", 4, $1, $2, $3, $4);}
  ;
formal-params: Lbracket fp-section SEMI_fp-section_list Rbracket {$$=CreateAst("formal-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=CreateAst("formal-params", 2, $1, $2);}
  ;
SEMI_fp-section_list: {$$=CreateAst("SEMI_fp-section_list", 0, -1);}
  | SEMI fp-section SEMI_fp-section_list {$$=CreateAst("SEMI_fp-section_list", 3, $1, $2, $3);}
  ;
fp-section: ID COMMA_ID_list COLON type {$$=CreateAst("fp-section", 4, $1, $2, $3, $4);}
  ;
statement: lvalue ASSIGNOP expression SEMI {$$=CreateAst("statement", 4, $1, $2, $3, $4);}
  | ID actual-params SEMI {$$=CreateAst("statement", 3, $1, $2, $3);}
  | READ Lbracket lvalue COMMA_lvalue_list Rbracket SEMI {$$=CreateAst("statement",6, $1, $2, $3, $4, $5, $6);}
  | WRITE write-params SEMI {$$=CreateAst("statement", 3, $1, $2, $3);}
  | WRITE write-params {yyclearin; yyerror("expected semicolon", cols - 5); yyerrok;}
  | IF expression THEN statement_list ELSIF_statement_list_list ELSE_statement_list_option END SEMI {$$=CreateAst("statement", 8, $1, $2, $3, $4, $5, $6, $7, $8);}
  | WHILE expression DO statement_list END SEMI {$$=CreateAst("statement", 6, $1, $2, $3, $4, $5, $6);}
  | LOOP statement_list END SEMI {$$=CreateAst("statement", 4, $1, $2, $3, $4);}
  | FOR ID ASSIGNOP expression TO expression BY_expression_option DO statement_list END SEMI {$$=CreateAst("statement", 11, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);}
  | EXIT SEMI {$$=CreateAst("statement", 2, $1, $2);}
  | RETURN expression_option SEMI {$$=CreateAst("statement", 3, $1, $2, $3);}
  ;
COMMA_lvalue_list: {$$=CreateAst("COMMA_lvalue_list", 0, -1);}
  | COMMA lvalue COMMA_lvalue_list {$$=CreateAst("COMMA_lvalue_list", 3, $1, $2, $3);}
  ;
ELSIF_statement_list_list: {$$=CreateAst("ELSIF_statement_list_list", 0, -1);}
  | ELSIF expression THEN statement_list ELSIF_statement_list_list{$$=CreateAst("ELSIF_statement_list_list", 5, $1, $2, $3, $4, $5);}
  ;
ELSE_statement_list_option: {$$=CreateAst("ELSE_statement_list_option", 0, -1);}
  | ELSE statement_list {$$=CreateAst("ELSE_statement_list_option", 2, $1, $2);}
  ;
BY_expression_option: {$$=CreateAst("BY_expression_option", 0, -1);}
  | BY expression {$$=CreateAst("BY_expression_option", 2, $1, $2);}
  ;
expression_option: {$$=CreateAst("expression_option", 0, -1);}
  | expression {$$=CreateAst("expression_option", 1, $1);}
  ;
write-params: Lbracket write-expr COMMA_write-expr_list Rbracket {$$=CreateAst("write-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=CreateAst("write-params", 2, $1, $2);}
  ;
COMMA_write-expr_list: {$$=CreateAst("COMMA_write-expr_list", 0, -1);}
  | COMMA write-expr COMMA_write-expr_list {$$=CreateAst("COMMA_write-expr_list", 3, $1, $2, $3);}
  ;
write-expr: STRING {$$=CreateAst("write-expr", 1, $1);}
  | expression {$$=CreateAst("write-expr", 1, $1);}
  ;
expression: number {$$=CreateAst("expression", 1, $1);}
  | lvalue {$$=CreateAst("expression", 1, $1);}
  | Lbracket expression Rbracket {$$=CreateAst("expression", 3, $1, $2, $3);}
  | unary-op expression %prec UNARYOP {$$=CreateAst("expression", 2, $1, $2);}
  | expression binary-op expression {$$=CreateAst("expression", 3, $1, $2, $3);}
  | ID actual-params {$$=CreateAst("expression", 2, $1, $2);}
  | ID comp-values {$$=CreateAst("expression", 2, $1, $2);}
  | ID array-values {$$=CreateAst("expression", 2, $1, $2);}
  ;
lvalue: ID {$$=CreateAst("lvalue", 1, $1);}
  | lvalue LSbracket expression RSbracket {$$=CreateAst("lvalue", 4, $1, $2, $3, $4);}
  | lvalue SPOT ID {$$=CreateAst("lvalue", 3, $1, $2, $3);}
  ;
actual-params: Lbracket expression COMMA_expression_list Rbracket {$$=CreateAst("actual-params", 4, $1, $2, $3, $4);}
  | Lbracket Rbracket {$$=CreateAst("actual-params", 2, $1, $2);}
  ;
COMMA_expression_list: {$$=CreateAst("COMMA_expression_list", 0, -1);}
  | COMMA expression COMMA_expression_list {$$=CreateAst("COMMA_expression_list", 3, $1, $2, $3);}
  ;
comp-values: LCbracket ID ASSIGNOP expression tmp_list_1 RCbracket {$$=CreateAst("comp-values", 6, $1, $2, $3, $4, $5, $6);}
  ;
tmp_list_1: {$$=CreateAst("tmp_list_1", 0, -1);}
  | SEMI ID ASSIGNOP expression tmp_list_1 {$$=CreateAst("tmp_list_1", 5, $1, $2, $3, $4, $5);}
  ;
array-values: Llimit array-value COMMA_array-value_list Rlimit {$$=CreateAst("array-values", 4, $1, $2, $3, $4);}
  ;
COMMA_array-value_list: {$$=CreateAst("COMMA_expression_list", 0, -1);}
  | COMMA array-value COMMA_array-value_list {$$=CreateAst("COMMA_array-value_list", 3, $1, $2, $3);}
  ;
array-value: expression {$$=CreateAst("array-value", 1, $1);}
  | expression OF expression {$$=CreateAst("array-value", 3, $1, $2, $3);}
  ;
number: INTEGER {$$=CreateAst("number", 1, $1);}
  | REAL {$$=CreateAst("number", 1, $1);}
  ;
unary-op: ADD | MINUS | NOT {$$=CreateAst("unary-op", 1, $1);}
  ;
binary-op: ADD | MINUS | STAR | DIVISON | DIV | MOD | OR | AND | BIGGER | SMALLER | NBIGGER | NSMALLER | EQUAL | SQUARE {$$=CreateAst("binary-op", 1, $1);}
  ;

%%
