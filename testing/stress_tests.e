note
	description: "Stress tests for simple_template"
	date: "2026-01-18"

class
	STRESS_TESTS

create
	make

feature {NONE} -- Initialization

	make
		do
			print ("Running STRESS tests for simple_template...%N%N")
			run_all_stress_tests
		end

feature -- Volume Tests - Variables

	test_100_variables
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 100 variables... ")
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
				if l_result.count > 0 then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - empty result%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_1000_variables
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 1000 variables... ")
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
				if l_result.count > 0 then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - empty result%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_5000_variables
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 5000 variables... ")
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
				if l_result.count > 0 then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - empty result%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

feature -- Volume Tests - List Iteration

	test_list_100_items
		local
			l_tpl: SIMPLE_TEMPLATE
			l_list: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			l_item: HASH_TABLE [STRING, STRING]
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing list with 100 items... ")
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
				if l_result.count > 700 then -- At least some output
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - too short%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_list_1000_items
		local
			l_tpl: SIMPLE_TEMPLATE
			l_list: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			l_item: HASH_TABLE [STRING, STRING]
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing list with 1000 items... ")
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
				if l_result.count > 8000 then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - too short%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

feature -- Worst Case Tests

	test_deeply_nested_sections
		local
			l_tpl: SIMPLE_TEMPLATE
			l_template: STRING
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 50 nested sections... ")
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
				if l_result.same_string ("DEEP") then
					print ("PASS%N")
				else
					print ("FAIL - got: " + l_result + "%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_partial_depth_limit_approach
		local
			l_tpl: SIMPLE_TEMPLATE
			l_partials: ARRAY [detachable SIMPLE_TEMPLATE]
			l_partial: SIMPLE_TEMPLATE
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 99 partial chain (under limit)... ")
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
				if l_result.has_substring ("END") then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - didn't reach end%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_rapid_render_calls
		local
			l_tpl: SIMPLE_TEMPLATE
			l_result: STRING
			i: INTEGER
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 1000 rapid render calls... ")
				create l_tpl.make_from_string ("Hello {{name}}!")
				l_tpl.set_variable ("name", "World")
				l_result := l_tpl.render -- Initialize before loop
				from i := 1 until i > 1000 loop
					l_result := l_tpl.render
					i := i + 1
				end
				if l_result.same_string ("Hello World!") then
					print ("PASS%N")
				else
					print ("FAIL%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

	test_very_long_variable_value
		local
			l_tpl: SIMPLE_TEMPLATE
			l_value: STRING
			l_result: STRING
			l_retried: BOOLEAN
		do
			if not l_retried then
				print ("Testing 1MB variable value... ")
				create l_value.make_filled ('X', 1000000)
				create l_tpl.make_from_string ("Value: {{big}}")
				l_tpl.set_variable ("big", l_value)
				l_result := l_tpl.render
				if l_result.count > 1000000 then
					print ("PASS (len=" + l_result.count.out + ")%N")
				else
					print ("FAIL - too short%N")
				end
			end
		rescue
			print ("CRASHED%N")
			l_retried := True
			retry
		end

feature -- Run All

	run_all_stress_tests
		do
			print ("=== Volume Tests - Variables ===%N")
			test_100_variables
			test_1000_variables
			test_5000_variables

			print ("%N=== Volume Tests - Lists ===%N")
			test_list_100_items
			test_list_1000_items

			print ("%N=== Worst Case Tests ===%N")
			test_deeply_nested_sections
			test_partial_depth_limit_approach
			test_rapid_render_calls
			test_very_long_variable_value

			print ("%N=== Stress Testing Complete ===%N")
		end

end
