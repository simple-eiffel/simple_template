note
	description: "Tests for template directive system (#if, #foreach, #across)"
	author: "Larry Rix"
	testing: "type/manual"

class
	DIRECTIVE_TESTS

inherit
	TEST_SET_BASE

feature -- Access

	context: ST_CONTEXT
		once
			create Result.make
		end

	parser: ST_DIRECTIVE_PARSER
		once
			create Result.make
		end

feature -- If Directive Tests

	test_if_true_condition
			-- Test #if with true condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("show", True)
			l_directive := parser.parse_if ("#if show then%NVisible content%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("visible", "%NVisible content%N", d.execute (context))
			end
		end

	test_if_false_condition
			-- Test #if with false condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("show", False)
			l_directive := parser.parse_if ("#if show then%NVisible content%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_true ("empty result", d.execute (context).is_empty)
			end
		end

	test_if_else_true
			-- Test #if...#else with true condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("logged_in", True)
			l_directive := parser.parse_if ("#if logged_in then%NWelcome!%N#else%NPlease login%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("welcome", "%NWelcome!%N", d.execute (context))
			end
		end

	test_if_else_false
			-- Test #if...#else with false condition
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("logged_in", False)
			l_directive := parser.parse_if ("#if logged_in then%NWelcome!%N#else%NPlease login%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("login", "%NPlease login%N", d.execute (context))
			end
		end

	test_if_comparison_equal
			-- Test #if with equality comparison
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("status", "active")
			l_directive := parser.parse_if ("#if status = %"active%" then%NYES%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("yes", "%NYES%N", d.execute (context))
			end
		end

	test_if_comparison_numeric
			-- Test #if with numeric comparison
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("count", 10)
			l_directive := parser.parse_if ("#if count > 5 then%NBIG%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("big", "%NBIG%N", d.execute (context))
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("both", "%NBOTH%N", d.execute (context))
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("one", "%NONE%N", d.execute (context))
			end
		end

	test_if_boolean_not
			-- Test #if with NOT operator
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			context.set_variable ("hidden", False)
			l_directive := parser.parse_if ("#if not hidden then%NSHOWN%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("shown", "%NSHOWN%N", d.execute (context))
			end
		end

feature -- Foreach Directive Tests

	test_foreach_basic
			-- Test #foreach basic iteration
		local
			l_directive: detachable ST_FOREACH_DIRECTIVE
			l_items: ARRAYED_LIST [STRING]
			l_result: STRING
		do
			create l_items.make (3)
			l_items.extend ("apple")
			l_items.extend ("banana")
			l_items.extend ("cherry")
			context.set_list ("fruits", l_items)
			l_directive := parser.parse_foreach ("#foreach $item in $fruits loop%N- $item%N#end")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (context)
				assert ("has apple", l_result.has_substring ("apple"))
				assert ("has banana", l_result.has_substring ("banana"))
				assert ("has cherry", l_result.has_substring ("cherry"))
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (context)
				assert ("has 1 A", l_result.has_substring ("1. A"))
				assert ("has 2 B", l_result.has_substring ("2. B"))
				assert ("has 3 C", l_result.has_substring ("3. C"))
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_true ("empty result", d.execute (context).is_empty)
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (context)
				assert ("has 10", l_result.has_substring ("10"))
				assert ("has 20", l_result.has_substring ("20"))
				assert ("has 30", l_result.has_substring ("30"))
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
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (context)
				assert ("has 1 X", l_result.has_substring ("[1] X"))
				assert ("has 2 Y", l_result.has_substring ("[2] Y"))
			end
		end

feature -- Context Tests

	test_context_boolean_evaluation
			-- Test boolean evaluation rules
		do
			assert_false ("void is falsy", context.is_truthy (Void))
			assert_true ("true is truthy", context.is_truthy (True))
			assert_false ("false is falsy", context.is_truthy (False))
			assert_true ("string is truthy", context.is_truthy ("hello"))
			assert_false ("empty string is falsy", context.is_truthy (""))
			assert_true ("integer is truthy", context.is_truthy (42))
			assert_false ("zero is falsy", context.is_truthy (0))
		end

	test_context_expression_evaluation
			-- Test expression evaluation
		do
			context.set_variable ("x", 5)
			context.set_variable ("y", 10)
			context.set_variable ("name", "test")
			assert_true ("x < y", context.evaluate_boolean ("x < y"))
			assert_false ("x > y", context.evaluate_boolean ("x > y"))
			assert_true ("x = 5", context.evaluate_boolean ("x = 5"))
			assert_true ("name = test", context.evaluate_boolean ("name = %"test%""))
		end

feature -- Parser Error Tests

	test_parser_missing_then
			-- Test parser detects missing 'then'
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			l_directive := parser.parse_if ("#if condition%Ncontent%N#end")
			assert ("no directive", l_directive = Void)
			assert_true ("has error", parser.has_error)
			assert ("error mentions then", parser.last_error.has_substring ("then"))
		end

	test_parser_missing_end
			-- Test parser detects missing #end
		local
			l_directive: detachable ST_IF_DIRECTIVE
		do
			l_directive := parser.parse_if ("#if condition then%Ncontent")
			assert ("no directive", l_directive = Void)
			assert_true ("has error", parser.has_error)
			assert ("error mentions end", parser.last_error.has_substring ("#end"))
		end

	test_parser_has_directive
			-- Test directive detection
		do
			assert_true ("has if", parser.has_directive ("Hello #if x then y #end"))
			assert_true ("has foreach", parser.has_directive ("#foreach $i in $list loop x #end"))
			assert_true ("has across", parser.has_directive ("#across $x as $y loop z #end"))
			assert_true ("has include", parser.has_directive ("#include %"file.txt%""))
			assert_true ("has evaluate", parser.has_directive ("#evaluate $template"))
			assert_false ("no directive", parser.has_directive ("Hello {{name}}"))
		end

feature -- Include Directive Tests

	test_include_parse_literal_path
			-- Test parsing #include with literal path
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include %"templates/header.txt%"")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("path", "%"templates/header.txt%"", d.path_expression)
			end
		end

	test_include_parse_variable_path
			-- Test parsing #include with variable path
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include $template_path")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("path", "$template_path", d.path_expression)
			end
		end

	test_include_path_traversal_blocked
			-- Test that path traversal is blocked
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include %"../../../etc/passwd%"")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_true ("empty result", d.execute (context).is_empty)
			end
		end

	test_include_absolute_path_blocked
			-- Test that absolute paths are blocked
		local
			l_directive: detachable ST_INCLUDE_DIRECTIVE
		do
			l_directive := parser.parse_include ("#include %"/etc/passwd%"")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_true ("empty result", d.execute (context).is_empty)
			end
		end

feature -- Evaluate Directive Tests

	test_evaluate_parse_variable
			-- Test parsing #evaluate with variable
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
		do
			l_directive := parser.parse_evaluate ("#evaluate $template_text")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("expression", "$template_text", d.expression)
			end
		end

	test_evaluate_basic
			-- Test basic #evaluate execution
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
		do
			context.set_variable ("tpl", "Hello {{name}}!")
			context.set_variable ("name", "World")
			l_directive := parser.parse_evaluate ("#evaluate $tpl")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("result", "Hello World!", d.execute (context))
			end
		end

	test_evaluate_empty_variable
			-- Test #evaluate with undefined variable
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
		do
			l_directive := parser.parse_evaluate ("#evaluate $undefined_var")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_true ("empty result", d.execute (context).is_empty)
			end
		end

	test_evaluate_literal_template
			-- Test #evaluate with literal template
		local
			l_directive: detachable ST_EVALUATE_DIRECTIVE
		do
			context.set_variable ("x", "42")
			l_directive := parser.parse_evaluate ("#evaluate %"Value: {{x}}%"")
			assert ("directive parsed", attached l_directive)
			if attached l_directive as d then
				assert_strings_equal ("result", "Value: 42", d.execute (context))
			end
		end

feature -- Expression Evaluator Tests

	test_expr_math_add
			-- Test addition expression
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("a", "10")
			context.set_variable ("b", "5")
			assert_strings_equal ("sum", "15", eval.evaluate ("a + b", context))
		end

	test_expr_math_subtract
			-- Test subtraction expression
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("x", "20")
			assert_strings_equal ("diff", "12", eval.evaluate ("x - 8", context))
		end

	test_expr_math_multiply
			-- Test multiplication expression
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("n", "7")
			assert_strings_equal ("product", "21", eval.evaluate ("n * 3", context))
		end

	test_expr_math_divide
			-- Test division expression
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("total", "100")
			assert ("quotient", eval.evaluate ("total / 4", context).has_substring ("25"))
		end

	test_filter_upper
			-- Test upper filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("name", "hello")
			assert_strings_equal ("upper", "HELLO", eval.evaluate ("name | upper", context))
		end

	test_filter_lower
			-- Test lower filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("name", "WORLD")
			assert_strings_equal ("lower", "world", eval.evaluate ("name | lower", context))
		end

	test_filter_capitalize
			-- Test capitalize filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("word", "test")
			assert_strings_equal ("capitalize", "Test", eval.evaluate ("word | capitalize", context))
		end

	test_filter_length
			-- Test length filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("text", "hello")
			assert_strings_equal ("length", "5", eval.evaluate ("text | length", context))
		end

	test_filter_default
			-- Test default filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			assert_strings_equal ("default used", "N/A", eval.evaluate ("missing | default:N/A", context))
			context.set_variable ("present", "value")
			assert_strings_equal ("default ignored", "value", eval.evaluate ("present | default:N/A", context))
		end

	test_filter_truncate
			-- Test truncate filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("long", "This is a very long string")
			assert_strings_equal ("truncated", "This is a ...", eval.evaluate ("long | truncate:10", context))
		end

	test_filter_chain
			-- Test chaining multiple filters
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("name", "  hello world  ")
			assert_strings_equal ("chained", "HELLO WORLD", eval.evaluate ("name | trim | upper", context))
		end

	test_filter_reverse
			-- Test reverse filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("str", "abc")
			assert_strings_equal ("reversed", "cba", eval.evaluate ("str | reverse", context))
		end

	test_filter_abs
			-- Test abs filter
		local
			eval: ST_EXPRESSION_EVALUATOR
		do
			create eval.make
			context.set_variable ("num", "-42")
			assert_strings_equal ("absolute", "42", eval.evaluate ("num | abs", context))
		end

feature -- Error Collector Tests

	test_error_collector_basic
			-- Test error collector
		local
			collector: ST_ERROR_COLLECTOR
		do
			create collector.make
			assert_false ("no errors", collector.has_errors)
			collector.add_error ("E001", "Test error")
			assert_true ("has errors", collector.has_errors)
			assert_integers_equal ("count", 1, collector.error_count)
			collector.add_warning ("W001", "Test warning")
			assert_true ("has warnings", collector.has_warnings)
		end

	test_error_with_location
			-- Test error with location information
		local
			err: ST_TEMPLATE_ERROR
			l_str: STRING
		do
			create err.make_with_location ("SYNTAX", "Unclosed tag", 10, 5, "{{name")
			assert_true ("has location", err.has_location)
			l_str := err.to_string
			assert ("has line", l_str.has_substring ("line 10"))
			assert ("has code", l_str.has_substring ("SYNTAX"))
		end

end
