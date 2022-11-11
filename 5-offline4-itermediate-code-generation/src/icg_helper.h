#pragma once
#include <bits/stdc++.h>
#include "parser_helper.h"
using namespace std;

int globalVarCnt = 0;
int localVarCnt = 0;

int labelCount = 0;
int tempCount = 0;
string mainFuncTerminateLabel;
bool isMain= false;

string newLabel(){
    return "@L_" + to_string(labelCount++);
}

string newLabel(string labelName)
{
    return "@"+labelName+"_" + to_string(labelCount++);
}

void addCommentln(string cmd)
{
    codeSegOut << "; line " << yylineno << ": " << cmd << endl;
}

void genCode(string asmCode, string cmnt = "")
{
    codeSegOut << asmCode << "\t";
    string lineNo = ";line " + to_string(yylineno) + ": ";
    codeSegOut << ((cmnt == "") ? "" : lineNo) << cmnt;
}

void genCodeln(string asmCode, string cmnt = "")
{
    genCode(asmCode, cmnt);
    codeSegOut << endl;
}

string getVarAddress(SymbolInfo *var, bool pop = false)
{
    if (pop)
    {
        if (var->isArray() && !var->isGlobal())
            genCodeln("\t\tPOP BX");
    }
    return var->getAsmName();
}

/**
 * @brief generate start code of the a function
 * for "main" function data segment load code is added.
 * 
 * @param funcName : string -> name of the the function
 */
void generateFuncStartCode(string funcName)
{
    codeSegOut << "\t" << funcName << " PROC\n";
    if (funcName == "main")
    {
        mainFuncTerminateLabel = newLabel();
        codeSegOut << "\t\tMOV AX, @DATA\n\t\tmov DS, AX\n";
        codeSegOut << "\t\t; data segment loaded\n\n";
        isMain = true;
    }else{
        isMain = false;
        genCodeln("\t\tPUSH BP"); // SAVE BP 
    }
    genCodeln("\t\tMOV BP, SP\n");
}

/**
 * @brief generate the function end code.
 * for "main" function call interrupt function to give control back to system.
 * 
 * @param funcName is the name of function to be ended
 */
void generateFuncEndCode(string funcName)
{
    if (funcName == "main")
    {
        codeSegOut << "\n\t\t" << mainFuncTerminateLabel << ":" << endl;
        codeSegOut << "\t\tMOV AH, 4CH" << endl;
        codeSegOut << "\t\tINT 21H" << endl;
    }else{
        addCommentln("For the case of not returning from a function");
        genCodeln("\t\tPOP BP");
        codeSegOut << "\t\tRET\n";
        isMain = true;
    }
    codeSegOut << "\t" << funcName << " ENDP\n\n";
}

/**
 * @brief generate variable declaration code
 * 
 * @param varInfo is the SymbolInfo of the variable
 * @param globalScope is false by default
 */
void generateVarDecCode(SymbolInfo *varInfo, bool globalScope = false)
{
    if (globalScope)
    {
        dataSegOut << "\t" << varInfo->getName();
        dataSegOut << " DW " << varInfo->getArraySize();
        if (varInfo->isArray())
        {
            dataSegOut << " DUP(" << 0 << ")";
            dataSegOut << "\t\t; array " << varInfo->getName() << " declared";
        }
        else
        {
            dataSegOut << "0   \t\t\t; variable " << varInfo->getName() << " declared";
        }
        varInfo->setAsmName(varInfo->getName(), true); // global true
        dataSegOut << endl;
    }
    else
    {
        if (varInfo->isArray())
        {
            int n = stoi(varInfo->getArraySize());
            int arrayStart = ((table.getVarCnt() + 1) * 2);
            string baseAddress = "W. [BP-" + to_string(arrayStart) + "]";
            varInfo->setAsmName(baseAddress, false, arrayStart);
            table.addToVarCnt(n);
            codeSegOut << "\t\tSUB SP, " << (n * 2) << "\t";
            // comment
            codeSegOut << ";line " << yylineno << ": ";
            codeSegOut << "array " << varInfo->getName();
            codeSegOut << " of size " << n << " declared\n";
            codeSegOut << "\t\t; from " << varInfo->getAsmName(0);
            codeSegOut << " to " << varInfo->getAsmName(n - 1) << endl;
        }
        else
        {
            table.addToVarCnt(1);
            varInfo->setAsmName("W. [BP-" + to_string(2 * table.getVarCnt()) + "]");
            codeSegOut << "\t\tSUB SP, 2\t";
            // comment
            codeSegOut << ";line " << yylineno << ": ";
            codeSegOut << varInfo->getName() << " declared: ";
            codeSegOut << varInfo->getAsmName() << "\n";
        }
    }
}

void genUnaryOerationCode(SymbolInfo *info, bool inc = true)
{
    string op = inc ? "INC" : "DEC";
    string address = getVarAddress(info, true);
    genCodeln("\t\tPUSH " + address);
    genCodeln("\t\t" + op + " " + address, info->getName() + (inc ? "++" : "--"));
}

string relopToJumpIns(string relop){
    if(relop == "<") return "JL";
    if(relop == "<=") return "JLE";
    if(relop == ">") return "JG";
    if(relop == ">=") return "JGE";
    if(relop == "==") return "JE";
    if(relop == "!=") return "JNE";
}