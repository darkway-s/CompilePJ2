GCC = @g++
LEX = @flex
YACC = @bison

parser: main.cpp yacc.o
			$(GCC) main.cpp yacc.o -o parser

yacc.o: yacc.c
			$(GCC) -c yacc.c -w

yacc.c: parser.y lexer.c
			$(YACC) -o yacc.c -d parser.y

lexer.c: parser.l
			$(LEX) -o lexer.c parser.l

clean:
			@-rm -f *.o *~ yacc.c yacc.h lexer.c parser
.PHONY: clean

test:
			./parser tests/case_1.pcat  ans/res1.txt
			./parser tests/case_2.pcat  ans/res2.txt
			./parser tests/case_3.pcat  ans/res3.txt
			./parser tests/case_4.pcat  ans/res4.txt
			./parser tests/case_5.pcat  ans/res5.txt
			./parser tests/case_6.pcat  ans/res6.txt
			./parser tests/case_7.pcat  ans/res7.txt
			./parser tests/case_8.pcat  ans/res8.txt
			./parser tests/case_9.pcat  ans/res9.txt
			./parser tests/case_10.pcat  ans/res10.txt
			./parser tests/case_12.pcat  ans/res12.txt
			./parser tests/case_13.pcat  ans/res13.txt
			./parser tests/case_14.pcat  ans/res14.txt
			./parser tests/case_11.pcat  ans/res11.txt -d