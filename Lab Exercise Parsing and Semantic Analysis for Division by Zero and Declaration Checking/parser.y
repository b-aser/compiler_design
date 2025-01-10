%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;  
extern int yylex(void);
extern int line_number;
void yyerror(const char* s);

// Symbol table for tracking used identifiers
#define MAX_IDENTIFIERS 100
char* symbol_table[MAX_IDENTIFIERS];
int symbol_count = 0;
void declare_identifier(const char* name);
int is_declared(const char* name);
%}

%union {
    char* string;
}

%token <string> INT IF ELSE IDENTIFIER NUMBER
%left '+' '-'
%left '*' '/'
%left '<' '>' '='

%nonassoc IFX
%type <string> condition expression
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
      {
          if (is_declared($2)) {
              printf("Error: Variable '%s' already declared (line %d).\n", $2, line_number);
              YYABORT;
          } else {
              declare_identifier($2);
              printf("Declared variable '%s' (line %d).\n", $2, line_number);
          }
      }
    | IDENTIFIER '=' expression ';'
      {
          if (!is_declared($1)) {
              printf("Error: Variable '%s' not declared (line %d).\n", $1, line_number);
              YYABORT;
          } else {
              printf("Assigned value to '%s' (line %d).\n", $1, line_number);
          }
      }
    | IF '(' condition ')' '{' statements '}' ELSE '{' statements '}'
      { printf("Parsed IF-ELSE statement (line %d).\n", line_number); }
    | IF '(' condition ')' '{' statements '}'
      { printf("Parsed IF statement (line %d).\n", line_number); }
    ;

condition:
    expression
    { printf("Evaluating condition at line %d.\n", line_number); }
    ;

expression:
      expression '+' expression
      { printf("Addition operation detected (line %d).\n", line_number); }
    | expression '-' expression
      { printf("Subtraction operation detected (line %d).\n", line_number); }
    | expression '*' expression
      { printf("Multiplication operation detected (line %d).\n", line_number); }
    | expression '>' expression
      { printf("Greater than operation detected (line %d).\n", line_number); }
    | expression '<' expression
      { printf("Less than comparison operation detected (line %d).\n", line_number); }
    | expression '=' expression
      { printf("Equality comparison detected (line %d).\n", line_number); }
    | expression '/' expression
      {
          if (strcmp($3, "0") == 0) {
              printf("Error: Division by zero (line %d).\n", line_number);
              YYABORT;
          }
          printf("Division operation detected (line %d).\n", line_number);
          $$ = strdup("result");
      }
    | '(' expression ')'
      { $$ = $2; }
    | NUMBER
      { $$ = $1; }
    | IDENTIFIER
      {
          if (!is_declared($1)) {
              printf("Error: Variable '%s' not declared (line %d).\n", $1, line_number);
              YYABORT;
          }

          $$ = $1;
      }
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

void declare_identifier(const char* name) {
    if (symbol_count >= MAX_IDENTIFIERS) {
        fprintf(stderr, "Error: Symbol table overflow (line %d).\n", line_number);
        exit(1);
    }
    symbol_table[symbol_count++] = strdup(name);
}

int is_declared(const char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i], name) == 0) {
            return 1;
        }
    }
    return 0;
}
