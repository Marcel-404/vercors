package vct.parsers.transform;

import de.tub.pes.syscir.sc_model.SCSystem;
import de.tub.pes.syscir.sc_model.expressions.ConstantExpression;
import de.tub.pes.syscir.sc_model.SCClass;
import de.tub.pes.syscir.sc_model.SCProcess;
import scala.math.BigInt;
import scala.reflect.ClassTag$;
import vct.col.ast.*;
import vct.col.ast.Class;
import vct.col.ref.DirectRef;
import vct.col.ref.Ref;
import vct.parsers.transform.systemctocol.engine.ExpressionTransformer;
import vct.parsers.transform.systemctocol.engine.MainTransformer;
import vct.parsers.transform.systemctocol.colmodel.COLClass;
import vct.parsers.transform.systemctocol.colmodel.COLSystem;
import vct.parsers.transform.systemctocol.colmodel.ProcessClass;
import vct.parsers.transform.systemctocol.colmodel.StateClass;
import vct.parsers.transform.systemctocol.util.GeneratedBlame;
import vct.parsers.transform.systemctocol.util.OriGen;
import vct.parsers.transform.systemctocol.util.Seqs;
import vct.parsers.transform.CPPToCol;
import vct.parsers.parser.ColCPPParser;

import java.util.HashMap;
import java.util.LinkedList;

import javax.lang.model.util.Elements.Origin;

import org.antlr.v4.runtime.*;

import vct.antlr4.generated.LangPSLParser;
import vct.antlr4.generated.LangPSLParserBaseVisitor;

public class PSLToColVisitor<T> extends LangPSLParserBaseVisitor<Expr<T>> {

        private final SCSystem sc_system;

        private final COLSystem<T> col_system;

        String current_module;

        java.util.Map<String, ProcessClass> processes = new HashMap<>();

        int newest_event_index;

        int event_value = 0;

        Ref<T, InstanceField<T>> event_state_ref;
        Deref<T> event_state_deref;
        Ref<T, InstanceField<T>> proc_state_ref;
        Deref<T> proc_state_deref;

        ColCPPParser cppparser;

        public PSLToColVisitor(SCSystem sc_system, COLSystem<T> col_system) {
                this.sc_system = sc_system;
                this.col_system = col_system;
                this.newest_event_index = col_system.get_total_nr_events()-1;
                this.event_value = 0;
                this.current_module = "";
                this.event_state_ref = new DirectRef<>(col_system.get_event_state(),
                                ClassTag$.MODULE$.apply(InstanceField.class));
                this.event_state_deref = new Deref<>(col_system.THIS, event_state_ref, new GeneratedBlame<>(),
                                OriGen.create());

                this.proc_state_ref = new DirectRef<>(col_system.get_process_state(),
                                ClassTag$.MODULE$.apply(InstanceField.class));
                this.proc_state_deref = new Deref<>(col_system.THIS, proc_state_ref, new GeneratedBlame<>(),
                                OriGen.create());
                for (ProcessClass proc : col_system.get_all_processes()) {
                        processes.put(proc.get_generating_instance().getName() + "."
                                        + proc.get_generating_function().getName(), proc);
                }
        }

        @Override
        public Expr<T> visitHdl_expr0(LangPSLParser.Hdl_expr0Context ctx) {
                String expression = ctx.getText();
                if (expression.contains("data_written_event()")) {
                        String x = expression.split("\\.")[0];
                        // Check if x contained in Main
                        return new Eq<>(getEventState(2), col_system.MINUS_TWO, OriGen.create());// TODO: Replace with actual event
                } else if (expression.contains("data_read_event()")) {
                        String x = expression.split("\\.")[0];
                        // Check if x contained in Main
                        return new Eq<>(getEventState(1), col_system.MINUS_TWO, OriGen.create());// Todo: Replace with actual event

                }
                java.io.Reader reader = new java.io.StringReader(expression);
                // Statement<T> stmt = CPPToCol$.MODULE$.convert(ctx.expression()); // TODO:
                // call CPPPtransform to transform this expression, statement expression
                // mismatch
                return new StringValue<>(expression, OriGen.create());
        }

        @Override
        public Expr<T> visitHdl_decl0(LangPSLParser.Hdl_decl0Context ctx) {
                return new StringValue<>(ctx.getText(), OriGen.create());

        }

        @Override
        public Expr<T> visitVerificationUnitVerificationItem(
                        LangPSLParser.VerificationUnitVerificationItemContext ctx) {
                return visit(ctx.verification_unit());
        }

        @Override
        public Expr<T> visitVerification_unit0(LangPSLParser.Verification_unit0Context ctx) {
                if (current_module.equals("Main")) {
                }
                java.util.List<Expr<T>> vunit_items = new java.util.ArrayList<>();
                for (LangPSLParser.Vunit_itemContext assertion : ctx.vunit_item()) {
                        vunit_items.add(visit(assertion));
                }
                return col_system.fold_star(vunit_items);
        }

        @Override
        public Expr<T> visitBindingSpecContextSpec(LangPSLParser.BindingSpecContextSpecContext ctx) {
                return visit(ctx.binding_spec());
        }

        @Override
        public Expr<T> visitBinding_spec0(LangPSLParser.Binding_spec0Context ctx) {
                return visit(ctx.hierarchical_hdl_name());
        }

        @Override
        public Expr<T> visitHierarchical_hdl_name0(LangPSLParser.Hierarchical_hdl_name0Context ctx) {
                String bound_module = ctx.getText();
                this.current_module = bound_module;
                System.out.println(bound_module);
                if (false) {
                        throw new IllegalArgumentException("Module not recognised: " + current_module);
                }
                return new StringValue<>(bound_module, OriGen.create());
        }

        @Override
        public Expr<T> visitPslDirectiveVunitItem(LangPSLParser.PslDirectiveVunitItemContext ctx) {
                return visit(ctx.psl_directive());
        }

        @Override
        public Expr<T> visitPslDeclarationVunitItem(LangPSLParser.PslDeclarationVunitItemContext ctx) {
                return visit(ctx.psl_declaration());
        }

        @Override
        public Expr<T> visitPsl_directive0(LangPSLParser.Psl_directive0Context ctx) {
                return visit(ctx.verification_directive());
        }

        // ==============================================================================================================
        // verification_directive:
        // ==============================================================================================================

        @Override
        public Expr<T> visitAssertDirectiveVerificationDirective(
                        LangPSLParser.AssertDirectiveVerificationDirectiveContext ctx) {
                return visit(ctx.assert_directive());
        }

        @Override
        public Expr<T> visitAssumeDirectiveVerificationDirective(
                        LangPSLParser.AssumeDirectiveVerificationDirectiveContext ctx) {
                throw new IllegalArgumentException("Verification Directive not supported: assume");
        }

        @Override
        public Expr<T> visitRestrictDirectiveVerificationDirective(
                        LangPSLParser.RestrictDirectiveVerificationDirectiveContext ctx) {
                throw new IllegalArgumentException("Verification Directive not supported: restrict");
        }

        @Override
        public Expr<T> visitRestrictStrongDirectiveVerificationDirective(
                        LangPSLParser.RestrictStrongDirectiveVerificationDirectiveContext ctx) {
                throw new IllegalArgumentException("Verification Directive not supported: restrict!");
        }

        @Override
        public Expr<T> visitCoverDirectiveVerificationDirective(
                        LangPSLParser.CoverDirectiveVerificationDirectiveContext ctx) {
                throw new IllegalArgumentException("Verification Directive not supported: cover");
        }

        @Override
        public Expr<T> visitFairnessStatementVerificationDirective(
                        LangPSLParser.FairnessStatementVerificationDirectiveContext ctx) {
                throw new IllegalArgumentException("Verification Directive not supported: fairness");
        }

        // ==============================================================================================================
        // ==============================================================================================================

        @Override
        public Expr<T> visitAssert_directive0(LangPSLParser.Assert_directive0Context ctx) {
                return visit(ctx.property());
        }

        // ==============================================================================================================
        // property:
        // ==============================================================================================================
        @Override
        public Expr<T> visitReplicatorPropertyProperty(LangPSLParser.ReplicatorPropertyPropertyContext ctx) {
                throw new IllegalArgumentException("Property not supported: Replicator Property");
        }

        @Override
        public Expr<T> visitFlPropertyProperty(LangPSLParser.FlPropertyPropertyContext ctx) {
                return visit(ctx.fl_property());
        }

        @Override
        public Expr<T> visitObePropertyProperty(LangPSLParser.ObePropertyPropertyContext ctx) {
                throw new IllegalArgumentException("Property not supported: OBE Property");
        }

        // ==============================================================================================================
        // ==============================================================================================================

        @Override
        public Expr<T> visitHdl_expression0(LangPSLParser.Hdl_expression0Context ctx) {
                return visit(ctx.hdl_expr());
        }

        // hdl_or_psl_expression

        @Override
        public Expr<T> visitBuiltInFunctionCallHdlOrPslExpression(
                        LangPSLParser.BuiltInFunctionCallHdlOrPslExpressionContext ctx) {
                return visit(ctx.built_in_function_call());
        }

        @Override
        public Expr<T> visitHdlExpressionHdlOrPslExpression(LangPSLParser.HdlExpressionHdlOrPslExpressionContext ctx) {
                return visit(ctx.hdl_expression());
        }

        @Override
        public Expr<T> visitArrowHdlOrPslExpression(LangPSLParser.ArrowHdlOrPslExpressionContext ctx) {
                return new Implies<>(visit(ctx.hdl_or_psl_expression(0)), visit(ctx.hdl_or_psl_expression(1)),
                                OriGen.create());
        }

        @Override
        public Expr<T> visitEquivalenceHdlOrPslExpression(LangPSLParser.EquivalenceHdlOrPslExpressionContext ctx) {
                Implies<T> left = new Implies<>(visit(ctx.hdl_or_psl_expression(0)),
                                visit(ctx.hdl_or_psl_expression(1)), OriGen.create());
                Implies<T> right = new Implies<>(visit(ctx.hdl_or_psl_expression(1)),
                                visit(ctx.hdl_or_psl_expression(0)), OriGen.create());
                return new And<>(left, right, OriGen.create());
        }

        // Forms of expression

        @Override
        public Expr<T> visitAny_type0(LangPSLParser.Any_type0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        @Override
        public Expr<T> visitBit_val0(LangPSLParser.Bit_val0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        @Override
        public Expr<T> visitBool_val0(LangPSLParser.Bool_val0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        @Override
        public Expr<T> visitBit_vector_val0(LangPSLParser.Bit_vector_val0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        @Override
        public Expr<T> visitNumber_val0(LangPSLParser.Number_val0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        @Override
        public Expr<T> visitString_val0(LangPSLParser.String_val0Context ctx) {
                return visit(ctx.hdl_or_psl_expression());
        }

        // FL property

        @Override
        public Expr<T> visitAlwaysFlProperty(LangPSLParser.AlwaysFlPropertyContext ctx) {
                return visit(ctx.fl_property());
        }

        @Override
        public Expr<T> visitBoolValFlProperty(LangPSLParser.BoolValFlPropertyContext ctx) {
                return visit(ctx.bool_val());
        }

        @Override
        public Expr<T> visitNotOpFlProperty(LangPSLParser.NotOpFlPropertyContext ctx) {
                return new Not<>(visit(ctx.fl_property()), OriGen.create());
        }

        @Override
        public Expr<T> visitAndFlProperty(LangPSLParser.AndFlPropertyContext ctx) {
                return new And<>(visit(ctx.fl_property(0)), visit(ctx.fl_property(1)), OriGen.create());
        }

        @Override
        public Expr<T> visitOrFlProperty(LangPSLParser.OrFlPropertyContext ctx) {
                return new Or<>(visit(ctx.fl_property(0)), visit(ctx.fl_property(1)), OriGen.create());
        }

        @Override
        public Expr<T> visitArrowFlProperty(LangPSLParser.ArrowFlPropertyContext ctx) {
                if (ctx.fl_property(1).getText().startsWith("within_t")) {
                        java.util.List<Expr<T>> expression = new java.util.ArrayList<>();

                        // Right side of equation
                        Expr<T> right = visit(ctx.fl_property(1));

                        // Left Side of equation
                        IntegerValue<T> event_index = new IntegerValue<>(BigInt.apply(event_value), OriGen.create());
                        Eq<T> equals = new Eq<>(getEventState(newest_event_index), event_index, OriGen.create());
                        Implies<T> left = new Implies<>(visit(ctx.fl_property(0)), equals, OriGen.create());

                        expression.add(left);
                        expression.add(right);
                        return col_system.fold_star(expression);
                }
                return new Implies<>(visit(ctx.fl_property(0)), visit(ctx.fl_property(1)), OriGen.create());
        }

        @Override
        public Expr<T> visitEquivalenceFlProperty(LangPSLParser.EquivalenceFlPropertyContext ctx) {
                Implies<T> left = new Implies<>(visit(ctx.fl_property(0)), visit(ctx.fl_property(1)), OriGen.create());
                Implies<T> right = new Implies<>(visit(ctx.fl_property(1)), visit(ctx.fl_property(0)), OriGen.create());
                return new And<>(left, right, OriGen.create());
        }

        @Override
        public Expr<T> visitWithinTFlProperty(LangPSLParser.WithinTFlPropertyContext ctx) {
                col_system.add_wait_event();
                this.newest_event_index = this.newest_event_index + 1;
                this.event_value = Integer.parseInt(ctx.number_val().getText()); // TODO: IDENTIFY WHAT HAPPENS IF THIS
                                                                                 // IS A STRING I.E. int x =1;
                Greater<T> equation = new Greater<>(getEventState(newest_event_index), col_system.ZERO, OriGen.create());
                return new Implies<>(visit(ctx.fl_property()), equation, OriGen.create());
        }

        // built_in_function_call

        @Override
        public Expr<T> visitActiveBuiltInFunctionCall(LangPSLParser.ActiveBuiltInFunctionCallContext ctx) {
                String process_name = ctx.any_type().getText();
                ProcessClass actual_process = processes.get(process_name);
                if (actual_process == null) {
                        throw new IllegalArgumentException("Process not recognised:" + process_name);
                }
                IntegerValue<T> index = new IntegerValue<>(BigInt.apply(actual_process.get_process_id()),
                                OriGen.create());
                SeqSubscript<T> proc_index = new SeqSubscript<>(proc_state_deref, index, new GeneratedBlame<>(),
                                OriGen.create());

                return new Eq<>(proc_index, col_system.MINUS_ONE, OriGen.create());// Maybe rename active() -> ready()?
        }

        @Override
        public Expr<T> visitWaitingBuiltInFunctionCall(LangPSLParser.WaitingBuiltInFunctionCallContext ctx) {
                String process_name = ctx.any_type().getText();
                ProcessClass actual_process = processes.get(process_name);
                if (actual_process == null) {
                        throw new IllegalArgumentException("Process not recognised:" + process_name);
                }
                IntegerValue<T> index = new IntegerValue<>(BigInt.apply(actual_process.get_process_id()),
                                OriGen.create());
                SeqSubscript<T> proc_index = new SeqSubscript<>(proc_state_deref, index, new GeneratedBlame<>(),
                                OriGen.create());

                return new GreaterEq<>(proc_index, col_system.ZERO, OriGen.create());
        }

        // Helper methods

        private Expr<T> getEventState(int index) {
                IntegerValue<T> event_id = new IntegerValue<>(BigInt.apply(index),
                                OriGen.create());
                SeqSubscript<T> proc_i = new SeqSubscript<>(event_state_deref, event_id, new GeneratedBlame<>(),
                                OriGen.create());
                return proc_i;
        }

}