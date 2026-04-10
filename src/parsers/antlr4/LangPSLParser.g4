// PSL Parser Defined for SystemC Flavour
// Based on IEEE Std 1850-2010
parser grammar LangPSLParser;
options {tokenVocab=LangPSLLexer;}
import CPPParser;

// Flavor Macros
def_sym: EQ;

range_sym: COLON;

and_op: AND;

or_op: OR;

not_op: NOT;

min_val: MINVAL;

max_val: MAXVAL;

hdl_expr: expression;//expression; 

hdl_clock_expr: expression; // SystemC_Event_expression

//systemc_event_expression: sc_event | sc_event_finder | sc_event_and_list | sc_event_or_list | sc_signal | sc_port;

hdl_unit: IDENTIFIER; // SystemC_class_sc_module TODO

hdl_decl: declaration;//SystemC_declaration;

hdl_stmt: statement; //SystemC_statement;

hdl_seq_stmt: statementSeq;// SystemC_statement;

hdl_variable_type: simpleTypeSpecifier;// SystemC_simple_type_specifier;

// hdl_range: ; (Only for VHDL)

left_sym: PAREN_OPEN;

right_sym: PAREN_CLOSE;

// Verification Units

psl_specification: verification_item* EOF;

verification_item: hdl_unit | verification_unit;

verification_unit:
	vunit_type IDENTIFIER (PAREN_OPEN context_spec PAREN_CLOSE)? BLOCK_OPEN inherit_spec* override_spec*
		vunit_item* BLOCK_CLOSE;

vunit_type: VUNIT | VPKG | VPROP | VMODE;

vunit_instance: label COLON vunit_type IDENTIFIER (BRACK_OPEN actual_parameter_list BRACK_CLOSE)?SEMICOLON;

context_spec: binding_spec | formal_parameter_list;

binding_spec: hierarchical_hdl_name;

hierarchical_hdl_name: hdl_module_name (path_seperator name)*;

hdl_module_name:
	name (PAREN_OPEN name PAREN_CLOSE)?;

path_seperator: POINT | SLASH;

name: hdl_or_psl_identifier;

inherit_spec: NONTRANSITIVE? INHERIT name (COMMA name)* SEMICOLON;

vunit_item:
	hdl_decl
	| hdl_stmt
	| psl_declaration
	| psl_directive
	| vunit_instance;

override_spec: OVERRIDE name_list;

name_list: IDENTIFIER (COMMA IDENTIFIER)*;

formal_parameter_list:
	formal_parameter (SEMICOLON formal_parameter)*;

// PSL DECLARATIONS

psl_declaration:
	property_declaration
	| sequence_declaration
	| clock_declaration;

property_declaration:
	PROPERTY IDENTIFIER (PAREN_OPEN formal_parameter_list PAREN_CLOSE)? def_sym property SEMICOLON;

formal_parameter: param_spec IDENTIFIER (COMMA IDENTIFIER)*;

param_spec:
	CONST
	|(CONST | MUTABLE)? value_parameter
	| SEQUENCE
	| PROPERTY;

value_parameter: hdl_type | psl_type_class;

hdl_type: HDLTYPE hdl_variable_type;

psl_type_class: BOOLEAN | BIT | BITVECTOR | NUMERIC | STRING;

sequence_declaration:
	SEQUENCE IDENTIFIER (PAREN_OPEN formal_parameter_list PAREN_CLOSE)? def_sym sequences SEMICOLON;

clock_declaration:
	DEFAULT CLOCK def_sym clock_expression SEMICOLON;

clock_expression:
	name
	| built_in_function_call
	| PAREN_OPEN bool_val PAREN_CLOSE
	| PAREN_OPEN hdl_clock_expr PAREN_CLOSE;

actual_parameter_list:
	actual_parameter (COMMA actual_parameter)*;

actual_parameter:
	 any_type
	| number_val
	| bool_val
	| property
	| sequences;

// PSL directives
psl_directive: (label COLON)? verification_directive;

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
	ASSERT property (REPORT STRING_LITERAL)? SEMICOLON;

assume_directive: ASSUME property SEMICOLON;

restrict_directive: RESTRICT sequences SEMICOLON;

restrict_strong_directive: RESTRICTSTRONG sequences SEMICOLON;

cover_directive:
	COVER sequences BRACK_OPEN REPORT STRING_LITERAL BRACK_CLOSE SEMICOLON;

fairness_statement:
	FAIRNESS bool_val SEMICOLON
	| STRONG FAIRNESS bool_val COMMA bool_val SEMICOLON;

// PSL properties 

property: replicator property | fl_property | obe_property;

replicator: FORALL parameter_definition COLON;

index_range:
	left_sym range right_sym ;
	// | PAREN_OPEN hdl_range PAREN_CLOSE; // (Only for VHDL)

value_set:
	BLOCK_OPEN value_range (COMMA value_range)* BLOCK_CLOSE
	| BOOLEAN;

value_range: value | range; 

value: bool_val | number_val;

proc_block: BRACK_OPEN BRACK_OPEN proc_block_Item (proc_block_Item)* BRACK_CLOSE BRACK_CLOSE;

proc_block_Item: hdl_decl | hdl_seq_stmt;

fl_property:
	bool_val
	| PAREN_OPEN (BRACK_OPEN BRACK_OPEN hdl_decl (COMMA hdl_decl)* BRACK_CLOSE BRACK_CLOSE )? fl_property PAREN_CLOSE 
	| sequences NOT?
	| name (PAREN_OPEN actual_parameter_list PAREN_CLOSE)?
	| fl_property CLOCKOP clock_expression
	| fl_property ABORT bool_val
	| fl_property ASYNC_ABORT bool_val
	| fl_property SYNC_ABORT bool_val
	| parameterized_property
	// Logical_Operators
	| not_op fl_property
	| fl_property and_op fl_property
	| fl_property or_op fl_property
	| fl_property IMPLY fl_property
	| fl_property EQUIVALENCE fl_property
	// Primitive_LTL_perators
	| LTLX fl_property
	| LTLXSTRONG fl_property
	| LTLF fl_property
	| LTLG fl_property
	| BRACK_OPEN fl_property LTLU fl_property BRACK_CLOSE
	| BRACK_OPEN fl_property LTLW fl_property BRACK_CLOSE
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
	| LTLX BRACK_OPEN number_val BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	| LTLXSTRONG BRACK_OPEN number_val BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	| NEXT BRACK_OPEN number_val BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTSTRONG BRACK_OPEN number_val BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	// 
	| NEXTALWAYS BRACK_OPEN range BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE 
	| NEXTALWAYSSTRONG BRACK_OPEN range BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE 
	| NEXTEXISTS BRACK_OPEN range BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE 
	| NEXTEXISTSSTRONG BRACK_OPEN range BRACK_CLOSE PAREN_OPEN fl_property PAREN_CLOSE 
	//
	| NEXTEVENTSTRONG PAREN_OPEN bool_val PAREN_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTEVENT PAREN_OPEN bool_val PAREN_CLOSE PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTEVENTSTRONG PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN number_val BRACK_CLOSE 
		PAREN_OPEN fl_property PAREN_CLOSE 
	| NEXTEVENT PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN number_val BRACK_CLOSE PAREN_OPEN
		fl_property PAREN_CLOSE
	//
	| NEXTEVENTALWAYSSTRONG PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN range BRACK_CLOSE 
		PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTEVENTALWAYS PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN range BRACK_CLOSE 
		PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTEVENTEXISTSSTRONG PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN range BRACK_CLOSE 
		PAREN_OPEN fl_property PAREN_CLOSE
	| NEXTEVENTEXISTS PAREN_OPEN bool_val PAREN_CLOSE BRACK_OPEN range BRACK_CLOSE 
		PAREN_OPEN fl_property PAREN_CLOSE
	// Operators_on_seres
	| sere* PAREN_OPEN fl_property PAREN_CLOSE
	| sequences OVERLAPSUFFIXIMPLY fl_property
	| sequences NONOVERLAPSUFFIXIMPLY fl_property
	// VPSL Operators
	| WITHIN_T BRACK_OPEN PAREN_OPEN number_val COMMA TIME_UNIT PAREN_CLOSE BRACK_CLOSE fl_property; 

sere:
	bool_val
	| bool_val proc_block
	| sequences
	| sere SEMICOLON sere
	| sere COLON sere
	| compound_sere;

compound_sere:
	repeated_sere
	| sequences BRACK_OPEN STAR count? BRACK_CLOSE
	| sequences BRACK_OPEN PLUS BRACK_CLOSE
	| sequences proc_block
	| braced_sere
	| clocked_sere
	| compound_sere and_or_sere_op compound_sere
	| compound_sere WITHIN compound_sere
	| parameterized_sere;

parameterized_property:
	FOR parameters_definition COLON and_or_property_op PAREN_OPEN fl_property PAREN_CLOSE;

parameterized_sere:
	FOR parameters_definition COLON and_or_property_op BLOCK_OPEN fl_property BLOCK_CLOSE;

parameters_definition:
	parameter_definition parameter_definition*;

parameter_definition:
	IDENTIFIER index_range? IN value_set;

and_or_property_op: and_op | or_op;

and_or_sere_op: AND | WEAKAND | WEAKOR;

// sequences
sequences:
	sequence_instance
	| repeated_sere
	| sequences BRACK_OPEN STAR count? BRACK_CLOSE
	| sequences BRACK_OPEN PLUS BRACK_CLOSE
	| sequences proc_block
	| braced_sere
	| clocked_sere;

repeated_sere:
	bool_val BRACK_OPEN STAR count? BRACK_CLOSE
	| BRACK_OPEN STAR count? BRACK_CLOSE
	| bool_val BRACK_OPEN PLUS BRACK_CLOSE
	| BRACK_OPEN PLUS BRACK_CLOSE
	| bool_val BRACK_OPEN EQ count BRACK_CLOSE
	| bool_val BRACK_OPEN IMPLY positive_count? BRACK_CLOSE
	| bool_val proc_block;

braced_sere:
	BLOCK_OPEN (BRACK_OPEN BRACK_OPEN hdl_decl hdl_decl* BRACK_CLOSE BRACK_CLOSE)? sere BLOCK_CLOSE
	| BLOCK_OPEN (FREE hdl_or_psl_identifier (hdl_or_psl_identifier)* )? sere BLOCK_CLOSE; 

sequence_instance:
	name (PAREN_OPEN actual_parameter_list PAREN_CLOSE)?;

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
	| hdl_or_psl_expression IMPLY hdl_or_psl_expression
	| hdl_or_psl_expression EQUIVALENCE hdl_or_psl_expression
	| built_in_function_call
	| hdl_or_psl_expression UNION hdl_or_psl_expression;

hdl_expression: hdl_expr;

built_in_function_call:
	PREV PAREN_OPEN any_type (COMMA number_val (COMMA clock_expression)?)? PAREN_CLOSE
	| NEXT PAREN_OPEN any_type PAREN_CLOSE
	| STABLE PAREN_OPEN any_type (COMMA clock_expression)? PAREN_CLOSE
	| ROSE PAREN_OPEN bit_val (COMMA clock_expression)? PAREN_CLOSE
	| FELL PAREN_OPEN bit_val (COMMA clock_expression)? PAREN_CLOSE
	| ENDED PAREN_OPEN sequences (COMMA clock_expression)? PAREN_CLOSE
	| ISUNKNOWN PAREN_OPEN bit_vector_val PAREN_CLOSE 
	| COUNTONES PAREN_OPEN bit_vector_val PAREN_CLOSE 
	| ONEHOT PAREN_OPEN bit_vector_val PAREN_CLOSE 
	| ONEHOT0 PAREN_OPEN bit_vector_val PAREN_CLOSE 
	| NONDET PAREN_OPEN value_set PAREN_CLOSE 
	| NONDETVECTOR PAREN_OPEN number_val COMMA value_set PAREN_OPEN
	// VPSL function calls
	| ACTIVE PAREN_OPEN any_type PAREN_CLOSE
	| WAITING PAREN_OPEN any_type PAREN_CLOSE;


// Optional Branching Extension 
obe_property:
	bool_val
	| PAREN_OPEN obe_property PAREN_CLOSE
	| IDENTIFIER (PAREN_OPEN actual_parameter_list PAREN_CLOSE)? //Name
	// Logical Operators
	| not_op obe_property
	| obe_property and_op obe_property
	| obe_property or_op obe_property
	| obe_property IMPLY obe_property
	| obe_property EQUIVALENCE obe_property
	// Universal Operators
	| CTLAX obe_property
	| CTLAG obe_property
	| CTLAF obe_property
	| CTLA BRACK_OPEN obe_property LTLU obe_property BRACK_CLOSE
	// Existential Operators:
	| CTLEX obe_property
	| CTLEG obe_property
	| CTLEF obe_property
	| CTLE BRACK_OPEN obe_property LTLU obe_property BRACK_CLOSE ;