# LDF-Parser
This framework utilizes the [JFlex Framework](https://www.jflex.de/) to tokenize lin description files, which simplifies further processing.

## Usage
JFlex has to generate java class files out of the provided [lin.flex](/src/main/jflex/lin.flex) file by executing:<br>
`mvn jflex:generate`<br>

Then you can use the LinParser class to tokenize your file.
The following example will just print out the tokenized file as string:

**The first token is always of TokenType **`META_FILENAME`** which contains the filename of the file that was parsed.
Because it is not needed for printing out the string it is removed here**
```java
class Main{
    public static void main(String[] args) {
            // actual parsing
            final var linTokens = LinParser.parse(linFile, ArrayList::new);
            linTokens.remove(0);
            // building a string out of the tokens
            final var parseOutputString = linTokens.stream()
                .map(LinToken::getValue)
                .collect(Collectors.joining());
            // Print the string, which should be the same as the file
            System.out.println(parseOutputString);
        }
}    
```
A `LinToken` consist of two final fields:
* `TokenType` for simple processing
* `StringBuilder` which contains the actual string value;

This enables the user to process the data  quite easily.<br> 
Here an example that filters all whitespaces and newlines:
```java
class Main{
    public static void main(String[] args) {

            final var linTokens = LinParser.parse(linFile, ArrayList::new);
            linTokens.remove(0);

            final var parseOutputString = linTokens.stream()
               .filter(linToken -> linToken.getToken() != TokenType.WHITESPACE)
               .filter(linToken -> linToken.getToken() != TokenType.LINE_TERMINATOR)
               .map(LinToken::getValue)
               .collect(Collectors.joining());

            System.out.println(parseOutputString);
        }
}    
``` 

### Licensing
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the 
License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by 
applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language 
governing permissions and limitations under the License.