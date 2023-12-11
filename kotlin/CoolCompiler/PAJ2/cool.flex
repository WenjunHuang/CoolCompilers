/*
 *  The scanner definition for COOL.
 */
import java_cup.runtime.Symbol;

%%
%class CoolLexer
%cup

%{
    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

%init{
%init}
%eofval{
return new Symbol(TokenConstants.EOF);
%eofval}


DecIntegerLiteral = 0 | [1-9][0-9]*
Identifier = [:jletter:_][:jletterdigit:_]*
LineFeed = \n|\r\n
WhiteSpace = {LineFeed} | [ \t\f]

%state STRING
%%
<YYINITIAL>{
/* arithmetic operators */
"+" {return new Symbol(TokenConstants.PLUS);}
"-" {return new Symbol(TokenConstants.MINUS);}
"*" {return new Symbol(TokenConstants.MULT);}
"/" {return new Symbol(TokenConstants.DIV);}

/* comparison operators */
"<" {return new Symbol(TokenConstants.LT); }
"<=" {return new Symbol(TokenConstants.LE); }
"=" {return new Symbol(TokenConstants.EQ); }

/* key words */
"class" {return new Symbol(TokenConstants.CLASS);}
"inherits" {return new Symbol(TokenConstants.INHERITS);}
"pool" {return new Symbol(TokenConstants.POOL);}
"loop" {return new Symbol(TokenConstants.LOOP);}
"case" {return new Symbol(TokenConstants.CASE);}
"esac" {return new Symbol(TokenConstants.ESAC);}
"not" {return new Symbol(TokenConstants.NOT);}
"in" {return new Symbol(TokenConstants.IN);}
"if" {return new Symbol(TokenConstants.IF);}
"fi" {return new Symbol(TokenConstants.FI);}
"of" {return new Symbol(TokenConstants.OF);}
"new" {return new Symbol(TokenConstants.NEW);}
"isvoid" {return new Symbol(TokenConstants.ISVOID);}
"(" {return new Symbol(TokenConstants.LPAREN);}
")" {return new Symbol(TokenConstants.RPAREN);}
"{" {return new Symbol(TokenConstants.LBRACE);}
"}" {return new Symbol(TokenConstants.RBRACE);}
";" {return new Symbol(TokenConstants.SEMI);}
":" {return new Symbol(TokenConstants.COLON);}
"," {return new Symbol(TokenConstants.COMMA);}
"<-" {return new Symbol(TokenConstants.ASSIGN);}
"." {return new Symbol(TokenConstants.DOT);}
"=>" {return new Symbol(TokenConstants.DARROW);}

"false" {return new Symbol(TokenConstants.BOOL_CONST,Boolean.FALSE);}
"true" {return new Symbol(TokenConstants.BOOL_CONST,Boolean.TRUE);}
\" {string_buf.setLength(0); yybegin(STRING);}
{Identifier} {return new Symbol(TokenConstants.ID,AbstractTable.idtable.addString(yytext()));}
{DecIntegerLiteral}  { return new Symbol(TokenConstants.INT_CONST,AbstractTable.inttable.addString(yytext())); }
{WhiteSpace} {}
}

<STRING> {
\" {yybegin(YYINITIAL);
return new Symbol(TokenConstants.STR_CONST,AbstractTable.stringtable.addString(string_buf.toString()));
}

\\{LineFeed} {string_buf.append(yytext().substring(1));}
\\\" {string_buf.append('\"');}
\\ {string_buf.append('\\');}
[^{LineFeed}\"\\]+ {string_buf.append(yytext());}

}

.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
