/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

public class LinToken {

    private final TokenType token;
    private final StringBuilder value;

    public TokenType getToken() {
        return token;
    }

    public String getValue() {
        return value.toString();
    }

    LinToken(TokenType token) {
        this.token = token;
        this.value = new StringBuilder();
    }

    LinToken(TokenType token, String value) {
        this(token);
        this.value.append(value);
    }

    void append(String part) {
        this.value.append(part);
    }

    void append(char part) {
        this.value.append(part);
    }

    @Override
    public String toString() {
        return "LinToken{" +
                "token=" + token +
                ", value=" + value.toString() +
                '}';
    }
}
