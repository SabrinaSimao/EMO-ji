%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include <string>
#include "node.h"
#include "parser.tab.hpp"

extern int sym_type(const char *);  /* returns type from symbol table */
#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it
extern void yyerror(const char *);  /* prints grammar violation message */
static void comment(void);
static int check_type(void);
#define YY_DECL extern "C" int yylex()
#define SAVE_TOKEN  yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t)    (yylval.token = t)
%}


%%

"U+1F501"                { return TOKEN(WHILE); }
"U+1F9D0"                { return TOKEN(ELSE); }
"U+1F914"                { return TOKEN(IF); }
"U+1F502"                { return TOKEN(FOR); }
"U+1F494"                { return TOKEN(BREAK); }
"U+1F4BC"                { return TOKEN(CASE); }
"U+00A9"                 { return TOKEN(CONST); }
"U+27A1"                 { return TOKEN(CONTINUE); }
"U+1F449"                { return TOKEN(DO); }
"U+1F30C"                { return TOKEN(EXTERN); }
"U+1F4E4"                { return TOKEN(RETURN); }
"U+1F331"                { return TOKEN(STATIC); }

"&"                     { return TOKEN('&'); }
"!"                     { return TOKEN('!'); }
"~"                     { return TOKEN('~'); }
"-"                     { return TOKEN('-'); }
"+"                     { return TOKEN('+'); }
"*"                     { return TOKEN('*'); }
"/"                     { return TOKEN('/'); }
"%"                     { return TOKEN('%'); }
"<"                     { return TOKEN('<'); }
">"                     { return TOKEN('>'); }
"^"                     { return TOKEN('^'); }
"|"                     { return TOKEN('|'); }

";"                     { return TOKEN(';'); }
("{"|"<%")              { return TOKEN('{'); }
("}"|"%>")              { return TOKEN('}'); }
","                     { return TOKEN(','); }
":"                     { return TOKEN(':'); }
"="                     { return TOKEN('='); }
"("                     { return TOKEN('('); }
")"                     { return TOKEN(')'); }
("["|"<:")              { return TOKEN('['); }
("]"|":>")              { return TOKEN(']'); }
"."                     { return TOKEN('.'); }

"void"                  { SAVE_TOKEN; return (VOID); }
"char"                  { SAVE_TOKEN; return (CHAR); }
"double"                { SAVE_TOKEN; return (DOUBLE); }
"int"                   { SAVE_TOKEN; return (INT); }
"long"                  { SAVE_TOKEN; return(LONG); }
"_Bool"                 { SAVE_TOKEN; return (BOOL); }

">>"                    { return TOKEN(RIGHT_OP); }
"<<"                    { return TOKEN(LEFT_OP); }
"++"                    { return TOKEN(INC_OP); }
"--"                    { return TOKEN(DEC_OP); }
"->"                    { return TOKEN(PTR_OP); }
"&&"                    { return TOKEN(AND_OP); }
"||"                    { return TOKEN(OR_OP); }
"<="                    { return TOKEN(LE_OP); }
">="                    { return TOKEN(GE_OP); }
"=="                    { return TOKEN(EQ_OP); }
"!="                    { return TOKEN(NE_OP); }

"..."                       { return TOKEN(ELLIPSIS); } //necessary for printf
"__func__"                  { return TOKEN(FUNC_NAME); }

{L}{A}*                     { SAVE_TOKEN; return check_type(); }
{HP}{H}+{IS}?               { SAVE_TOKEN; return INT_C; }
{NZ}{D}*{IS}?               { SAVE_TOKEN; return INT_C; }
"0"{O}*{IS}?                { SAVE_TOKEN; return INT_C; }
{CP}?"'"([^'\\\n]|{ES})+"'" { SAVE_TOKEN; return INT_C; }

{D}+{E}{FS}?                { SAVE_TOKEN; return FLOAT_C; }
{D}*"."{D}+{E}?{FS}?        { SAVE_TOKEN; return FLOAT_C; }
{D}+"."{E}?{FS}?            { SAVE_TOKEN; return FLOAT_C; }
{HP}{H}+{P}{FS}?            { SAVE_TOKEN; return FLOAT_C; }
{HP}{H}*"."{H}+{P}{FS}?     { SAVE_TOKEN; return FLOAT_C; }
{HP}{H}+"."{P}{FS}?         { SAVE_TOKEN; return FLOAT_C; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+   { SAVE_TOKEN; return STRING_LITERAL; }

"/*"                    { comment(); }
"//".*                  { /* consume //-comment */ }
{WS}+                   { /* whitespace separates tokens */ }
.                       { /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}
static void comment(void)
{
    printf("Removing comments..\n");
    int c;
    while ((c = yyinput()) != 0)
        if (c == '*')
        {
            while ((c = yyinput()) == '*')
                ;
            if (c == '/')
                return;
            if (c == 0)
                break;
        }
    // yyerror("unterminated comment");
}
static int check_type(void)
{
    switch (sym_type(yytext))
    {
    default:                          /* includes undefined */
        SAVE_TOKEN;
        return  IDENTIFIER;
    }
}
