%{
#include<unistd.h>
#include<stdio.h>   
#include "syntax_tree.h"
#include "lexer.c"

struct Ast *ast_root = NULL;
%}

%union{
struct Ast* a;
double d;
}
%token <a> INTEGER FLOAT STRING
%token <a> PROGRAM IS BEGIN_1 VAR END WRITE SEMI COLON COMMA ASSIGNOP Lbracket Rbracket ID TYPE ADD MINUS STAR DIVISON REAL DO BY ARRAY AND ELSE ELSEIF DIV READ TYPENAME
%token <a> LSbracket RSbracket SPOT OF PROCEDURE
%token <a> NOT MOD OR RECORD
%token <a> BIGGER SMALLER EQUAL NSMALLER NBIGGER SQUARE Llimit Rlimit LHbracket RHbracket
%token <a> RETURN EXIT FOR LOOP WHILE IF THEN TO
%token <a> EOL
%token <a> T_EOF
%token <a> C_EOF

%type <a> body
%type <a> declaration
%type <a> var-decl
%type <a> var-decl2
%type <a> statement
%type <a> ID-closure
%type <a> write-params
%type <a> write-expr
%type <a> write-expr-closure
%type <a> unary-op
%type <a> binary-op
%type <a> expression
%type <a> lvalue
%type <a> lvalue-closure
%type <a> type-decl
%type <a> type-decl-closure
%type <a> type
%type <a> component
%type <a> component-closure
%type <a> procedure-decl
%type <a> procedure-decl2
%type <a> procedure-decl-closure
%type <a> formal-params
%type <a> fp-section
%type <a> fp-section-closure
%type <a> actual-params
%type <a> expression-closure
%type <a> array-value
%type <a> array2
%type <a> array-values
%type <a> array-closure
%type <a> comp-values
%type <a> comp-closure
%type <a> expression2
%type <a> statement-closure
%type <a> by-expression

%type <a> root


%%
 root: {$$=newast((char*)"root",0,-1); ast_root = $$;}
  | PROGRAM IS body SEMI{$$=newast((char*)"root",4,$1,$2,$3,$4);ast_root = $$;evalformat($$,0);}
  ;

body: {$$=newast((char*)"body",0,-1);}
  | declaration BEGIN_1 statement END {$$=newast((char*)"body",4,$1,$2,$3,$4);}
  ;

declaration: {$$=newast((char*)"declaration",0,-1);}
  | VAR var-decl SEMI declaration {$$=newast((char*)"declaration",4,$1,$2,$3,$4);}
  | var-decl SEMI declaration {$$=newast((char*)"declaration",3,$1,$2,$3);}
  | TYPE type-decl type-decl-closure declaration {$$=newast((char*)"declaration",4,$1,$2,$3,$4);}
  | PROCEDURE procedure-decl procedure-decl-closure declaration {$$=newast((char*)"declaration",4,$1,$2,$3,$4);}
  ;

var-decl: {$$=newast((char*)"var-decl",0,-1);}
  | error {yyclearin; yyerror((char*)"float error", cols); yyerrok;} 
  | ID ID-closure var-decl2 ASSIGNOP expression {$$=newast((char*)"var-decl",5,$1,$2,$3,$4,$5);}
  ;

var-decl2: {$$=newast((char*)"var-decl2",0,-1);}
  | COLON TYPENAME {$$=newast((char*)"var-decl2",2,$1,$2);}
  | COLON ID {$$=newast((char*)"var-decl2",2,$1,$2);}
  ;

ID-closure: {$$=newast((char*)"ID-closure",0,-1);}
  | COMMA ID ID-closure {$$=newast((char*)"ID-closure",3,$1,$2,$3);}
  ;

expression: INTEGER {$$=newast((char*)"integer", 1, $1);} 
  | FLOAT {$$=newast((char*)"real", 1, $1);}
  | unary-op expression {$$=newast((char*)"expression",2,$1,$2);}
  | expression binary-op expression {$$=newast((char*)"expression",3,$1,$2,$3);}
  | lvalue {$$=newast((char*)"expression",1,$1);}
  | Lbracket expression Rbracket {$$=newast((char*)"expression",3,$1,$2,$3);}
  | ID actual-params {$$=newast((char*)"expression",2,$1,$2);}
  | ID comp-values {$$=newast((char*)"expression",2,$1,$2);}
  | ID array-values {$$=newast((char*)"expression",2,$1,$2);}
  ;

unary-op: ADD | MINUS | NOT {$$=newast((char*)"unary-op",1,$1);};

binary-op: ADD | MINUS | STAR | DIVISON | DIV | MOD | OR | AND | BIGGER | SMALLER | EQUAL | NSMALLER | NBIGGER | SQUARE {$$=newast((char*)"binary-op",1,$1);};

statement: {$$=newast((char*)"statement",0,-1);}
  | error WRITE{yyclearin; yyerror((char*)"statement error, lack semi or other error",cols-5); yyerrok;}
  | WRITE write-params SEMI statement {$$=newast((char*)"statement",4,$1,$2,$3,$4);}
  | READ Lbracket lvalue lvalue-closure Rbracket SEMI statement {$$=newast((char*)"statement",7,$1,$2,$3,$4,$5,$6,$7);}
  | lvalue ASSIGNOP expression SEMI statement {$$=newast((char*)"statement",5,$1,$2,$3,$4,$5);}
  | ID actual-params SEMI statement {$$=newast((char*)"statement",4,$1,$2,$3,$4);}
  | RETURN expression2 SEMI statement {$$=newast((char*)"statement",4,$1,$2,$3,$4);}
  | EXIT SEMI statement {$$=newast((char*)"statement",3,$1,$2,$3);}
  | FOR ID ASSIGNOP expression TO expression by-expression DO statement END SEMI statement {$$=newast((char*)"statement",12,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12);}
  | LOOP statement END SEMI statement {$$=newast((char*)"statement",5,$1,$2,$3,$4,$5);}
  | WHILE expression DO statement END SEMI statement {$$=newast((char*)"statement",7,$1,$2,$3,$4,$5,$6,$7);}
  | IF expression THEN statement statement-closure expression2 END SEMI statement {$$=newast((char*)"statement",9,$1,$2,$3,$4,$5,$6,$7,$8,$9);}
  ;

by-expression: {$$=newast((char*)"by expression",0,-1);}
  | BY expression {$$=newast((char*)"by expression",2,$1,$2);}
  ;

expression2: {$$=newast((char*)"expression2",0,-1);}
  | expression {$$=newast((char*)"expression2",1,$1);}
  | ELSE statement {$$=newast((char*)"expression2",2,$1,$2);}
  ;

statement-closure: {$$=newast((char*)"statement-closure",0,-1);}
  | ELSEIF expression THEN statement statement-closure {$$=newast((char*)"statement-closure",5,$1,$2,$3,$4,$5);}
  ;

write-params: Lbracket write-expr write-expr-closure Rbracket {$$=newast((char*)"write-params",4,$1,$2,$3,$4);}
  | Lbracket Rbracket {$$=newast((char*)"write-params",2,$1,$2);}
  ;

write-expr: STRING {$$=newast((char*)"write-expr",1,$1);}
  | expression {$$=newast((char*)"write-expr",1,$1);}
  ;

write-expr-closure: {$$=newast((char*)"write-expr-closure",0,-1);}
  | COMMA write-expr write-expr-closure {$$=newast((char*)"write-expr-closure",3,$1,$2,$3);}
  ;

lvalue-closure: {$$=newast((char*)"lvalue-closure",0,-1);}
  | COMMA lvalue lvalue-closure {$$=newast((char*)"lvalue-closure",3,$1,$2,$3);}
  ;

lvalue: ID {$$=newast((char*)"lvalue",1,$1);}
  | lvalue LSbracket expression RSbracket {$$=newast((char*)"lvalue",4,$1,$2,$3,$4);}
  | lvalue SPOT ID {$$=newast((char*)"lvalue",3,$1,$2,$3);}
  ;

type-decl: ID IS type SEMI {$$=newast((char*)"type-decl",4,$1,$2,$3,$4);}
  ;

type-decl-closure: {$$=newast((char*)"type-decl-closure",0,-1);}
  | type-decl type-decl-closure {$$=newast((char*)"type-decl-closure",2,$1,$2);}
  ;

type: ID {$$=newast((char*)"type",1,$1);}
  | TYPENAME {$$=newast((char*)"type",1,$1);}
  | ARRAY OF type {$$=newast((char*)"type",3,$1,$2,$3);}
  | RECORD component component-closure END {$$=newast((char*)"type",4,$1,$2,$3,$4);}
  ;

component: ID COLON type SEMI {$$=newast((char*)"component",4,$1,$2,$3,$4);};

component-closure: {$$=newast((char*)"component-closure",0,-1);}
  | component component-closure {$$=newast((char*)"component-closure",2,$1,$2);}
  ;

procedure-decl-closure: {$$=newast((char*)"procedure-decl-closure",0,-1);}
  | procedure-decl procedure-decl-closure {$$=newast((char*)"procedure-decl-closure",2,$1,$2);}
  ;

procedure-decl: ID formal-params procedure-decl2 IS body SEMI {$$=newast((char*)"procedure-decl",6,$1,$2,$3,$4,$5,$6);}
  | ID formal-params procedure-decl2 PROCEDURE {yyclearin;yyerror((char*)"procedure error:, wrong format in declaration",cols-9); yyerrok;}
  ;

procedure-decl2: {$$=newast((char*)"procedure-decl2",0,-1);}
  | COLON type {$$=newast((char*)"procedure-decl2",2,$1,$2);}
  ;

formal-params: Lbracket Rbracket {$$=newast((char*)"formal-params",2,$1,$2);}
  | Lbracket fp-section fp-section-closure Rbracket {$$=newast((char*)"formal-params",4,$1,$2,$3,$4);}
  ;

fp-section-closure: {$$=newast((char*)"fp-section-closure",0,-1);}
  | SEMI fp-section fp-section-closure {$$=newast((char*)"fp-section-closure",3,$1,$2,$3);}
  ;

fp-section: ID ID-closure COLON type {$$=newast((char*)"fp-section",4,$1,$2,$3,$4);};

actual-params: Lbracket Rbracket {$$=newast((char*)"actual-params",2,$1,$2);}
  | Lbracket expression expression-closure Rbracket {$$=newast((char*)"actual-params",4,$1,$2,$3,$4);}
  ;

expression-closure: {$$=newast((char*)"expression-closure",0,-1);}
  | COMMA expression expression-closure {$$=newast((char*)"expression-closure",3,$1,$2,$3);}
  ;

array-value: array2 expression {$$=newast((char*)"array-value",2,$1,$2);};

array2: {$$=newast((char*)"array-value",0,-1);}
  | expression OF {$$=newast((char*)"array-value",2,$1,$2);}
  ;

array-values: Llimit array-value array-closure Rlimit {$$=newast((char*)"array-values",4,$1,$2,$3,$4);};

array-closure: {$$=newast((char*)"array-closure",0,-1);}
  | COMMA array-value array-closure {$$=newast((char*)"array-closure",3,$1,$2,$3);}
  ;

comp-values: LHbracket ID ASSIGNOP expression comp-closure RHbracket {$$=newast((char*)"comp-values",6,$1,$2,$3,$4,$5,$6);};

comp-closure: {$$=newast((char*)"comp-closure",0,-1);}
  | SEMI ID ASSIGNOP expression comp-closure {$$=newast((char*)"comp-closure",5,$1,$2,$3,$4,$5);}
  ;

%%