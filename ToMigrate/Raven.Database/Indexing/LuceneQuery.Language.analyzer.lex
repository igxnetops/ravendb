%namespace Raven.Database.Indexing
%scannertype LuceneQueryScanner
%visibility internal
%tokentype Token
 
%option stack, minimize, parser, verbose, persistbuffer, noembedbuffers  

Comment    [ \t\r\n\f]"//"([^\n\r]*)
Whitespace [ \t\r\n\f]
Digit      [0-9]
Number     [+-]?{Digit}+
Decimal    [+-]?{Number}\.{Number}
EscapeChar \\[^]
TermStartChar [^ :\t\r\n\f\+\-!\{\}()"^\*\?\\~\[\],]|{EscapeChar}
TermChar {TermStartChar}|[,\-\+]
WildCardStartChar {TermStartChar}|[\*\?]
WildCardChar [\*\?]|{TermChar}
QuotedChar [^\*\?\"\\]|{EscapeChar}
QuotedWildcardChar {QuotedChar}|[\*\?]
UnanalizedTerm \[\[(([^\]])|([\]][^\]]+))*\]\]
QuotedWildcardTerm \"{QuotedWildcardChar}*\"
QuotedTerm \"{QuotedChar}*\"
UnquotedTerm {TermStartChar}{TermChar}*
PrefixTerm {UnquotedTerm}"\*"
WildCardTerm  {WildCardStartChar}{WildCardChar}*
Method \@[^<]+\<[^>]+\>
DateTime {Digit}{4}-{Digit}{2}-{Digit}{2}T{Digit}{2}\:{Digit}{2}\:{Digit}{2}\.{Digit}{7}Z?


%{

%}

%%
","								{return (int)Token.COMMA;}
"^"								{return (int)Token.BOOST;}
"~"								{return (int)Token.TILDA;}
"{"								{return (int)Token.OPEN_CURLY_BRACKET;}
"}"								{return (int)Token.CLOSE_CURLY_BRACKET;}
"["								{return (int)Token.OPEN_SQUARE_BRACKET;}
"]"								{return (int)Token.CLOSE_SQUARE_BRACKET;}
"TO"							{return (int)Token.TO;}
"OR"							{return (int)Token.OR;}
"||"							{return (int)Token.OR;}
"AND"							{return (int)Token.AND;}
"&&"							{return (int)Token.AND;}
"NOT"							{return (int)Token.NOT;}
"+"								{return (int)Token.PLUS;}
"-"								{return (int)Token.MINUS;}
"\""							{return (int)Token.QUOTE;}
":"								{return (int)Token.COLON;}
"("								{return (int)Token.OPEN_PAREN;}
")"								{return (int)Token.CLOSE_PAREN;}
"*:*"							{return (int)Token.ALL_DOC;}
"INTERSECT"						{return (int)Token.INTERSECT;}
"NULL"							{ yylval.s = yytext; return (int)Token.NULL;}
{DateTime}						{ yylval.s = yytext; return (int)Token.DATETIME;}
{Method}						{ yylval.s = yytext; return (int)Token.METHOD;}
{UnanalizedTerm}				{ yylval.s = DiscardEscapeChar(yytext); return (int)Token.UNANALIZED_TERM;}
{QuotedTerm}					{ yylval.s = yytext; return (int)Token.QUOTED_TERM;}
{QuotedWildcardTerm}			{ yylval.s = yytext; return (int)Token.QUOTED_WILDCARD_TERM;}
{Comment}						{/* skip */}
{Decimal}						{ yylval.s = yytext; return (int)Token.FLOAT_NUMBER;}
"Dx"({Decimal}|{Number})	    { yylval.s = yytext; return (int)Token.DOUBLE_NUMBER;}
"Fx"({Decimal}|{Number})	    { yylval.s = yytext; return (int)Token.FLOAT_NUMBER;}
{Number}						{ yylval.s = yytext; return (int)Token.INT_NUMBER;}
"Ix"{Number}					{ yylval.s = yytext; return (int)Token.INT_NUMBER;}
"Lx"{Number}					{ yylval.s = yytext; return (int)Token.LONG_NUMBER;}
"0x"{Number}					{ yylval.s = yytext; return (int)Token.HEX_NUMBER;}
{UnquotedTerm}					{ 					
								if(InMethod && bStack.Count == 0) 
								{
									yylval.s = HandleTermInMethod();
								}
								else 
								{
									yylval.s = DiscardEscapeChar(yytext, true);
								}
								return (int)Token.UNQUOTED_TERM;
								}
{PrefixTerm}					{ yylval.s = DiscardEscapeChar(yytext);  return (int)Token.PREFIX_TERM;}
{WildCardTerm}					{ yylval.s = DiscardEscapeChar(yytext);  return (int)Token.WILDCARD_TERM;}
{Whitespace}					{/* skip */}
<<EOF>>							/*This is needed for yywrap to work, do not delete this comment!!!*/

%%