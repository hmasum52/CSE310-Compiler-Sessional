%option noyywrap 

%x STRING 
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

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

    string str; // string to be parsed
    int strStartLine; // line number where the strig str starts

    int lineCnt = 1; // line numbers
    int errorCnt = 0; // number of errors

    void logPrint(int line, string token, string lexeme, bool newline=true){
        cout << "Line no " << line << ": Token <" << token << "> Lexeme " << lexeme << " found";
        if(newline) cout<< endl<<endl;
    }

    void printToken(string token, string lexeme){
        tokenout << "<" << token << ", " << lexeme << "> ";
    }

    // keyword will not be inserted in the symbol table
    void addKeyword(string keyword, string token){
        logPrint(lineCnt, token, keyword);

        // print the token
        tokenout << "<" << token << "> ";
    }
    // ===== Constants: CONST_INT, CONST_FLOAT, CONST_CHAR =======
    void addConstNumber(string number, string token){
        logPrint(lineCnt, token, number);

        printToken(token, number);

        if(symboltable.insert(number, token)){
            symboltable.printAllScopeTables();
        }
    }

    void addConstChar(string character, string token){
        logPrint(lineCnt, token, character, false);
        string ch = "";
        ch += character[1];
        cout<<" --> " <<  "<"<<token<<", "<<ch<<">" << endl<<endl;

        printToken(token, ch);

        if(symboltable.insert(character, token)){
            symboltable.printAllScopeTables();
        }
    }

    void addConstEscapeChar(string escapeChar, string token){
        logPrint(lineCnt, token, escapeChar, false);
        string ch = escapeCharMap[escapeChar[2]];
        cout<<" --> " <<  "<"<<token<<", "<<ch<<">" << endl<<endl;

        printToken(token, ch);
    
        if(symboltable.insert(escapeChar, token)){
            symboltable.printAllScopeTables();
        }
    }
    // operator will not be inserted in the symbol table
    void addOperator(string _operator, string token){
        logPrint(lineCnt, token, _operator);

        printToken(token, _operator);
    }

    // punctuator will not be inserted in the symbol table
    void addPunctuator(string punctuator, string token){
        logPrint(lineCnt, token, punctuator);

        printToken(token, punctuator);
    }

    void addID(string id, string token){
        logPrint(lineCnt ,token, id);

        printToken(token, id);

        if(symboltable.insert(id, token)){
            symboltable.printAllScopeTables();
        }
    }
    // string will not be inserted in the symbol table
    void addString(string str, string token){
        logPrint(strStartLine, token, str, false);
        
        string str2 = "";
        for(int i = 0; i < str.length(); i++){
            if(str[i] == '\\'){
                str2 += escapeCharMap[str[i+1]];
                i++;
            }
            else{
                str2 += str[i];
            }
        }
        cout<< " --> "<< "<"<<token<<", "<<str2<<">" << endl<<endl;

        printToken(token, str2);
    }
    // comment will not be inserted in the symbol table
    // also no token is generated for comment
    void addComment(string comment){
        logPrint(strStartLine, "COMMENT", comment);
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

CONST_INT [0-9]+

CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?

CONST_CHAR \'[^\\\n\r]\'

CONST_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'

IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

/* --- ERRORS --- */
TOO_MANY_DEMICAL_POINTS_ERROR {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?
ILL_FORMAT_NUMBER_ERROR {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+
IVALID_SUFFIX_OR_PREFIX_ERROR  {CONST_FLOAT}+{IDENTIFIER}+
MULTI_CHAR_CONST_ERROR \'.[^\'\r\n]+\' 
UNTERMINATED_CHAR_ERROR \'(.|\\\')?[^\'\r\n]*

/* ============ translation rules====================*/
%%
   

[ \t\v]+ {} /*ignore space*/
    
    /* platform independent new line */
{NEWLINE} {lineCnt++;}

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
{CONST_INT} {
    addConstNumber(yytext, "CONST_INT");
}

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

    /* start of the string*/
\" {
    str = yytext;
    strStartLine = lineCnt; // save the line number of the start of the string
    //cout<<"String state started"<<endl;
    BEGIN STRING;
}
    /* ignore multiline string line divider \ */
<STRING>\\{NEWLINE} {
    str += yytext;
    lineCnt++;
}
    /* for " inside the string */
<STRING>\\\" {
    str += yytext;
    //cout<<"ESCAPE CHAR inside string "<<yytext<<endl;
} 
    /* add char to string until end of string or line */
<STRING>[^\"\n\r] {
    str += yytext;
    //cout<<str<<endl;
}
    /* end of the string */
<STRING>\" {
    str += yytext;
    addString(str, "STRING");
    //cout<<"String state ended"<<endl;
    BEGIN INITIAL;
}
    /* error-7: unterminated string*/
<STRING>{NEWLINE} {
    error(strStartLine,str, "Unterminated String");
    lineCnt++;
    //cout<<"String state ended"<<endl;
    BEGIN INITIAL;
}

    /* =============== SINGLE LINE COMMENT =============== */
"//" {
    str = yytext;
    strStartLine = lineCnt; // save the line number of the start of the string
    //cout<<"Single line comment start===="<<endl;
    BEGIN SINGLE_LINE_COMMENT;
}

<SINGLE_LINE_COMMENT>. {
    str+=yytext;
}

<SINGLE_LINE_COMMENT>\\{NEWLINE} {
    // ignore
    str+=yytext;
    //cout<<"found \\ in single line comment"<<endl;
    lineCnt++;
}

<SINGLE_LINE_COMMENT>{NEWLINE} {
    // ignore the new line
    addComment(str);
    lineCnt++;
    //cout<<"Single line comment end====="<<endl;
    BEGIN INITIAL;
}

    /* ========== MULTI LINE COMMENT ================ */
"/*" {
    str = yytext;
    strStartLine = lineCnt; // save the line number of the start of the string
    //cout<<"multiline comment started."<<endl;
    BEGIN MULTI_LINE_COMMENT;
}

<MULTI_LINE_COMMENT>. {
    str+=yytext;
}


<MULTI_LINE_COMMENT>{NEWLINE} {
    // ignore
    str += yytext;
    lineCnt++;
}


<MULTI_LINE_COMMENT>"*/" {
    //cout<<"multiline line comment end====="<<endl;
    str += yytext;
    addComment(str);
    BEGIN INITIAL;
} 

    /* error-8: multiline comment error */
<MULTI_LINE_COMMENT><<EOF>> {
    lineCnt--;
    error(strStartLine, str, "Unterminated Comment");
    symboltable.printAllScopeTables();
    cout<<"Total lines: "<<lineCnt<<endl;
    cout<<"Total errors: "<<errorCnt<<endl;
    return 0;
}   


 /* ============= ERRORS ==================*/

    /* error1: too many demical points */
{TOO_MANY_DEMICAL_POINTS_ERROR} {
    error(lineCnt,yytext, "Too many decimal points");
}
    /* error2: ill formed number such as 1E10.7 */
{ILL_FORMAT_NUMBER_ERROR} {
    error(lineCnt,yytext, "Ill formed number");
}

    /* error3: invalid suffix or prefix */
{IVALID_SUFFIX_OR_PREFIX_ERROR} {
    error(lineCnt, yytext, "Invalid prefix on ID or invalid suffix on Number");
}
    /* error 4: multi character const error */
{MULTI_CHAR_CONST_ERROR} {
    error(lineCnt, yytext, "Multi character constant error");
}

    /* error 6: emtpy character error*/
\'\' {
    error(lineCnt, yytext, "Empty character constant error");
}

    /* error 5: unterminated character */
{UNTERMINATED_CHAR_ERROR} {
    error(lineCnt, yytext, "Unterminated character");
}

   
 /* ========== EOF ============ */

<<EOF>> {
    symboltable.printAllScopeTables();
    cout<<"Total lines: "<<lineCnt<<endl;
    cout<<"Total errors: "<<errorCnt<<endl;
    return 0;
}

    /* if nothing match above.  match single charcter */
    /* error-9: Unrecognized character */
. {error(lineCnt, yytext, "Unrecognized character");} /* {} means no action */
%%

/* ========== main ============= */
int main(int argc,char *argv[]){
    if(argc != 2){
        cout<<"Please provide input file name and try again."<<endl;
        return 0;
    }

    FILE *fin = freopen("input.txt", "r", stdin);
    if(fin == nullptr){
        cout<<"Can't open specified file."<<endl;
        return 0;
    }
    tokenout.open("1805052_token.txt");
    freopen("1805052_log.txt", "w", stdout);

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    //yylineno = 1; // 

    // start scanning the file here
    yylex();

    fclose(yyin);
    return 0;
}
