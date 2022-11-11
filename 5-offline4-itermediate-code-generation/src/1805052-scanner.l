%option noyywrap yylineno

%{
#include <bits/stdc++.h>
#include "symboltable/symbolinfo.h"
#include "symboltable/symboltable.h"
#include "y.tab.hpp"
using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
extern int errorCnt;

map<char, string> escapeCharMap = {
        {'n', "\n"},
        {'t', "\t"},
        {'\\', "\\"},
        {'\'', "\'"},
        {'a', "\a"},
        {'f', "\f"},
        {'r', "\r"},
        {'b', "\b"},
        {'v', "\v"},
        {'0', "\0"},
        {'\"', "\""},
    };

int countLines(string str){
        int cnt = 0;
        for(int i = 0; i < str.length(); i++){
            if(str[i]=='\n'){
                cnt++;
            }
        }
        return cnt;
}

void error(int line, string symbol, string erorrMessage) {
  cout << "Error at line no " << line << ": " << erorrMessage << " " << symbol << endl<<endl;
  errorCnt++;
}



%}

/* ================ PATTERNS ================== */
DIGIT [0-9]

EXPONENT [Ee][+-]?{DIGIT}+

NEWLINE (\r)?\n

CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?

CONST_CHAR \'[^\\\n\r]\'

CONST_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'

IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

/* --- ERRORS --- */
TOO_MANY_DEMICAL_POINTS_ERROR {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?
ILL_FORMAT_NUMBER_ERROR {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+
INVALID_SUFFIX_OR_PREFIX_ERROR  {CONST_FLOAT}+{IDENTIFIER}+
MULTI_CHAR_CONST_ERROR \'.[^\'\r\n]+\' 
UNTERMINATED_CHAR_ERROR \'(.|\\\')?[^\'\r\n]*

/* ============ translation rules====================*/
%%
   

[ \t\v]+ {} /*ignore whitespaces */
    
    /* platform independent new line */
{NEWLINE} {}

    /* ============== KEYWORDS ============== */
if { return IF;}
else { return ELSE;}
for { return FOR; }
while { return WHILE;}
do { return DO;}
break { return BREAK;}
int { return INT;}
char { return CHAR;}
float { return FLOAT;}
double { return DOUBLE;}
void { return VOID; }
return { return RETURN;}
switch { return SWITCH;}
case { return CASE;}
default { return DEFAULT;}
continue { return CONTINUE;}
println	{return PRINTLN;}

    /*arithmetic operators*/
[+-] { yylval.symbol_info = new SymbolInfo(yytext, "ADDOP");  return ADDOP;}
[*/%] { yylval.symbol_info = new SymbolInfo(yytext, "MULOP");  return MULOP;}

    /* unitary operators */
"++" { return INCOP;}
"--" { return DECOP;}

    /* relational operators */
\<|"<="|\>|">="|"=="|"!=" {
    yylval.symbol_info = new SymbolInfo(yytext, "RELOP");
    return RELOP;
}
    /* assignment operator */
\= { return ASSIGNOP;}

    /* logical operators */
"&&"|"||" { 
    yylval.symbol_info = new SymbolInfo(yytext, "LOGICOP");
    return LOGICOP;
}
\! { return NOT;}

    /* Punctuators */
\( { return LPAREN;}
\) { return RPAREN;}
\{ { return LCURL;}
\} { return RCURL;}
\[ { return LTHIRD;}
\] { return RTHIRD;}
\, { return COMMA;}
\; { return SEMICOLON;}

    /* ======== constants ============ */
    
    /* constant integers */
{DIGIT}+ {
    yylval.symbol_info = new SymbolInfo(yytext, "CONST_INT");
    return CONST_INT;
}

    /* constant floats */
{CONST_FLOAT} {
    yylval.symbol_info = new SymbolInfo(yytext, "CONST_FLOAT");
    return CONST_FLOAT; 
}
    /* CONST CHAR */
{CONST_CHAR} {
    yylval.symbol_info = new SymbolInfo(yytext, "CONST_CHAR");
    return CONST_CHAR;
}

{CONST_ESCAPE_CHAR} {
    yylval.symbol_info = new SymbolInfo(yytext, "CONST_CHAR");
    return CONST_CHAR;
}

    /* identifiers: names given to C entities,
     such as variables, functions, structures etc */
{IDENTIFIER} {
    yylval.symbol_info = new SymbolInfo(yytext, "ID");
    cout<<"ID: "<<yytext<<endl<<endl;
    return ID;
}
    /* ============ STRING =============== */
(\")(.|\\.|\\{NEWLINE})*(\") {
    return STRING;
}

    /* unterminated string error */
(\")(.|\\.|\\{NEWLINE})* {
    int lineCnt = 0;
    string str = yytext;
    for(int i = 0; i < str.length(); i++){
        if(str[i] == '\n'){
            lineCnt++;
        }
    }
    error(yylineno-lineCnt,yytext, "Unterminated String");
}

    /* ============== single line comment ===========*/
("//")(.|(\\{NEWLINE}))* {
    //addComment(yytext);
} 

    /* multiline comment */
("/*")(.|{NEWLINE})*("*/") {
    //addComment(yytext);
} 
    /* multiline comment error */
("/*")(.|{NEWLINE})* {
    string str = yytext;
    error(yylineno - countLines(str), str, "Unterminated Comment");
}

    /* ============= ERRORS ==================*/

    /* error1: too many demical points */
{TOO_MANY_DEMICAL_POINTS_ERROR} {
    error(yylineno,yytext, "Too many decimal points");
}
    /* error2: ill formed number such as 1E10.7 */
{ILL_FORMAT_NUMBER_ERROR} {
    error(yylineno,yytext, "Ill formed number");
}

    /* error3: invalid suffix or prefix */
{INVALID_SUFFIX_OR_PREFIX_ERROR} {
    error(yylineno, yytext, "Invalid prefix on ID or invalid suffix on Number");
}
    /* error 4: multi character const error */
{MULTI_CHAR_CONST_ERROR} {
    error(yylineno, yytext, "Multi character constant error");
}

    /* error 6: emtpy character error*/
\'\' {
    error(yylineno, yytext, "Empty character constant error");
}

    /* error 5: unterminated character */
{UNTERMINATED_CHAR_ERROR} {
    error(yylineno, yytext, "Unterminated character");
}


 /* ========== EOF ============ */
<<EOF>> {
    return 0;
}
%%

