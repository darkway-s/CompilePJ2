      
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
char *filename;

extern "C" int tokens_num;
extern "C" int lcol;
extern "C" int col;
extern "C" int rows;
extern "C" char *yytext;
extern "C" int yyleng;

#define MAXSTRING_LEN 257
#define MAXIDENTI_LEN 255

extern "C" struct Ast *ast_root;
int flag = 0;
int lex_tag = 0;
int i;

int Has_TAB(char *target)
{
  int limit = strlen(target);
  for (int i = 0; i < limit; ++i)
  {
    if (target[i] == '\t')
      return 1;
  }
  return 0;
}

void doutput(FILE *fpl, const char *msg)
{
  fprintf(fpl, "%s\n", msg);
}
void doutput(FILE *fpl, const char *typ, const char *msg, int r, int lc)
{
  fprintf(fpl, "%d\t\t%d\t\t\t\t%s\t\t\t\t%s\n", r, lc, typ, msg);
}

int main(int argc, char *args[])
{
  if (argc > 1)
  {
    FILE *file = fopen(args[1], "r");
    cout << "Read from " << args[1] << endl;
    cout << "Write to " << args[2] << endl << endl;
    if (argc > 2)
    {
      filename = args[2];
    }
    else
    {
      printf("need destination filename\n");
      return 1;
    }
    if (!file)
    {
      printf("can not open file");
      return 1;
    }
    else
    {
      yyin = file;
    }
  }

  // 额外词法分析
  if (argc > 3 && !strcmp(args[3], "-lex"))
  {
    lex_tag = 1;
  }

  fp = fopen(filename, "w+");

  // 针对case_11
  if (argc > 3 && !strcmp(args[3], "-d"))
  {
    doutput(fp, "ROW\t\tCOL\t\t\t\tTYPE\t\t\t\t\tTOKEN/ERROR MESSAGE");
    while (1)
    {
      int n = yylex();
      if (n == T_EOF)
      {
        break;
      }
      else if (n == C_EOF)
      {
        doutput(fp, "comment  ", "an unterminated comment", rows, lcol);
        break;
      }
      else
      {
        switch (n)
        {
        case STRING:
          if (yyleng > MAXSTRING_LEN)
          {
            doutput(fp, "string    ", "an overly long string", rows, lcol);
            tokens_num--;
          }
          // an invalid string with tab(s) in it
          else if (Has_TAB(yytext))
          {
            doutput(fp, "string    ", "an invalid string with tab(s) in it", rows, lcol);
            tokens_num--;
          }
          // an ok string
          else
          {
            doutput(fp, "string    ", yytext, rows, lcol);
          }
          lcol += yyleng;
          break;

        case ID:
          // an overly long identifier
          if (yyleng > MAXIDENTI_LEN)
          {
            doutput(fp, "identifier", "an overly long identifier", rows, lcol);
            tokens_num--;
          }
          // an ok identifier
          else
          {
            doutput(fp, "identifier", yytext, rows, lcol);
          }
          lcol += yyleng;
          break;

        case UTSTRING:
          doutput(fp, "string    ", "an unterminated string", rows, lcol);
          rows++;
          break;

        case BADCHAR:
          doutput(fp, "bad char  ", "a bad character (bell)", rows, lcol);
          lcol += yyleng;
          break;

        case INTEGER:
          // an out of range integer
          if (yyleng > 10 || atoll(yytext) > 2147483647)
          {
            doutput(fp, "integer    ", "an out of range integer", rows, lcol);
            tokens_num--;
          }
          // valid case
          else
          {
            doutput(fp, "integer    ", yytext, rows, lcol);
          }
          lcol += yyleng;
          break;

        case ADD:
        case MINUS:
        case STAR:
        case DIVISON:
        case BIGGER:
        case SMALLER:
        case NBIGGER:
        case NSMALLER:
        case SQUARE:
        case ASSIGNOP:
          doutput(fp, "operator  ", yytext, rows, lcol);
          lcol += yyleng;
          break;

        case REAL:
          doutput(fp, "real      ", yytext, rows, lcol);
          lcol += yyleng;
          break;

        default:
          break;
        }
      }
    }
    fprintf(fp, "\nThe number of the tokens: %d\n", tokens_num);
  }
  else
  {
    yyparse();
    //程序正常运行则清除
    if(flag==0)
      deleteAst(ast_root);
  }
  fclose(fp);

  return 0;
}

/*构造抽象语法树,变长参数，name:语法单元名字；num:变长参数中语法结点个数*/
struct Ast *CreateAst(char *name, int num, ...)
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
    { // ID
      char *t;
      t = (char *)malloc(sizeof(char *) * 40);
      strcpy(t, yytext);
      a->content = t;
    }
  }
  return a;
}

/*遍历抽象语法树，level为树的层数*/
void PrintNode(struct Ast *a, int level)
{
  if (a != NULL)
  {
    for (int i = 0; i < level; i++) // 孩子结点相对父节点缩进2个空格
      fprintf(fp, "  ");
    if (a->line != -1)
    {                              // 产生空的语法单元不需要打印信息
      fprintf(fp, "%s ", a->name); // 打印语法单元名字
      if (!strcmp(a->name, "INTEGER"))
        fprintf(fp, ": %d", a->intgr);
      else if (!strcmp(a->name, "REAL"))
        fprintf(fp, ": %.1f", a->flt);
      else
      {
        if (a->content)
          fprintf(fp, ": %s", a->content);
      }
      fprintf(fp, "\t\t @(%d:%d)", a->line, a->cols);
    }
    fprintf(fp, "\n");

    // DFS
    for (std::vector<Ast *>::iterator iter = a->children.begin(); iter != a->children.end(); iter++)
    {
      PrintNode((*iter), level + 1);
    }
  }
}

void PrintAst(struct Ast *a, int level)
{
  if (flag == 0)
  {
    cout << "Printing Tree>>>" << endl;
    PrintNode(a, level);
    cout << "Success!" << endl << endl;
  }
  // if (flag == 1)
  // {
  //   cout << "Printing Error Tree>>>" << endl;
  //   PrintNode(a, level);
  //   cout << "End;" << endl << endl;
  // }
}

void yyerror(char *s, int err_cols)
{
  flag = 1;
  // 仅做语法分析
  if (lex_tag == 0)
  {
    if (!strcmp(s, "syntax error"))
    {
      return;
    }
    fprintf(fp, "(row: %d, col: %d):error: %s\n", yylineno, err_cols, s); // 错误行,列,内容
  }
  // 也做词法分析
  else
  {
    fprintf(fp, "(row: %d):error: %s\n", yylineno, s); // 错误行,内容
  }
}

void yyerror(char *s)
{
  flag = 1;
  // 仅做语法分析
  if (lex_tag == 0)
  {
    if (!strcmp(s, "syntax error"))
    {
      return;
    }
  }
  // 也做词法分析
  fprintf(fp, "(row: %d) error: %s\n", yylineno, s); // 错误行,内容
}


void deleteAst(struct Ast *a) // 回收内存~
{
  for (std::vector<Ast *>::iterator iter = a->children.begin(); iter != a->children.end(); iter++)
  {
    deleteAst((*iter));
  }
  if(!strcmp(a->name, "IDENTIFIER"))
  {
    free(a->content);
    a->content = nullptr;
  }
  delete a;
  a = nullptr;
}

    