note
	description: "[
		Runs the tests in simple_template's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 28 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 28 in all.
		do
			run_adversarial_tests
			run_stress_tests
		end

feature {NONE} -- Test sets

	run_adversarial_tests
		local
			l_evaluator: EQA_TEST_EVALUATOR [ADVERSARIAL_TESTS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v11_stale_error_after_partial_depth), "ADVERSARIAL_TESTS.test_v11_stale_error_after_partial_depth")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v11_error_cleared_on_empty_template), "ADVERSARIAL_TESTS.test_v11_error_cleared_on_empty_template")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v08_empty_variable_name_in_template), "ADVERSARIAL_TESTS.test_v08_empty_variable_name_in_template")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v09_empty_section_name_in_template), "ADVERSARIAL_TESTS.test_v09_empty_section_name_in_template")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v10_partial_variables_not_modified), "ADVERSARIAL_TESTS.test_v10_partial_variables_not_modified")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_m06_partial_depth_exactly_at_limit), "ADVERSARIAL_TESTS.test_m06_partial_depth_exactly_at_limit")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v15_path_traversal_parent_dir), "ADVERSARIAL_TESTS.test_v15_path_traversal_parent_dir")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v15_absolute_unix_path), "ADVERSARIAL_TESTS.test_v15_absolute_unix_path")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v15_absolute_windows_path), "ADVERSARIAL_TESTS.test_v15_absolute_windows_path")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_v16_path_traversal_write), "ADVERSARIAL_TESTS.test_v16_path_traversal_write")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_empty_string_template), "ADVERSARIAL_TESTS.test_empty_string_template")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_template_with_null_byte), "ADVERSARIAL_TESTS.test_template_with_null_byte")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_very_long_template), "ADVERSARIAL_TESTS.test_very_long_template")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_very_long_variable_name), "ADVERSARIAL_TESTS.test_very_long_variable_name")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_unclosed_variable_tag), "ADVERSARIAL_TESTS.test_unclosed_variable_tag")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_unclosed_section), "ADVERSARIAL_TESTS.test_unclosed_section")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_directive_empty_condition), "ADVERSARIAL_TESTS.test_directive_empty_condition")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_directive_nested_depth), "ADVERSARIAL_TESTS.test_directive_nested_depth")
			report (l_evaluator.execute (agent {ADVERSARIAL_TESTS}.test_directive_special_chars_in_content), "ADVERSARIAL_TESTS.test_directive_special_chars_in_content")
		end

	run_stress_tests
		local
			l_evaluator: EQA_TEST_EVALUATOR [STRESS_TESTS]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_100_variables), "STRESS_TESTS.test_100_variables")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_1000_variables), "STRESS_TESTS.test_1000_variables")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_5000_variables), "STRESS_TESTS.test_5000_variables")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_list_100_items), "STRESS_TESTS.test_list_100_items")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_list_1000_items), "STRESS_TESTS.test_list_1000_items")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_deeply_nested_sections), "STRESS_TESTS.test_deeply_nested_sections")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_partial_depth_limit_approach), "STRESS_TESTS.test_partial_depth_limit_approach")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_rapid_render_calls), "STRESS_TESTS.test_rapid_render_calls")
			report (l_evaluator.execute (agent {STRESS_TESTS}.test_very_long_variable_value), "STRESS_TESTS.test_very_long_variable_value")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
