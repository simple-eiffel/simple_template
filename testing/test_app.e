note
	description: "Test application for simple_template"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: LIB_TESTS
		do
			create tests
			print ("simple_template test runner%N")
			print ("=============================%N%N")

			passed := 0
			failed := 0

			-- Initialization
			run_test (agent tests.test_make, "test_make")
			run_test (agent tests.test_make_from_string, "test_make_from_string")

			-- Configuration
			run_test (agent tests.test_set_escape_html, "test_set_escape_html")
			run_test (agent tests.test_set_missing_variable_policy, "test_set_missing_variable_policy")

			-- Variables
			run_test (agent tests.test_set_variable, "test_set_variable")
			run_test (agent tests.test_set_variables, "test_set_variables")
			run_test (agent tests.test_clear_variables, "test_clear_variables")
			run_test (agent tests.test_set_variable_any, "test_set_variable_any")

			-- Basic Rendering
			run_test (agent tests.test_render_plain_text, "test_render_plain_text")
			run_test (agent tests.test_render_variable, "test_render_variable")
			run_test (agent tests.test_render_multiple_variables, "test_render_multiple_variables")
			run_test (agent tests.test_render_variable_with_spaces, "test_render_variable_with_spaces")

			-- HTML Escaping
			run_test (agent tests.test_html_escape, "test_html_escape")
			run_test (agent tests.test_html_escape_ampersand, "test_html_escape_ampersand")
			run_test (agent tests.test_html_escape_quotes, "test_html_escape_quotes")
			run_test (agent tests.test_raw_unescaped, "test_raw_unescaped")
			run_test (agent tests.test_escape_disabled, "test_escape_disabled")

			-- Sections
			run_test (agent tests.test_section_truthy, "test_section_truthy")
			run_test (agent tests.test_section_falsy, "test_section_falsy")
			run_test (agent tests.test_section_missing_is_falsy, "test_section_missing_is_falsy")
			run_test (agent tests.test_inverted_section_truthy, "test_inverted_section_truthy")
			run_test (agent tests.test_inverted_section_falsy, "test_inverted_section_falsy")

			-- Lists
			run_test (agent tests.test_list_iteration, "test_list_iteration")
			run_test (agent tests.test_empty_list, "test_empty_list")

			-- Comments
			run_test (agent tests.test_comment, "test_comment")
			run_test (agent tests.test_multiline_comment, "test_multiline_comment")

			-- Missing Variables
			run_test (agent tests.test_missing_variable_empty, "test_missing_variable_empty")
			run_test (agent tests.test_missing_variable_placeholder, "test_missing_variable_placeholder")

			-- Required Variables
			run_test (agent tests.test_required_variables, "test_required_variables")

			-- Partials
			run_test (agent tests.test_partial, "test_partial")
			run_test (agent tests.test_partial_depth_limit, "test_partial_depth_limit")

			-- Nested Sections
			run_test (agent tests.test_nested_sections, "test_nested_sections")
			run_test (agent tests.test_nested_section_inner_false, "test_nested_section_inner_false")

			-- Complex Templates
			run_test (agent tests.test_complex_template, "test_complex_template")

			-- File Output
			run_test (agent tests.test_render_to_file, "test_render_to_file")

			-- Encoding Detection (simple_encoding integration)
			run_test (agent tests.test_has_utf8_bom, "test_has_utf8_bom")
			run_test (agent tests.test_strip_bom, "test_strip_bom")

			-- Object Rendering (simple_reflection integration)
			run_test (agent tests.test_set_variables_from_object, "test_set_variables_from_object")
			run_test (agent tests.test_render_with_object, "test_render_with_object")

			-- Directive Integration (evolicity-style via SIMPLE_TEMPLATE)
			run_test (agent tests.test_render_with_directives_basic, "test_render_with_directives_basic")
			run_test (agent tests.test_render_with_directives_combined, "test_render_with_directives_combined")
			run_test (agent tests.test_has_directives, "test_has_directives")

			-- Compilation (Phase 3)
			run_test (agent tests.test_compile_basic, "test_compile_basic")
			run_test (agent tests.test_render_compiled, "test_render_compiled")
			run_test (agent tests.test_compiled_escaping, "test_compiled_escaping")
			run_test (agent tests.test_compiled_raw, "test_compiled_raw")
			run_test (agent tests.test_compiled_sections, "test_compiled_sections")
			run_test (agent tests.test_compiled_inverted_section, "test_compiled_inverted_section")
			run_test (agent tests.test_template_compiler, "test_template_compiler")
			run_test (agent tests.test_template_cache, "test_template_cache")
			run_test (agent tests.test_cache_eviction, "test_cache_eviction")

			-- Adversarial Tests
			run_adversarial_tests

			-- Stress Tests
			run_stress_tests

			-- Directive Tests (evolicity-style)
			run_directive_tests

			-- Performance Benchmarks (Phase 4F)
			run_benchmarks

			print ("%N=============================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER
	adversarial_tests: ADVERSARIAL_TESTS
	stress_tests: STRESS_TESTS
	directive_tests: DIRECTIVE_TESTS
	benchmarks: PERFORMANCE_BENCHMARKS

	run_adversarial_tests
			-- Run adversarial test suite.
		do
			create adversarial_tests.make
			adversarial_tests.run_all
			-- Add adversarial counts to main totals
			passed := passed + adversarial_tests.passed
			failed := failed + adversarial_tests.failed
		end

	run_stress_tests
			-- Run stress test suite.
		do
			create stress_tests.make
			-- Stress tests print their own output, no counter integration
		end

	run_benchmarks
			-- Run performance benchmarks.
		do
			create benchmarks.make
			benchmarks.run_all
		end

	run_directive_tests
			-- Run directive test suite (evolicity-style directives).
		do
			print ("%NDirective Tests (evolicity-style):%N")
			create directive_tests.make

			-- If Directive Tests
			run_test (agent directive_tests.test_if_true_condition, "test_if_true_condition")
			run_test (agent directive_tests.test_if_false_condition, "test_if_false_condition")
			run_test (agent directive_tests.test_if_else_true, "test_if_else_true")
			run_test (agent directive_tests.test_if_else_false, "test_if_else_false")
			run_test (agent directive_tests.test_if_comparison_equal, "test_if_comparison_equal")
			run_test (agent directive_tests.test_if_comparison_numeric, "test_if_comparison_numeric")
			run_test (agent directive_tests.test_if_boolean_and, "test_if_boolean_and")
			run_test (agent directive_tests.test_if_boolean_or, "test_if_boolean_or")
			run_test (agent directive_tests.test_if_boolean_not, "test_if_boolean_not")

			-- Foreach Directive Tests
			run_test (agent directive_tests.test_foreach_basic, "test_foreach_basic")
			run_test (agent directive_tests.test_foreach_with_index, "test_foreach_with_index")
			run_test (agent directive_tests.test_foreach_empty_list, "test_foreach_empty_list")

			-- Across Directive Tests
			run_test (agent directive_tests.test_across_basic, "test_across_basic")
			run_test (agent directive_tests.test_across_with_cursor_index, "test_across_with_cursor_index")

			-- Context Tests
			run_test (agent directive_tests.test_context_boolean_evaluation, "test_context_boolean_evaluation")
			run_test (agent directive_tests.test_context_expression_evaluation, "test_context_expression_evaluation")

			-- Parser Error Tests
			run_test (agent directive_tests.test_parser_missing_then, "test_parser_missing_then")
			run_test (agent directive_tests.test_parser_missing_end, "test_parser_missing_end")
			run_test (agent directive_tests.test_parser_has_directive, "test_parser_has_directive")

			-- Include Directive Tests
			run_test (agent directive_tests.test_include_parse_literal_path, "test_include_parse_literal_path")
			run_test (agent directive_tests.test_include_parse_variable_path, "test_include_parse_variable_path")
			run_test (agent directive_tests.test_include_path_traversal_blocked, "test_include_path_traversal_blocked")
			run_test (agent directive_tests.test_include_absolute_path_blocked, "test_include_absolute_path_blocked")

			-- Evaluate Directive Tests
			run_test (agent directive_tests.test_evaluate_parse_variable, "test_evaluate_parse_variable")
			run_test (agent directive_tests.test_evaluate_basic, "test_evaluate_basic")
			run_test (agent directive_tests.test_evaluate_empty_variable, "test_evaluate_empty_variable")
			run_test (agent directive_tests.test_evaluate_literal_template, "test_evaluate_literal_template")

			-- Expression Evaluator Tests (Phase 4)
			print ("%NExpression Evaluator Tests (Phase 4):%N")
			run_test (agent directive_tests.test_expr_math_add, "test_expr_math_add")
			run_test (agent directive_tests.test_expr_math_subtract, "test_expr_math_subtract")
			run_test (agent directive_tests.test_expr_math_multiply, "test_expr_math_multiply")
			run_test (agent directive_tests.test_expr_math_divide, "test_expr_math_divide")

			-- Filter Tests (Phase 4)
			print ("%NFilter Tests (Phase 4):%N")
			run_test (agent directive_tests.test_filter_upper, "test_filter_upper")
			run_test (agent directive_tests.test_filter_lower, "test_filter_lower")
			run_test (agent directive_tests.test_filter_capitalize, "test_filter_capitalize")
			run_test (agent directive_tests.test_filter_length, "test_filter_length")
			run_test (agent directive_tests.test_filter_default, "test_filter_default")
			run_test (agent directive_tests.test_filter_truncate, "test_filter_truncate")
			run_test (agent directive_tests.test_filter_chain, "test_filter_chain")
			run_test (agent directive_tests.test_filter_reverse, "test_filter_reverse")
			run_test (agent directive_tests.test_filter_abs, "test_filter_abs")

			-- Error Handling Tests (Phase 4)
			print ("%NError Handling Tests (Phase 4):%N")
			run_test (agent directive_tests.test_error_collector_basic, "test_error_collector_basic")
			run_test (agent directive_tests.test_error_with_location, "test_error_with_location")
		end

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
