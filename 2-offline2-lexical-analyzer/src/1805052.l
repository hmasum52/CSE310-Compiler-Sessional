%option noyywrap yylineno


/* ============ declarations ====================*/
%{
    #include<bits/stdc++.h>
    #include"symboltable/symboltable.h"
    using namespace std;

    ofstream tokenout; //token output file 1805052_token.txt
    
    SymbolTable symboltable(7);

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

    int errorCnt = 0; // number of errors

    int countLines(string str){
        int cnt = 0;
        for(int i = 0; i < str.length(); i++){
            if(str[i]=='\n'){
                cnt++;
            }
        }
        return cnt;
    }

    void logPrint(int line, string token, string lexeme, bool newline=true){
        cout << "Line no " << line << ": Token <" << token << "> Lexeme " << lexeme << " found";
        if(newline) cout<< endl<<endl;
    }

    void printToken(string token, string lexeme){
        tokenout << "<" << token << ", " << lexeme << "> ";
    }

    // keyword will not be inserted in the symbol table
    void addKeyword(string keyword, string token){
        logPrint(yylineno, token, keyword);
        // print the token
        tokenout << "<" << token << "> ";
    }
    // ===== Constants: CONST_INT, CONST_FLOAT, CONST_CHAR =======
    void addConstNumber(string number, string token){
        logPrint(yylineno, token, number);

        printToken(token, number);

        if(symboltable.insert(number, token)){
            symboltable.printAllScopeTables();
        }
    }

    void addConstChar(string character, string token){
        logPrint(yylineno, token, character, false);
        string ch = "";
        ch += character[1];
        cout<<" --> " <<  "<"<<token<<", "<<ch<<">" << endl<<endl;

        printToken(token, ch);

        if(symboltable.insert(character, token)){
            symboltable.printAllScopeTables();
        }
    }

    void addConstEscapeChar(string escapeChar, string token){
        logPrint(yylineno, token, escapeChar, false);
        string ch = escapeCharMap[escapeChar[2]];
        cout<<" --> " <<  "<"<<token<<", "<<ch<<">" << endl<<endl;

        printToken(token, ch);
    
        if(symboltable.insert(escapeChar, token)){
            symboltable.printAllScopeTables();
        }
    }
    // operator will not be inserted in the symbol table
    void addOperator(string _operator, string token){
        logPrint(yylineno, token, _operator);
        printToken(token, _operator);
    }

    // punctuator will not be inserted in the symbol table
    void addPunctuator(string punctuator, string token){
        logPrint(yylineno, token, punctuator);
        printToken(token, punctuator);
    }

    void addID(string id, string token){
        logPrint(yylineno ,token, id);
        printToken(token, id);

        if(symboltable.insert(id, token)){
            symboltable.printAllScopeTables();
        }
    }
    // string will not be inserted in the symbol table
    void addString(string str, string token){
        int lineCnt = 0; // line cnt of the string
        string str2 = "";
        for(int i = 0; i < str.length(); i++){
            if(str[i]=='\n'){
                lineCnt++;
            }

            if(str[i] == '\\'){
                str2 += escapeCharMap[str[i+1]];
                i++;
            }
            else{
                str2 += str[i];
            }
        }

        logPrint(yylineno-lineCnt, token, str, false);

        cout<< " --> "<< "<"<<token<<", "<<str2<<">" << endl<<endl;

        printToken(token, str2);
    }
    // comment will not be inserted in the symbol table
    // also no token is generated for comment
    void addComment(string comment){
        logPrint(yylineno-countLines(comment), "COMMENT", comment);
    }

    void error(int line, string symbol, string erorrMessage) {
        cout << "Error at line no " << line << ": " << erorrMessage << " " << symbol << endl<<endl;
        errorCnt++;
    }
%}

/* ================ PATTERNS ================== */
DIGIT [0-9]

LETTER [a-zA-Z]

LETTER_ [a-zA-Z_]

ESCAPE_CHAR [nt\\'afrbv0]

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
if {addKeyword("if", "IF");}
else {addKeyword("else", "ELSE");}
for {addKeyword("for", "FOR");}
while {addKeyword("while", "WHILE");}
do {addKeyword("do", "DO");}
break {addKeyword("break", "BREAK");}
int {addKeyword("int", "INT");}
char {addKeyword("char", "CHAR");}
float {addKeyword("float", "FLOAT");}
double {addKeyword("double", "DOUBLE");}
void {addKeyword("void", "VOID");}
return {addKeyword("return", "RETURN");}
switch {addKeyword("switch", "SWITCH");}
case {addKeyword("case", "CASE");}
default {addKeyword("default", "DEFAULT");}
continue {addKeyword("continue", "CONTINUE");}

    /* ======== constants ============ */
    
    /* constant integers */
{DIGIT}+ {
    addConstNumber(yytext, "CONST_INT");
}

    /* constant floats */
{CONST_FLOAT} {
    addConstNumber(yytext, "CONST_FLOAT"); 
}
    /* CONST CHAR */
{CONST_CHAR} {
    addConstChar(yytext, "CONST_CHAR");
    //addConstChar(yytext, "CHAR_CONST");
}

{CONST_ESCAPE_CHAR} {
    addConstEscapeChar(yytext, "CONST_CHAR");
    //addConstEscapeChar(yytext, "CHAR_CONST");
}

  /*arithmetic operators*/
[+-] {addOperator(yytext, "ADDOP");}

[*/%] { addOperator(yytext, "MULOP");}

    /* unitary operators */
"++"|"--" {addOperator(yytext, "INCOP");}

    /* relational operators */
\<|"<="|\>|">="|"=="|"!=" {
    addOperator(yytext, "RELOP");
}

    /* assignment operator */
\= {addOperator(yytext, "ASSIGNOP");}


    /* logical operators */
"&&"|"||" {addOperator(yytext, "LOGICOP");}

\! {
    addOperator(yytext, "NOT");
}

    /* Punctuators */
\( {addPunctuator(yytext, "LPAREN");}
\) {addPunctuator(yytext, "RPAREN");}
\{ {
    addPunctuator(yytext, "LCURL");
    symboltable.enterScope();
}
\} {
    addPunctuator(yytext, "RCURL");
    symboltable.exitScope();
}
\[ {addPunctuator(yytext, "LTHIRD");}
\] {addPunctuator(yytext, "RTHIRD");}
\, {addPunctuator(yytext, "COMMA");}
\; {addPunctuator(yytext, "SEMICOLON");}

    /* identifiers: names given to C entities,
     such as variables, functions, structures etc */
{IDENTIFIER} {
    addID(yytext, "ID");
}
    /* ============ STRING =============== */

(\")(.|\\.|\\{NEWLINE})*(\") {
    cout<<"line no: "<<yylineno<<endl;
    addString(yytext, "STRING");
}

(\")(.|\\.|\\{NEWLINE})* {
    cout<<"line no: "<<yylineno<<endl;

    int lineCnt = 0;
    string str = yytext;
    for(int i = 0; i < str.length(); i++){
        if(str[i] == '\n'){
            lineCnt++;
        }
    }
    error(yylineno-lineCnt,yytext, "Unterminated String");
}

    /* single line comment */
("//")(.|(\\{NEWLINE}))* {
    addComment(yytext);
} 

    /* multiline comment */
("/*")(.|{NEWLINE})*("*/") {
    addComment(yytext);
} 
    /* multiline comment error */
("/*")(.|{NEWLINE})* {
    string str = yytext;
    error(yylineno - countLines(str), str, "Unterminated Comment");
    symboltable.printAllScopeTables();
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
    symboltable.printAllScopeTables();
    cout<<"Total lines: "<<yylineno<<endl;
    cout<<"Total errors: "<<errorCnt<<endl;
    return 0;
}

    /* if nothing match above.  match single charcter */
    /* error-9: Unrecognized character */
. {error(yylineno, yytext, "Unrecognized character");} /* {} means no action */
%%

/* ========== main ============= */
int main(int argc,char *argv[]){
    if(argc != 2){
        cout<<"Please provide input file name and try again."<<endl;
        return 0;
    }

    FILE *fin = freopen(argv[1], "r", stdin);
    if(fin == nullptr){
        cout<<"Can't open specified file."<<endl;
        return 0;
    }
    tokenout.open("1805052_token.txt");
    freopen("1805052_log.txt", "w", stdout);

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    yylineno = 1; // line number starts from 1

    // start scanning the file here
    yylex();

    fclose(yyin);
    return 0;
}
