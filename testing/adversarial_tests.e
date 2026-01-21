note
	description: "Adversarial tests for simple_template - designed to break things"
	date: "2026-01-18"

class
	ADVERSARIAL_TESTS

create
	make

feature {NONE} -- Initialization

	make
		do
			passed := 0
			failed := 0
			risk := 0
		end

feature -- Counters

	passed, failed, risk: INTEGER

feature -- V11: Stale Error Tests

	test_v11_stale_error_after_partial_depth
			-- V11: Error persists after successful render.
			-- BUG: Once last_error is set, it should clear on next successful render.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_partial: SIMPLE_TEMPLATE
		do
			-- Create template with circular partial (will set error)
			create l_tpl.make_from_string ("{{>circular}}")
			create l_partial.make_from_string ("{{>circular}}")
			l_tpl.register_partial ("circular", l_partial)
			l_partial.register_partial ("circular", l_partial)

			-- This render will exceed partial depth and set last_error
			l_tpl.render.do_nothing

			if not l_tpl.is_valid then
				-- Good, error was set. Now the bug test:
				-- Set a simple template with NO error-producing content
				l_tpl := l_tpl -- Can't change template_source directly, create new
				create l_tpl.make_from_string ("Simple text")
				l_tpl.render.do_nothing

				if l_tpl.is_valid then
					passed := passed + 1
					print ("  PASS: test_v11_stale_error_after_partial_depth%N")
				else
					-- BUG! Error persisted from previous render
					failed := failed + 1
					print ("  FAIL: test_v11_stale_error_after_partial_depth - stale error persists%N")
				end
			else
				risk := risk + 1
				print ("  RISK: test_v11_stale_error_after_partial_depth - partial depth not triggered%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_v11_stale_error_after_partial_depth - exception%N")
			passed := passed -- Keep for retry safety
		end

	test_v11_error_cleared_on_empty_template
			-- V11: Empty template render should have is_valid = True.
			-- Assault postcondition: error_cleared_on_empty.
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			create l_tpl.make
			-- Empty template_source from make
			l_tpl.render.do_nothing

			if l_tpl.is_valid then
				passed := passed + 1
				print ("  PASS: test_v11_error_cleared_on_empty_template%N")
			else
				failed := failed + 1
				print ("  FAIL: test_v11_error_cleared_on_empty_template - empty has error%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_v11_error_cleared_on_empty_template - exception%N")
		end

feature -- V08: Empty Variable Name Tests

	test_v08_empty_variable_name_in_template
			-- V08: Template {{}} has empty variable name.
			-- Should trigger get_variable precondition: name_not_empty.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_string ("Hello {{}} World")
				l_result := l_tpl.render
				-- If we get here, the precondition didn't fire
				risk := risk + 1
				print ("  RISK: test_v08_empty_variable_name - no precondition fired, got: " + l_result + "%N")
			end
		rescue
			-- Expected: precondition violation
			passed := passed + 1
			print ("  PASS: test_v08_empty_variable_name_in_template - precondition caught empty name%N")
			l_retried := True
			retry
		end

feature -- V09: Empty Section Name Tests

	test_v09_empty_section_name_in_template
			-- V09: Template {{#}}content{{/}} has empty section name.
			-- Should trigger is_section_truthy precondition: name_not_empty.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_string ("{{#}}content{{/}}")
				l_result := l_tpl.render
				risk := risk + 1
				print ("  RISK: test_v09_empty_section_name - no precondition fired, got: " + l_result + "%N")
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_v09_empty_section_name_in_template - precondition caught empty section%N")
			l_retried := True
			retry
		end

feature -- V10: Partial State Pollution Tests

	test_v10_partial_variables_not_modified
			-- V10: Partial should not have extra variables after render.
		local
			l_parent: SIMPLE_TEMPLATE
			l_partial: SIMPLE_TEMPLATE
			l_partial_vars_before: INTEGER
			l_partial_vars_after: INTEGER
		do
			-- Create partial with NO variables
			create l_partial.make_from_string ("Partial content: {{passed_var}}")
			l_partial_vars_before := 0 -- Partial starts with no variables

			-- Create parent that passes variable to partial
			create l_parent.make_from_string ("Before {{>child}} After")
			l_parent.register_partial ("child", l_partial)
			l_parent.set_variable ("passed_var", "VALUE")

			-- Render parent (this passes variables to partial)
			l_parent.render.do_nothing

			-- Check if partial now has variables it shouldn't have
			if l_partial.has_variable ("passed_var") then
				-- BUG! Partial state was polluted
				failed := failed + 1
				print ("  FAIL: test_v10_partial_variables_not_modified - partial state polluted%N")
			else
				passed := passed + 1
				print ("  PASS: test_v10_partial_variables_not_modified%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_v10_partial_variables_not_modified - exception%N")
		end

feature -- M06: Mutation Killer Tests

	test_m06_partial_depth_exactly_at_limit
			-- M06 Mutation Killer: Test exact boundary at Max_partial_depth (100).
			-- Kills mutation: >= to > in partial depth check.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_partials: ARRAY [detachable SIMPLE_TEMPLATE]
			l_partial: SIMPLE_TEMPLATE
			l_result: STRING
			i: INTEGER
		do
			-- Create chain of exactly 100 partials (at limit, should trigger error)
			-- Partial 1..99 call the next, partial 100 tries to call partial 101 (doesn't exist)
			-- The chain is: tpl -> p1 -> p2 -> ... -> p99 -> p100
			-- At depth 100, we should get error

			create l_partials.make_filled (Void, 1, 101)

			-- Create partials 1-100, each calling the next
			from i := 1 until i > 100 loop
				create l_partial.make_from_string ("D" + i.out + "{{>p" + (i + 1).out + "}}")
				l_partials[i] := l_partial
				i := i + 1
			end
			-- Partial 101 doesn't call another (endpoint)
			create l_partial.make_from_string ("END")
			l_partials[101] := l_partial

			-- Register partials
			from i := 1 until i > 100 loop
				if attached l_partials[i] as l_p and attached l_partials[i + 1] as l_next then
					l_p.register_partial ("p" + (i + 1).out, l_next)
				end
				i := i + 1
			end

			-- Main template starts at depth 0, calls p1
			create l_tpl.make_from_string ("{{>p1}}")
			if attached l_partials[1] as l_first then
				l_tpl.register_partial ("p1", l_first)
			end

			l_result := l_tpl.render

			-- At depth 100 (p100), partial_depth = 100, which is >= Max_partial_depth
			-- With correct code (>=), this triggers error
			-- With mutated code (>), this would NOT trigger error at 100
			if not l_tpl.is_valid then
				passed := passed + 1
				print ("  PASS: test_m06_partial_depth_exactly_at_limit - depth 100 triggers limit%N")
			else
				-- Bug! The >= was mutated to >
				failed := failed + 1
				print ("  FAIL: test_m06_partial_depth_exactly_at_limit - depth 100 didn't trigger limit%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_m06_partial_depth_exactly_at_limit - exception%N")
		end

feature -- V15: Path Traversal Read Tests

	test_v15_path_traversal_parent_dir
			-- V15: make_from_file("../etc/passwd") should fail precondition.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_file ("../etc/passwd")
				-- If we get here, path traversal was allowed!
				failed := failed + 1
				print ("  FAIL: test_v15_path_traversal_parent_dir - path traversal allowed!%N")
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_v15_path_traversal_parent_dir - precondition blocked traversal%N")
			l_retried := True
			retry
		end

	test_v15_absolute_unix_path
			-- V15: Absolute Unix path should fail precondition.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_file ("/etc/passwd")
				failed := failed + 1
				print ("  FAIL: test_v15_absolute_unix_path - absolute path allowed!%N")
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_v15_absolute_unix_path - precondition blocked absolute path%N")
			l_retried := True
			retry
		end

	test_v15_absolute_windows_path
			-- V15: Absolute Windows path should fail precondition.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_file ("C:\Windows\System32\config")
				failed := failed + 1
				print ("  FAIL: test_v15_absolute_windows_path - Windows absolute allowed!%N")
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_v15_absolute_windows_path - precondition blocked Windows path%N")
			l_retried := True
			retry
		end

feature -- V16: Path Traversal Write Tests

	test_v16_path_traversal_write
			-- V16: render_to_file("../important.txt") should fail precondition.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_tpl.make_from_string ("malicious content")
				l_tpl.render_to_file ("../../../important.txt")
				-- If we get here, path traversal for WRITE was allowed!
				failed := failed + 1
				print ("  FAIL: test_v16_path_traversal_write - CRITICAL: path traversal write allowed!%N")
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_v16_path_traversal_write - precondition blocked write traversal%N")
			l_retried := True
			retry
		end

feature -- Empty Input Tests

	test_empty_string_template
			-- Empty template should render to empty string.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create l_tpl.make_from_string ("")
			l_result := l_tpl.render
			if l_result.is_empty then
				passed := passed + 1
				print ("  PASS: test_empty_string_template%N")
			else
				failed := failed + 1
				print ("  FAIL: test_empty_string_template - got non-empty: " + l_result + "%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_empty_string_template - exception%N")
		end

feature -- Special Character Tests

	test_template_with_null_byte
			-- Template containing null byte.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			l_retried: BOOLEAN
		do
			if not l_retried then
				l_template := "Hello%UWorld"
				create l_tpl.make_from_string (l_template)
				l_result := l_tpl.render
				-- If we get here, null byte was handled somehow
				risk := risk + 1
				print ("  RISK: test_template_with_null_byte - null handled, len=" + l_result.count.out + "%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_template_with_null_byte - exception on null byte%N")
			l_retried := True
			retry
		end

feature -- Boundary Tests

	test_very_long_template
			-- Template with 100K characters.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
		do
			create l_template.make_filled ('X', 100000)
			create l_tpl.make_from_string (l_template)
			l_result := l_tpl.render
			if l_result.count = 100000 then
				passed := passed + 1
				print ("  PASS: test_very_long_template (100K chars)%N")
			else
				failed := failed + 1
				print ("  FAIL: test_very_long_template - expected 100000, got " + l_result.count.out + "%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_very_long_template - exception%N")
		end

	test_very_long_variable_name
			-- Variable name with 10K characters.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_var_name: STRING
			l_template: STRING
			l_result: STRING
		do
			create l_var_name.make_filled ('x', 10000)
			l_template := "{{" + l_var_name + "}}"
			create l_tpl.make_from_string (l_template)
			l_tpl.set_variable (l_var_name, "VALUE")
			l_result := l_tpl.render
			if l_result.same_string ("VALUE") then
				passed := passed + 1
				print ("  PASS: test_very_long_variable_name (10K chars)%N")
			else
				failed := failed + 1
				print ("  FAIL: test_very_long_variable_name - unexpected result%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_very_long_variable_name - exception%N")
		end

feature -- Malformed Template Tests

	test_unclosed_variable_tag
			-- Template with unclosed {{.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create l_tpl.make_from_string ("Hello {{name World")
			l_result := l_tpl.render
			-- Should degrade gracefully, outputting characters
			risk := risk + 1
			print ("  RISK: test_unclosed_variable_tag - got: " + l_result + "%N")
		rescue
			failed := failed + 1
			print ("  FAIL: test_unclosed_variable_tag - exception%N")
		end

	test_unclosed_section
			-- Template with unclosed section.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create l_tpl.make_from_string ("{{#section}}content without end")
			l_tpl.set_section ("section", True)
			l_result := l_tpl.render
			risk := risk + 1
			print ("  RISK: test_unclosed_section - got: " + l_result + "%N")
		rescue
			failed := failed + 1
			print ("  FAIL: test_unclosed_section - exception%N")
		end

feature -- Directive Adversarial Tests

	test_directive_empty_condition
			-- Test #if with whitespace-only condition
		local
			l_parser: ST_DIRECTIVE_PARSER
			l_directive: detachable ST_IF_DIRECTIVE
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_parser.make
				l_directive := l_parser.parse_if ("#if   then%Ncontent%N#end")
				-- Should parse but empty condition should evaluate to false
				if l_directive = Void then
					passed := passed + 1
					print ("  PASS: test_directive_empty_condition - parser rejected empty condition%N")
				else
					risk := risk + 1
					print ("  RISK: test_directive_empty_condition - empty condition accepted%N")
				end
			end
		rescue
			passed := passed + 1
			print ("  PASS: test_directive_empty_condition - exception on empty condition%N")
			l_retried := True
			retry
		end

	test_directive_nested_depth
			-- Test deeply nested #if directives
		local
			l_parser: ST_DIRECTIVE_PARSER
			l_template: STRING
			l_directive: detachable ST_IF_DIRECTIVE
			l_context: ST_CONTEXT
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_parser.make
				create l_context.make

				-- Build 50 nested #if directives
				create l_template.make (2000)
				from i := 1 until i > 50 loop
					l_template.append ("#if x then%N")
					i := i + 1
				end
				l_template.append ("DEEP")
				from i := 1 until i > 50 loop
					l_template.append ("%N#end")
					i := i + 1
				end

				l_context.set_variable ("x", True)
				l_directive := l_parser.parse_if (l_template)

				if attached l_directive as d then
					l_result := d.execute (l_context)
					if l_result.has_substring ("DEEP") then
						passed := passed + 1
						print ("  PASS: test_directive_nested_depth - 50 levels handled%N")
					else
						risk := risk + 1
						print ("  RISK: test_directive_nested_depth - deep content not rendered%N")
					end
				else
					risk := risk + 1
					print ("  RISK: test_directive_nested_depth - parse failed%N")
				end
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_directive_nested_depth - exception on deep nesting%N")
			l_retried := True
			retry
		end

	test_directive_special_chars_in_content
			-- Test directives with special characters in content
		local
			l_parser: ST_DIRECTIVE_PARSER
			l_directive: detachable ST_IF_DIRECTIVE
			l_context: ST_CONTEXT
			l_result: STRING
			l_retried: BOOLEAN
		do
			if not l_retried then
				create l_parser.make
				create l_context.make
				l_context.set_variable ("show", True)

				l_directive := l_parser.parse_if ("#if show then%N<script>alert('xss')</script>%N#end")

				if attached l_directive as d then
					l_result := d.execute (l_context)
					if l_result.has_substring ("<script>") then
						risk := risk + 1
						print ("  RISK: test_directive_special_chars_in_content - script tag passed through%N")
					else
						passed := passed + 1
						print ("  PASS: test_directive_special_chars_in_content - script tag filtered%N")
					end
				else
					failed := failed + 1
					print ("  FAIL: test_directive_special_chars_in_content - parse failed%N")
				end
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_directive_special_chars_in_content - exception%N")
			l_retried := True
			retry
		end

feature -- Run All

	run_all
		do
			print ("%N=== Adversarial Tests ===%N%N")

			print ("-- V11: Stale Error Tests --%N")
			test_v11_stale_error_after_partial_depth
			test_v11_error_cleared_on_empty_template

			print ("%N-- V08: Empty Variable Name Tests --%N")
			test_v08_empty_variable_name_in_template

			print ("%N-- V09: Empty Section Name Tests --%N")
			test_v09_empty_section_name_in_template

			print ("%N-- V10: Partial State Pollution Tests --%N")
			test_v10_partial_variables_not_modified

			print ("%N-- M06: Mutation Killer Tests --%N")
			test_m06_partial_depth_exactly_at_limit

			print ("%N-- V15: Path Traversal Read Tests --%N")
			test_v15_path_traversal_parent_dir
			test_v15_absolute_unix_path
			test_v15_absolute_windows_path

			print ("%N-- V16: Path Traversal Write Tests --%N")
			test_v16_path_traversal_write

			print ("%N-- Empty Input Tests --%N")
			test_empty_string_template

			print ("%N-- Special Character Tests --%N")
			test_template_with_null_byte

			print ("%N-- Boundary Tests --%N")
			test_very_long_template
			test_very_long_variable_name

			print ("%N-- Malformed Template Tests --%N")
			test_unclosed_variable_tag
			test_unclosed_section

			print ("%N-- Directive Adversarial Tests --%N")
			test_directive_empty_condition
			test_directive_nested_depth
			test_directive_special_chars_in_content

			print ("%N=== Adversarial Summary: " + passed.out + " pass, " + failed.out + " fail, " + risk.out + " risk ===%N")
		end

end
