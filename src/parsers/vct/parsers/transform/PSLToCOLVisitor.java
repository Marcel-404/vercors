package vct.parsers.transform;

import java.util.LinkedList;

import org.antlr.v4.runtime.*;

import vct.antlr4.generated.LangPSLParser;
import vct.antlr4.generated.LangPSLParserBaseVisitor;
import vct.antlr4.generated.LangPSLLexer;

public class PSLToCOLVisitor extends LangPSLParserBaseVisitor<String> {


    //private java.util.Map<String,java.util.List<String>> vunits = new java.util.HashMap<>();

    //private java.util.Map<String,LangPSLParser.PropertyContext> properties = new java.util.HashMap<>();

    // ===================================================================================================
    // Supported visitMethods
    // ===================================================================================================


    /*public java.util.Map<String,java.util.List<String>> getVunits(){
        return vunits;
    }*/

    @Override
    /**
     * Visit Method for start rule psl_specification
     * 
     * @param ctx
     * @return
     */
    public String visitPsl_specification0(LangPSLParser.Psl_specification0Context ctx) {
        String result = "";
        for (LangPSLParser.Verification_itemContext item : ctx.verification_item()) {
            result = result + visit(item) + "\n";
        }
        return result;
    }

    @Override
    public String visitVerificationUnitVerificationItem(LangPSLParser.VerificationUnitVerificationItemContext ctx) {
        return visit(ctx.verification_unit());
    }

    @Override
    public String visitVerification_unit0(LangPSLParser.Verification_unit0Context ctx) {
        String vunit_type = visit(ctx.vunit_type());
        String vunit_name = ctx.Identifier().getText();
        String assertions = "";
        boolean firstVisit = true;
        for (LangPSLParser.Vunit_itemContext assertion : ctx.vunit_item()) {
            if (!firstVisit) {
                assertions = assertions + " ** ";
            }
            assertions = assertions + visit(assertion);
            firstVisit = false;
        }
        return vunit_name + ": " + assertions;
    }

    @Override
    public String visitVunitVunitType(LangPSLParser.VunitVunitTypeContext ctx) {
        return ctx.VUNIT().getText();
    }

    @Override
    public String visitPslDirectiveVunitItem(LangPSLParser.PslDirectiveVunitItemContext ctx) {
        return visit(ctx.psl_directive());
    }

    @Override
    public String visitAssertDirectiveVerificationDirective(
            LangPSLParser.AssertDirectiveVerificationDirectiveContext ctx) {
        return visit(ctx.assert_directive());
    }

    @Override
    public String visitAssert_directive0(LangPSLParser.Assert_directive0Context ctx) {
        return visit(ctx.property());
    }

    @Override
    public String visitFlPropertyProperty(LangPSLParser.FlPropertyPropertyContext ctx) {

        return visit(ctx.fl_property());
    }

    @Override
    public String visitBoolValFlProperty(LangPSLParser.BoolValFlPropertyContext ctx) {
        return visit(ctx.bool_val());
    }

    @Override
    public String visitBool_val0(LangPSLParser.Bool_val0Context ctx) {
        return visit(ctx.hdl_or_psl_expression());
    }

    @Override
    public String visitHdlExpressionHdlOrPslExpression(LangPSLParser.HdlExpressionHdlOrPslExpressionContext ctx) {
        return visit(ctx.hdl_expression());
    }

    @Override
    public String visitHdl_expression0(LangPSLParser.Hdl_expression0Context ctx) {
        return visit(ctx.hdl_expr());
    }

    @Override
    public String visitHdl_expr0(LangPSLParser.Hdl_expr0Context ctx) {
        return ctx.getText(); // TODO CHANGE TO EXPRESSION
    }

    @Override
    public String visitWithinTFlProperty(LangPSLParser.WithinTFlPropertyContext ctx) {
        String fl_property = ctx.fl_property().getText();
        String process_active = extractBetween(fl_property, "active(", ")");
        String process_waiting = extractBetween(fl_property, "waiting(", ")");
        String process = process_active.isEmpty() ? process_waiting : process_active;
        return visit(ctx.fl_property()) + "==> " + process + "." + process + "_timer_value > 0";
    }

    @Override
    public String visitNumber_val0(LangPSLParser.Number_val0Context ctx) {
        return visit(ctx.hdl_or_psl_expression());
    }

    @Override
    public String visitActiveBuiltInFunctionCall(LangPSLParser.ActiveBuiltInFunctionCallContext ctx) {
        return "process_state[ID:" + ctx.Identifier().getText() + "] == -1 ";
    }

    @Override
    public String visitWaitingBuiltInFunctionCall(LangPSLParser.WaitingBuiltInFunctionCallContext ctx) {
        return "process_state[ID:" + ctx.Identifier().getText() + "] != -1 "; // TODO: Illogical that process could be
                                                                            // waiting but its timer value could be > 0
    }

    @Override
    public String visitArrowFlProperty(LangPSLParser.ArrowFlPropertyContext ctx) {
        String left = ctx.fl_property(0).getText();
        String right = ctx.fl_property(1).getText();
        String processLeft = extractBetween(left, "active(", ")");
        String processRight = extractBetween(right, "active(", ")");
        String timer_value = extractBetween(right, "within_t[(", ",");
        /*
         * if(Integer.parseInt(timer_value)<0){
         * throw new
         * IllegalArgumentException("Time Value for Operator within_t may not be < 0");
         * }
         */
        String timer = "";
        if (!timer_value.isEmpty()) {
            timer = "==> " + processLeft + "." + processLeft + "_timer_value == " + timer_value;
        }
        return visit(ctx.fl_property(0)) + timer + " ** " + visit(ctx.fl_property(1));
    }

    @Override
    public String visitPropertyDeclarationPslDeclaration(LangPSLParser.PropertyDeclarationPslDeclarationContext ctx) {
        return visit(ctx.property_declaration());
    }

    @Override
    public String visitProperty_declaration0(LangPSLParser.Property_declaration0Context ctx) {
        //properties.put(ctx.Identifier().getText(),ctx.property());
        return null;
    }

    /**
     * Private Method that extracts String between left and right, if left is
     * contained in the string
     * 
     * @param input input String to be extracted from
     * @param left  left String that represents the start of the extraction
     * @param right right String that represents the end of the extraction
     * @return extracted item
     */
    private String extractBetween(String input, String left, String right) {
        String result = "";
        if (input.contains(left)) {
            int start = input.indexOf(left) + left.length();
            result = input.substring(start, input.indexOf(right, start));
        }
        return result;
    }
}