/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Stack;

%%

%public
%class LinTokenizer
%function next
%line
%column
%eofclose
%ctorarg String fileName
%unicode
%type LinToken

%state HEAD
%state LIN_DEFINITION
%state TOPLEVEL
%state DEFINITION_START

%state ENUMERATION
%state LISTING
%state ASSIGNMENT

%state STRING_VALUE

//%debug
//%standalone

OctDigit          = [0-7]
StringCharacter = [^\r\n\"\\]
HexIntegerLiteral = 0[xX][0-9a-fA-F]+
DecIntegerLiteral = [-+]?\d+
DecRealLiteral = \d+?\.\d+

//Letter = \p{L}
//Word = \p{L}+
Definition_Literal = [A-Z][a-z_]*
Literal = [a-zA-Z_][a-zA-Z0-9_]*

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}
TraditionalComment   = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/**" {CommentContent} "*"+ "/"
CommentContent       = ( [^*] | \*+ [^/*] )*

Schedule_table_constants = AssignNAD | ConditionalChangeNAD | DataDump | SaveConfiguration | AssignFrameIdRange | FreeFormat | AssignFrameId


%{
  private LinToken metaToken;
  private LinToken token;
  private Stack<Integer> stateStack;

  private void yypush(){
      this.yypush(yystate());
  }

  private void yypush(int state){
      this.stateStack.push(state);
  }

  private Integer yypop(){
      return this.stateStack.pop();
  }

  public LinToken getMetaToken(){
      return this.metaToken;
  }

%}

%init{
    this.metaToken = new LinToken(TokenType.META_FILENAME, fileName);
    this.stateStack = new Stack<>();
%init}

%eof{

%eof}

%eofval{
  return new LinToken(TokenType.EOF_LIN);
%eofval}

%%
<YYINITIAL> {
    .+  {
       yypushback(yytext().length());
       yybegin(HEAD);
       return getMetaToken();
      }
}

<HEAD> {
  {Comment} { return new LinToken(TokenType.META_COMMENT, yytext()); }
  "LIN_description_file" {
          yybegin(LIN_DEFINITION);
          return new LinToken(TokenType.START_LIN, yytext());
      }
}


<LIN_DEFINITION> {
  ;  { return new LinToken(TokenType.SEMICOLON, yytext()); }
  "LIN_protocol_version" |
  "LIN_language_version" |
  "Channel_name" |
  "LIN_speed"  { return new LinToken(TokenType.VARIABLE_NAME, yytext()); }
  "=" {
          yypush();
          yybegin(ASSIGNMENT);
          return new LinToken(TokenType.ASSIGNMENT, yytext());
      }
  {Definition_Literal} {
            yybegin(TOPLEVEL);
            yypushback(yytext().length());
      }
}

<TOPLEVEL> {
  {Definition_Literal} {
          yybegin(DEFINITION_START);
          return new LinToken(TokenType.DEFINITION_KEYWORD, yytext());
      }
}

<DEFINITION_START> {
    "{" {
          yypush(TOPLEVEL);
          yybegin(ENUMERATION);
          return new LinToken(TokenType.OPEN_CURLY, yytext());
      }
}

<ENUMERATION> {
    {Schedule_table_constants}  {
          yypush();
          yybegin(LISTING);
          return new LinToken(TokenType.CONSTANT, yytext());
      }
    {Literal} { return new LinToken(TokenType.LITERAL, yytext()); }
    :  {
          yypush();
          yybegin(ASSIGNMENT);
          return new LinToken(TokenType.COLON, yytext());
      }
    "=" {
          yypush();
          yybegin(ASSIGNMENT);
          return new LinToken(TokenType.ASSIGNMENT, yytext());
      }
    , {
          yypush();
          yybegin(LISTING);
          return new LinToken(TokenType.COMMA, yytext());
      }
    "{" {
          yypush();
          yybegin(ENUMERATION);
          return new LinToken(TokenType.OPEN_CURLY, yytext());
      }
    "}" {
          yybegin(yypop());
          return new LinToken(TokenType.CLOSE_CURLY, yytext());
      }

    ; { return new LinToken(TokenType.SEMICOLON, yytext()); }
    "kbps" { return new LinToken(TokenType.KBPS_UNIT, yytext()); }
    "ms" { return new LinToken(TokenType.MS_UNIT, yytext()); }
    {HexIntegerLiteral} { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
    {DecRealLiteral}  { return new LinToken(TokenType.REAL_VALUE, yytext()); }
    {DecIntegerLiteral}  { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
}

<ASSIGNMENT> {
    ; {
          yybegin(yypop());
          return new LinToken(TokenType.SEMICOLON, yytext());
      }
    , { return new LinToken(TokenType.COMMA, yytext()); }
    "{" {
          yybegin(ENUMERATION);
          return new LinToken(TokenType.OPEN_CURLY, yytext());
      }
    \"  {
          yypush();
          yybegin(STRING_VALUE);
          this.token = new LinToken(TokenType.STRING_VALUE);
          this.token.append(yytext());
      }
    "kbps" { return new LinToken(TokenType.KBPS_UNIT, yytext()); }
    "ms" { return new LinToken(TokenType.MS_UNIT, yytext()); }
    {HexIntegerLiteral} { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
    {Literal} { return new LinToken(TokenType.LITERAL, yytext()); }
    {DecRealLiteral}  { return new LinToken(TokenType.REAL_VALUE, yytext()); }
    {DecIntegerLiteral}  { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
}

<LISTING> {
    "{" { return new LinToken(TokenType.OPEN_CURLY, yytext()); }
    ; {
          yybegin(yypop());
          return new LinToken(TokenType.SEMICOLON, yytext());
      }
    "}" { return new LinToken(TokenType.CLOSE_CURLY, yytext()); }
    , { return new LinToken(TokenType.COMMA, yytext()); }
    \"  {
          yypush();
          yybegin(STRING_VALUE);
          this.token = new LinToken(TokenType.STRING_VALUE);
          this.token.append(yytext());
      }
    "kbps" { return new LinToken(TokenType.KBPS_UNIT, yytext()); }
    "ms" { return new LinToken(TokenType.MS_UNIT, yytext()); }
    {HexIntegerLiteral} { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
    {Literal} { return new LinToken(TokenType.LITERAL, yytext()); }
    {DecRealLiteral}  { return new LinToken(TokenType.REAL_VALUE, yytext()); }
    {DecIntegerLiteral}  { return new LinToken(TokenType.INTEGER_VALUE, yytext()); }
}



<STRING_VALUE> {
  \"                             {
          yybegin(yypop());
          this.token.append(yytext());
          return this.token;
      }
  {StringCharacter}+             { this.token.append(yytext()); }
  "\\b"                          { this.token.append( '\b' ); }
  "\\t"                          { this.token.append( '\t' ); }
  "\\n"                          { this.token.append( '\n' ); }
  "\\f"                          { this.token.append( '\f' ); }
  "\\r"                          { this.token.append( '\r' ); }
  "\\\""                         { this.token.append( '\"' ); }
  "\\'"                          { this.token.append( '\'' ); }
  "\\\\"                         { this.token.append( '\\' ); }
  \\[0-3]?{OctDigit}?{OctDigit}  {
          var val = (char) Integer.parseInt(yytext().substring(1),8);
          this.token.append(val);
      }
  /* error cases */
  \\.                            { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
  {LineTerminator}               { throw new RuntimeException("Unterminated string at end of line"); }
}


\R  { return new LinToken(TokenType.LINE_TERMINATOR, yytext()); }
\s  { return new LinToken(TokenType.WHITESPACE, yytext()); }
{Comment}  { return new LinToken(TokenType.META_COMMENT, yytext());  }
\S { throw new RuntimeException("Illegal character \""+yytext()+"\" at " + (yyline+1) + ":" + (yycolumn+1) +" state: " + yystate() ); }
. { throw new RuntimeException("Illegal character \""+yytext()+"\" at " + (yyline+1) + ":" + (yycolumn+1) +" state: " + yystate() ); }
