%{
    #include <bits/stdc++.h>
	#include "symboltable/symbolinfo.h"
    #include "symboltable/symboltable.h"
    using namespace std;

    // external function and variable declarations
    int yyparse(void);
    int yylex(void);
    extern FILE *yyin;
    extern int yylineno;

    SymbolTable table = SymbolTable(30);
	int errorCnt = 0;
	ofstream errorOut;
	vector<SymbolInfo*>* funcParamList = nullptr;
	int paramDeclineNo;

	void yyerror(const char* s){
		cout<<"Error at line "<<yylineno<<": "<<s<<"\n"<<endl;
		//errout<<"Error at line "<<line_count<<": "<<s<<"\n"<<endl;
		errorCnt++;
	}

	void debug(string s){
		cout<<"debug: Line "<<yylineno<<": "<<s<<endl<<endl;
	}

    void logError(string s, int lineNo = -1){
        errorOut<<"Error at line "<<(lineNo == -1 ? yylineno:lineNo)<<": "<<s<<"\n"<<endl;
        cout<<"Error at line "<<(lineNo == -1 ? yylineno:lineNo)<<": "<<s<<"\n"<<endl;
		errorCnt++;
    }

	void logRule(string rule, string code){
		cout<<"Line "<<yylineno<<": "<<rule<<endl<<endl<<code<<endl<<endl;
	}

	/**
	 * @brief make comma separated variable declaration code
	 * @return the code as string
	 */
	string toVarDeclarationListStr(vector<SymbolInfo*>* list){
		string code = "";
		for(SymbolInfo* info: *list){
			if(info->getArraySize()==""){
				code += info->getName()+",";
			}else{
				code += info->getName()+"["+ info->getArraySize()+"],";
			}
		}
		int len = code.length();
		if(len>0){
			code = code.substr(0, len-1);
		}
		return code;
	}

	void freeSymbolInfoVector(vector<SymbolInfo*>* list){
		for(SymbolInfo* info: *list){
			delete info;
		}
		delete list;
	}

	string toFuncParamListStr(vector<SymbolInfo*>* list){
		string code = "";
		for(SymbolInfo* info: *list){
			code += info->getDataType()+" "+info->getName()+",";
		}
		int len = code.length();
		if(len>0){
			code = code.substr(0, len-1);
		}
		return code;
	}

	string toSymbolNameListStr(vector<SymbolInfo*>* list){
		string code = "";
		for(SymbolInfo* info: *list){
			code += info->getName()+",";
		}
		int len = code.length();
		if(len>0){
			code = code.substr(0, len-1);
		}
		return code;
	}

	void declareFuncParam(string dataType, string name, int lineNo = yylineno){
		if(dataType == "void"){
			logError("Function parameter cannot be void");
			return;
		}
		if(table.insert(name, "ID")){
			SymbolInfo* info = table.lookup(name);
			info->setDataType(dataType);
			return;
		}
		logError("Multiple declaration of "+name+" in parameter", lineNo);
	}

	void declareFuncParamList(vector<SymbolInfo*>* &list, int lineNo=yylineno){
		if(list == nullptr){
			//cout<< "Line "<<yylineno<<": "<<"declareFuncParamList: no params"<<endl;
			return;
		}
		//cout<<"Line "<<yylineno<<": "<<"declaring function parameter list"<<endl;
		for(SymbolInfo* info: *list){
			declareFuncParam(info->getDataType(), info->getName(), lineNo);
		}
		list = nullptr;
	}
	
	void declareFunction(string functionName, string returnType, vector<SymbolInfo*>* parameterList = nullptr, int lineNo=yylineno){
		// insert a new ID in the symbol table
		bool success = table.insert(functionName, "ID");
		// get the symbol info to add return type and params
		SymbolInfo* info = table.lookup(functionName);
		
		if(success){
			info->setInfoType(SymbolInfo::FUNCTION_DECLARATION);
			info->setReturnType(returnType);
			// add functions params to the symbol info
			if(parameterList != nullptr)
				for(SymbolInfo* param: *parameterList){
					info->addParameter(param->getDataType(), param->getName());
				}
			
			//debug("Function \""+functionName+"\" declared");
			//debug("Total params: "+to_string(info->getParameters().size()));
		}else{
			if(info->getInfoType()==SymbolInfo::FUNCTION_DECLARATION){
				logError("redeclaration of "+functionName, lineNo);
				return;
			}
		}
	}

	void defineFunction(string functionName, string returnType, int lineNo=yylineno, vector<SymbolInfo*>* parameterList=nullptr){
		// get the symbol info to add return type and params
		SymbolInfo* info = table.lookup(functionName);

		// if the function is not declared
		// then insert it in the symbol table as ID 
		if(info==nullptr){ // function name not found in the symbol table
			table.insert(functionName, "ID");
			info = table.lookup(functionName);
		}else{
			 // function already declared previously
			if(info->getInfoType() == SymbolInfo::FUNCTION_DECLARATION){
				if(info->getReturnType()!=returnType){
					logError("Return type mismatch with function declaration in function "+functionName, lineNo);
					return;
				}
				vector<pair<string, string> > params = info->getParameters();
				int paramCnt = parameterList == nullptr ? 0 : parameterList->size();
				if(params.size() != paramCnt){
					logError("Number of arguments doesn't match prototype of the function "+functionName, lineNo);
					return;
				}
				if(parameterList != nullptr){ // for non-void functions
					vector<SymbolInfo*> paramList = *parameterList;
					for(int i=0; i<params.size(); i++){
						if(params[i].first != paramList[i]->getDataType()){
							logError("conflicting argument types for "+functionName, lineNo);
							return;
						}
					}
				}
			}else{ // non-function type declared with same name
				logError(" Multiple declaration of "+functionName);
				return;
			}
		}
		if(info->getInfoType() == SymbolInfo::FUNCTION_DEFINITION){
			logError("redefinition of "+functionName, lineNo);
			return;
		}
		info->setInfoType(SymbolInfo::FUNCTION_DEFINITION);
		info->setReturnType(returnType);
		info->setParameters(vector<pair<string, string> >());
		// add functions params to the symbol info
		if(parameterList != nullptr) // for non void functions
			for(SymbolInfo* param: *parameterList){
				info->addParameter(param->getDataType(), param->getName());
			}
	}

	void callFunction(SymbolInfo* &funcSym, vector<SymbolInfo*>* args = nullptr){
		string functionName = funcSym->getName();
		SymbolInfo* info = table.lookup(functionName);
		if(info == nullptr){
			logError("Undeclared Function "+functionName);
			return;
		}
		if(!info->isFunction()){ // a function call cannot be made with non-function type identifier.
			logError(functionName+" is not a function");
			return;
		}
		funcSym->setReturnType(info->getReturnType());
		if(info->getInfoType() != SymbolInfo::FUNCTION_DEFINITION){
			logError("Function "+functionName+" not defined");
			return;
		}
		vector<pair<string, string> > params = info->getParameters();
		int paramCnt = args == nullptr ? 0 : args->size();
		// Check whether a function is called with appropriate number of parameters
		if(params.size() != paramCnt){
			logError("Total number of arguments mismatch in function "+functionName);
			return;
		}
		if(args != nullptr){ // for non-void functions
			vector<SymbolInfo*> argList = *args;
			// Type Checking: During a function call all the arguments should be consistent with the function definition.
			for(int i=0; i<params.size(); i++){
				// Check whether a function is called with appropriate types. 
				if(params[i].first != argList[i]->getDataType()){
					logError(to_string(i+1)+"th argument mismatch in function "+functionName);
					return;
				}
			}
		}
	}

	string autoTypeCasting(SymbolInfo* x, SymbolInfo* y){
		if(x->getDataType() == y->getDataType())
			return x->getDataType();
		if(x->getDataType() == "int" && y->getDataType() == "float"){
			x->setDataType("float");
			return "float";
		}else if(x->getDataType() == "float" && y->getDataType() == "int"){
			y->setDataType("float");
			return "float";
		}
		if(x->getDataType()!="void"){
			return x->getDataType();
		}
		return y->getDataType();
	}

	void checkVoidFunction(SymbolInfo* a, SymbolInfo* b){
		// Type Checking: A void function cannot be called as a part of an expression.
		if(a->getDataType() == "void" || b->getDataType() == "void"){
			logError("Void function used in expression");
		}
	}

%}
	//// read: https://stackoverflow.com/questions/1853204/yylval-and-union
%union{
	SymbolInfo* symbol_info; 
	string* str_info;
	vector<SymbolInfo*>* symbol_info_list;
}

	/* TERMINAL SYMBOLS */ 
	//////////////// keywords ////////////////
%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
	//////////////// operators ////////////////
%token <symbol_info> ADDOP MULOP RELOP LOGICOP
%token INCOP DECOP ASSIGNOP NOT
	//////////////// puncuators ////////////////
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
	//////////////// identifiers and const ////////////////
%token <symbol_info> CONST_INT CONST_FLOAT CONST_CHAR ID
	//////////////// other ////////////////
%token STRING 

	/* NON-TERMINAL SYMBOLS */
%type <symbol_info> variable factor term unary_expression simple_expression rel_expression logic_expression expression
%type <str_info> expression_statement statement statements compound_statement
%type <str_info> type_specifier var_declaration func_declaration func_definition unit program 
%type <symbol_info_list>  declaration_list parameter_list argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
    /* =================== production rules ================*/
start : program { // full program parsing is done
		logRule("start : program", "");
		table.printAllScopeTables(); table.exitScope();
		cout << "Total Lines: " << yylineno << endl;
		cout << "Total Errors: " << errorCnt << endl;
	}
	;
program : program unit { //append newly parsed unit to the end of the program
		string code = *$1 +"\n"+ *$2;
		logRule("program : program unit",code);
		$$ = new string(code);
		delete $1;delete $2;
	}
	| unit { // this is for 1st unit in the program
		logRule("program : unit",*$1);
		$$ = $1;
	}
	;
// a unit can be variable declaration or function declaration or function definition	
unit : var_declaration {
		logRule( "unit : var_declaration",*$1); //$$ = $1;
	}
    | func_declaration {
		logRule( "unit : func_declaration",*$1); //$$ = $1;
	}
    | func_definition {
		logRule( "unit : func_definition",*$1); //$$ = $1;
	}
    ;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		string code = *$1 + " " + $2->getName() + "(" +toFuncParamListStr($4) + ");";
		logRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",code);;
		$$ = new string(code);
		declareFunction($2->getName(), *$1, $4);
		//free stuff
		delete $1; delete $2; freeSymbolInfoVector($4);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON {
		string code = *$1 +" "+$2->getName()+"();";
		logRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",code);
		declareFunction($2->getName(), *$1);
		$$ = new string(code);
		delete $1; delete $2;
	}
	;
func_definition : type_specifier ID LPAREN parameter_list RPAREN {defineFunction($2->getName(), *$1,yylineno, $4);} compound_statement {
		string code = *$1 + " " + $2->getName() + "(" +toFuncParamListStr($4) + ")" + *$7;	
		logRule( "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",code);;
		$$ = new string(code);
		//cout<<"freeing for "<<$2->getName()<<endl;
		//free stuff
		delete $1; delete $2; delete $7; freeSymbolInfoVector($4);
	}
	| type_specifier ID LPAREN RPAREN {defineFunction($2->getName(), *$1,yylineno);} compound_statement {
		string code = *$1 +" "+$2->getName()+"()"+ *$6;
		logRule( "func_definition : type_specifier ID LPAREN RPAREN compound_statement",code);
		$$ = new string(code);
		delete $1;delete $2;delete $6;
	}
	;				
//vector<SymbolInfo*>*
parameter_list  : parameter_list COMMA type_specifier ID { // void fun(int a, in b);
		string code = toFuncParamListStr($1);
		code+= ","+*$3+" "+$4->getName();
		logRule("parameter_list  : parameter_list COMMA type_specifier ID",code);
		$1->push_back(new SymbolInfo($4->getName(),"", *$3));
		$$ = $1;
		funcParamList = $1; // save the parameter to store in function scope
		paramDeclineNo = yylineno;
		delete $3; delete $4;
	}
	| parameter_list COMMA type_specifier { // void fun(int, float)
		string code = toFuncParamListStr($1);
		code+= "," + *$3;
		logRule("parameter_list  : parameter_list COMMA type_specifier",code);
		$1->push_back(new SymbolInfo(*$3, ""));
		$$ = $1;
		funcParamList = $1; 
		paramDeclineNo = yylineno;
		delete $3;
	}
	| type_specifier ID { // void fun(int a)
		string code = *$1 +" "+$2->getName();
		logRule("parameter_list  : type_specifier ID",code);
		$$ = new vector<SymbolInfo*>();
		$$->push_back(new SymbolInfo($2->getName(), "", *$1));
		funcParamList = $$;
		paramDeclineNo = yylineno;
		delete $1; delete $2;
	}
	// start of paramter list
	| type_specifier {// void fun(int);
		logRule("parameter_list  : type_specifier",*$1);
		// init parameter list
		$$ = new vector<SymbolInfo*>();
		$$->push_back(new SymbolInfo(*$1,"", *$1));
		delete $1;
	}
	;
compound_statement : LCURL {table.enterScope(); declareFuncParamList(funcParamList, paramDeclineNo);} statements RCURL {
		string code = "{\n"+*$3+"\n}\n";
		logRule("compound_statement : LCURL statements RCURL",code);
		$$ = new string(code);
		delete $3;
		table.printAllScopeTables();table.exitScope();
	}
	| LCURL {table.enterScope();} RCURL {
		logRule("compound_statement : LCURL RCURL","{}");
		$$ = new string("{}");
		table.printAllScopeTables();table.exitScope();
	}
	;

var_declaration : type_specifier declaration_list SEMICOLON {
		string code = *$1 +" " +  toVarDeclarationListStr($2) + ";";
		logRule("var_declaration : type_specifier declaration_list SEMICOLON",code);
		$$ = new string(code);
		// decare variables in the symbol table
		for(SymbolInfo* info : *$2){
			if(*$1 == "void"){
				logError("Variable type cannot be void");
				continue;
			}
			bool success = table.insert(info->getName(), info->getType());
			if(!success){
				logError("Multiple declaration of "+info->getName());
			}else{
				// get the variable from symbol table
				SymbolInfo* newVar = table.lookup(info->getName());
				newVar->setDataType(*$1); // set the data type of the variable
				if(info->isArray()){ // set array size for array type variables
					newVar->setArraySize(info->getArraySize());
				}
			}
		}
		// free stuff
		delete $1; freeSymbolInfoVector($2);
	}
	;
type_specifier	: INT {
		logRule("type_specifier : INT","int");
		$$ = new string("int");
	}
	| FLOAT {
		logRule("type_specifier : FLOAT","float");
		$$ = new string("float");
	}
	| VOID {
		logRule("type_specifier : VOID","void");
		$$ = new string("void");
	}
	;
// vector<SymbolInfo*>*
declaration_list : declaration_list COMMA ID {
		string code = toVarDeclarationListStr($1);
		code+= ","+$3->getName(); // add new variable declaration
		$1->push_back($3); // add new variable to the list
		logRule("declaration_list : declaration_list COMMA ID",code);
		$$ = $1;
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
		string code = toVarDeclarationListStr($1);
		code+= "," + $3->getName()+"["+$5->getName()+"]";
		$3->setArraySize($5->getName());
		$1->push_back($3);
		logRule("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD",code);
		$$ = $1;
		delete $5; //free stuff
	}
	| ID {
		logRule("declaration_list : ID",$1->getName());
		// create list for the first symbol
		$$ = new vector<SymbolInfo*>();
		$$->push_back($1);
	}
	// for array declaration
	// for first declaration
	| ID LTHIRD CONST_INT RTHIRD {
		string code = $1->getName()+"["+$3->getName()+"]";
		logRule("declaration_list : ID LTHIRD CONST_INT RTHIRD",code);
		// create list for the first symbol
		$$ = new vector<SymbolInfo*>();
		// add the first symbol to the param list
		$1->setArraySize($3->getName());
		$$->push_back($1);

		delete $3;
	}
	;
statements : statement {
		logRule( "statements : statement",*$1);
		$$ = $1;
	}
	| statements statement {
		string code = *$1 + "\n"+ *$2;
		logRule( "statements : statements statement",code);
		$$ = new string(code);
		delete $1;delete $2;
	}
	;
statement : var_declaration {
		logRule("statement : var_declaration",*$1); // auto $$ = $1;
	}	
	| expression_statement {
		logRule("statement : expression_statement",*$1); // auto $$ = $1;
	}
	| compound_statement {
		logRule("statement : compound_statement",*$1); // auto $$ = $1;
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		string code = "for("+*$3+";"+*$4+";"+$5->getName()+")"+*$7;
		logRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",code);
		$$ = new string(code);
		delete $3;delete $4;delete $5;delete $7;
	}
	| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		string code = "if("+$3->getName()+")"+*$5;
		logRule("statement : IF LPAREN expression RPAREN statement",code);
		$$ = new string(code);
		delete $3;delete $5;
	}
	| IF LPAREN expression RPAREN statement ELSE statement {
		string code = "if("+$3->getName()+")"+*$5+"else "+*$7;
		logRule("statement : IF LPAREN expression RPAREN statement ELSE statement",code);
		$$ = new string(code);
		delete $3;delete $5;delete $7;
	}
	| WHILE LPAREN expression RPAREN statement {
		string code = "while("+$3->getName()+")"+*$5;
		logRule("statement : WHILE LPAREN expression RPAREN statement",code);
		$$ = new string(code);
		delete $3;delete $5;
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON {
		string code = "printf("+$3->getName()+");";
		logRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON",code);
		if(!table.lookup($3->getName())){
			logError("Undeclared variable  "+$3->getName());
		}
		$$ = new string(code);
		delete $3;
	}
	| RETURN expression SEMICOLON {
		string code = "return "+$2->getName()+";";
		logRule("statement : RETURN expression SEMICOLON",code);
		$$ = new string(code);
		delete $2;
	}
	;
expression_statement : SEMICOLON {
		logRule("expression_statement : SEMICOLON",";");
		$$ = new string(";");
	}			
	| expression SEMICOLON {
		string code = $1->getName() + ";";
		logRule("expression_statement : expression SEMICOLON",code);
		$$ = new string(code);
		delete $1;
	}
	;
//SymbolInfo*
variable : ID { 
		logRule("variable : ID",$1->getName());
		SymbolInfo *info = table.lookup($1->getName());
		//  check whether a variable used in an expression is declared or not
		if(info!=nullptr){
			//  check whether there is an index used with array
			if(info->isArray()){
				logError("Type mismatch, "+info->getName()+" is an array");
			}
			$$ = new SymbolInfo(*info); // copy everything
			delete $1; // free ID SymbolInfo*
		}else{
			logError("Undeclared variable "+$1->getName());
			$$ = $1;
		}
	}
	| ID LTHIRD expression RTHIRD {
		string code = $1->getName()+"["+$3->getName()+"]";
		logRule("variable : ID LTHIRD expression RTHIRD",code);
		SymbolInfo *info = table.lookup($1->getName());
		if(info != nullptr){ // symbo found in the table
			$1->setDataType(info->getDataType());
			if(!info->isArray()){ // check if the variable is array or not
				logError($1->getName()+" is not an array.");
			}
			// Generate an error message if the index of an array is not an integer
			if($3->getDataType()!="int"){
				logError("Expression inside third brackets not an integer");
			}
		}else{
			logError("Undeclared variable "+$1->getName());
		}
		$1->setName(code);// new variable name
		$$ = $1;
		delete $3;
	}
	;
//SymbolInfo*
expression : logic_expression {
		logRule("expression : logic_expression",$1->getName());
		$$ = $1;
	}
	| variable ASSIGNOP logic_expression {
		string exp = $1->getName() + "=" + $3->getName();
		logRule("expression : variable ASSIGNOP logic_expression",exp);
		SymbolInfo *info = table.lookup($1->getName());
		if(info!=nullptr){
			if(info->getDataType()=="int" && $3->getDataType()=="float"){
				logError("Type mismatch");
			}
		}
		if($3->getDataType()=="void"){
				logError("Void function used in expression");
		}
		$$ = new SymbolInfo(exp, "expression", $1->getType());
		delete $1; delete $3;
	}	
	;
//SymbolInfo*
logic_expression : rel_expression { 
		logRule("logic_expression : rel_expression",$1->getName());// $$ = $1;
	}	
	| rel_expression LOGICOP rel_expression {
		string code = $1->getName()+$2->getName()+$3->getName();
		logRule("logic_expression : rel_expression LOGICOP rel_expression",code);
		$$ = new SymbolInfo(code,"logic_expression","int");
		delete $1,$2,$3;
	}	
	;
//SymbolInfo*
rel_expression : simple_expression {
		logRule("rel_expression : simple_expression",$1->getName());
	}
	| simple_expression RELOP simple_expression	{
		string code = $1->getName()+$2->getName()+$3->getName();
		logRule("rel_expression : simple_expression RELOP simple_expression",code);
		autoTypeCasting($1,$3);
		$$ = new SymbolInfo(code,"rel_expression","int");
		delete $1,$2,$3;
	}
	;
//SymbolInfo*
simple_expression : term {
		logRule("simple_expression : term",$1->getName());//$$ = $1;
		//debug($1->getName()+" : "+$1->getDataType());
	}	
	| simple_expression ADDOP term {
		string code = $1->getName() + $2->getName()  + $3->getName();
		logRule("simple_expression : simple_expression ADDOP term",code);
		checkVoidFunction($1, $3);
		$$ = new SymbolInfo(code, "simple_expression", autoTypeCasting($1, $3));
		delete $1; delete $2; delete $3;
	} 
	;
//SymbolInfo*
term :	unary_expression {
		logRule("term : unary_expression",$1->getName()); //$$ = $1; 
	}
    |  term MULOP unary_expression {
		string code = $1->getName() + $2->getName()  + $3->getName();
		logRule("term : term MULOP unary_expression",code);
		checkVoidFunction($1, $3);
		if($2->getName() == "%"){
			if($3->getName() == "0") logError("Modulus by Zero");
			// Type Checking: Both the operands of the modulus operator should be integers.
			if($1->getDataType() != "int" || $3->getDataType() != "int"){
				logError("Non-Integer operand on modulus operator");
			}
			$1->setDataType("int");
			$3->setDataType("int");
		}
		$$ = new SymbolInfo(code, "term", autoTypeCasting($1,$3));
		delete $1; delete $2; delete $3;
	}
    ;
//SymbolInfo* 
unary_expression : ADDOP unary_expression {
		string code = $1->getName() + $2->getName();
		logRule("unary_expression : ADDOP unary_expression",code);
		$$ = new SymbolInfo(code, "unary_expression", $2->getDataType());
		delete $1; delete $2;
	}  
	| NOT unary_expression {
		string code = "!"+ $2->getName();
		logRule("unary_expression : NOT unary_expression",code);
		$$ = new SymbolInfo(code, "unary_expression", $2->getDataType());
		delete $2;
	} 
	| factor {
		logRule("unary_expression : factor",$1->getName());
	} 
	;
	
//SymbolInfo*
factor	: variable {
		logRule("factor : variable",$1->getName());
		$$ = $1;
	}
	| ID LPAREN argument_list RPAREN { // function call
		string code = $1->getName() + "(" + toSymbolNameListStr($3) + ")";
		logRule("factor : ID LPAREN argument_list RPAREN",code);
		
		callFunction($1,$3);

		$$ = new SymbolInfo(code, "function", $1->getReturnType());
		debug($$->getName()+" : "+$$->getDataType());
		delete $1; freeSymbolInfoVector($3);
	}
	| LPAREN expression RPAREN {
		string code = "(" + $2->getName() + ")";
		logRule("factor : LPAREN expression RPAREN",code);
		$$ = new SymbolInfo(code, "factor", $2->getDataType());
		delete $2;
	}
	| CONST_INT { // terminal
		logRule("factor : CONST_INT", $1->getName());
		$$ = new SymbolInfo($1->getName(), $1->getType(), "int");
	}
	| CONST_FLOAT { // terminal
		logRule("factor : CONST_FLOAT",$1->getName());
		$$ = new SymbolInfo($1->getName(), "factor", "float");
	}
	| variable INCOP {
		string code = $1->getName() + "++";
		logRule("factor : variable INCOP",code);
		$$ = new SymbolInfo(code, "factor", $1->getDataType());
		delete $1;
	}
	| variable DECOP {
		string code = $1->getName() + "--";
		logRule("factor : variable DECOP",code);
		$$ = new SymbolInfo(code, "factor", $1->getDataType());
		delete $1;
	}
	;
	
//vector<SymbolInfo*>*
argument_list : arguments {
		string code = toSymbolNameListStr($1);
		logRule("argument_list : arguments",code);
		$$ = $1;
	}
	| //empty 
	{
		logRule("argument_list :","");
		$$ = new vector<SymbolInfo*>();
	}
	;
	
//vector<SymbolInfo*>*
arguments : arguments COMMA logic_expression {
		string code = toSymbolNameListStr($1) + "," + $3->getName();
		logRule("arguments : arguments COMMA logic_expression",code);
		$$->push_back($3);
	}
	| logic_expression {
		logRule("arguments : logic_expression",$1->getName());
		$$ = new vector<SymbolInfo*>(); // init list
		$$->push_back($1);
	}
	;
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

	cout<<argv[1]<<" opened successfully."<<endl;
	
    errorOut.open("error.txt");
    freopen("log.txt", "w", stdout);

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    yylineno = 1; // line number starts from 1

    // start scanning the file here
	yyparse();

    fclose(yyin);
    return 0;
}
