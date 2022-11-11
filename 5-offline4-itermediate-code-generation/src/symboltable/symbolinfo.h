#pragma once
#include<bits/stdc++.h>
using namespace std;


/**
 * This class contains the information regarding a symbol faced
 * in the source program.
 *
 * @author Hasan Masum
 * ID: 1805052
 */
class SymbolInfo
{
    string name; // lexeme
    string type; // token type
    SymbolInfo *next;

    string label;

    // for 8086 assembly code
    string asmName; // name of the symbol in assembly code
    int arrayStart; // start of the array
    bool global;

    // extra fields for passing infromation from\
    lexical analyzer to semantic analyzer
    string dataType; // data type of the variable or return type of the function
    int infoType; // variable or function
    string arraySize; // store array size if it is an array
    vector<pair<string, string>> parameters; // parameters of the function


public:
    // static const vars
    static const int VARIABLE = 1;
    static const int FUNCTION_DECLARATION = 2;
    static const int FUNCTION_DEFINITION = 3;

    void copy(SymbolInfo* other){
        this->name = other->name;
        this->type = other->type;
        this->next = other->next;
        this->asmName = other->asmName;
        this->arrayStart = other->arrayStart;
        this->global = other->global;
        this->dataType = other->dataType;
        this->infoType = other->infoType;
        this->arraySize = other->arraySize;
        this->parameters = other->parameters;
    }

    SymbolInfo(SymbolInfo *info){
        this->name = info->name;
        this->type = info->type;
        this->next = info->next;
        this->dataType = info->dataType;
        this->infoType = info->infoType;
        this->arraySize = info->arraySize;
        this->parameters = info->parameters;

    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->dataType = "";
        this->infoType = VARIABLE;
        this->arraySize = "";
        this->parameters.clear();
    }

    SymbolInfo(string name, string type, string dataType, int infoType = VARIABLE, string arraySize="")
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->dataType = dataType;
        this->infoType = infoType;
        this->arraySize = arraySize;
        this->parameters.clear();
    }

    // copy constructor
    SymbolInfo(const SymbolInfo &other)
    {
        this->name = other.name;
        this->type = other.type;
        this->next = other.next;
        this->asmName = other.asmName;
        this->arrayStart = other.arrayStart;
        this->global = other.global;
        this->dataType = other.dataType;
        this->infoType = other.infoType;
        this->arraySize = other.arraySize;
        this->parameters = other.parameters;
    }
    
    // getters
    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

    SymbolInfo *getNext()
    {
        return next;
    }

    // setters
    void setName(string name)
    {
        this->name = name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    void setNext(SymbolInfo *next)
    {
        this->next = next;
    }

    // for assembly code ////////////////////////////////
    void setLabel(string label){
        this->label = label;
    }

    string getLabel(){
        return label;
    }

    string getAsmName()
    {
        return asmName;
    }

    string getAsmName(int idx){
        if(global){
            return asmName+"[SI+"+to_string(idx)+"]";
        }
        int offset = arrayStart + idx*2;
        return "[BP-"+to_string(offset)+"]";
    }

    void setAsmName(string asmName,bool global=false, int arrayStart=0)
    {
        this->asmName = asmName;
        this->global = global;
        this->arrayStart = arrayStart;
    }

    int getArrayStart()
    {
        return arrayStart;
    }

    void setArrayStart(int arrayStart)
    {
        this->arrayStart = arrayStart;
    }

    bool isGlobal()
    {
        return global;
    }

    /**
     * @brief friend function to print the symbol information
     * e.g. SymbolInfo info("a", "int");
     * cout << info << endl; // prints < a : int > 
     * 
     */
    friend ostream &operator<<(ostream &os, const SymbolInfo &obj)
    {
        os << "< " << obj.name << " : " << obj.type << ">";
        return os;
    }
////////////////////////////////////////////////////////////
    // extra function for passing infromation from\
    lexical analyzer to semantic analyzer
////////////////////////////////////////////////////////////

    /**
     * @brief Set the dataType is the symbol is a variable
     * or return type of if the symbol is a function
     * 
     * @param dataType 
     */
    void setDataType(string dataType)
    {
        this->dataType = dataType;
    }

    string getDataType()
    {
        return dataType;
    }

    void setInfoType(int infoType)
    {
        this->infoType = infoType;
    }

    int getInfoType()
    {
        return infoType;
    }

    ///////////////////////
    // functions for array
    ///////////////////////
    bool isArray()
    {
        return arraySize != "";
    }

    void setArraySize(string arraySize)
    {
        this->arraySize = arraySize;
    }

    string getArraySize()
    {
        return arraySize;
    }

    ///////////////////////
    // functions for function infos
    ///////////////////////

    bool isFunction()
    {
        return infoType == FUNCTION_DECLARATION || infoType == FUNCTION_DEFINITION;
    }

    /**
     * @brief if the symbol is a function, then add the parameter to the list
     * 
     * @param dataType of the parameter
     * @param paramName is the name of the parameter
     */
    void addParameter(string dataType, string paramName)
    {
        parameters.push_back({dataType, paramName});
    }

    void setParameters(vector<pair<string, string>> parameters)
    {
        this->parameters = parameters;
    }

    vector<pair<string, string>> getParameters()
    {
        return parameters;
    }

    void setReturnType(string dataType)
    {
        this->dataType = dataType;
    }

    string getReturnType()
    {
        return dataType;
    }
};