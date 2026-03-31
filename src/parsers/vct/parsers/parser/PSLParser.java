package vct.parsers.parser;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;


class PSLParser extends Parser{
      public static void main(String[] args) throws Exception {

        CharStream charStream = CharStreams.fromString(input);

        BasicLexer lexer = new (charStream);

        CommonTokenStream tokens = new CommonTokenStream(lexer);

        PSLParser parser = new PSLParser(tokens);

        ParseTree tree = parser.startRule();

        System.out.println(tree.toStringTree(parser));
    }
}
