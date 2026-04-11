lexer grammar LangPSLLexer;

import LangCPPLexer;

// TOKENS
//BRACK_OPEN: '[';
//BRACK_CLOSE: ']';
//PAREN_OPEN: '(';
//PAREN_CLOSE: ')';
//BLOCK_OPEN: '{';
//BLOCK_CLOSE: '}';

//COMMA: ',';
//SEMICOLON: ';';
//COLON: ':';
//DOUBLEPOINT: '..';
//TRIPLEPOINT: '...';
//EQ: '=';
COLON_ASSIGN: ':=';

//STAR: '*';
//PLUS: '+';
OVERLAPSUFFIXIMPLY: '|->';
NONOVERLAPSUFFIXIMPLY: '|=>';
EQUIVALENCE: '<->';
//IMPLY: '->';

REPEATSTAR: '[*';
REPEATPLUS: '[+]';
SEQARROWRIGHT: '[->';
SEQEQUALS: '[=';

//AND: '&&';
//WEAKAND: '&';
//OR: '||';
//WEAKOR: '|';
//NOT: '!';

DOLLAR: '$';
CLOCKOP: '@';
//POINT: '.';
//SLASH: '/';

MINVAL: '0';
MAXVAL: 'inf';

// Verification Units

VUNIT: 'vunit';
VPKG: 'vpkg';
VPROP: 'vprop';
VMODE: 'vmode';

INHERIT: 'inherit';

// PSL Declarations

PROPERTY: 'property';

//CONST: 'const';
//MUTABLE: 'mutable';
SEQUENCE: 'sequence';
HDLTYPE: 'hdltype';

BOOLEAN: 'boolean';
BIT: 'bit';
BITVECTOR: 'bitvector';
NUMERIC: 'numeric';
//STRING: 'string';

STRING_LITERAL : '"' STRING_CHARACTER* '"';

fragment
STRING_CHARACTER : ~["\\] | ESCAPE;

fragment
ESCAPE :   '\\' [tnr"'\\] | UNICODE_ESCAPE;

fragment
UNICODE_ESCAPE
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

fragment
HEX_DIGIT
    :   [0-9a-fA-F]
    ;

// ---------------------------------------------------------------

//DEFAULT: 'default';
CLOCK: 'clock';

// PSL Directives
//ASSERT: 'assert';
REPORT: 'report';
//ASSUME: 'assume';
RESTRICT: 'restrict';
RESTRICTSTRONG: 'restrict!';
COVER: 'cover';
FAIRNESS: 'fairness';
STRONG: 'strong';


// PSL Properties

FORALL: 'forall';

ABORT: 'abort';
ASYNC_ABORT: 'async_abort';
SYNC_ABORT: 'sync_abort';

LTLX: 'X';
LTLXSTRONG: 'X!';
LTLF: 'F';
LTLG: 'G';
LTLU: 'U';
LTLW: 'W';

// Simple Temporal Operators
ALWAYS: 'always';
NEVER: 'never';
NEXT: 'next';
NEXTSTRONG: 'next!';
EVENTUALLYSTRONG: 'eventually!';
UNTILSTRONG: 'until!';
UNTIL: 'until';
UNTIL_STRONG: 'until!_';
UNTIL_: 'until_';
BEFORESTRONG: 'before!';
BEFORE: 'before';
BEFORE_STRONG: 'before!_';
BEFORE_: 'before_';

// Extended Next (Event) Operators

NEXTALWAYS: 'next_a';
NEXTALWAYSSTRONG: 'next_a!';
NEXTEXISTS: 'next_e';
NEXTEXISTSSTRONG: 'next_e!';

NEXTEVENTSTRONG: 'next_event!';
NEXTEVENT: 'next_event';
NEXTEVENTALWAYS: 'next_event_a';
NEXTEVENTALWAYSSTRONG: 'next_event_a!';
NEXTEVENTEXISTS: 'next_event_e';
NEXTEVENTEXISTSSTRONG: 'next_event_e!';


// Parameterized Properties and SEREs
//FOR: 'for';
IN: 'in';

// Built in Fnctions
PREV: 'prev';
STABLE: 'stable';
ROSE: 'rose';
FELL: 'fell';
ENDED: 'ended';
ISUNKNOWN: 'isunknown';
COUNTONES: 'countones';
ONEHOT: 'onehot';
ONEHOT0: 'onehot0';
NONDET: 'nondet';
NONDETVECTOR: 'nondet_vector';

//UNION: 'union';

// Optional Branching Extension

CTLAX: 'AX';
CTLAG: 'AG';
CTLAF: 'AF';
CTLA: 'A';
CTLEX: 'EX';
CTLEG: 'EG';
CTLEF: 'EF';
CTLE: 'E';

//TRUE: 'true';
//FALSE: 'false';

WITHIN: 'within';

//OVERRIDE: 'override';
NONTRANSITIVE: 'nontransitive';
FREE: 'free';

// VPSL Operators
WITHIN_T: 'within_t';

WAITING: 'waiting';

ACTIVE: 'active';

TIME_UNIT: 'SC_SEC' | 'SC_MS' | 'SC_US' | 'SC_NS' | 'SC_PS' | 'SC_FS';

IDENTIFIER: [a-zA-Z]('_'?[a-zA-Z0-9])*;

WS: [ \t\r\n]+ -> skip;
