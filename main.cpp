#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdarg> //变长参数函数所需的头文件
#include "yacc.h"
#include "syntax_tree.h"
using namespace std;

int yylex();
int yyparse();
extern "C" FILE *yyin;
FILE *fp = stdin;
char* filename;

extern "C" int tokens_num;
extern "C" int lcol;
extern "C" int rows;
extern "C" char *yytext;
extern "C" int yyleng;

extern "C" struct Ast *ast_root;
int flag = 0;
int i;

int main(int argc, char *args[])
{
  if (argc > 1) {
    FILE *file = fopen(args[1], "r");
    cout << "this is agrs[1]" << args[1] << endl;
    cout << "this is agrs[2]" << args[2] << endl;
    if (argc > 2) {
        filename = args[2];
    }else {
        printf("Please designate the name of the outfile!\n");
        return 1;
    }
    if (!file) {
      printf("can not open file");
      return 1;
    } else {
      yyin = file;
    }
  }

  fp = fopen(filename,"w+");
  
  yyparse();
  
  fclose(fp);

  // deleteAst(ast_root);
  return 0;
}

/*构造抽象语法树,变长参数，name:语法单元名字；num:变长参数中语法结点个数*/
struct Ast *newast(char *name, int num, ...)
{
  va_list valist;                   // 定义变长参数列表
  struct Ast *a = new (struct Ast); // 新生成的父节点
  struct Ast *child;
  if (!a)
  {
    yyerror((char *)"out of space");
    exit(0);
  }
  a->name = name;        // 语法单元名字
  va_start(valist, num); // 初始化变长参数为num后的参数

  if (num > 0) // num>0为非终结符：变长参数均为语法树结点
  {
    // 先取得第一个参数
    child = va_arg(valist, struct Ast *);
    a->children.push_back(child);
    a->line = child->line; // 父节点a的行号等于第一个孩子的行号

    for (int i = 1; i < num; i++)
    {
      child = va_arg(valist, struct Ast *); // 取参数
      a->children.push_back(child);
    }
  }
  else // num==0为终结符或产生空的语法单元：第1个变长参数表示行号，产生空的语法单元行号为-1。
  {
    int t = va_arg(valist, int); // 取第1个变长参数, -1或者是行号
    int c = va_arg(valist, int); // 取第2个变长参数，列号
    a->line = t;
    a->cols = c;
    if (!strcmp(a->name, "INTEGER"))
    {
      a->intgr = atoi(yytext);
    }
    else if (!strcmp(a->name, "REAL"))
    {
      a->flt = atof(yytext);
    }
    else
    { // ID or TYPE
      char *t;
      t = (char *)malloc(sizeof(char *) * 40);
      strcpy(t, yytext);
      a->content = t;
    }
  }
  return a;
}

/*遍历抽象语法树，level为树的层数*/
void eval(struct Ast *a, int level)
{
  if (a != NULL)
  {
    for (int i = 0; i < level; i++) // 孩子结点相对父节点缩进2个空格
      fprintf(fp, "  ");
    if (a->line != -1)
    {                              // 产生空的语法单元不需要打印信息
      fprintf(fp, "%s ", a->name); // 打印语法单元名字
      // if((!strcmp(a->name,"ID"))||(!strcmp(a->name,"TYPE")))fprintf(fp,": %s ",a->idtype);
      if (!strcmp(a->name, "INTEGER"))
        fprintf(fp, ": %d", a->intgr);
      else if (!strcmp(a->name, "REAL"))
        fprintf(fp, ": %.1f", a->flt);
      else
        fprintf(fp, ": %s", a->content);
      // else
      fprintf(fp, "    (row: %d, col: %d)", a->line, a->cols);
    }
    fprintf(fp, "\n");

    // DFS
    for (std::vector<Ast *>::iterator iter = a->children.begin(); iter != a->children.end(); iter++)
    {
      eval((*iter), level + 1);
    }
  }
}

void evalformat(struct Ast *a, int level)
{
  if (flag == 0)
  {
    printf("打印syntax tree:\n");
    eval(a, level);
    printf("syntax tree打印完毕!\n\n");
  }
}

void yyerror(char *s, ...) // 变长参数错误处理函数
{
  flag = 1;
  va_list ap;
  va_start(ap, s);
  if (!strcmp(s, "syntax error!"))
  {
    return;
  }
  fprintf(fp, "(row: %d, ", yylineno); // 错误行号
  int cols = va_arg(ap, int);
  fprintf(fp, "col: %d) :error:", cols); // 错误列号
  vfprintf(fp, s, ap);
  fprintf(fp, "\n");
}

void deleteAst(struct Ast *a) // 回收内存~
{
  for (std::vector<Ast *>::iterator iter = a->children.begin(); iter != a->children.end(); iter++)
  {
    deleteAst((*iter));
  }
  delete a;
}