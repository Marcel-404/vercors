// PSL Parser Defined for SystemC Flavour Based on IEEE Std 1850-2010
parser grammar LangPSLParser;
options {
	superClass = CPPParserBase;
	tokenVocab = LangPSLLexer;
}
import CPPParser;

// Verification Units

psl_specification: verification_item* EOF;

verification_item:
	//hdl_unit			# HdlUnitVerificationItem // SC_MODULE along with its definitions, however not needed to parse PSL expressions |
	verification_unit # VerificationUnitVerificationItem;

verification_unit:
	vunit_type clangppIdentifier (
		LeftParen context_spec RightParen
	)? LeftBrace inherit_spec* override_spec* vunit_item* RightBrace;

vunit_type:
	VUNIT	# VunitVunitType
	| VPKG	# VpkgVunitType
	| VPROP	# VPropVunitType
	| VMODE	# VModeVunitType;

vunit_instance:
	label Colon vunit_type clangppIdentifier (
		LeftBracket actual_parameter_list RightBracket
	)? Semi;

context_spec:
	binding_spec			# BindingSpecContextSpec
	| formal_parameter_list	# FormalParameterListContextSpec;

binding_spec: hierarchical_hdl_name;

hierarchical_hdl_name: hdl_module_name (path_seperator name)*;

hdl_module_name: name; //(LeftParen name RightParen)?;

path_seperator:
	Dot # DotPathSeperator; //| Div # DivPathSeperator;

name: hdl_or_psl_identifier # HdlOrPslIdentifierName;

inherit_spec: NONTRANSITIVE? INHERIT name (Comma name)* Semi;

vunit_item:
	psl_declaration		# PslDeclarationVunitItem
	| psl_directive		# PslDirectiveVunitItem
	| vunit_instance	# VunitInstanceVunitItem;
// | hdl_decl # HdlDeclVunitItem | hdl_stmt # HdlStmtVunitItem;

override_spec: Override name_list;

name_list: clangppIdentifier (Comma clangppIdentifier)*;

formal_parameter_list:
	formal_parameter (Semi formal_parameter)*;

// PSL DECLARATIONS

psl_declaration:
	property_declaration	# PropertyDeclarationPslDeclaration
	| sequence_declaration	# SequenceDeclaration
	| clock_declaration		# ClockDeclaration;

property_declaration:
	PROPERTY clangppIdentifier (
		LeftParen formal_parameter_list RightParen
	)? def_sym property Semi;

formal_parameter:
	param_spec clangppIdentifier (Comma clangppIdentifier)*;

param_spec:
	Const									# ConstParamSpec
	| (Const | Mutable)? value_parameter	# ValueParameterParamSpec
	| SEQUENCE								# SequenceParamSpec
	| PROPERTY								# PropertyParamSpec;

value_parameter:
	psl_type_class	# PslTypeClassValueParameter
	| hdl_type		# HdlTypeValueParameter;

hdl_type: HDLTYPE hdl_variable_type;

psl_type_class:
	BOOLEAN			# BooleanPslTypeClass
	| BIT			# BitPslTypeClass
	| BITVECTOR		# BitvectorPslTypeClass
	| NUMERIC		# NumericPslTypeClass
	| VAL_STRING	# ValStringPslTypeClass;

sequence_declaration:
	SEQUENCE clangppIdentifier (
		LeftParen formal_parameter_list RightParen
	)? def_sym sequences Semi;

clock_declaration: Default CLOCK def_sym clock_expression Semi;

clock_expression:
	name									# NameClockExpression
	| built_in_function_call				# BuiltInFunctionCallClockExpression
	| LeftParen bool_val RightParen			# BoolValClockExpression
	| LeftParen hdl_clock_expr RightParen	# HdlClockExprClockExpression;

actual_parameter_list:
	actual_parameter (Comma actual_parameter)*;

actual_parameter:
	any_type		# AnyTypeActualParameter
	| number_val	# NumberValActualParameter
	| bool_val		# BoolValActualParameter
	| property		# PropertyActualParameter
	| sequences		# SequencesActualParameter;

// PSL directives
psl_directive: (label Colon)? verification_directive;

label: clangppIdentifier;

hdl_or_psl_identifier: clangppIdentifier;

verification_directive:
	assert_directive			# AssertDirectiveVerificationDirective
	| assume_directive			# AssumeDirectiveVerificationDirective
	| restrict_directive		# RestrictDirectiveVerificationDirective
	| restrict_strong_directive	# RestrictStrongDirectiveVerificationDirective
	| cover_directive			# CoverDirectiveVerificationDirective
	| fairness_statement		# FairnessStatementVerificationDirective;

assert_directive:
	VAL_ASSERT property (REPORT StringLiteral)? Semi;

assume_directive: VAL_ASSUME property Semi;

restrict_directive: RESTRICT sequences Semi;

restrict_strong_directive: RESTRICTSTRONG sequences Semi;

cover_directive:
	COVER sequences LeftBracket REPORT StringLiteral RightBracket Semi;

fairness_statement:
	FAIRNESS bool_val Semi							# FairnessFairnessStatement
	| STRONG FAIRNESS bool_val Comma bool_val Semi	# StrongFairnessStatement;

// PSL properties 

property:
	replicator property	# ReplicatorPropertyProperty
	| fl_property		# FlPropertyProperty
	| obe_property		# ObePropertyProperty;

replicator: FORALL parameter_definition Colon;

index_range: left_sym range right_sym;
// | LeftParen hdl_range RightParen; // (Only for VHDL)

value_set:
	LeftBrace value_range (Comma value_range)* RightBrace	# ValueRangeValueSet
	| BOOLEAN												# BooleanValueSet;

value_range: value # ValueValueRange | range # RangeValueRange;

value: bool_val # BoolValValue | number_val # NumberValValue;

proc_block:
	LeftBracket LeftBracket proc_block_Item (proc_block_Item)* RightBracket RightBracket;

proc_block_Item:
	hdl_decl		# HdlDeclProcBlockItem
	| hdl_seq_stmt	# HdlSeqStmtProcBlockItem;

fl_property:
	bool_val												# BoolValFlProperty
	| sequences Not?										# StrongSequenceFlProperty
	| name (LeftParen actual_parameter_list RightParen)?	# NameFlProperty
	| fl_property CLOCKOP clock_expression					# ClockOpFlProperty
	| fl_property ABORT bool_val							# AbortFlProperty
	| fl_property ASYNC_ABORT bool_val						# AsyncAbortFlProperty
	| fl_property SYNC_ABORT bool_val						# SyncAbortFlProperty
	| parameterized_property								# ParameterizedPropertyFlProperty
	// Logical_Operators
	| not_op fl_property					# NotOpFlProperty
	| fl_property and_op fl_property		# AndFlProperty
	| fl_property or_op fl_property			# OrFlProperty
	| fl_property Arrow fl_property			# ArrowFlProperty
	| fl_property EQUIVALENCE fl_property	# EquivalenceFlProperty
	// Primitive_LTL_perators
	| LTLX fl_property										# LTLXFlProperty
	| LTLXSTRONG fl_property								# LTLXStrongFlProperty
	| LTLF fl_property										# LTLFFLProperty
	| LTLG fl_property										# LTLGFLProperty
	| LeftBracket fl_property LTLU fl_property RightBracket	# LTLUFLProperty
	| LeftBracket fl_property LTLW fl_property RightBracket	# LTLWFlProperty
	// Simple_Temporal_Operators
	| ALWAYS fl_property			# AlwaysFlProperty
	| NEVER fl_property				# NeverFlProperty
	| NEXT fl_property				# NextFlProperty
	| NEXTSTRONG fl_property		# NextStrongFlProperty
	| EVENTUALLYSTRONG fl_property	# EventuallyStrongFlProperty
	//
	| fl_property UNTILSTRONG fl_property	# UntilStrongFlProperty
	| fl_property UNTIL fl_property			# UntilFlProperty
	| fl_property UNTIL_STRONG fl_property	# Until_StrongFlProperty
	| fl_property UNTIL_ fl_property		# Until_FlProperty
	//
	| fl_property BEFORESTRONG fl_property	# BeforeStrongFlProperty
	| fl_property BEFORE fl_property		# BeforeFlProperty
	| fl_property BEFORE_STRONG fl_property	# Before_StrongFlProperty
	| fl_property BEFORE_ fl_property		# Before_FlProperty
	// Extended Next (Event) Operators:
	| LTLX LeftBracket number_val RightBracket LeftParen fl_property RightParen #
		LTLXNumberFlproperty
	| LTLXSTRONG LeftBracket number_val RightBracket LeftParen fl_property RightParen #
		LTLXStrongNumberFlProperty
	| NEXT LeftBracket number_val RightBracket LeftParen fl_property RightParen #
		NextNumberFlProperty
	| NEXTSTRONG LeftBracket number_val RightBracket LeftParen fl_property RightParen #
		NextStrongNumberFlProperty
	// 
	| NEXTALWAYS LeftBracket range RightBracket LeftParen fl_property RightParen #
		NextAlwaysFlProperty
	| NEXTALWAYSSTRONG LeftBracket range RightBracket LeftParen fl_property RightParen #
		NextAlwaysStrongFlProperty
	| NEXTEXISTS LeftBracket range RightBracket LeftParen fl_property RightParen #
		NextExistsFlProperty
	| NEXTEXISTSSTRONG LeftBracket range RightBracket LeftParen fl_property RightParen #
		NextExistsStrongFlProperty
	//
	| NEXTEVENTSTRONG LeftParen bool_val RightParen LeftParen fl_property RightParen #
		NextEventStrongFlProperty
	| NEXTEVENT LeftParen bool_val RightParen LeftParen fl_property RightParen # NextEventFlProperty
	| NEXTEVENTSTRONG LeftParen bool_val RightParen LeftBracket number_val RightBracket LeftParen
		fl_property RightParen # NextEventStrongNumberFlProperty
	| NEXTEVENT LeftParen bool_val RightParen LeftBracket number_val RightBracket LeftParen
		fl_property RightParen # NextEventNumberFlProperty
	//
	| NEXTEVENTALWAYSSTRONG LeftParen bool_val RightParen LeftBracket range RightBracket LeftParen
		fl_property RightParen # NextEventAlwaysStrongFlProperty
	| NEXTEVENTALWAYS LeftParen bool_val RightParen LeftBracket range RightBracket LeftParen
		fl_property RightParen # NextEventAlwaysFlProperty
	| NEXTEVENTEXISTSSTRONG LeftParen bool_val RightParen LeftBracket range RightBracket LeftParen
		fl_property RightParen # NextEventExistsStrongFlProperty
	| NEXTEVENTEXISTS LeftParen bool_val RightParen LeftBracket range RightBracket LeftParen
		fl_property RightParen # NextEventExistsFlProperty
	// Operators_on_seres
	| sere* LeftParen fl_property RightParen		# SereFlProperty
	| sequences OVERLAPSUFFIXIMPLY fl_property		# OverlapSuffixImplyFlProperty
	| sequences NONOVERLAPSUFFIXIMPLY fl_property	# NonOverlapSuffixImplyFlProperty
	// VPSL Operators
	| WITHIN_T LeftBracket LeftParen IntegerLiteral Comma TIME_UNIT RightParen RightBracket
		fl_property # WithinTFlProperty
	// HDL 
	| LeftParen (
		LeftBracket LeftBracket hdl_decl (Comma hdl_decl)* RightBracket RightBracket
	)? fl_property RightParen # ParenFlProperty;

sere:
	bool_val				# BoolValSere
	| bool_val proc_block	# ProcBlockSere
	| sequences				# SequencesSere
	| sere Semi sere		# SemiSere
	| sere Colon sere		# ColonSere
	| compound_sere			# CompundSereSere;

compound_sere:
	repeated_sere										# RepeatedSereCompoundSere
	| sequences LeftBracket Star count? RightBracket	# StarCompoundSere
	| sequences LeftBracket Plus RightBracket			# PlusCompoundSere
	| sequences proc_block								# ProcBlockCompoundSere
	| braced_sere										# BracedSereCompoundSere
	| clocked_sere										# ClockedSereCompoundSere
	| compound_sere and_or_sere_op compound_sere		# AndOrCompoundSere
	| compound_sere WITHIN compound_sere				# WithinCompoundSere
	| parameterized_sere								# ParameterizedSereCompoundSere;

parameterized_property:
	For parameters_definition Colon and_or_property_op LeftParen fl_property RightParen;

parameterized_sere:
	For parameters_definition Colon and_or_property_op LeftBrace fl_property RightBrace;

parameters_definition:
	parameter_definition parameter_definition*;

parameter_definition:
	clangppIdentifier index_range? IN value_set;

and_or_property_op:
	and_op	# AndOpAndOrProperty
	| or_op	# OrOpAndOrProperty;

and_or_sere_op:
	AndAnd	# AndAndAndOrSereOp
	| And	# AndAndOrSereOp
	| Or	# OrAndOrSereOp;

// sequences
sequences:
	sequence_instance									# SequenceInstanteSequences
	| repeated_sere										# RepeatedSereSequences
	| sequences LeftBracket Star count? RightBracket	# StarSequences
	| sequences LeftBracket Plus RightBracket			# PlusSequences
	| sequences proc_block								# ProcBlockSequences
	| braced_sere										# BracedSereSequences
	| clocked_sere										# ClockedSereSequences;

repeated_sere:
	bool_val LeftBracket Star count? RightBracket				# BoolValStarRepeatedSere
	| LeftBracket Star count? RightBracket						# StarRepeatedSere
	| bool_val LeftBracket Plus RightBracket					# BoolValPlusRepeatedSere
	| LeftBracket Plus RightBracket								# PlusRepeatedSere
	| bool_val LeftBracket Assign count RightBracket			# AssignRepeatedSere
	| bool_val LeftBracket Arrow positive_count? RightBracket	# ArrowRepeatedSere
	| bool_val proc_block										# ProcBlockRepeatedSere;

braced_sere:
	LeftBrace (
		LeftBracket LeftBracket hdl_decl hdl_decl* RightBracket RightBracket
	)? sere RightBrace # HdlDeclBracedSere
	| LeftBrace (
		FREE hdl_or_psl_identifier (hdl_or_psl_identifier)*
	)? sere RightBrace # FreeBracedSere;

sequence_instance:
	name (LeftParen actual_parameter_list RightParen)?;

clocked_sere: braced_sere CLOCKOP clock_expression;

count: number_val # NumberValCount | range # RangeCount;

positive_count:
	number_val	# NumberValPositiveCount
	| range		# RangePositiveCount;

range: low_bound range_sym high_bound;

low_bound:
	number_val	# NumberValLowBound
	| MINVAL	# MinValLowBound;

high_bound:
	number_val	# NumberValHighBound
	| MAXVAL	# MaxValHighBound;

hdl_or_psl_expression:
	built_in_function_call										# BuiltInFunctionCallHdlOrPslExpression
	| hdl_expression											# HdlExpressionHdlOrPslExpression
	| hdl_or_psl_expression Arrow hdl_or_psl_expression			# ArrowHdlOrPslExpression
	| hdl_or_psl_expression EQUIVALENCE hdl_or_psl_expression	# EquivalenceHdlOrPslExpression
	| hdl_or_psl_expression Union hdl_or_psl_expression			# UnionHdlOrPslExpression;

hdl_expression: hdl_expr;

built_in_function_call:
	// VPSL function calls
	ACTIVE LeftParen referenceExpr RightParen and_op referenceExpr	# ActiveBuiltInFunctionCall
	| READY LeftParen referenceExpr RightParen						# ReadyBuiltInFunctionCall
	| WAITING LeftParen referenceExpr RightParen					# WaitingBuiltInFunctionCall
	//
	| PREV LeftParen any_type (
		Comma number_val (Comma clock_expression)?
	)? RightParen														# PrevBuiltInFunctionCall
	| NEXT LeftParen any_type RightParen								# NextBuiltInFunctionCall
	| STABLE LeftParen any_type (Comma clock_expression)? RightParen	# StableBuiltInFunctionCall
	| ROSE LeftParen bit_val (Comma clock_expression)? RightParen		# RoseBuiltInFunctionCall
	| FELL LeftParen bit_val (Comma clock_expression)? RightParen		# FellBuiltInFunctionCall
	| ENDED LeftParen sequences (Comma clock_expression)? RightParen	# EndedBuiltInFunctionCall
	| ISUNKNOWN LeftParen bit_vector_val RightParen						# IsUnknownBuiltInFunctionCall
	| COUNTONES LeftParen bit_vector_val RightParen						# CountOnesBuiltInFunctionCall
	| ONEHOT LeftParen bit_vector_val RightParen						# OneHotBuiltInFunctionCall
	| ONEHOT0 LeftParen bit_vector_val RightParen						# OneHot0BuiltInFunctionCall
	| NONDET LeftParen value_set RightParen								# NonDetBuiltInFunctionCall
	| NONDETVECTOR LeftParen number_val Comma value_set LeftParen		# NonDetVectorBuiltInFunctionCall;

// Optional Branching Extension 
obe_property:
	LeftParen obe_property RightParen # ParenObeProperty
	| clangppIdentifier (
		LeftParen actual_parameter_list RightParen
	)? # IdentiferObeProperty //Name
	// Logical Operators
	| not_op obe_property					# NotOpObeProperty
	| obe_property and_op obe_property		# AndOpObeProperty
	| obe_property or_op obe_property		# OrOpObeProperty
	| obe_property Arrow obe_property		# ArrowObeProperty
	| obe_property EQUIVALENCE obe_property	# EquivalenceObeProperty
	// Universal Operators
	| CTLAX obe_property											# CTLAXObeProperty
	| CTLAG obe_property											# CTLAGObeProperty
	| CTLAF obe_property											# CTLAFObeProperty
	| CTLA LeftBracket obe_property LTLU obe_property RightBracket	# CTLAObeProperty
	// Existential Operators:
	| CTLEX obe_property											# CTLEXObeProperty
	| CTLEG obe_property											# CTLEGObeProperty
	| CTLEF obe_property											# CTLEFObeProperty
	| CTLE LeftBracket obe_property LTLU obe_property RightBracket	# CTLEObeProperty
	| bool_val														# BoolValObeProperty;

// Forms of expression

any_type: hdl_or_psl_expression;

bit_val: hdl_or_psl_expression;

bool_val: hdl_or_psl_expression;

bit_vector_val: hdl_or_psl_expression;

number_val: hdl_or_psl_expression;

string_val: hdl_or_psl_expression;

// Flavor Macros
def_sym: Assign;

range_sym: Colon;

and_op: AndAnd;

or_op: OrOr;

not_op: Not;

min_val: MINVAL;

max_val: MAXVAL;

hdl_expr: hdl_expressions; //equalityExpression; 

hdl_clock_expr: clangppIdentifier; // SystemC_Event_expression

//hdl_unit: clangppIdentifier; // Not needed since SystemC module already parsed in xml
hdl_decl: declarationseq; //declaration;

hdl_stmt: statement; //statement;

hdl_seq_stmt: statementSeq; // statementSeq;

hdl_variable_type: simpleTypeSpecifier; // simpleTypeSpecifier;

// hdl_range: ; (Only for VHDL)

left_sym: LeftParen;

right_sym: RightParen;

// Alternative manual HDL_Expression subset
hdl_expressions:
	referenceExpr hdl_operator referenceExpr
	| referenceExpr;

hdl_operator:
	Equal
	| NotEqual
	| Less
	| LessEqual
	| Greater
	| GreaterEqual;

referenceExpr: referenceprimary referencePostfixExpr*;

referenceprimary: clangppIdentifier;

referencePostfixExpr:
	Dot clangppIdentifier	# refIdentifier
	| referenceIndex		# refIndex
	| referenceMethod		# refMethod;

referenceMethod:
	Dot clangppIdentifier LeftParen RightParen (Dot (
		NOTIFIED_TIMED
		| NOT_NOTIFIED
		| NOTIFIED_UNTIMED
		| NOTIFIED_DELTA
		| NOTIFIED_PREV_DELTA
	) LeftParen RightParen)?;


referenceIndex:
	Dot clangppIdentifier LeftBracket (MINVAL | IntegerLiteral) RightBracket;