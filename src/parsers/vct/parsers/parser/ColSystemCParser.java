package vct.parsers.parser;

import de.tub.pes.syscir.engine.Engine;
import de.tub.pes.syscir.engine.Environment;
import de.tub.pes.syscir.engine.TransformerFactory;
import de.tub.pes.syscir.sc_model.expressions.MarkerExpression;
import de.tub.pes.syscir.sc_model.expressions.PSLExpression;
import de.tub.pes.syscir.sc_model.SCSystem;
import hre.io.Readable;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import vct.col.origin.Origin;
import vct.parsers.ParseResult;
import vct.parsers.Parser;
import vct.parsers.debug.DebugOptions;
import vct.parsers.transform.BlameProvider;
import vct.parsers.transform.systemctocol.engine.Transformer;
import vct.parsers.transform.systemctocol.colmodel.COLSystem;
import vct.parsers.transform.systemctocol.exceptions.IllegalOperationException;
import vct.result.VerificationError;

import javax.xml.parsers.DocumentBuilderFactory;
import java.io.Reader;
import java.nio.file.Path;
import java.util.List;
import java.util.ArrayList;
// Imports for psl
import java.util.LinkedList;
import vct.antlr4.generated.LangPSLParser;
import vct.antlr4.generated.LangPSLLexer;
import vct.parsers.transform.PSLToCOLVisitor;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.logging.log4j.Marker;

public class ColSystemCParser extends Parser {

    private final String systemCConfig;

    public ColSystemCParser(Path systemCConfig) {
        this.systemCConfig = systemCConfig.toString();
    }

    public <G> ParseResult<G> parseReader(Reader reader, Origin baseOrigin) {
        // Configure SystemC Intermediate Representation
        TransformerFactory.CONFIG_FOLDER = systemCConfig;
        TransformerFactory.IMPLEMENTATION_FOLDER = TransformerFactory.CONFIG_FOLDER + "/implementation/";
        TransformerFactory.PROPERTIES_FOLDER = TransformerFactory.CONFIG_FOLDER + "/properties/";

        // Read XML document from input

        Document document;
        try {
            document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(reader));
        } catch (Throwable any_exception) {
            return null;
        }

        // Use SystemC Intermediate Representation to parse a SystemC system from the
        // document
        if (document == null)
            throw new IllegalOperationException("Could not open input XML document.");
        Environment environment = Engine.parseSystem(document);
        SCSystem sc_system = environment.getSystem();

        // Parse PSL Annotations
        sc_system.setAnnotations(parseAnnotations(sc_system));

        
        // Transform SystemC system to COL system
        Transformer<G> sc_to_col_transformer = new Transformer<>(sc_system);
        sc_to_col_transformer.create_col_model();
        COLSystem<G> col_system = sc_to_col_transformer.get_col_system();

        // Transform COL system to parse result
        return col_system.to_parse_result();
    }

    /**
     * Parses the PSL annotations and transforms them to PVL equivalents
     * 
     * @param sc_system
     * @return
     */
    public ArrayList<MarkerExpression> parseAnnotations(SCSystem sc_system) {
        ArrayList<MarkerExpression> pvl_annotations = new ArrayList<MarkerExpression>();
        if (sc_system.getAnnotations() != null) {
            for (MarkerExpression annotation : sc_system.getAnnotations()) {
                MarkerExpression a =new PSLExpression(annotation.getNode(),(transformAnnotation(annotation.toString())));
                pvl_annotations.add(a);
            }
        }
        return pvl_annotations;
    }

    private String transformAnnotation(String annotation) {
        //String input = annotation.toString();
        //String input = "vunit main {assert always active(proc1) -> within_t[(ONE,SC_MS)] active(proc2);} vunit src {assert never x;}";
        String input = "vunit main{assert always active(proc) -> within_t[(One,SC_MS)] waiting(proc2); property aba = y; assert aba;} vunit ABSASR{assert always v>0;}";
        //String input = "vunit main {}";
        LangPSLLexer lexer = new LangPSLLexer(CharStreams.fromString(input));
        LangPSLParser parser = new LangPSLParser(new CommonTokenStream(lexer));
        ParseTree tree = parser.psl_specification();

        System.out.println(tree.toStringTree(parser)+"\n\n\n\n\n");
                
        String result = new PSLToCOLVisitor().visit(tree);

        System.out.println(result+"\n\n\n\n\n");
        return result;
    }

}
