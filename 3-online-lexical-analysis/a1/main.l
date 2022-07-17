%option noyywrap

%x TEMPLATE

%{
    #include<bits/stdc++.h>
    using namespace std;

    int cnt = 0;
%}

IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

%%
{IDENTIFIER} {
    BEGIN TEMPLATE;
}

<TEMPLATE>< {
    cout<<"start of the template"<<endl;
    BEGIN TEMPLATE;
}

<TEMPLATE>{IDENTIFIER} {
    cout<<"ID -> "<<yytext<<endl;
}

<TEMPLATE>> {
    cout<<"end of the template"<<endl;
}

<TEMPLATE>[> ] {
    cout<<"end of initial template"<<endl;
    BEGIN INITIAL;
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