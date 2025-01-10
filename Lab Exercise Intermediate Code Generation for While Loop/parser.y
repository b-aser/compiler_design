 %{
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 // Counter for temporary variables and labels
 int temp_count = 0;
 int label_count = 0;
 // External declarations for Flex integration
 extern FILE* yyin;
 int yylex(void);
 void yyerror(const char* s);
 // Generate new temporary variable
 char* new_temp() {
 char* temp = (char*)malloc(10);
 sprintf(temp, "t%d", temp_count++);
 return temp;
 }
 // Generate new label
 char* new_label() {
 char* label = (char*)malloc(10);
 sprintf(label, "L%d", label_count++);
 return label;
 }
 %}
 %union {
    char* string;
 }
 %token <string> WHILE IDENTIFIER NUMBER
 %token EQ
 %left '+' '-'
 %left '*' '/'
 %type <string> condition expression statements statement
 %%
 program:
    statements
    ;
 statements:
    statement
    | statements statement
    ;
 statement:
      WHILE '(' condition ')' '{' statements '}'
      {
          char* start_label = new_label();
          char* end_label = new_label();
          printf("%s:\n", start_label);                // Start of the loop
          printf("IF NOT %s GOTO %s\n", $3, end_label); // Condition check
          printf("%s\n", $6);                          // Loop body
          printf("GOTO %s\n", start_label);            // Jump back to the condition
          printf("%s:\n", end_label);                  // End of the loop
      }
    | IDENTIFIER '=' expression ';'
      {
          printf("%s = %s\n", $1, $3);
      }
    ;
 condition:
    expression '<' expression
    {
        char* temp = (char*)malloc(strlen($1) + strlen($3) + 5);
        sprintf(temp, "%s < %s", $1, $3);
        $$ = temp;
    }
    | expression '>' expression
    {
        char* temp = (char*)malloc(strlen($1) + strlen($3) + 5);
        sprintf(temp, "%s > %s", $1, $3);
        $$ = temp;
    }
    | expression EQ expression
    {
        char* temp = (char*)malloc(strlen($1) + strlen($3) + 5);
        sprintf(temp, "%s == %s", $1, $3);
        $$ = temp;
    }
    ;
 expression:
      expression '+' expression
      {
          char* temp = new_temp();
          printf("%s = %s + %s\n", temp, $1, $3);
          $$ = temp;
      }
    | expression '-' expression
      {
          char* temp = new_temp();
          printf("%s = %s - %s\n", temp, $1, $3);
          $$ = temp;
      }
    | expression '*' expression
      {
          char* temp = new_temp();
          printf("%s = %s * %s\n", temp, $1, $3);
          $$ = temp;
      }
    | expression '/' expression
      {
          char* temp = new_temp();
          printf("%s = %s / %s\n", temp, $1, $3);
          $$ = temp;
      }
    | NUMBER
      {
          $$ = $1;
      }
    | IDENTIFIER
      {
          $$ = $1;
      }
    ;
 %%
 int main(int argc, char* argv[]) {
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
    yyparse();
    return 0;
 }
 void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: %s\n", s);
 }