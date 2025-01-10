%{
#include "parser.tab.h"  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line_number = 1;
%}

%%

"int"          { return INT; }
"if"           { return IF; }
"else"         { return ELSE; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.string = strdup(yytext); return IDENTIFIER; }

[0-9]+                 { yylval.string = strdup(yytext); return NUMBER; }

"+"|"-"|"*"|"/"    { return yytext[0]; }
"<"|">"|"<="|">="|"=="|"!="    { return yytext[0]; }

"="             { return '='; }
";"             { return ';'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }

"//".*          ;  
"/\*([^*]|\*+[^*/])*\*+/" ;  

\n               { line_number++; }

[ \t]+           ;

.               { printf("Unknown token '%s' at line %d\n", yytext, line_number); }

%%

int yywrap() {
    return 1;
}
