note
	description: "Stress tests for simple_template"
	date: "2026-01-18"

class
	STRESS_TESTS

inherit
	TEST_SET_BASE

feature -- Volume Tests - Variables

	test_100_variables
			-- Test template with 100 variables.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
		do
			create l_template.make (2000)
			from i := 1 until i > 100 loop
				l_template.append ("{{var" + i.out + "}}")
				i := i + 1
			end
			create l_tpl.make_from_string (l_template)
			from i := 1 until i > 100 loop
				l_tpl.set_variable ("var" + i.out, "V" + i.out)
				i := i + 1
			end
			l_result := l_tpl.render
			assert ("100_vars_rendered", l_result.count > 0)
		end

	test_1000_variables
			-- Test template with 1000 variables.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
		do
			create l_template.make (20000)
			from i := 1 until i > 1000 loop
				l_template.append ("{{var" + i.out + "}}")
				i := i + 1
			end
			create l_tpl.make_from_string (l_template)
			from i := 1 until i > 1000 loop
				l_tpl.set_variable ("var" + i.out, "V" + i.out)
				i := i + 1
			end
			l_result := l_tpl.render
			assert ("1000_vars_rendered", l_result.count > 0)
		end

	test_5000_variables
			-- Test template with 5000 variables.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
		do
			create l_template.make (100000)
			from i := 1 until i > 5000 loop
				l_template.append ("{{var" + i.out + "}}")
				i := i + 1
			end
			create l_tpl.make_from_string (l_template)
			from i := 1 until i > 5000 loop
				l_tpl.set_variable ("var" + i.out, "V" + i.out)
				i := i + 1
			end
			l_result := l_tpl.render
			assert ("5000_vars_rendered", l_result.count > 0)
		end

feature -- Volume Tests - List Iteration

	test_list_100_items
			-- Test list iteration with 100 items.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_list: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			l_item: HASH_TABLE [STRING, STRING]
			l_result: STRING
			i: INTEGER
		do
			create l_tpl.make_from_string ("{{#items}}[{{name}}]{{/items}}")
			create l_list.make (100)
			from i := 1 until i > 100 loop
				create l_item.make (1)
				l_item.force ("Item" + i.out, "name")
				l_list.extend (l_item)
				i := i + 1
			end
			l_tpl.set_list ("items", l_list)
			l_result := l_tpl.render
			assert ("100_items_rendered", l_result.count > 700)
		end

	test_list_1000_items
			-- Test list iteration with 1000 items.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_list: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			l_item: HASH_TABLE [STRING, STRING]
			l_result: STRING
			i: INTEGER
		do
			create l_tpl.make_from_string ("{{#items}}[{{name}}]{{/items}}")
			create l_list.make (1000)
			from i := 1 until i > 1000 loop
				create l_item.make (1)
				l_item.force ("Item" + i.out, "name")
				l_list.extend (l_item)
				i := i + 1
			end
			l_tpl.set_list ("items", l_list)
			l_result := l_tpl.render
			assert ("1000_items_rendered", l_result.count > 8000)
		end

feature -- Worst Case Tests

	test_deeply_nested_sections
			-- Test 50 nested sections.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
		do
			create l_template.make (1000)
			from i := 1 until i > 50 loop
				l_template.append ("{{#s" + i.out + "}}")
				i := i + 1
			end
			l_template.append ("DEEP")
			from i := 50 until i < 1 loop
				l_template.append ("{{/s" + i.out + "}}")
				i := i - 1
			end
			create l_tpl.make_from_string (l_template)
			from i := 1 until i > 50 loop
				l_tpl.set_section ("s" + i.out, True)
				i := i + 1
			end
			l_result := l_tpl.render
			assert_strings_equal ("50_nested", "DEEP", l_result)
		end

	test_partial_depth_limit_approach
			-- Test 99 partial chain (under limit).
		local
			l_tpl: SIMPLE_TEMPLATE
			l_partials: ARRAY [detachable SIMPLE_TEMPLATE]
			l_partial: SIMPLE_TEMPLATE
			l_result: STRING
			i: INTEGER
		do
			-- Create 100 templates, each calling the next
			create l_partials.make_filled (Void, 1, 100)
			from i := 1 until i > 99 loop
				create l_partial.make_from_string ("L" + i.out + "{{>p" + (i + 1).out + "}}")
				l_partials[i] := l_partial
				i := i + 1
			end
			-- Last partial doesn't call another
			create l_partial.make_from_string ("END")
			l_partials[100] := l_partial

			-- Register all partials
			from i := 1 until i > 99 loop
				if attached l_partials[i] as l_p and attached l_partials[i + 1] as l_next then
					l_p.register_partial ("p" + (i + 1).out, l_next)
				end
				i := i + 1
			end

			-- Main template calls first partial
			create l_tpl.make_from_string ("START{{>p1}}")
			if attached l_partials[1] as l_first then
				l_tpl.register_partial ("p1", l_first)
			end

			l_result := l_tpl.render
			assert ("99_partials_reached_end", l_result.has_substring ("END"))
		end

	test_rapid_render_calls
			-- Test 1000 rapid render calls.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
			i: INTEGER
		do
			create l_tpl.make_from_string ("Hello {{name}}!")
			l_tpl.set_variable ("name", "World")
			l_result := l_tpl.render
			from i := 1 until i > 1000 loop
				l_result := l_tpl.render
				i := i + 1
			end
			assert ("rapid_renders", attached l_result as lr and then lr.same_string ("Hello World!"))
		end

	test_very_long_variable_value
			-- Test 1MB variable value.
		local
			l_tpl: SIMPLE_TEMPLATE
			l_value: STRING
			l_result: STRING
		do
			create l_value.make_filled ('X', 1000000)
			create l_tpl.make_from_string ("Value: {{big}}")
			l_tpl.set_variable ("big", l_value)
			l_result := l_tpl.render
			assert ("1mb_var_rendered", l_result.count > 1000000)
		end

end
