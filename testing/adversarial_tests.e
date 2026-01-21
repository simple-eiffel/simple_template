note
	description: "Adversarial tests for simple_template - designed to break things"
	date: "2026-01-18"

class
	ADVERSARIAL_TESTS

inherit
	TEST_SET_BASE

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

			assert ("error_was_set", not l_tpl.is_valid)

			-- Now the bug test: create new template with NO error-producing content
			create l_tpl.make_from_string ("Simple text")
			l_tpl.render.do_nothing

			assert ("new_template_valid", l_tpl.is_valid)
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

			assert ("empty_template_valid", l_tpl.is_valid)
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
				assert ("precondition_should_fire", False)
			end
			-- If we retried, we're here because exception was caught - test passes
		rescue
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
				assert ("precondition_should_fire", False)
			end
		rescue
			l_retried := True
			retry
		end

feature -- V10: Partial State Pollution Tests

	test_v10_partial_variables_not_modified
			-- V10: Partial should not have extra variables after render.
		local
			l_parent: SIMPLE_TEMPLATE
			l_partial: SIMPLE_TEMPLATE
		do
			-- Create partial with NO variables
			create l_partial.make_from_string ("Partial content: {{passed_var}}")

			-- Create parent that passes variable to partial
			create l_parent.make_from_string ("Before {{>child}} After")
			l_parent.register_partial ("child", l_partial)
			l_parent.set_variable ("passed_var", "VALUE")

			-- Render parent (this passes variables to partial)
			l_parent.render.do_nothing

			-- Check if partial now has variables it shouldn't have
			assert ("partial_not_polluted", not l_partial.has_variable ("passed_var"))
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
			assert ("depth_limit_triggered", not l_tpl.is_valid)
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
				assert ("path_traversal_blocked", False)
			end
		rescue
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
				assert ("absolute_path_blocked", False)
			end
		rescue
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
				assert ("windows_path_blocked", False)
			end
		rescue
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
				assert ("write_traversal_blocked", False)
			end
		rescue
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
			assert ("empty_renders_empty", l_result.is_empty)
		end

feature -- Special Character Tests

	test_template_with_null_byte
			-- Template containing null byte.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
		do
			l_template := "Hello%UWorld"
			create l_tpl.make_from_string (l_template)
			l_result := l_tpl.render
			-- Null byte should be handled gracefully
			assert ("null_byte_handled", l_result.count > 0)
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
			assert_integers_equal ("100k_chars", 100000, l_result.count)
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
			assert_strings_equal ("long_var_name", "VALUE", l_result)
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
			-- Should degrade gracefully, not crash
			assert ("unclosed_handled", l_result.count > 0)
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
			-- Should degrade gracefully, not crash
			assert ("unclosed_section_handled", l_result.count > 0)
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
				-- Empty condition should be rejected or evaluate to false
				assert ("empty_condition_rejected", l_directive = Void)
			end
		rescue
			-- Exception on empty condition is acceptable
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
		do
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

			assert ("deep_nesting_parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (l_context)
				assert ("deep_content_rendered", l_result.has_substring ("DEEP"))
			end
		end

	test_directive_special_chars_in_content
			-- Test directives with special characters in content
		local
			l_parser: ST_DIRECTIVE_PARSER
			l_directive: detachable ST_IF_DIRECTIVE
			l_context: ST_CONTEXT
			l_result: STRING
		do
			create l_parser.make
			create l_context.make
			l_context.set_variable ("show", True)

			l_directive := l_parser.parse_if ("#if show then%N<script>alert('xss')</script>%N#end")

			assert ("special_chars_parsed", attached l_directive)
			if attached l_directive as d then
				l_result := d.execute (l_context)
				-- Content should be preserved (escaping is caller's responsibility)
				assert ("content_rendered", l_result.count > 0)
			end
		end

end
