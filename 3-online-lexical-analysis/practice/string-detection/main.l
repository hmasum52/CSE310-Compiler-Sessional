%option noyywrap

%{
    #include<bits/stdc++.h>
    using namespace std;

    int cnt = 0;
%}

digit [0-9]
letter [a-zA-Z]
newline (\r)?\n


%%
[ \t\v]+ {} 

{newline} {}


(\")(.|\\.|\\{newline})*(\") {
    cout<<"string found: "<<endl;
    cout<<yytext<<endl;
}

(\")(.|\\.|\\{newline})* {
    cout<<"error: unfinished string"<<endl;
    cout<<yytext<<endl;
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

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    // start scanning the file here
    yylex();

    fclose(yyin);
    return 0;
}