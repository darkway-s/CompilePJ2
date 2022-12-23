/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_YACC_H_INCLUDED
# define YY_YY_YACC_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    SEMI = 258,
    COLON = 259,
    COMMA = 260,
    SPOT = 261,
    ASSIGNOP = 262,
    BIGGER = 263,
    SMALLER = 264,
    EQUAL = 265,
    NSMALLER = 266,
    NBIGGER = 267,
    SQUARE = 268,
    OR = 269,
    AND = 270,
    ADD = 271,
    MINUS = 272,
    STAR = 273,
    DIVISON = 274,
    DIV = 275,
    MOD = 276,
    NOT = 277,
    UNARYOP = 278,
    INTEGER = 279,
    REAL = 280,
    STRING = 281,
    PROGRAM = 282,
    IS = 283,
    MY_BEGIN = 284,
    VAR = 285,
    END = 286,
    WRITE = 287,
    Lbracket = 288,
    Rbracket = 289,
    ID = 290,
    TYPE = 291,
    DO = 292,
    BY = 293,
    ARRAY = 294,
    ELSE = 295,
    ELSIF = 296,
    READ = 297,
    LSbracket = 298,
    RSbracket = 299,
    OF = 300,
    PROCEDURE = 301,
    RECORD = 302,
    Llimit = 303,
    Rlimit = 304,
    LCbracket = 305,
    RCbracket = 306,
    RETURN = 307,
    EXIT = 308,
    FOR = 309,
    LOOP = 310,
    WHILE = 311,
    IF = 312,
    THEN = 313,
    TO = 314,
    EOL = 315,
    T_EOF = 316,
    C_EOF = 317
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 11 "parser.y"

  struct Ast* node;
  double val;

#line 125 "yacc.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_YACC_H_INCLUDED  */
