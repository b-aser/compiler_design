%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

"while"        { return WHILE; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.string = strdup(yytext); return IDENTIFIER; }

[0-9]+                 { yylval.string = strdup(yytext); return NUMBER; }

"="             { return '='; }
"<"             { return '<'; }
">"             { return '>'; }
"=="            { return EQ; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
";"             { return ';'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }

[ \t\n]+        ;

.               { printf("Unknown token: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}
