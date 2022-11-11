%{
    //#include "parser_helper.h"
	#include "icg_helper.h"

	bool globalScope = true;
	bool arrayIndex = false;
	map<string, string> labelMap;
	int paramCnt = 0;
	string whileLoop;
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
%type <symbol_info> expression_statement if_common_part // expression_statement -> expression SEMICOLON is for the loop
%type <str_info> statement statements compound_statement
%type <str_info> type_specifier var_declaration func_declaration func_definition unit program 
%type <symbol_info_list>  declaration_list parameter_list argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
    /* =================== production rules ================*/
start : {
	// declare global segments
	dataSegOut << ".MODEL SMALL\n.STACK 100h\n.DATA\n\n";
	codeSegOut << ".CODE\n";
} program { // full program parsing is done
		logRule("start : program", "");
		table.printAllScopeTables(); table.exitScope();
		cout << "Total Lines: " << yylineno << endl;
		cout << "Total Errors: " << errorCnt << endl;
		genFunctionForPrintln();
		generateCodeDotAsmFile();
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
unit : var_declaration { // no code gen
		logRule( "unit : var_declaration",*$1); //$$ = $1;
	}
    | func_declaration { // no code gen
		logRule( "unit : func_declaration",*$1); //$$ = $1;
	}
    | func_definition { // no code gen
		logRule( "unit : func_definition",*$1); //$$ = $1;
	}
    ;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON { // no code gen
		string code = *$1 + " " + $2->getName() + "(" +toFuncParamListStr($4) + ");";
		logRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",code);;
		$$ = new string(code);
		declareFunction($2->getName(), *$1, $4);
		//free stuff
		delete $1; delete $2; freeSymbolInfoVector($4);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON { // no code gen
		string code = *$1 +" "+$2->getName()+"();";
		logRule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",code);
		declareFunction($2->getName(), *$1);
		$$ = new string(code);
		delete $1; delete $2;
	}
	;
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
	{
		globalScope = false;
		generateFuncStartCode($2->getName());
		defineFunction($2->getName(), *$1,yylineno, $4);
	} compound_statement {
		generateFuncEndCode($2->getName());
		string code = *$1 + " " + $2->getName() + "(" +toFuncParamListStr($4) + ")" + *$7;	
		logRule( "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",code);;
		$$ = new string(code);
		delete $1; delete $2; delete $7; freeSymbolInfoVector($4);
	}
	| type_specifier ID LPAREN RPAREN {
		globalScope = false;
		generateFuncStartCode($2->getName());
		defineFunction($2->getName(), *$1,yylineno);
	}compound_statement {
		generateFuncEndCode($2->getName());
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
compound_statement : LCURL {
		table.enterScope();
		declareFuncParamList(funcParamList, paramDeclineNo);
	} statements RCURL {
		string code = "{\n"+*$3+"\n}\n";
		logRule("compound_statement : LCURL statements RCURL",code);
		$$ = new string(code);
		delete $3;
		table.printAllScopeTables();table.exitScope();
	}
	| LCURL {table.enterScope();} RCURL { // no code gen
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
				newVar->copy(info);
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
		generateVarDecCode($3, globalScope);
		$1->push_back($3); // add new variable to the list
		logRule("declaration_list : declaration_list COMMA ID",code);
		$$ = $1;
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {

		string code = toVarDeclarationListStr($1);
		code+= "," + $3->getName()+"["+$5->getName()+"]";
		$3->setArraySize($5->getName());
		generateVarDecCode($3, globalScope);
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
		generateVarDecCode($1, globalScope);
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
		generateVarDecCode($1, globalScope);
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
		genCodeln("");
	}	
	| expression_statement {
		logRule("statement : expression_statement",$1->getName());
		genCodeln("\t\tPOP AX", "evaluated exp: "+$1->getName()+"\n");
		$$ = new string($1->getName()); delete $1;
	}
	| compound_statement {
		logRule("statement : compound_statement",*$1); // auto $$ = $1;
	}
	| FOR LPAREN {
		addCommentln("======for loop start======");
		addCommentln("for loop initialization");
		labelMap.clear();
	} expression_statement { //init
		labelMap["forCond"] = newLabel("FOR_COND");
		labelMap["forStmt"] = newLabel("FOR_STMT");
		labelMap["forUpdate"] = newLabel("FOR_UPDATE");
		labelMap["endFor"] = newLabel("END_FOR");

		genCodeln("\t\tPOP AX", "evaluated for loop init exp: "+$4->getName()+"\n");

		addCommentln("for loop condition");
		genCodeln("\t\t"+labelMap["forCond"]+":"); //create label for the condition
	} expression_statement { // condition check
		genCodeln("\t\tPOP AX", "load "+$6->getName()); 
		genCodeln("\t\tCMP AX, 0");
		genCodeln("\t\tJE "+labelMap["endFor"], "break for loop"); 
		genCodeln("\t\tJMP "+labelMap["forStmt"],"execute for statement");

		addCommentln("for loop update");
		genCodeln("\t\t"+labelMap["forUpdate"]+":"); // create label for the update
	} expression { // update
		
		genCodeln("\t\tPOP AX", "evaluated for loop update exp: "+$8->getName()+"\n");

		genCodeln("\t\tJMP "+labelMap["forCond"],"continue for loop");

		addCommentln("for loop statement");
		genCodeln("\t\t"+labelMap["forStmt"]+":"); // create label for the statement
	} RPAREN statement { // statement
		string code = "for("+$4->getName()+$6->getName()+$8->getName()+")"+*$11;
		logRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",code);
		$$ = new string(code);
		
		genCodeln("\t\tJMP "+labelMap["forUpdate"],"go to update section");
		addCommentln("======for loop end======");
		genCodeln("\t\t"+labelMap["endFor"]+":"); // create label for the end of the for loop
		
		delete $4;delete $6;delete $8;delete $11;
	}
	| if_common_part %prec LOWER_THAN_ELSE {
		// print end label from $1
		genCodeln("\t\t"+$1->getLabel()+":\n");
		//string code = "if("+$3->getName()+")"+*$5;
		logRule("statement : IF LPAREN expression RPAREN statement",$1->getName());
		$$ = new string($1->getName());
		delete $1;
	}
	| if_common_part ELSE {
		// generate new label and send down - after else statement
		// jmp to new label
		string elseEnd = newLabel("END_ELSE");
		genCodeln("\t\tJMP "+elseEnd); 
		genCodeln("\t\t"+$1->getLabel()+":\n");
		addCommentln("else block start");
		$1->setLabel(elseEnd);
	} statement {
		string code = $1->getName()+"else "+ *$4;
		logRule("statement : IF LPAREN expression RPAREN statement ELSE statement",code);
		$$ = new string(code);

		addCommentln("else block end");
		genCodeln("\t\t"+$1->getLabel()+":\n");

		delete $1;delete $4;
	}
	| WHILE LPAREN {
		whileLoop = newLabel("WHILE_LOOP");
		genCodeln("\t\t"+whileLoop+":");
	} expression RPAREN {
		addCommentln("while block start");
		//string whileLoop = newLabel("WHILE_LOOP");
		string whileEnd = newLabel("END_WHILE");
		genCodeln("\t\tPOP AX", "load "+$4->getName());
		genCodeln("\t\tCMP AX,0");
		genCodeln("\t\tJE "+whileEnd);
		$4->setLabel(whileLoop+" "+whileEnd);
	} statement {
		string code = "while("+$4->getName()+")"+*$7;
		logRule("statement : WHILE LPAREN expression RPAREN statement",code);
		$$ = new string(code);

		stringstream ss($4->getLabel());
		string whileLoop, whileEnd;
		ss >> whileLoop >> whileEnd;
		genCodeln("\t\tJMP "+whileLoop);
		genCodeln("\t\t"+whileEnd+":\n");

		delete $4;delete $7;
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON {
		string code = "println("+$3->getName()+");";
		logRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON",code);
		SymbolInfo* info = table.lookup($3->getName());
		if(info==nullptr){
			logError("Undeclared variable  "+$3->getName());
		}else{
			addCommentln("println("+$3->getName()+")");
			genCodeln("\t\tMOV BX, "+info->getAsmName(), "load "+$3->getName());
			genCodeln("\t\tCALL PRINT_NUM_FROM_BX");
		}

		$$ = new string(code);
		delete $3;
	}
	| RETURN expression SEMICOLON {
		string code = "return "+$2->getName()+";";
		logRule("statement : RETURN expression SEMICOLON",code);
		$$ = new string(code);
		if(!isMain){ // for main INT 21 is called instead of the following codes
			addCommentln(code); // print the actual code
			// pop value to be returned from the top of the stack to AX
			genCodeln("\t\tPOP AX", "load "+$2->getName());
			genCodeln("\t\tMOV [BP+4], AX","\n"); // move value from AX to return value location

			// remove all the local variable decalared in the function scope
			addCommentln("removing all local variables from the stack");
			genCodeln("\t\tADD SP, "+to_string(table.getVarCnt()*2), "\n");

			genCodeln("\t\tPOP BP"); // restore BP for the caller function	
			genCodeln("\t\tRET"); // return control to the caller funcdtion
		}
		delete $2;
	}
	;

if_common_part : IF LPAREN expression RPAREN {
	// generate end label and jeq 0 end
	string endif = newLabel("END_IF");
	addCommentln("if("+$3->getName()+")");
	genCodeln("\t\tPOP AX", "load "+$3->getName());
	genCodeln("\t\tCMP AX, 0");
	genCodeln("\t\tJE "+endif);
	$3->setLabel(endif);
	addCommentln("if block start");
} statement {
	// end label return
	addCommentln("if block end");
	string code = "if("+$3->getName()+")"+*$6;
	$$ = new SymbolInfo(code, "nonterminal");
	$$->setLabel($3->getLabel());
	delete $3;delete $6;
};

expression_statement : SEMICOLON {
		logRule("expression_statement : SEMICOLON",";");
		addCommentln("push 1 for infinite loop");
		genCodeln("\t\tPUSH 1\n"); 
		$$ = new SymbolInfo(";", "nonterminal");
	}			
	| expression SEMICOLON {
		string code = $1->getName() + ";";
		logRule("expression_statement : expression SEMICOLON",code);
		$$ = new SymbolInfo(code, "nonterminal");
		delete $1;
	}
	;
//SymbolInfo* // variable access  // no code gen
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
			$$->setAsmName(getVarAddress(info));
			delete $1; // free ID SymbolInfo*
		}else{
			logError("Undeclared variable "+$1->getName());
			$$ = $1;
		}
	}
	| ID LTHIRD {arrayIndex = true;} expression RTHIRD {
		arrayIndex = false;
		string code = $1->getName()+"["+$4->getName()+"]";
		logRule("variable : ID LTHIRD expression RTHIRD",code);
		SymbolInfo *info = table.lookup($1->getName());
		if(info != nullptr){ // symbo found in the table
			$1->setDataType(info->getDataType());
			if(!info->isArray()){ // check if the variable is array or not
				logError($1->getName()+" is not an array.");
			}
			// Generate an error message if the index of an array is not an integer
			if($4->getDataType()!="int"){
				logError("Expression inside third brackets not an integer");
			}
			$1->copy(info);
			addCommentln(code);
			genCodeln("\t\tPOP AX","pop index "+$4->getName()+" of array "+$1->getName());
			genCodeln("\t\tSHL AX, 1", "multiply by 2 to get offset");
			genCodeln("\t\tLEA BX, "+info->getAsmName(), "get array base address");
			genCodeln("\t\tSUB BX, AX", "[BX]->"+code);
			genCodeln("\t\tPUSH BX\n");
			$1->setAsmName("[BX]");
		}else{
			logError("Undeclared variable "+$1->getName());
		}
		$1->setName(code);// new variable name
		$$ = $1; delete $4;
	}
	;
//SymbolInfo* //done
expression : logic_expression {
		logRule("expression : logic_expression",$1->getName());
		$$ = $1;
	}
	| variable ASSIGNOP logic_expression {
		string code = $1->getName() + "=" + $3->getName();
		logRule("expression : variable ASSIGNOP logic_expression",code);
		SymbolInfo *info = table.lookup($1->getName());
		if(info!=nullptr){
			if(info->getDataType()=="int" && $3->getDataType()=="float"){
				logError("Type mismatch");
			}
		}
		if($3->getDataType()=="void"){
				logError("Void function used in expression");
		}
		$$ = new SymbolInfo(code, "expression", $1->getType());

		// code gen
		addCommentln(code);
		genCodeln("\t\tPOP AX", "load "+$3->getName());
		genCodeln("\t\tMOV "+getVarAddress($1, true)+", AX", code);
		genCodeln("\t\tPUSH AX", "save "+$1->getName()+"\n");

		delete $1; delete $3;
	}	
	;
//SymbolInfo*
logic_expression : rel_expression { 
		logRule("logic_expression : rel_expression",$1->getName());// $$ = $1;
	}	
	| rel_expression LOGICOP {
		// short circuit
		addCommentln($1->getName()+ " short circuit jump");
		genCodeln("\t\tPOP AX", "load "+$1->getName());
		string boolVal = $2->getName() == "&&" ? "1" : "0";
		genCodeln("\t\tCMP AX, "+boolVal);
		string jmpLabel = newLabel();
		genCodeln("\t\tJNE "+jmpLabel);
		$1->setLabel(jmpLabel);

	} rel_expression {
		string code = $1->getName()+$2->getName()+$4->getName();
		logRule("logic_expression : rel_expression LOGICOP rel_expression",code);
		$$ = new SymbolInfo(code,"logic_expression","int");

		// gen code
		addCommentln(code);
		genCodeln("\t\tPOP AX", "load "+$4->getName());
		string boolVal = $2->getName() == "&&" ? "1" : "0";
		genCodeln("\t\tCMP AX, "+boolVal);
		genCodeln("\t\tJNE "+$1->getLabel());
		boolVal = $2->getName()== "&&"? "1" :"0";
		genCodeln("\t\t\tPUSH "+boolVal);
		string logicEnd = newLabel();
		genCodeln("\t\t\tJMP "+logicEnd);
		genCodeln("\t\t"+$1->getLabel()+":");
		boolVal = $2->getName()== "&&"? "0" :"1";
		genCodeln("\t\t\tPUSH " +boolVal);
		genCodeln("\t\t"+logicEnd+":\n");

		delete $1,$2,$4;
	}	
	;
//SymbolInfo*
rel_expression : simple_expression { // simple exp value is in the top of the stack
		logRule("rel_expression : simple_expression",$1->getName());
	}
	| simple_expression RELOP simple_expression	{
		string code = $1->getName()+$2->getName()+$3->getName();
		logRule("rel_expression : simple_expression RELOP simple_expression",code);
		autoTypeCasting($1,$3);
		$$ = new SymbolInfo(code,"rel_expression","int");

		string trueL = newLabel();
		string endL = newLabel();
		string op = relopToJumpIns($2->getName());
		addCommentln(code);
		genCodeln("\t\tPOP BX", "load "+$3->getName());
		genCodeln("\t\tPOP AX", "load "+$1->getName());
		genCodeln("\t\tCMP AX, BX");
		genCodeln("\t\t"+op+" "+trueL, code);
		genCodeln("\t\t\tPUSH 0\n\t\t\tJMP "+endL);
		genCodeln("\t\t"+trueL+":\n\t\t\tPUSH 1");
		genCodeln("\t\t"+endL+":\n");

		delete $1,$2,$3;
	}
	;
//SymbolInfo* // done
simple_expression : term { // term value is in the top of the stack
		logRule("simple_expression : term",$1->getName());//$$ = $1;
		//debug($1->getName()+" : "+$1->getDataType());
	}	
	| simple_expression ADDOP term {
		string code = $1->getName() + $2->getName()  + $3->getName();
		logRule("simple_expression : simple_expression ADDOP term",code);
		checkVoidFunction($1, $3);
		$$ = new SymbolInfo(code, "simple_expression", autoTypeCasting($1, $3));

		// code gen
		addCommentln($1->getName()+$2->getName()+$3->getName());
		genCodeln("\t\tPOP BX", "load "+$3->getName());
		genCodeln("\t\tPOP AX", "load "+$1->getName());
		string op = $2->getName() == "+" ? "ADD" : "SUB";
		genCodeln("\t\t"+op+" AX, BX");
		genCodeln("\t\tPUSH AX", "save "+$1->getName()+"\n");

		delete $1; delete $2; delete $3;
	} 
	;
//SymbolInfo*
term :	unary_expression { // no code: unary_expression value is in the top of the stack
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

		// gen code
		addCommentln(code);
		genCodeln("\t\tPOP BX", "load "+$3->getName());
		genCodeln("\t\tPOP AX", "load "+$1->getName());
		genCodeln("\t\tXOR DX, DX", "clear DX");
		string op = $2->getName() == "*" ? "IMUL" : "IDIV";
		genCodeln("\t\t"+op+" BX", code);
		string result = $2->getName() == "%" ? "DX" : "AX";
		genCodeln("\t\tPUSH "+result, "save "+code+"\n");

		$$ = new SymbolInfo(code, "term", autoTypeCasting($1,$3));
		delete $1; delete $2; delete $3;
	}
    ;
//SymbolInfo* 
unary_expression : ADDOP unary_expression {
		string code = $1->getName() + $2->getName();
		logRule("unary_expression : ADDOP unary_expression",code);
		$$ = new SymbolInfo(code, "unary_expression", $2->getDataType());
		if($1->getName() == "-"){
			addCommentln("-"+$2->getName());
			genCodeln("\t\tPOP AX");
			genCodeln("\t\tNEG AX");
			genCodeln("\t\tPUSH AX\n");
		}
		delete $1; delete $2;
	}  
	| NOT unary_expression {
		string code = "!"+ $2->getName();
		logRule("unary_expression : NOT unary_expression",code);
		$$ = new SymbolInfo(code, "unary_expression", $2->getDataType());
		
		string l1 = newLabel();
		string l2 = newLabel(); 
		addCommentln("!"+$2->getName());
		genCodeln("\t\tPOP AX\t\t;load "+$2->getName());
		genCodeln("\t\tCMP AX, 0");
		genCodeln("\t\tJE "+l1);
		genCodeln("\t\t\tPUSH 0");
		genCodeln("\t\t\tJMP "+l2);
		genCodeln("\t\t"+l1+":\n\t\tPUSH 1\n");
		genCodeln("\t\t"+l2+":");
		
		delete $2;
	} 
	| factor {
		logRule("unary_expression : factor",$1->getName());
	} 
	;
	
//SymbolInfo*
factor	: variable {
		logRule("factor : variable",$1->getName());
		genCodeln("\t\tPUSH "+getVarAddress($1, true), "save "+$1->getName()+"\n");
		$$ = $1;
	}
	| ID LPAREN {
		addCommentln("calling function "+$1->getName());
	} argument_list RPAREN { // function call
		string code = $1->getName() + "(" + toSymbolNameListStr($4) + ")";
		logRule("factor : ID LPAREN argument_list RPAREN",code);
		callFunction($1,$4);
		$$ = new SymbolInfo(code, "function", $1->getReturnType());
		//debug($$->getName()+" : "+$$->getDataType());
		genCodeln("\t\tPUSH 0", "location for return value"); // BP+4
		genCodeln("\t\tCALL "+$1->getName(), "call function"+$1->getName());
		genCodeln("\t\tPOP AX", "load return value");
		genCodeln("\t\tADD SP,"+to_string($4->size()*2), "pop function param from stack");
		if($1->getReturnType() != "void"){
			genCodeln("\t\tPUSH AX", "save return value");
		}else{
			genCodeln("\t\tPUSH 0", "save dummy return value for void");
		}
		addCommentln("returned from function "+$1->getName()+"\n");
		delete $1; freeSymbolInfoVector($4);
	}
	| LPAREN expression RPAREN {
		string code = "(" + $2->getName() + ")";
		logRule("factor : LPAREN expression RPAREN",code);
		$$ = new SymbolInfo(code, "factor", $2->getDataType());
		delete $2;
	}
	| CONST_INT { // terminal
		logRule("factor : CONST_INT", $1->getName());
		genCodeln("\t\tPUSH " + $1->getName(), "save "+$1->getName()+"\n");
		$$ = new SymbolInfo($1->getName(), $1->getType(), "int");
	}
	| CONST_FLOAT { // terminal
		logRule("factor : CONST_FLOAT",$1->getName());
		genCodeln("\t\tPUSH " + $1->getName(), "save "+$1->getName()+"\n");
		$$ = new SymbolInfo($1->getName(), "factor", "float");
	}
	| variable INCOP {
		string code = $1->getName() + "++";
		logRule("factor : variable INCOP",code);
		genUnaryOerationCode($1);
		$$ = new SymbolInfo(code, "factor", $1->getDataType());
		delete $1;
	}
	| variable DECOP {
		string code = $1->getName() + "--";
		logRule("factor : variable DECOP",code);
		genUnaryOerationCode($1, false);
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
		//genCodeln("\t\tPUSH "+$3->getName(), "save func arg "+$3->getName()+"\n");
	}
	| logic_expression {
		logRule("arguments : logic_expression",$1->getName());
		$$ = new vector<SymbolInfo*>(); // init list
		$$->push_back($1);
		//genCodeln("\t\tPUSH "+$1->getName(), "save func arg "+$1->getName()+"\n");
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
	
    // errorOut.open("error.txt");
    // freopen("log.txt", "w", stdout);
	openFiles();

    yyin = fin; // read symbols from fin streams

    yylineno = 1; // line number starts from 1

    // start scanning the file here
	yyparse();

    fclose(yyin);
	errorOut.close();
    return 0;
}
