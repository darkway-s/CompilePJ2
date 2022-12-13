# include <iostream>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <stdarg.h>//变长参数函数所需的头文件
# include "yacc.h"
# include "syntax_tree.h"
using namespace std;

int yylex();
int yyparse();
extern "C" FILE* yyin;
char* filename;
FILE* fp = stdin;

extern int tokens_num;
extern int lcol;
extern int rows;
extern char *yytext;
extern int yyleng;

int flag = 0;
int i;



int main(int argc, char* args[]) {
  if (argc > 1) {
    FILE *file = fopen(args[1], "r");
    if (!file) {
      cerr << "Can not open file." << endl;
      return 1;
    } else {
      yyin = file;
    }
  }

  yyparse();
  return 0;
}


/*构造抽象语法树,变长参数，name:语法单元名字；num:变长参数中语法结点个数*/
struct ast *newast(char* name,int num,...){
  return nullptr;
}

/*遍历抽象语法树，level为树的层数*/
void eval(struct ast* a,int level){
  fprintf(fp,"    (row: %d, col: %d)",a->line, a->cols);
}

void evalformat(struct ast* a, int level){
  if(flag == 0){
        printf("打印syntax tree:\n");
        eval(a,level);
        printf("syntax tree打印完毕!\n\n");
    }
}