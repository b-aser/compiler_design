%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex(void);
extern int line_number;
void yyerror(const char* s);

%}
%union {
    char* string;
}

%token <string> INT IDENTIFIER NUMBER
%left '+' '-'
%left '*' '/'

%%

program:
    statements
    ;

statements:
    statement
    | statements statement
    ;

statement:
      INT IDENTIFIER ';'
    | IDENTIFIER '=' expression ';'
    ;

expression:
      expression '+' expression
      { printf("Addition operation detected (line %d).\n", line_number); }
    | expression '-' expression
      { printf("Subtraction operation detected (line %d).\n", line_number); }
    | expression '*' expression
      { printf("Multiplication operation detected (line %d).\n", line_number); }
    | expression '/' expression
      { printf("Division operation detected (line %d).\n", line_number); }
    | '(' expression ')'
    | NUMBER
    | IDENTIFIER
    ;

%%

int main(int argc, char* argv[]) {
    // Check if input file is provided
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        yyin = file;  // Set Flex's input stream to the file
    } else {
        printf("Usage: %s <input_file.java>\n", argv[0]);
        return 1;
    }
   // Start parsing
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: %s at line %d\n", s, line_number);
}
