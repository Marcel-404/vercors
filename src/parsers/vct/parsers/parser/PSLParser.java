package vct.parsers.parser;
import org.antlr.v4.runtime.*;

import vct.antlr4.generated.LangPSLParser;

public abstract class PSLParser extends Parser{

        protected PSLParser(TokenStream input)
    {
        super(input);
    }
}
