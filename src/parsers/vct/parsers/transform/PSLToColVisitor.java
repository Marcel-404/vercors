package vct.parsers.transform;

import de.tub.pes.syscir.sc_model.SCClass;
import de.tub.pes.syscir.sc_model.SCProcess;
import de.tub.pes.syscir.sc_model.SCSystem;
import de.tub.pes.syscir.sc_model.SCFunction;
import de.tub.pes.syscir.sc_model.SCVariable;
import de.tub.pes.syscir.sc_model.variables.SCKnownType;
import de.tub.pes.syscir.sc_model.variables.SCClassInstance;
import de.tub.pes.syscir.sc_model.variables.SCSimpleType;
import scala.math.BigInt;
import scala.reflect.ClassTag$;
import vct.col.ast.*;
import vct.col.ast.Class;
import vct.col.ref.DirectRef;
import vct.col.ref.Ref;
import vct.result.VerificationError;
import vct.parsers.transform.systemctocol.colmodel.COLClass;
import vct.parsers.transform.systemctocol.colmodel.COLSystem;
import vct.parsers.transform.systemctocol.colmodel.ProcessClass;
import vct.parsers.transform.systemctocol.colmodel.StateClass;
import vct.parsers.transform.systemctocol.util.GeneratedBlame;
import vct.parsers.transform.systemctocol.util.OriGen;
import vct.parsers.transform.systemctocol.util.Timing;
import vct.parsers.transform.systemctocol.util.Seqs;
import java.util.HashMap;
import javax.lang.model.util.Elements.Origin;
import org.antlr.v4.runtime.*;
import vct.antlr4.generated.LangPSLParser;
import vct.antlr4.generated.LangPSLParserBaseVisitor;

class UnsupportedPSLException extends VerificationError.UserError {

        private final String text;

        public UnsupportedPSLException(String text) {
                this.text = text;
        }

        @Override
        public String text() {
                return "Unsupported operator: " + text;
        }

        @Override
        public String code() {
                return "Unsupported PSL Construct";
        }
}

class PSLFormatException extends VerificationError.SystemError {

        private final String text;

        public PSLFormatException(String text) {
                this.text = text;
        }

        @Override
        public String text() {
                return text;
        }

}

class PSLParseException extends VerificationError.UserError {
        private final String text;

        public PSLParseException(String text) {
                this.text = text;
        }

        @Override
        public String text() {
                return text;
        }

        @Override
        public String code() {
                return "PSL Parse Failure";
        }
}

class PSLTransformationException extends VerificationError.UserError {
        private final String text;

        public PSLTransformationException(String text) {
                this.text = text;
        }

        @Override
        public String text() {
                return text;
        }

        @Override
        public String code() {
                return "PSL Transformation Failure";
        }
}

public class PSLToColVisitor<T> extends LangPSLParserBaseVisitor<Expr<T>> {

        private final SCSystem sc_system;

        private final COLSystem<T> col_system;

        String current_module;

        java.util.Map<String, ProcessClass> processes = new HashMap<>();

        java.util.Map<String, Expr<T>> properties = new HashMap<>();

        java.util.List<Integer> event_indices;

        Ref<T, InstanceField<T>> event_state_ref;
        Deref<T> event_state_deref;
        Ref<T, InstanceField<T>> proc_state_ref;
        Deref<T> proc_state_deref;

        public PSLToColVisitor(SCSystem sc_system, COLSystem<T> col_system) {
                this.sc_system = sc_system;
                this.col_system = col_system;
                this.event_indices = new java.util.ArrayList<>();
                this.current_module = "";
                this.event_state_ref = new DirectRef<>(col_system.get_event_state(),
                                ClassTag$.MODULE$.apply(InstanceField.class));
                this.event_state_deref = new Deref<>(col_system.THIS, event_state_ref, new GeneratedBlame<>(),
                                OriGen.create());

                this.proc_state_ref = new DirectRef<>(col_system.get_process_state(),
                                ClassTag$.MODULE$.apply(InstanceField.class));
                this.proc_state_deref = new Deref<>(col_system.THIS, proc_state_ref, new GeneratedBlame<>(),
                                OriGen.create());
        }

        @Override
        public Expr<T> visitPsl_specification0(LangPSLParser.Psl_specification0Context ctx) {
                java.util.List<Expr<T>> verification_items = new java.util.ArrayList<>();
                for (LangPSLParser.Verification_itemContext verification_item : ctx.verification_item()) {
                        if (this.current_module == "Main") {
                                // Add to main
                        }
                        verification_items.add(visit(verification_item));
                }
                return col_system.fold_star(verification_items);
        }

        @Override
        public Expr<T> visitVerificationUnitVerificationItem(
                        LangPSLParser.VerificationUnitVerificationItemContext ctx) {
                Expr<T> result = null;
                try {
                        result = visit(ctx.verification_unit());
                } catch (Exception ignored) {
                        throw new PSLParseException("One or more PSL constructs could not be transformed!");
                }
                return result;
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
        public Expr<T> visitVunit_instance0(LangPSLParser.Vunit_instance0Context ctx) {
                return visitChildren(ctx);
        }

        @Override
        public Expr<T> visitHierarchical_hdl_name0(LangPSLParser.Hierarchical_hdl_name0Context ctx) {
                String bound_module = ctx.getText();
                if (bound_module != "Main") {
                        throw new IllegalArgumentException("Vunit has to be bound to Main Class!");
                }
                this.current_module = bound_module;
                return new StringValue<>(bound_module, OriGen.create());
        }

        @Override
        public Expr<T> visitPsl_directive0(LangPSLParser.Psl_directive0Context ctx) {
                return visit(ctx.verification_directive());
        }

        // ==============================================================================================================
        // verification_directive:
        // ==============================================================================================================

        @Override
        public Expr<T> visitAssumeDirectiveVerificationDirective(
                        LangPSLParser.AssumeDirectiveVerificationDirectiveContext ctx) {
                throw new UnsupportedPSLException("Verification Directive not supported: assume");
        }

        /*
         * @Override
         * public Expr<T> visitRestrictDirectiveVerificationDirective(
         * LangPSLParser.RestrictDirectiveVerificationDirectiveContext ctx) {
         * throw new
         * UnsupportedPSLException("Verification Directive not supported: restrict");
         * }
         * 
         * @Override
         * public Expr<T> visitRestrictStrongDirectiveVerificationDirective(
         * LangPSLParser.RestrictStrongDirectiveVerificationDirectiveContext ctx) {
         * throw new
         * UnsupportedPSLException("Verification Directive not supported: restrict!");
         * }
         * 
         * @Override
         * public Expr<T> visitCoverDirectiveVerificationDirective(
         * LangPSLParser.CoverDirectiveVerificationDirectiveContext ctx) {
         * throw new
         * UnsupportedPSLException("Verification Directive not supported: cover");
         * }
         */

        @Override
        public Expr<T> visitFairnessStatementVerificationDirective(
                        LangPSLParser.FairnessStatementVerificationDirectiveContext ctx) {
                throw new UnsupportedPSLException("Verification Directive not supported: fairness");
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
        /*
         * @Override
         * public Expr<T> visitReplicatorPropertyProperty(LangPSLParser.
         * ReplicatorPropertyPropertyContext ctx) {
         * throw new
         * PSLFormatException("Property not supported: Replicator Property");
         * }
         * 
         * @Override
         * public Expr<T>
         * visitObePropertyProperty(LangPSLParser.ObePropertyPropertyContext ctx) {
         * throw new PSLFormatException("Property not supported: OBE Property");
         * }
         */
        // ==============================================================================================================
        // ==============================================================================================================

        // hdl_or_psl_expression

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
        public Expr<T> visitBool_val0(LangPSLParser.Bool_val0Context ctx) {
                Expr<T> bool_expr = visit(ctx.hdl_or_psl_expression());
                if (true) {
                        // For CPP expressions here a check would be made if the expression is actually
                        // Boolean
                        // In our case we only allow a subset of Boolean expressions
                }
                return bool_expr;
        }

        // FL property

        @Override
        public Expr<T> visitParenFlProperty(LangPSLParser.ParenFlPropertyContext ctx) {
                return visit(ctx.fl_property());
        }

        @Override
        public Expr<T> visitAlwaysFlProperty(LangPSLParser.AlwaysFlPropertyContext ctx) {
                return visit(ctx.fl_property());
        }

        @Override
        public Expr<T> visitNeverFlProperty(LangPSLParser.NeverFlPropertyContext ctx) {
                return new Not<>(visit(ctx.fl_property()), OriGen.create());
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
                String right_property = ctx.fl_property(1).getText().replaceFirst("^\\(+", "");
                if (right_property.startsWith("within_t")) {
                        int val_idx = event_indices.size();
                        int e_idx = this.col_system.get_total_nr_events();
                        java.util.List<Expr<T>> expression = new java.util.ArrayList<>();
                        Expr<T> right = visit(ctx.fl_property(1));
                        IntegerValue<T> event_index = new IntegerValue<>(BigInt.apply(this.event_indices.get(val_idx)),
                                        OriGen.create());
                        Eq<T> equals = new Eq<>(getEventState(e_idx), event_index, OriGen.create());
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
                int newest_event_index = this.col_system.get_total_nr_events();
                col_system.add_wait_event(); // Add variable to each Class
                int event_value = 0;
                Expr<T> result = null;
                if (ctx.SC_ZERO_TIME() != null) {
                        event_value = -1;
                        result = new Eq<>(getEventState(newest_event_index), col_system.MINUS_TWO,
                                        OriGen.create());
                } else {
                        int within_value = Integer.parseInt(ctx.IntegerLiteral().getText());
                        if (within_value < 0) {
                                throw new PSLFormatException("Value for within_t operator may not be < 0!");
                        }
                        double relative_value = Timing.getTimeFactor(ctx.TIME_UNIT().getText());
                        event_value = (int) (within_value * relative_value);
                        result = new Greater<>(getEventState(newest_event_index), col_system.ZERO,
                                        OriGen.create());
                }
                this.event_indices.add(event_value);
                return new Implies<>(visit(ctx.fl_property()), result, OriGen.create());
        }

        // built_in_function_call

        @Override
        public Expr<T> visitActiveBuiltInFunctionCall(LangPSLParser.ActiveBuiltInFunctionCallContext ctx) {
                Expr<T> proc_id = visit(ctx.referenceExpr(0));
                Expr<T> event = visit(ctx.referenceExpr(1));
                SeqSubscript<T> proc_index = new SeqSubscript<>(proc_state_deref, proc_id, new GeneratedBlame<>(),
                                OriGen.create());
                Eq<T> process_state = new Eq<>(proc_index, col_system.MINUS_ONE, OriGen.create());
                return new And<>(process_state, event, OriGen.create());
        }

        @Override
        public Expr<T> visitReadyBuiltInFunctionCall(LangPSLParser.ReadyBuiltInFunctionCallContext ctx) {
                Expr<T> proc_id = visit(ctx.referenceExpr());
                SeqSubscript<T> proc_index = new SeqSubscript<>(proc_state_deref, proc_id, new GeneratedBlame<>(),
                                OriGen.create());

                return new Eq<>(proc_index, col_system.MINUS_ONE, OriGen.create());
        }

        @Override
        public Expr<T> visitWaitingBuiltInFunctionCall(LangPSLParser.WaitingBuiltInFunctionCallContext ctx) {
                Expr<T> proc_id = visit(ctx.referenceExpr());
                SeqSubscript<T> proc_index = new SeqSubscript<>(proc_state_deref, proc_id, new GeneratedBlame<>(),
                                OriGen.create());

                return new GreaterEq<>(proc_index, col_system.ZERO, OriGen.create());
        }

        @Override
        public Expr<T> visitEventBuiltInFunctionCall(LangPSLParser.EventBuiltInFunctionCallContext ctx) {
                String notification_type = ctx.event_operator().getText();
                Expr<T> result = visit(ctx.referenceExpr());
                switch (notification_type) {
                        case "notified_prev_delta":
                                result = new Eq<>(result, col_system.MINUS_TWO,
                                                OriGen.create());
                                break;
                        case "notified_delta":
                                result = new Eq<>(result, col_system.MINUS_ONE,
                                                OriGen.create());
                                break;
                        case "notified_timed":
                                result = new GreaterEq<>(result, col_system.ONE,
                                                OriGen.create());
                                break;
                        case "notified_untimed":
                                result = new Eq<>(result, col_system.ZERO,
                                                OriGen.create());
                                break;
                        case "not_notified":
                                result = new Eq<>(result, col_system.MINUS_THREE,
                                                OriGen.create());
                                break;
                        default:
                                break;
                }
                return result;
        }

        @Override
        public Expr<T> visitReferenceExpr0(LangPSLParser.ReferenceExpr0Context ctx) {
                String primary = ctx.referenceprimary().getText();
                SCClassInstance class_instance = this.sc_system.getInstanceByName(primary);
                if (class_instance == null) {
                        throw new PSLFormatException("Unknown Class instance: " + primary);
                }
                Object current = class_instance;
                Expr<T> result = null;
                for (LangPSLParser.ReferencePostfixExprContext rest : ctx.referencePostfixExpr()) {
                        if (rest instanceof LangPSLParser.RefIdentifierContext new_ctx) {
                                String field = new_ctx.clangppIdentifier().getText();
                                if (current instanceof SCClassInstance sci) {
                                        ProcessClass found_process = findProcess(field, col_system.get_processes(sci));
                                        SCVariable var = sci.getSCClass().getMemberByName(field);
                                        if (found_process != null) {
                                                current = found_process;
                                                result = new IntegerValue<>(
                                                                BigInt.apply(found_process.get_process_id()),
                                                                OriGen.create());
                                        } else if (var != null) {
                                                current = var;
                                                result = getFieldReference(sci, var);
                                        } else
                                                throw new PSLFormatException(
                                                                "Unknown Process or Variable: " + field);
                                } else if (current instanceof ProcessClass pc) {
                                        result = getProcessReference(pc);
                                        SCVariable var = pc.get_generating_function().getLocalVariable(field);
                                        if (var != null) {
                                                current = var;
                                                result = getFieldReference(pc.get_generating_instance(), var);
                                        }
                                } else
                                        throw new PSLFormatException("Unknown Process or Variable: " + field);

                        } else if (rest instanceof LangPSLParser.RefIndexContext new_ctx) {
                                String field = new_ctx.referenceIndex().getChild(1).getText();
                                String index = new_ctx.referenceIndex().getChild(3).getText();
                                Expr<T> index_expr = null;
                                if (current instanceof SCClassInstance sci) {
                                        SCVariable var = sci.getSCClass().getMemberByName(field);
                                        if (var != null) {
                                                index_expr = getFieldReference(sci, var);
                                        }
                                } else if (current instanceof ProcessClass pc) {
                                        SCVariable var = pc.get_generating_function().getLocalVariable(field);
                                        if (var != null) {
                                                index_expr = getFieldReference(pc.get_generating_instance(), var);
                                        }
                                } else
                                        throw new PSLFormatException("Unknown Process or Variable: " + field);
                                if (index_expr != null) {
                                        IntegerValue<T> var_index = new IntegerValue<>(
                                                        BigInt.apply(Integer.parseInt(index)),
                                                        OriGen.create());
                                        result = new SeqSubscript<>(index_expr, var_index,
                                                        new GeneratedBlame<>(),
                                                        OriGen.create());
                                }
                        } else if (rest instanceof LangPSLParser.RefMethodContext new_ctx) {
                                String event_type = new_ctx.referenceMethod().getChild(1).getText();
                                if (current instanceof SCClassInstance sci) {
                                        java.util.List<Integer> events = this.col_system
                                                        .get_channel_events((SCKnownType) sci);
                                        switch (event_type) {
                                                case "data_read_event":
                                                        result = getEventState(events.get(0));
                                                        break;
                                                case "data_written_event":
                                                        result = getEventState(events.get(1));
                                                        break;
                                                case "written":
                                                        InstanceField<T> wri_if = col_system
                                                                        .get_primitive_instance_field((SCKnownType) sci,
                                                                                        2);
                                                        Expr<T> write_ref = getChannelFieldReference((SCKnownType) sci,
                                                                        wri_if);
                                                        Size<T> size = new Size<>(write_ref, OriGen.create());
                                                        result = new Eq<>(size,
                                                                        new IntegerValue<>(BigInt.apply(1),
                                                                                        OriGen.create()),
                                                                        OriGen.create());
                                                        break;
                                                case "read":
                                                        InstanceField<T> read_if = col_system
                                                                        .get_primitive_instance_field((SCKnownType) sci,
                                                                                        1);
                                                        Expr<T> read_ref = getChannelFieldReference((SCKnownType) sci,
                                                                        read_if);
                                                        result = new Eq<>(read_ref,
                                                                        new IntegerValue<>(BigInt.apply(1),
                                                                                        OriGen.create()),
                                                                        OriGen.create());
                                                        break;
                                                default:
                                                        throw new PSLFormatException(
                                                                        "Unknown event:" + event_type);
                                        }
                                } else if (current instanceof ProcessClass pc) {
                                        switch (event_type) {
                                                case "wait_event":
                                                        result = getEventState(
                                                                        this.col_system.get_nr_primitive_channels() * 2
                                                                                        + pc.get_process_id());
                                                        break;
                                                default:
                                                        throw new PSLFormatException(
                                                                        "Unknown event:" + event_type);
                                        }
                                }
                        }
                }
                if (result == null) {
                        throw new PSLFormatException(
                                        "Referring to just the class instance \"" + primary + "\" is not allowed!");
                }
                return result;
        }

        @Override
        public Expr<T> visitHdl_expressions0(LangPSLParser.Hdl_expressions0Context ctx) {
                Expr<T> op = null;
                Expr<T> left = visit(ctx.referenceExpr(0));
                Expr<T> right = visit(ctx.referenceExpr(1));
                switch (ctx.hdl_operator().getText()) {
                        case "==":
                                op = new Eq<>(left, right, OriGen.create());
                                break;
                        case ">=":
                                op = new GreaterEq<>(left, right, OriGen.create());
                                break;
                        case "<=":
                                op = new LessEq<>(left, right, OriGen.create());
                                break;
                        case ">":
                                op = new Greater<>(left, right, OriGen.create());
                                break;
                        case "<":
                                op = new Less<>(left, right, OriGen.create());
                                break;
                        default:
                                break;
                }
                return op;
        }

        // Helper methods

        /**
         * Returns reference to event_state[index]
         * 
         * @param index
         * @return reference to event_state[index]
         */
        private Expr<T> getEventState(int index) {
                IntegerValue<T> event_id = new IntegerValue<>(BigInt.apply(index),
                                OriGen.create());
                SeqSubscript<T> proc_i = new SeqSubscript<>(event_state_deref, event_id, new GeneratedBlame<>(),
                                OriGen.create());
                return proc_i;
        }

        /**
         * Returns the process, if its name is recognised, otherwise an exception is
         * thrown
         * 
         * @param proc_name
         * @param processes
         * @return process, which conforms to the given name, otherwise throws Exception
         * @throws IllegalArgumentException
         */
        private ProcessClass findProcess(String proc_name, java.util.List<ProcessClass> processes)
                        throws IllegalArgumentException {
                for (ProcessClass proc : processes) {
                        if (proc.get_generating_function().getName().equals(proc_name)) {
                                return proc;
                        }
                }
                throw new PSLFormatException("Unknown process: " + proc_name);
        }

        /**
         * Returns the field reference to the corresponding SCVariable and
         * SCClassinstance
         * 
         * @param class_instance
         * @param var
         * @return field reference to SCClassinstance.SCVariable
         */
        private Expr<T> getFieldReference(SCClassInstance class_instance, SCVariable var) {
                // Get field and COLClass
                InstanceField<T> f_field = this.col_system.get_instance_field(class_instance, var);
                COLClass col_class = this.col_system.get_containing_class(f_field);
                // Get reference to the field instance
                InstanceField<T> sci_field = this.col_system.get_instance_by_class(col_class);
                Ref<T, InstanceField<T>> field_ref = new DirectRef<>(sci_field,
                                ClassTag$.MODULE$.apply(InstanceField.class));
                Deref<T> field_deref = new Deref<>(col_system.THIS, field_ref, new GeneratedBlame<>(), OriGen.create());

                // Get references to the field
                Ref<T, InstanceField<T>> f_field_ref = new DirectRef<>(f_field,
                                ClassTag$.MODULE$.apply(InstanceField.class));
                Deref<T> f_field_deref = new Deref<>(field_deref, f_field_ref, new GeneratedBlame<>(), OriGen.create());

                return f_field_deref;
        }

        /**
         * Returns the field reference to the corresponding ProcessClass and
         * SCClassinstance
         * 
         * @param class_instance
         * @param proc
         * @return field reference to SCClassinstance.SCVariable
         */
        private Expr<T> getProcessReference(ProcessClass proc) {
                InstanceField<T> sci_field = this.col_system.get_instance_by_class(proc);
                Ref<T, InstanceField<T>> field_ref = new DirectRef<>(sci_field,
                                ClassTag$.MODULE$.apply(InstanceField.class));
                Deref<T> field_deref = new Deref<>(col_system.THIS, field_ref, new GeneratedBlame<>(), OriGen.create());
                return field_deref;
        }

        /**
         * Gets the reference to the corresponding channel
         * 
         * @param sc_inst Channel SCClassinstance
         * @param f_field Variable referencing the channel
         * @return field reference to channel.f_field
         */
        private Expr<T> getChannelFieldReference(SCKnownType sc_inst, InstanceField<T> f_field) {
                // Get field and COLClass
                COLClass col_class = this.col_system.get_containing_class(f_field);

                // Get reference to the field instance
                InstanceField<T> sci_field = this.col_system.get_primitive_channel(sc_inst);
                Ref<T, InstanceField<T>> field_ref = new DirectRef<>(sci_field,
                                ClassTag$.MODULE$.apply(InstanceField.class));
                Deref<T> field_deref = new Deref<>(col_system.THIS, field_ref, new GeneratedBlame<>(), OriGen.create());

                // Get references to the field
                Ref<T, InstanceField<T>> f_field_ref = new DirectRef<>(f_field,
                                ClassTag$.MODULE$.apply(InstanceField.class));
                Deref<T> f_field_deref = new Deref<>(field_deref, f_field_ref, new GeneratedBlame<>(), OriGen.create());

                return f_field_deref;
        }
}