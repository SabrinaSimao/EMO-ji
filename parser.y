%{
#include "node.h"
#include <cstdio>
#include <cstdlib>

BlockNode *programBlock; /* the top level root node of our final AST */

using namespace std;

extern "C" int yylex();
int yyparse();
extern "C" FILE *yyin;
void yyerror(const char *s);
bool debug = false;
%}



%union {
	BlockNode *block;
	ExprNode *expr;
	StmtNode *stmt;
	IdentiferNode *ident;
	NIdentifierParam *identparam;
	VariableDeclaration *var_decl;
	AssignmentNode *var_init;
	QualStorageTypeNode *var_stor;
	std::vector<ExprNode*> *exprvec;
	std::vector<VariableDeclaration*> *varvec;
	std::string *string;
	int token;
	CommonDeclarationNode *common_dec;
}

%token <string> IDENTIFIER INT_C FLOAT_C STRING_LITERAL FUNC_NAME
%token <string> BOOL CHAR INT LONG DOUBLE VOID
%token <token> ';' '='
%token <token> '+' '*' '-' '/' '%' AND_OP OR_OP '^' '|' '&' EQ_OP
%token <token> LE_OP GE_OP '<' '>'
%token <token> '!' '~'
%token	<token> CASE IF ELSE WHILE DO FOR CONTINUE BREAK RETURN
%token	<token> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP NE_OP
%token	<token> CONST ELLIPSIS
%token	<token> EXTERN STATIC



// **************TYPES FROM HERE*****************

%type <ident> type_specifier storage_class_specifier type_qualifier

// declarator has to return expr
%type<expr> declarator
%type<common_dec> direct_declarator
%type <var_stor> declaration_specifiers
%type <stmt> declaration function_definition jump_statement
%type <var_decl> parameter_declaration
%type <block> program translation_unit
%type <block> compound_statement block_item_list statement

%type <expr> primary_expression postfix_expression unary_expression cast_expression
%type <expr> multiplicative_expression additive_expression shift_expression
%type <expr> relational_expression equality_expression and_expression exclusive_or_expression
%type <expr> inclusive_or_expression logical_and_expression logical_or_expression
%type <expr> conditional_expression assignment_expression constant_expression expression

%type <expr> initializer constant string

%type <varvec> parameter_list
%type <identparam> parameter_type_list
%type <exprvec> argument_expression_list
%type <var_init> init_declarator init_declarator_list

%type <stmt> selection_statement iteration_statement

//-----------
%type<token> unary_operator assignment_operator
%type<expr> expression_statement
//--------

%start program
%%

program : translation_unit { programBlock = $1; }
		;

abstract_declarator
	: pointer direct_abstract_declarator {}
	| pointer {}
	| direct_abstract_declarator {}
	;

argument_expression_list
	: assignment_expression { $$ = new ExpressionList(); $$->push_back($<expr>1);}
	| argument_expression_list ',' assignment_expression { $1->push_back($<expr>3);}
	;


assignment_operator
	: '='
	;

block_item_list
	: block_item { $$ = new BlockNode(); $$->statements.push_back($<stmt>1); }
	| block_item_list block_item { $1->statements.push_back($<stmt>2); }
	;

block_item
	: declaration {}
	| statement {}
	;

compound_statement
	: '{' '}' { $$ = new BlockNode(); }
	| '{'  block_item_list '}' { $$  = $2; }
	;

constant
	: INT_C	{
		if(isdigit( ($1->c_str())[0] )){
			long val = atol($1->c_str());
			if(val > 2147483647){
				$$ = new LongNode(val);
			}else{
		 		$$ = new IntNode(atoi($1->c_str()));
	 		}
		  delete $1;
		}else{
			$$ = new CharNode(($1->c_str())[1]);
		}
			cout<<"Detected as INT_C\n";
	 }
	| FLOAT_C	{ $$ = new DoubleNode(atof($1->c_str())); delete $1;}
	;

declaration
	: declaration_specifiers ';'  {}
	| declaration_specifiers init_declarator_list ';' {

		 if((new CHK_TYPE())->isFunc(*$2))
		 	$$ = new FunctionDeclarationNode(*$1, *$2);
			else
			$$ = new VariableDeclaration(*$1, *$2);
	 }
	;

// Returns ExprNode (This has to return expression because of variable and funtion dependencies)
// It can be Identifier, IndentifierParam or AssignmentNode

// Identifier when there is no assignment_operator (NO)
// AssignmentNode when there is an assignment to the IDENTIFIER
// IndentifierParam when it is a function
declarator
	: pointer direct_declarator {

		$2->setIsPtr(true);
		$$ = $2;
	}
	| direct_declarator { }
	;

// Returns storage type
declaration_specifiers
	: storage_class_specifier declaration_specifiers {
		$$ = new QualStorageTypeNode(NULL, $1, $2);

	}
	| storage_class_specifier {
		$$ = new QualStorageTypeNode();
		$$->setStorage($1);
	}
	| type_specifier declaration_specifiers {
		/* $$ = new QualStorageTypeNode($<var_stor>2); */
		$2->setType($1);
		$$ = $2;
}
	| type_specifier {
		 $$ = new QualStorageTypeNode();
		 $$->setType($1);
	 }
	| type_qualifier declaration_specifiers {
		$2->setQualifier($1);
		$$ =  $2;}
	| type_qualifier {
		$$ = new QualStorageTypeNode();
		$$->setQualifier($1);
		}
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

// Returns EXPRESSIONS
// AssignmentNode or IndentifierParam
direct_declarator
	: IDENTIFIER     {$$ = new AssignmentNode(new IdentiferNode(*$1)); delete $1;  }
	| '(' declarator ')' {$$ = new AssignmentNode(new IdentiferNode(*$2));}
	| direct_declarator '[' ']' {}
	| direct_declarator '[' '*' ']' {}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']' {}
	| direct_declarator '[' STATIC assignment_expression ']' {}
	| direct_declarator '[' type_qualifier_list '*' ']' {}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {}
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {}
	| direct_declarator '[' type_qualifier_list ']' {}
	| direct_declarator '[' assignment_expression ']' {}
	| direct_declarator '(' parameter_type_list ')' {

		 $3->setId($1);
		 $$ = $3;
	 }
	| direct_declarator '(' ')' { $$ = new NIdentifierParam(*$1, true);}
	| direct_declarator '(' identifier_list ')' {}
	;

	designation
		: designator_list '='
		;

	designator_list
		: designator
		| designator_list designator
		;

	designator
		: '[' constant_expression ']'
		| '.' IDENTIFIER
		;

	direct_abstract_declarator
		: '(' abstract_declarator ')' {{}}
		| '[' ']'
		| '[' '*' ']'
		| '[' STATIC type_qualifier_list assignment_expression ']'
		| '[' STATIC assignment_expression ']'
		| '[' type_qualifier_list STATIC assignment_expression ']'
		| '[' type_qualifier_list assignment_expression ']'
		| '[' type_qualifier_list ']'
		| '[' assignment_expression ']'
		| direct_abstract_declarator '[' ']'
		| direct_abstract_declarator '[' '*' ']'
		| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
		| direct_abstract_declarator '[' STATIC assignment_expression ']'
		| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
		| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
		| direct_abstract_declarator '[' type_qualifier_list ']'
		| direct_abstract_declarator '[' assignment_expression ']'
		| '(' ')'
		| '(' parameter_type_list ')'
		| direct_abstract_declarator '(' ')'
		| direct_abstract_declarator '(' parameter_type_list ')'
		;


external_declaration
	: function_definition
	| declaration
	;


expression_statement
	: ';' {}
	| expression ';'
	;


function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement {
		$$ = new FunctionDefinitionNode(*$1, *$2, *$3);}
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

//expression
initializer
	: '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	| assignment_expression
    ;

initializer_list
	: designation initializer
	| initializer
	| initializer_list ',' designation initializer
	| initializer_list ',' initializer
	;
	;

//Input: ExprNode:(declarator)
//Input: ExprNode: initializer
//Returns AssignmentNode
init_declarator
	: declarator '=' initializer {
		$$ = new AssignmentNode(*$1, $3);
		$$->setOp($2);
	}
	| declarator {}
	;

//Returns: AssignmentNode
//TODO this should return a List og AssignmentNode
init_declarator_list
	: init_declarator {}
	| init_declarator_list ',' init_declarator {}
	;

iteration_statement
	: WHILE '(' expression ')' statement {$$ = new WhileLoopNode($3,$5);}
	| DO statement WHILE '(' expression ')' ';' {$$ = new DoWhileLoopNode($5,$2);}
	| FOR '(' expression_statement expression_statement ')' statement{
		$$ = new ForLoopNode($3,$4,NULL,$6);
	}
	| FOR '(' expression_statement expression_statement expression ')' statement{
		$$ = new ForLoopNode($3,$4,$5,$7);
	}
	| FOR '(' declaration expression_statement ')' statement{
		$$ = new ForLoopNode($3,$4,NULL,$6);
	}
	| FOR '(' declaration expression_statement expression ')' statement {
		$$ = new ForLoopNode($3,$4,$5,$7);
	}
	;

jump_statement
	: CONTINUE ';'
	| BREAK ';'
	| RETURN ';' {$$ = new ReturnStatementNode();}
	| RETURN expression ';' {$$ = new ReturnStatementNode($2);}
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	;


// returning identparam
parameter_type_list
	: parameter_list ',' ELLIPSIS {$$ = new NIdentifierParam(*$1);
		$$->setEllipsis(true);
	}
	| parameter_list { $$ = new NIdentifierParam(*$1); }
	;

// return variablelist varvec
parameter_list
	: parameter_declaration { $$ = new VariableList(); $$->push_back($<var_decl>1); }
	| parameter_list ',' parameter_declaration { $1->push_back($<var_decl>3); }
	;

// defined as stmt
//input dec_spec : QualStorageTypeNode
//input declarator: can be of different type,  assig, param
parameter_declaration
	: declaration_specifiers declarator {
		 $$ = new VariableDeclaration(*$1, *$2);
	}
	| declaration_specifiers abstract_declarator {}
	| declaration_specifiers {}
	;

pointer
	: '*' type_qualifier_list pointer {}
	| '*' type_qualifier_list {}
	| '*' pointer {}
	| '*' {}
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement {

		$$ = new IfNode($3,$5,$7);
	}
	| IF '(' expression ')' statement {

		$$ = new IfNode($3, $5);
	}
	;


specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;


statement
	: labeled_statement {}
	| compound_statement {}
	| expression_statement {}
	| selection_statement {}
	| iteration_statement {}
	| jump_statement {}
	;

string
    : STRING_LITERAL {$$ = new StringNode(*$1);delete $1;}
    | FUNC_NAME
    ;

storage_class_specifier
	: EXTERN
	| STATIC
	;

type_name
	: specifier_qualifier_list abstract_declarator
	| specifier_qualifier_list
	;

translation_unit
	: external_declaration { $$ = new BlockNode(); $$->statements.push_back($<stmt>1); }
	| translation_unit external_declaration { $1->statements.push_back($<stmt>2); }
	;

type_qualifier
	: CONST
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


type_specifier
	: VOID { $$ = new IdentiferNode(*$1); delete $1; }
	| CHAR { $$ = new IdentiferNode(*$1); delete $1; }
	| INT { $$ = new IdentiferNode(*$1); delete $1; }
	| LONG { $$ = new IdentiferNode(*$1); delete $1; }
	| DOUBLE { $$ = new IdentiferNode(*$1); delete $1; }
	| BOOL { $$ = new IdentiferNode(*$1); delete $1; }
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

//============== EXPRESSIONS
primary_expression
	: IDENTIFIER {$$ = new IdentiferNode(*$1); delete $1; }
	| constant   {$$ = $1; }
	| string {$$ = $1;}
	| '(' expression ')' {$$=$2;}
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']' { }
	| postfix_expression '(' ')' {$$ = new FunctionCallNode(*$1);}
	| postfix_expression '(' argument_expression_list ')' {$$ = new FunctionCallNode(*$1, *$3) ;}
	| postfix_expression '.' IDENTIFIER { }
	| postfix_expression PTR_OP IDENTIFIER { }
	| postfix_expression INC_OP {
		$$ = new UnaryOperatorNode(*$1, $2, false);
		}
	| postfix_expression DEC_OP {
		$$ = new UnaryOperatorNode(*$1, $2, false);
		 }
	| '(' type_name ')' '{' initializer_list '}' { }
	| '(' type_name ')' '{' initializer_list ',' '}' { }
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression {
		$$ = new UnaryOperatorNode(*$2, $1, true);
		}
	| DEC_OP unary_expression {
		$$ = new UnaryOperatorNode(*$2, $1, true);
		}
	| unary_operator cast_expression {
		if(dynamic_cast<IntNode *>($2)){
		 $$ = new IntNode($1, $2) ;
	 }else if(dynamic_cast<DoubleNode *>($2)){
		 $$ = new DoubleNode($1, $2) ;
	 }else if(dynamic_cast<LongNode *>($2)){
		 $$ = new LongNode($1, $2) ;
	 }else{
		 cout<<"ERRROR Here in parser\n";
	 }
		 cout<<"Single Unary\n";
	 }
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression {}
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| multiplicative_expression '/' cast_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| multiplicative_expression '%' cast_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

additive_expression
	: multiplicative_expression {}
	| additive_expression '+' multiplicative_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| additive_expression '-' multiplicative_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

shift_expression
	: additive_expression {}
	| shift_expression LEFT_OP additive_expression {}
	| shift_expression RIGHT_OP additive_expression {}
	;

relational_expression
	: shift_expression {}
	| relational_expression '<' shift_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| relational_expression '>' shift_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| relational_expression LE_OP shift_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	| relational_expression GE_OP shift_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

equality_expression
	: relational_expression {}
	| equality_expression EQ_OP relational_expression {$$ = new ExprBoolNode( $2, $1, $3);
		}
	| equality_expression NE_OP relational_expression {$$ = new ExprBoolNode($2, $1 , $3);
		}
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression {$$ = new BinaryOperatorNode(*$1, $2, *$3);}
	;

conditional_expression
	: logical_or_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression {
		$$ = new AssignmentNode(*$1, $3);
		((AssignmentNode *)$$)->setOp($2);
	}
	;

constant_expression
	: conditional_expression	{} /* with constraints */
	;

expression
	: assignment_expression {}
	| expression ',' assignment_expression {}
	;

//============

%%
#include <stdio.h>

void yyerror(const char *s)
{
	//fflush(stdout);
	printf("*** %s\n", s);
}
