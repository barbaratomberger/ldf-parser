/*
  Copyright (C) 2020, Bayerische Motoren Werke Aktiengesellschaft (BMW AG), [Author: Florian Fusseder (florian.fusseder@partner.bmwgroup.com)]

  SPDX-License-Identifier: Apache-2.0
*/
package de.bmw.parser.lin;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.*;
import java.nio.charset.Charset;
import java.util.Collection;
import java.util.function.Supplier;


public class TokenCollector<T extends Collection<LinToken>> {

    private static final Logger LOGGER = LogManager.getLogger(TokenCollector.class);

    private final File file;
    private final Supplier<T> supplier;
    private final Charset charset;

    public TokenCollector(File file, Supplier<T> supplier) {
        this(file, Charset.defaultCharset(), supplier);
    }

    public TokenCollector(File file, Charset charset, Supplier<T> supplier) {
        this.file = file;
        this.supplier = supplier;
        this.charset = charset;
    }

    T tokenize() {
        final var collection = supplier.get();
        final var fileName = file.getName();
        try (var stream = new FileInputStream(file)) {
            var reader = new InputStreamReader(stream, this.charset);
            var tokenizer = new LinTokenizer(reader, fileName);
            LinToken token;
            do {
                token = tokenizer.next();
                LOGGER.debug("Got token {}", token);
                collection.add(token);
            } while (token.getToken() != TokenType.EOF_LIN);
        } catch (FileNotFoundException e) {
            LOGGER.error("File not found: \"{}\"", fileName, e);
        } catch (IOException e) {
            LOGGER.error("IO error scanning file: \"{}\"", fileName, e);
        } catch (Exception e) {
            LOGGER.error("Unexpected exception in file: {}", fileName, e);
        }
        return collection;
    }
}
