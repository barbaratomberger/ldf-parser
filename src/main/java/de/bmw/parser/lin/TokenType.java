/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

public enum TokenType {

    META_FILENAME,
    META_COMMENT,

    START_LIN,
    DEFINITION_KEYWORD,
    CONSTANT,

    LITERAL,
    VARIABLE_NAME,

    KBPS_UNIT,
    MS_UNIT,

    STRING_VALUE,
    INTEGER_VALUE,
    REAL_VALUE,

    COLON,
    SEMICOLON,
    ASSIGNMENT,
    COMMA,
    OPEN_CURLY,
    CLOSE_CURLY,

    LINE_TERMINATOR,
    WHITESPACE,

    EOF_LIN,
    ;
}
