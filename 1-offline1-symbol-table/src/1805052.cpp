#include <bits/stdc++.h>
#include "scopetable.h"
using namespace std;


int main()
{
    /* Symbolinfo info("a", "int");
    cout << info << endl; */
    // ScopeTable table(7);
    // table.insertSymbol("foo", "FUNCTION");
    // table.insertSymbol("o", "o");
    freopen("../input.txt", "r", stdin);

    char cmd;
    string name, type; // for INSERT
    ScopeTable *prev = new ScopeTable(7, nullptr);
    ScopeTable *currentScope = new ScopeTable(7, prev);
    currentScope->insertSymbol("a", "a");
    currentScope->insertSymbol("h", "h");
    currentScope->insertSymbol("k", "k");
    currentScope->insertSymbol("<=", "RELOP");
    currentScope->print();
    /*  while(cin>>cmd){
         switch (cmd){
         case 'I':
             cin>>name>>type;
             currentScope->insertSymbol(name, type);
             cout<<endl;
             break;
         default:
             break;
         }
     } */
}
