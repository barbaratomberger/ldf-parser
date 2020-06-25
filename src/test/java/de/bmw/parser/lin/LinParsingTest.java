/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.stream.Collectors;

public class LinParsingTest {

    @Test
    void linParsingTest() throws IOException {
        final var linFile = new File(getClass().getResource("/example.ldf").getFile());
        final var linTokens = LinParser.parse(linFile, ArrayList::new);
        linTokens.remove(0);

        final var parseOutputString = linTokens.stream()
                .map(LinToken::getValue)
                .collect(Collectors.joining());

        var fileByteArray = Files.readAllBytes(linFile.toPath());
        var tokenByteArray = parseOutputString.getBytes();
        Assertions.assertArrayEquals(fileByteArray, tokenByteArray);
    }
}
