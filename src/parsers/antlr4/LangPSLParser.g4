// PSL Parser Defined for SystemC Flavour
// Based on IEEE Std 1850-2010
parser grammar LangPSLParser;
options {tokenVocab=LangPSLLexer;}
//import CPPParser;

// Flavor Macros
def_sym: Assign;

range_sym: Colon;

and_op: AndAnd;

or_op: OrOr;

not_op: Not;

min_val: MINVAL;

max_val: MAXVAL;

hdl_expr: IDENTIFIER;//expression; 

hdl_clock_expr: IDENTIFIER; // SystemC_Event_expression

//systemc_event_expression: sc_event | sc_event_finder | sc_event_and_list | sc_event_or_list | sc_signal | sc_port;

hdl_unit: IDENTIFIER; // SystemC_class_sc_module TODO

hdl_decl: IDENTIFIER;//SystemC_declaration;

hdl_stmt: IDENTIFIER; //SystemC_statement;

hdl_seq_stmt: IDENTIFIER;// SystemC_statement;

hdl_variable_type: IDENTIFIER;// SystemC_simple_type_specifier;

// hdl_range: ; (Only for VHDL)

left_sym: LeftParen;

right_sym: RightParen;

// Verification Units

psl_specification: verification_item* EOF;

verification_item: hdl_unit | verification_unit;

verification_unit:
	vunit_type IDENTIFIER (LeftParen context_spec RightParen)? LeftBrace inherit_spec* override_spec*
		vunit_item* RightBrace; 

vunit_type: VUNIT | VPKG | VPROP | VMODE;

vunit_instance: label Colon vunit_type IDENTIFIER (LeftBracket actual_parameter_list RightBracket)?Semi;

context_spec: binding_spec | formal_parameter_list;

binding_spec: hierarchical_hdl_name;

hierarchical_hdl_name: hdl_module_name (path_seperator name)*;

hdl_module_name:
	name (LeftParen name RightParen)?;

path_seperator: Dot | Div;

name: hdl_or_psl_identifier;

inherit_spec: NONTRANSITIVE? INHERIT name (Comma name)* Semi;

vunit_item:
	hdl_decl
	| hdl_stmt
	| psl_declaration
	| psl_directive
	| vunit_instance;

override_spec: Override name_list;

name_list: IDENTIFIER (Comma IDENTIFIER)* ;

formal_parameter_list:
	formal_parameter (Semi formal_parameter)*;

// PSL DECLARATIONS

psl_declaration:
	property_declaration
	| sequence_declaration
	| clock_declaration;

property_declaration:
	PROPERTY IDENTIFIER (LeftParen formal_parameter_list RightParen)? def_sym property Semi;

formal_parameter: param_spec IDENTIFIER (Comma IDENTIFIER)*;

param_spec:
	Const
	|(Const | Mutable)? value_parameter
	| SEQUENCE
	| PROPERTY;

value_parameter: hdl_type | psl_type_class;

hdl_type: HDLTYPE hdl_variable_type;

psl_type_class: BOOLEAN | BIT | BITVECTOR | NUMERIC | VAL_STRING;

sequence_declaration:
	SEQUENCE IDENTIFIER (LeftParen formal_parameter_list RightParen)? def_sym sequences Semi;

clock_declaration:
	Default CLOCK def_sym clock_expression Semi;

clock_expression:
	name
	| built_in_function_call
	| LeftParen bool_val RightParen
	| LeftParen hdl_clock_expr RightParen;

actual_parameter_list:
	actual_parameter (Comma actual_parameter)*;

actual_parameter:
	 any_type
	| number_val
	| bool_val
	| property
	| sequences;

// PSL directives
psl_directive: (label Colon)? verification_directive;

label: IDENTIFIER;

hdl_or_psl_identifier: IDENTIFIER;

verification_directive:
	assert_directive
	| assume_directive
	| restrict_directive
	| restrict_strong_directive
	| cover_directive
	| fairness_statement;

assert_directive:
	VAL_ASSERT property (REPORT STRING_LITERAL)? Semi;

assume_directive: VAL_ASSUME property Semi;

restrict_directive: RESTRICT sequences Semi;

restrict_strong_directive: RESTRICTSTRONG sequences Semi;

cover_directive:
	COVER sequences LeftBracket REPORT STRING_LITERAL RightBracket Semi;

fairness_statement:
	FAIRNESS bool_val Semi
	| STRONG FAIRNESS bool_val Comma bool_val Semi;

// PSL properties 

property: replicator property | fl_property | obe_property;

replicator: FORALL parameter_definition Colon;

index_range:
	left_sym range right_sym ;
	// | LeftParen hdl_range RightParen; // (Only for VHDL)

value_set:
	LeftBrace value_range (Comma value_range)* RightBrace
	| BOOLEAN;

value_range: value | range; 

value: bool_val | number_val;

proc_block: LeftBracket LeftBracket proc_block_Item (proc_block_Item)* RightBracket RightBracket;

proc_block_Item: hdl_decl | hdl_seq_stmt;

fl_property:
	bool_val
	| LeftParen (LeftBracket LeftBracket hdl_decl (Comma hdl_decl)* RightBracket RightBracket )? fl_property RightParen 
	| sequences Not?
	| name (LeftParen actual_parameter_list RightParen)?
	| fl_property CLOCKOP clock_expression
	| fl_property ABORT bool_val
	| fl_property ASYNC_ABORT bool_val
	| fl_property SYNC_ABORT bool_val
	| parameterized_property
	// Logical_Operators
	| not_op fl_property
	| fl_property and_op fl_property
	| fl_property or_op fl_property
	| fl_property Arrow fl_property
	| fl_property EQUIVALENCE fl_property
	// Primitive_LTL_perators
	| LTLX fl_property
	| LTLXSTRONG fl_property
	| LTLF fl_property
	| LTLG fl_property
	| LeftBracket fl_property LTLU fl_property RightBracket
	| LeftBracket fl_property LTLW fl_property RightBracket
	// Simple_Temporal_Operators
	| ALWAYS fl_property
	| NEVER fl_property
	| NEXT fl_property
	| NEXTSTRONG fl_property
	| EVENTUALLYSTRONG fl_property
	//
	| fl_property UNTILSTRONG fl_property
	| fl_property UNTIL fl_property
	| fl_property UNTIL_STRONG fl_property
	| fl_property UNTIL_ fl_property
	//
	| fl_property BEFORESTRONG fl_property
	| fl_property BEFORE fl_property
	| fl_property BEFORE_STRONG fl_property
	| fl_property BEFORE_ fl_property
	// Extended Next (Event) Operators:
	| LTLX LeftBracket number_val RightBracket LeftParen fl_property RightParen
	| LTLXSTRONG LeftBracket number_val RightBracket LeftParen fl_property RightParen
	| NEXT LeftBracket number_val RightBracket LeftParen fl_property RightParen
	| NEXTSTRONG LeftBracket number_val RightBracket LeftParen fl_property RightParen
	// 
	| NEXTALWAYS LeftBracket range RightBracket LeftParen fl_property RightParen 
	| NEXTALWAYSSTRONG LeftBracket range RightBracket LeftParen fl_property RightParen 
	| NEXTEXISTS LeftBracket range RightBracket LeftParen fl_property RightParen 
	| NEXTEXISTSSTRONG LeftBracket range RightBracket LeftParen fl_property RightParen 
	//
	| NEXTEVENTSTRONG LeftParen bool_val RightParen LeftParen fl_property RightParen
	| NEXTEVENT LeftParen bool_val RightParen LeftParen fl_property RightParen
	| NEXTEVENTSTRONG LeftParen bool_val RightParen LeftBracket number_val RightBracket 
		LeftParen fl_property RightParen 
	| NEXTEVENT LeftParen bool_val RightParen LeftBracket number_val RightBracket LeftParen
		fl_property RightParen
	//
	| NEXTEVENTALWAYSSTRONG LeftParen bool_val RightParen LeftBracket range RightBracket 
		LeftParen fl_property RightParen
	| NEXTEVENTALWAYS LeftParen bool_val RightParen LeftBracket range RightBracket 
		LeftParen fl_property RightParen
	| NEXTEVENTEXISTSSTRONG LeftParen bool_val RightParen LeftBracket range RightBracket 
		LeftParen fl_property RightParen
	| NEXTEVENTEXISTS LeftParen bool_val RightParen LeftBracket range RightBracket 
		LeftParen fl_property RightParen
	// Operators_on_seres
	| sere* LeftParen fl_property RightParen
	| sequences OVERLAPSUFFIXIMPLY fl_property
	| sequences NONOVERLAPSUFFIXIMPLY fl_property
	// VPSL Operators
	| WITHIN_T LeftBracket LeftParen number_val Comma TIME_UNIT RightParen RightBracket fl_property; 

sere:
	bool_val
	| bool_val proc_block
	| sequences
	| sere Semi sere
	| sere Colon sere
	| compound_sere;

compound_sere:
	repeated_sere
	| sequences LeftBracket Star count? RightBracket
	| sequences LeftBracket Plus RightBracket
	| sequences proc_block
	| braced_sere
	| clocked_sere
	| compound_sere and_or_sere_op compound_sere
	| compound_sere WITHIN compound_sere
	| parameterized_sere;

parameterized_property:
	For parameters_definition Colon and_or_property_op LeftParen fl_property RightParen;

parameterized_sere:
	For parameters_definition Colon and_or_property_op LeftBrace fl_property RightBrace;

parameters_definition:
	parameter_definition parameter_definition*;

parameter_definition:
	IDENTIFIER index_range? IN value_set;

and_or_property_op: and_op | or_op;

and_or_sere_op: AndAnd | And | Or;

// sequences
sequences:
	sequence_instance
	| repeated_sere
	| sequences LeftBracket Star count? RightBracket
	| sequences LeftBracket Plus RightBracket
	| sequences proc_block
	| braced_sere
	| clocked_sere;

repeated_sere:
	bool_val LeftBracket Star count? RightBracket
	| LeftBracket Star count? RightBracket
	| bool_val LeftBracket Plus RightBracket
	| LeftBracket Plus RightBracket
	| bool_val LeftBracket Assign count RightBracket
	| bool_val LeftBracket Arrow positive_count? RightBracket
	| bool_val proc_block;

braced_sere:
	LeftBrace (LeftBracket LeftBracket hdl_decl hdl_decl* RightBracket RightBracket)? sere RightBrace
	| LeftBrace (FREE hdl_or_psl_identifier (hdl_or_psl_identifier)* )? sere RightBrace; 

sequence_instance:
	name (LeftParen actual_parameter_list RightParen)?;

clocked_sere: braced_sere CLOCKOP clock_expression;

count: number_val | range;

positive_count: number_val | range;

range: low_bound range_sym high_bound;

low_bound: number_val | MINVAL;

high_bound: number_val | MAXVAL;

// Forms of expression

any_type: hdl_or_psl_expression; 

bit_val: hdl_or_psl_expression;

bool_val: hdl_or_psl_expression;

bit_vector_val: hdl_or_psl_expression;

number_val: hdl_or_psl_expression;

string_val: hdl_or_psl_expression;

hdl_or_psl_expression:
	hdl_expression
	| hdl_or_psl_expression Arrow hdl_or_psl_expression
	| hdl_or_psl_expression EQUIVALENCE hdl_or_psl_expression
	| built_in_function_call
	| hdl_or_psl_expression Union hdl_or_psl_expression;

hdl_expression: hdl_expr;

built_in_function_call:
	PREV LeftParen any_type (Comma number_val (Comma clock_expression)?)? RightParen
	| NEXT LeftParen any_type RightParen
	| STABLE LeftParen any_type (Comma clock_expression)? RightParen
	| ROSE LeftParen bit_val (Comma clock_expression)? RightParen
	| FELL LeftParen bit_val (Comma clock_expression)? RightParen
	| ENDED LeftParen sequences (Comma clock_expression)? RightParen
	| ISUNKNOWN LeftParen bit_vector_val RightParen 
	| COUNTONES LeftParen bit_vector_val RightParen 
	| ONEHOT LeftParen bit_vector_val RightParen 
	| ONEHOT0 LeftParen bit_vector_val RightParen 
	| NONDET LeftParen value_set RightParen 
	| NONDETVECTOR LeftParen number_val Comma value_set LeftParen
	// VPSL function calls
	| ACTIVE LeftParen any_type RightParen
	| WAITING LeftParen any_type RightParen;


// Optional Branching Extension 
obe_property:
	bool_val
	| LeftParen obe_property RightParen
	| IDENTIFIER (LeftParen actual_parameter_list RightParen)? //Name
	// Logical Operators
	| not_op obe_property
	| obe_property and_op obe_property
	| obe_property or_op obe_property
	| obe_property Arrow obe_property
	| obe_property EQUIVALENCE obe_property
	// Universal Operators
	| CTLAX obe_property
	| CTLAG obe_property
	| CTLAF obe_property
	| CTLA LeftBracket obe_property LTLU obe_property RightBracket
	// Existential Operators:
	| CTLEX obe_property
	| CTLEG obe_property
	| CTLEF obe_property
	| CTLE LeftBracket obe_property LTLU obe_property RightBracket ;