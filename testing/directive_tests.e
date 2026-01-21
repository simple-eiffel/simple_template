note
	description: "Tests for template directive system (#if, #foreach, #across)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DIRECTIVE_TESTS

create
	make

feature {NONE} -- Initialization

	make
			-- Create and initialize tests.
		do
			create context.make
			create parser.make
		end

feature -- Access

	context: ST_CONTEXT
	parser: ST_DIRECTIVE_PARSER

feature -- If Directive Tests

	test_if_true_condition
			-- Test #if with true condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("show", True)
			l_directive := parser.parse_if ("#if show then%NVisible content%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NVisible content%N") end
			end
		end

	test_if_false_condition
			-- Test #if with false condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("show", False)
			l_directive := parser.parse_if ("#if show then%NVisible content%N#end")

			check attached l_directive as d then
				check d.execute (context).is_empty end
			end
		end

	test_if_else_true
			-- Test #if...#else with true condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("logged_in", True)
			l_directive := parser.parse_if ("#if logged_in then%NWelcome!%N#else%NPlease login%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NWelcome!%N") end
			end
		end

	test_if_else_false
			-- Test #if...#else with false condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("logged_in", False)
			l_directive := parser.parse_if ("#if logged_in then%NWelcome!%N#else%NPlease login%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NPlease login%N") end
			end
		end

	test_if_comparison_equal
			-- Test #if with equality comparison
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("status", "active")
			l_directive := parser.parse_if ("#if status = %"active%" then%NYES%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NYES%N") end
			end
		end

	test_if_comparison_numeric
			-- Test #if with numeric comparison
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("count", 10)
			l_directive := parser.parse_if ("#if count > 5 then%NBIG%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NBIG%N") end
			end
		end

	test_if_boolean_and
			-- Test #if with AND operator
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("a", True)
			context.set_variable ("b", True)
			l_directive := parser.parse_if ("#if a and b then%NBOTH%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NBOTH%N") end
			end
		end

	test_if_boolean_or
			-- Test #if with OR operator
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("a", False)
			context.set_variable ("b", True)
			l_directive := parser.parse_if ("#if a or b then%NONE%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NONE%N") end
			end
		end

	test_if_boolean_not
			-- Test #if with NOT operator
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("hidden", False)
			l_directive := parser.parse_if ("#if not hidden then%NSHOWN%N#end")

			check attached l_directive as d then
				check d.execute (context).same_string ("%NSHOWN%N") end
			end
		end

feature -- Foreach Directive Tests

	test_foreach_basic
			-- Test #foreach basic iteration
		local
			l_directive: detachable ST_FOREACH_DIRECTIVE
			l_items: ARRAYED_LIST [STRING]
		do
			create l_items.make (3)
			l_items.extend ("apple")
			l_items.extend ("banana")
			l_items.extend ("cherry")
			context.set_list ("fruits", l_items)

			l_directive := parser.parse_foreach ("#foreach $item in $fruits loop%N- $item%N#end")

			check attached l_directive as d then
				check d.execute (context).has_substring ("apple") end
				check d.execute (context).has_substring ("banana") end
				check d.execute (context).has_substring ("cherry") end
			end
		end

	test_foreach_with_index
			-- Test #foreach with loop_index variable
		local
			l_directive: detachable ST_FOREACH_DIRECTIVE
			l_items: ARRAYED_LIST [STRING]
			l_result: STRING
		do
			create l_items.make (3)
			l_items.extend ("A")
			l_items.extend ("B")
			l_items.extend ("C")
			context.set_list ("letters", l_items)

			l_directive := parser.parse_foreach ("#foreach $item in $letters loop%N$loop_index. $item%N#end")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.has_substring ("1. A") end
				check l_result.has_substring ("2. B") end
				check l_result.has_substring ("3. C") end
			end
		end

	test_foreach_empty_list
			-- Test #foreach with empty list
		local
			l_directive: detachable ST_FOREACH_DIRECTIVE
			l_items: ARRAYED_LIST [STRING]
		do
			create l_items.make (0)
			context.set_list ("items", l_items)

			l_directive := parser.parse_foreach ("#foreach $item in $items loop%NItem: $item%N#end")

			check attached l_directive as d then
				check d.execute (context).is_empty end
			end
		end

feature -- Across Directive Tests

	test_across_basic
			-- Test #across basic iteration
		local
			l_directive: detachable ST_ACROSS_DIRECTIVE
			l_items: ARRAYED_LIST [INTEGER]
			l_result: STRING
		do
			create l_items.make (3)
			l_items.extend (10)
			l_items.extend (20)
			l_items.extend (30)
			context.set_list ("numbers", l_items)

			l_directive := parser.parse_across ("#across $numbers as $n loop%NValue: $n%N#end")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.has_substring ("10") end
				check l_result.has_substring ("20") end
				check l_result.has_substring ("30") end
			end
		end

	test_across_with_cursor_index
			-- Test #across with cursor_index
		local
			l_directive: detachable ST_ACROSS_DIRECTIVE
			l_items: ARRAYED_LIST [STRING]
			l_result: STRING
		do
			create l_items.make (2)
			l_items.extend ("X")
			l_items.extend ("Y")
			context.set_list ("chars", l_items)

			l_directive := parser.parse_across ("#across $chars as $c loop%N[$cursor_index] $c%N#end")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.has_substring ("[1] X") end
				check l_result.has_substring ("[2] Y") end
			end
		end

feature -- Context Tests

	test_context_boolean_evaluation
			-- Test boolean evaluation rules
		do
			-- Void is falsy
			check not context.is_truthy (Void) end

			-- Boolean values
			check context.is_truthy (True) end
			check not context.is_truthy (False) end

			-- Strings
			check context.is_truthy ("hello") end
			check not context.is_truthy ("") end

			-- Integers
			check context.is_truthy (42) end
			check not context.is_truthy (0) end
		end

	test_context_expression_evaluation
			-- Test expression evaluation
		do
			context.set_variable ("x", 5)
			context.set_variable ("y", 10)
			context.set_variable ("name", "test")

			-- Comparisons
			check context.evaluate_boolean ("x < y") end
			check not context.evaluate_boolean ("x > y") end
			check context.evaluate_boolean ("x = 5") end
			check context.evaluate_boolean ("name = %"test%"") end
		end

feature -- Parser Error Tests

	test_parser_missing_then
			-- Test parser detects missing 'then'
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			l_directive := parser.parse_if ("#if condition%Ncontent%N#end")

			check l_directive = Void end
			check parser.has_error end
			check parser.last_error.has_substring ("then") end
		end

	test_parser_missing_end
			-- Test parser detects missing #end
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			l_directive := parser.parse_if ("#if condition then%Ncontent")

			check l_directive = Void end
			check parser.has_error end
			check parser.last_error.has_substring ("#end") end
		end

	test_parser_has_directive
			-- Test directive detection
		do
			check parser.has_directive ("Hello #if x then y #end") end
			check parser.has_directive ("#foreach $i in $list loop x #end") end
			check parser.has_directive ("#across $x as $y loop z #end") end
			check parser.has_directive ("#include %"file.txt%"") end
			check parser.has_directive ("#evaluate $template") end
			check not parser.has_directive ("Hello {{name}}") end
		end

feature -- Include Directive Tests

	test_include_parse_literal_path
			-- Test parsing #include with literal path
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include %"templates/header.txt%"")

			check attached l_directive as d then
				check d.path_expression.same_string ("%"templates/header.txt%"") end
			end
		end

	test_include_parse_variable_path
			-- Test parsing #include with variable path
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include $template_path")

			check attached l_directive as d then
				check d.path_expression.same_string ("$template_path") end
			end
		end

	test_include_path_traversal_blocked
			-- Test that path traversal is blocked
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
			l_result: STRING
		do
			l_directive := parser.parse_include ("#include %"../../../etc/passwd%"")

			check attached l_directive as d then
				l_result := d.execute (context)
				-- Should return empty due to path traversal attempt
				check l_result.is_empty end
			end
		end

	test_include_absolute_path_blocked
			-- Test that absolute paths are blocked
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
			l_result: STRING
		do
			l_directive := parser.parse_include ("#include %"/etc/passwd%"")

			check attached l_directive as d then
				l_result := d.execute (context)
				-- Should return empty due to absolute path
				check l_result.is_empty end
			end
		end

feature -- Evaluate Directive Tests

	test_evaluate_parse_variable
			-- Test parsing #evaluate with variable
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
		do
			l_directive := parser.parse_evaluate ("#evaluate $template_text")

			check attached l_directive as d then
				check d.expression.same_string ("$template_text") end
			end
		end

	test_evaluate_basic
			-- Test basic #evaluate execution
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
			l_result: STRING
		do
			-- Set a template in a variable
			context.set_variable ("tpl", "Hello {{name}}!")
			context.set_variable ("name", "World")

			l_directive := parser.parse_evaluate ("#evaluate $tpl")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.same_string ("Hello World!") end
			end
		end

	test_evaluate_empty_variable
			-- Test #evaluate with undefined variable
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
			l_result: STRING
		do
			l_directive := parser.parse_evaluate ("#evaluate $undefined_var")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.is_empty end
			end
		end

	test_evaluate_literal_template
			-- Test #evaluate with literal template
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
			l_result: STRING
		do
			context.set_variable ("x", "42")

			l_directive := parser.parse_evaluate ("#evaluate %"Value: {{x}}%"")

			check attached l_directive as d then
				l_result := d.execute (context)
				check l_result.same_string ("Value: 42") end
			end
		end

feature -- Expression Evaluator Tests

	test_expr_math_add
			-- Test addition expression
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("a", "10")
			context.set_variable ("b", "5")
			l_result := eval.evaluate ("a + b", context)
			check l_result.same_string ("15") end
		end

	test_expr_math_subtract
			-- Test subtraction expression
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("x", "20")
			l_result := eval.evaluate ("x - 8", context)
			check l_result.same_string ("12") end
		end

	test_expr_math_multiply
			-- Test multiplication expression
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("n", "7")
			l_result := eval.evaluate ("n * 3", context)
			check l_result.same_string ("21") end
		end

	test_expr_math_divide
			-- Test division expression
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("total", "100")
			l_result := eval.evaluate ("total / 4", context)
			check l_result.has_substring ("25") end
		end

	test_filter_upper
			-- Test upper filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("name", "hello")
			l_result := eval.evaluate ("name | upper", context)
			check l_result.same_string ("HELLO") end
		end

	test_filter_lower
			-- Test lower filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("name", "WORLD")
			l_result := eval.evaluate ("name | lower", context)
			check l_result.same_string ("world") end
		end

	test_filter_capitalize
			-- Test capitalize filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("word", "test")
			l_result := eval.evaluate ("word | capitalize", context)
			check l_result.same_string ("Test") end
		end

	test_filter_length
			-- Test length filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("text", "hello")
			l_result := eval.evaluate ("text | length", context)
			check l_result.same_string ("5") end
		end

	test_filter_default
			-- Test default filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			-- Empty variable with default
			l_result := eval.evaluate ("missing | default:N/A", context)
			check l_result.same_string ("N/A") end

			-- Non-empty variable ignores default
			context.set_variable ("present", "value")
			l_result := eval.evaluate ("present | default:N/A", context)
			check l_result.same_string ("value") end
		end

	test_filter_truncate
			-- Test truncate filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("long", "This is a very long string")
			l_result := eval.evaluate ("long | truncate:10", context)
			check l_result.same_string ("This is a ...") end
		end

	test_filter_chain
			-- Test chaining multiple filters
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("name", "  hello world  ")
			l_result := eval.evaluate ("name | trim | upper", context)
			check l_result.same_string ("HELLO WORLD") end
		end

	test_filter_reverse
			-- Test reverse filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("str", "abc")
			l_result := eval.evaluate ("str | reverse", context)
			check l_result.same_string ("cba") end
		end

	test_filter_abs
			-- Test abs filter
		local
			eval: ST_EXPRESSION_EVALUATOR
			l_result: STRING
		do
			create eval.make
			context.set_variable ("num", "-42")
			l_result := eval.evaluate ("num | abs", context)
			check l_result.same_string ("42") end
		end

feature -- Error Collector Tests

	test_error_collector_basic
			-- Test error collector
		local
			collector: ST_ERROR_COLLECTOR
		do
			create collector.make
			check not collector.has_errors end

			collector.add_error ("E001", "Test error")
			check collector.has_errors end
			check collector.error_count = 1 end

			collector.add_warning ("W001", "Test warning")
			check collector.has_warnings end
		end

	test_error_with_location
			-- Test error with location information
		local
			err: ST_TEMPLATE_ERROR
			l_str: STRING
		do
			create err.make_with_location ("SYNTAX", "Unclosed tag", 10, 5, "{{name")
			check err.has_location end
			l_str := err.to_string
			check l_str.has_substring ("line 10") end
			check l_str.has_substring ("SYNTAX") end
		end

end
