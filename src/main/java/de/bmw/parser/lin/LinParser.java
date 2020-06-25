/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

import java.io.File;
import java.util.Collection;
import java.util.List;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class LinParser {

    private LinParser() {
    }

    public static <T extends Collection<LinToken>> List<T> parse(Iterable<File> list, Supplier<T> supplier) {
        return StreamSupport.stream(list.spliterator(), true)
                .map(file -> parse(file, supplier))
                .collect(Collectors.toUnmodifiableList());
    }

    public static <T extends Collection<LinToken>> T parse(File linFile, Supplier<T> supplier) {
        final TokenCollector<T> tokenCollector = new TokenCollector<>(linFile, supplier);
        return tokenCollector.tokenize();
    }
}
