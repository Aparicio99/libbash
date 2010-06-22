/**
Copyright 2010 Nathan Eloe

This file is part of libbash.

libbash is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

libbash is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with libbash.  If not, see <http://www.gnu.org/licenses/>.
**/
grammar bashast;
options
{
	backtrack=true;
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}
tokens{
	ARG;
	ARRAY;
	BRACE;
	BRACE_EXP;
	COMMAND_SUB;
	CASE_PATTERN;
	SUBSHELL;
	CURRSHELL;
	COMPOUND_ARITH;
	COMPOUND_COND;
	FOR_INIT;
	FOR_COND;
	FOR_MOD;
	FNAME;
	OFFSET;
	LIST_EXPAND;
	OP;
	PRE_INCR;
	PRE_DECR;
	POST_INCR;
	POST_DECR;
	PROC_SUB;
}

list	:	list_level_2 BLANK!? (';'!|'&'^|EOL!)?;
clist	:	list_level_2;
list_level_1
	:	pipeline (BLANK!?('&&'^|'||'^)BLANK!? pipeline)*;
list_level_2
	:	list_level_1 ((BLANK!?';'!|BLANK!?'&'^|(BLANK!? EOL!)+)BLANK!? list_level_1)*;
pipeline
	:	time?('!' BLANK)? command^ (BLANK!?PIPE^ BLANK!? simple_command)*;
time	:	TIME^ BLANK! timearg?;
timearg	:	'-p' BLANK!;
command	:	var_def+
	|	simple_command
	|	compound_comm;
simple_command
	:	var_def+ bash_command^ redirect*
	|	bash_command^ redirect*;
bash_command
	:	fpath^ (BLANK! fpath)*;
redirect:	BLANK!?hsop^BLANK!? fpath
	|	BLANK!?hdop^BLANK!? fpath EOL! heredoc
	|	BLANK!?redir_op^BLANK!? DIGIT MINUS?
	|	BLANK!?redir_op^BLANK!? redir_dest;

heredoc	:	(fpath EOL!)*;
redir_dest
	:	fpath //path to a file
	|	file_desc_as_file; //handles file descriptors0
file_desc_as_file
	:	a='&'b=DIGIT -> OP[$a.text+$b.text]
	|	a='&'b=DIGIT'-' -> OP[$a.text+$b.text+"-"];
hsop	:	'<''<''<' -> OP["<<<"];
hdop	:	'<''<''-' -> OP["<<-"]
	|	'<''<' -> OP["<<"];
redir_op:	'&''<' -> OP["&<"]
	|	'>''&' -> OP[">&"]
	|	'<''&' -> OP["<&"]
	|	'<''>' -> OP["<>"]
	|	'>''>' -> OP[">>"]
	|	'&''>' -> OP["&>"]
	|	'&''>''>' -> OP ["&>>"]
	|	'<'
	|	'>'
	|	fd=DIGIT op=redir_op -> OP[$fd.text+$op.text];
brace_expansion
	:	pre=fpath? brace post=fpath? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK? braceexp BLANK?RBRACE -> ^(BRACE braceexp);
braceexp:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	NAME DOTDOT^ NAME;
bepart	:	fpath|brace;
commasep:	bepart(','! bepart)+;
command_sub
	:	DOLLAR LPAREN BLANK? pipeline BLANK? RPAREN -> ^(COMMAND_SUB pipeline)
	|	TICK BLANK? pipeline BLANK? TICK -> ^(COMMAND_SUB pipeline) ;
//compound commands
compound_comm
	:	for_expr
	|	sel_expr
	|	if_expr
	|	while_expr
	|	until_expr
	|	case_expr
	|	subshell
	|	currshell
	|	arith_comp
	|	cond_comp;

for_expr:	FOR BLANK NAME (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(FOR NAME (word)? clist)
	|	FOR BLANK? LLPAREN EOL? (BLANK? init=arith_expr BLANK?|BLANK)? (SEMIC (BLANK? fcond=arith_expr BLANK?|BLANK)? SEMIC|DOUBLE_SEMIC) (BLANK?mod=arith_expr)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $fcond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK NAME (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(SELECT NAME (word)? clist)
	;
if_expr	:	IF wspace+ arg=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel EOL* (elif_expr)* (ELSE wspace+ else_list=clist BLANK? semiel EOL*)? FI
		-> ^(IF $arg $iflist (elif_expr)* ^($else_list)?)
	;
elif_expr
	:	ELIF BLANK arg=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel -> ^(IF["if"] $arg $iflist);
while_expr
	:	WHILE wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(WHILE $istrue $dothis)
	;
until_expr
	:	UNTIL wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(UNTIL $istrue $dothis)
	;
case_expr
	:	CASE^ BLANK! word wspace! IN! wspace! (case_stmt wspace!)* last_case? ESAC!;
case_stmt
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist wspace* DOUBLE_SEMIC
		-> ^(CASE_PATTERN $pat+ clist)
	;
last_case
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist (wspace* DOUBLE_SEMIC|(BLANK? EOL)+)
		-> ^(CASE_PATTERN $pat+ clist)
	;
subshell:	LPAREN wspace? clist (BLANK? SEMIC)? (BLANK? EOL)* BLANK? RPAREN -> ^(SUBSHELL clist);
currshell
	:	LBRACE wspace clist semiel RBRACE -> ^(CURRSHELL clist);
arith_comp
	:	LLPAREN wspace? arith_expr wspace? RRPAREN -> ^(COMPOUND_ARITH arith_expr);
cond_comp
	:	LLSQUARE wspace comp_expr wspace RRSQUARE -> ^(COMPOUND_COND comp_expr);
//stubs for compound commands
arith_expr
	:	'arith_stub';
comp_expr
	:	'cond_stub';
//Variables
var_def	:	BLANK!? NAME EQUALS^ value BLANK!?;
value	:	DIGIT
	|	NUMBER
	|	fpath
	|	LPAREN! BLANK!? arr_val RPAREN!;
arr_val	:	(BLANK? arg+=fpath)* -> ^(ARRAY $arg+);
//Array variables
var_ref
	:	DOLLAR! LBRACE! BLANK!? var_exp BLANK!? RBRACE!
	|	DOLLAR!NAME;
var_exp	:	NAME WORDOP^ NAME
	|	NAME COLON os=num (COLON len=num)? -> ^(OFFSET NAME $os ^($len)?)
	|	BANG^ NAME (TIMES|AT)
	|	BANG NAME LSQUARE (op=TIMES|op=AT) RSQUARE -> ^(LIST_EXPAND NAME $op)
	|	POUND^ NAME
	|	NAME (POUND^|POUNDPOUND^) fpath
	|	NAME (PCT^|PCTPCT^) fpath
	|	NAME SLASH^ fname SLASH! fname
	|	arr_var_ref
	|	NAME;
arr_var_ref
	:	NAME^ LSQUARE! DIGIT+ RSQUARE!;
//Conditional Expressions
cond_expr
	:	LLSQUARE! BLANK! cond BLANK! RRSQUARE!
	|	LSQUARE! BLANK! cond BLANK! RSQUARE!
	|	TEST! BLANK! cond;
cond
	:	binary_cond
	|	unary_cond;
binary_cond
	:	fname BLANK! BSTROP^ BLANK! fname (BLANK!?(LOGICOR^|LOGICAND^) BLANK!?cond)?
	|	fpath BLANK! BFILEOP BLANK! fpath(BLANK!?(LOGICOR^|LOGICAND^) BLANK!?cond)?
	|	num BLANK! BIOP^ BLANK! num(BLANK!?(LOGICOR^|LOGICAND^) BLANK!?cond)?;
unary_cond
	:	USTROP^ BLANK! fname
	|	UFILEOP^ BLANK! fpath;
//Rules for tokens.
wspace	:	BLANK|EOL;
semiel	:	(';'|EOL) BLANK?;

//definition of word.  this is just going to grow...
word	:	command_sub
	;
pattern	:	command_sub
	|	fname
	|	TIMES;
num	:	DIGIT|NUMBER;
//A rule for filenames
fname	:	q1=QUOTE a=qfname q2=QUOTE -> FNAME[$q1.text+$a.text+$q2.text]
	|	nqfname
	|	NAME
	|	DOT
	|	DOTDOT
	|	TILDE
	|	TEST
	|	TIMES;
qfname	:	a=fnamepart b=qfname -> FNAME[$a.text+$b.text]
	|	(c=BLANK|c=LBRACE|c=RBRACE) b=qfname -> FNAME[$c.text+$b.text]
	|	fnamepart
	|	BLANK|LBRACE|RBRACE;
nqfname	:	a=fnamepart b=nqfnamep -> FNAME[$a.text+$b.text];
nqfnamep:	a=fnamepart b=nqfnamep -> FNAME[$a.text+$b.text]
	|	fnamepart;
fnamepart
	:	BANG|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE
		|TIME|LLSQUARE|RRSQUARE|LSQUARE|RSQUARE|DOTDOT|TILDE|TEST
		|DOLLAR|AT|TIMES|MINUS|OTHER|DOT|NAME|NUMBER|DIGIT|EQUALS
		|BIOP|UFILEOP|BFILEOP|USTROP|BSTROP|INC|DEC|PLUS|EXP|LEQ|GEQ|CARET;
fpath	:	a=path_elm b=fpath -> ARG[$a.text+$b.text]
	|	a=path_elm -> ARG[$a.text];
path_elm:	fname
	|	SLASH;
//Arithmetic expansion
arithmetic
	:	logicor;
primary	:	num
	|	LPAREN! arith_expr RPAREN!;
post_inc_dec
	:	NAME BLANK?INC -> ^(POST_INCR NAME)
	|	NAME BLANK?DEC -> ^(POST_DECR NAME);
pre_inc_dec
	:	INC BLANK?NAME -> ^(PRE_INCR NAME)
	|	DEC BLANK?NAME -> ^(PRE_DECR NAME);
unary	:	primary
	|	PLUS^ primary
	|	MINUS^ primary
	|	post_inc_dec
	|	pre_inc_dec;
negation
	:	(BANG^BLANK!?|TILDE^BLANK!?)?unary;
exp	:	negation (BLANK!? EXP^ BLANK!? negation)* ;
tdm	:	exp (BLANK!?(TIMES^|SLASH^|PCT^)BLANK!? exp)*;
addsub	:	tdm (BLANK!? (PLUS^|MINUS^)BLANK!? tdm)*;
shifts	:	addsub (BLANK!? (shiftop^) BLANK!? addsub)*;
shiftop	:	'<''<' -> OP["<<"]
	|	'>''>' -> OP[">>"];
compare	:	shifts (BLANK!? (LEQ^|GEQ^|'<'^|'>'^)BLANK!? shifts)?;
bitand	:	compare (BLANK!? AMP^ BLANK!? compare)*;
bitxor	:	bitand (BLANK!? CARET^ BLANK!? bitand)*;
bitor	:	bitxor (BLANK!? PIPE^ BLANK!? bitxor)*;
logicand:	bitor (BLANK!? LOGICAND^ BLANK!? bitor)*;
logicor	:	logicand (BLANK!? LOGICOR^ BLANK!? logicand)*;
//process substitution
proc_sub:	(dir='<'|dir='>')LPAREN BLANK? clist BLANK? RPAREN -> ^(PROC_SUB $dir clist);
//TOkens

COMMENT
    :  (BLANK|EOL) '#' ~('\n'|'\r')* (EOL|EOF){$channel=HIDDEN;}
    ;
//Bash "reserved words"
BANG	:	'!';
CASE	:	'case';
DO	:	'do';
DONE	:	'done';
ELIF	:	'elif';
ELSE	:	'else';
ESAC	:	'esac';
FI	:	'fi';
FOR	:	'for';
FUNCTION:	'function';
IF	:	'if';
IN	:	'in';
SELECT	:	'select';
THEN	:	'then';
UNTIL	:	'until';
WHILE	:	'while';
LBRACE	:	'{';
RBRACE	:	'}';
TIME	:	'time';
LLSQUARE:	'[[';
RRSQUARE:	']]';

//Other special useful symbols
RPAREN	:	')';
LPAREN	:	'(';
LLPAREN	:	'((';
RRPAREN	:	'))';
LSQUARE	:	'[';
RSQUARE	:	']';
TICK	:	'`';
DOLLAR	:	'$';
AT	:	'@';
DOT	:	'.';
DOTDOT	:	'..';
//Arith ops
TIMES	:	'*';
EQUALS	:	'=';
MINUS	:	'-';
PLUS	:	'+';
INC	:	'++';
DEC	:	'--';
EXP	:	'**';
AMP	:	'&';
LEQ	:	'<=';
GEQ	:	'>=';
CARET	:	'^';
//some separators
SEMIC	:	';';
DOUBLE_SEMIC
	:	';;';
PIPE	:	'|';
QUOTE	:	'"';
//Because bash isn't exactly whitespace dependent... need to explicitly handle blanks
BLANK	:	(' '|'\t')+;
EOL	:	('\r'?'\n')+ ;
//some fragments for creating words...
DIGIT	:	'0'..'9';
NUMBER	:	DIGIT DIGIT+;
fragment
LETTER	:	('a'..'z'|'A'..'Z');
fragment
ALPHANUM:	(DIGIT|LETTER);
//Some special redirect operators
TILDE	:	'~';
//Tokens for parameter expansion
POUND	:	'#';
POUNDPOUND
	:	'##';
PCT	:	'%';
PCTPCT	:	'%%';
SLASH	:	'/';
WORDOP	:	(':-'|':='|':?'|':+');
COLON	:	':';
//Operators for conditional statements
TEST	:	'test';
LOGICAND
	:	'&&';
LOGICOR	:	'||';
BIOP		:	('-eq'|'-ne'|'-lt'|'-le'|'-gt'|'-ge');
UFILEOP		:	('-a'|'-b'|'-c'|'-d'|'-e'|'-f'|'-h'|'-k'|'-p'|'-r'|'-s'|'-t'|'-u'|'-w'|'-x'|'-O'|'-G'|'-L'|'-S'|'-N');
BFILEOP		:	('-nt'|'-ot'|'-ef');
USTROP		:	('-n'|'-z');
BSTROP		:	('=='|'!'?'='|'<'|'>');
//Tokens for strings
NAME	:	(LETTER|'_')(ALPHANUM|'_')*;
OTHER	:	.;
