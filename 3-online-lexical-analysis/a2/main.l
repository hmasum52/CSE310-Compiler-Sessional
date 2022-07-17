%option noyywrap

%{
    #include<bits/stdc++.h>
    using namespace std;
%}

DIGIT [0-9]
EXPONENT [Ee][+-]?{DIGIT}+

WS [ \t\v]+
NEWLINE (\r)?\n
DEFINE "#define"
LETTER_ [a-zA-Z_]
CONST_INT [0-9]+
CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?
CONST_STRING \"([^\r\n\\]|\\.|\\{NEWLINE})*\"
DATA_TYPE int|float|double|string|long|"long long int"|"long long float"|"long long double"
VALUE ({CONST_INT}|{CONST_FLOAT}|{CONST_STRING}|{DATA_TYPE})

%%
[ \t\v]+ {}

{DEFINE}{WS}{LETTER_}+{WS}{VALUE} {
    cout<<"MACRO "<<yytext<<" (MACRO WITH VALUE) DETECTED"<<endl;
}

. {} //ignore
%%

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
   // freopen("1805052_log.txt", "w", stdout);

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    //yylineno = 1; // 

    // start scanning the file here
    yylex();

    fclose(yyin);
    return 0;
}