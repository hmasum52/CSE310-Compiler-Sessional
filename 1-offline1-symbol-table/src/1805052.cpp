#include <bits/stdc++.h>
#include "symboltable.h"

using namespace std;

int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    char cmd, cmd2;
    string symbolName, type; // for INSERT

    int scopeTableSize;
    cin>>scopeTableSize;
    //log(tag("main"),  scopeTableSize);
    SymbolTable symbolTable(scopeTableSize);
    while (cin >> cmd)
    {
        switch (cmd)
        {
        case 'I':
            cin >> symbolName >> type;
            cout<<cmd << " " << symbolName << " " << type << endl << endl;
            symbolTable.insert(symbolName, type);
            break;
        case 'L':
            cin>> symbolName;
            cout << cmd << " " << symbolName<< endl << endl;
            symbolTable.lookup(symbolName);
            break;
        case 'D':
            cin>> symbolName;
            cout << cmd << " " << symbolName << endl << endl;
            symbolTable.remove(symbolName);
            break;
        case 'P':
            cin>>cmd2;
            cout << cmd << " " << cmd2 << endl << endl;
            if(cmd2 == 'A')
                symbolTable.printAllScopeTables();
            else if( cmd2 == 'C')
                symbolTable.printCurrentScopeTable();
            break;
        case 'S':
            cout<<cmd<<endl<<endl;
            symbolTable.enterScope();
            break;
        case 'E':
            cout<<cmd<<endl<<endl;
            symbolTable.exitScope();
            break;
        default:
            cout<<"Invalid command"<<endl;
            break;
        }
    }
}
