package vct.parsers.transform;

import org.antlr.v4.runtime.*;

import vct.antlr4.generated.LangPSLParser;
import vct.antlr4.generated.LangPSLParserBaseVisitor;
import vct.antlr4.generated.LangPSLLexer;

public class PSLToCOLVisitor extends LangPSLParserBaseVisitor<String> {

    @Override
    public String visitPsl_specification0(LangPSLParser.Psl_specification0Context ctx) {
        String left = ctx.getChild(0).getText();
        
        System.out.println(left+"\n\n\n\n");
        return visitChildren(ctx);
    }

    @Override
    public String visitVerification_unit0(LangPSLParser.Verification_unit0Context ctx) {
        String vunit_type = ctx.getChild(0).getText();
        String ident = ctx.getChild(1).getText();
        String assertions = "";
        String brack1 = ctx.getChild(2).getText();
        String brack2 = ctx.getChild(ctx.getChildCount()-1).getText();
        System.out.println(vunit_type+"\n\n\n\n");
        System.out.println(ident+"\n\n\n\n");
        System.out.println(brack1+"\n\n\n\n");
        System.out.println(brack2+"\n\n\n\n");
        return "**";
    }

    @Override
    public String visitVunit_type0(LangPSLParser.Vunit_type0Context ctx) {
        String left = ctx.getChild(0).getText();
        return "";
    }
}
