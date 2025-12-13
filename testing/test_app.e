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

			-- Nested Sections
			run_test (agent tests.test_nested_sections, "test_nested_sections")
			run_test (agent tests.test_nested_section_inner_false, "test_nested_section_inner_false")

			-- Complex Templates
			run_test (agent tests.test_complex_template, "test_complex_template")

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
