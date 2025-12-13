note
	description: "Tests for SIMPLE_TEMPLATE"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Initialization

	test_make
			-- Test empty initialization.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.make"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make
			assert_true ("empty source", tpl.template_source.is_empty)
			assert_true ("escape enabled", tpl.escape_html_enabled)
		end

	test_make_from_string
			-- Test initialization from string.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.make_from_string"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{name}}!")
			assert_strings_equal ("source set", "Hello, {{name}}!", tpl.template_source)
		end

feature -- Test: Configuration

	test_set_escape_html
			-- Test setting escape mode.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_escape_html"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make
			assert_true ("default enabled", tpl.escape_html_enabled)
			tpl.set_escape_html (False)
			assert_false ("disabled", tpl.escape_html_enabled)
			tpl.set_escape_html (True)
			assert_true ("re-enabled", tpl.escape_html_enabled)
		end

	test_set_missing_variable_policy
			-- Test setting missing variable policy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_missing_variable_policy"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make
			tpl.set_missing_variable_policy (tpl.Policy_keep_placeholder)
			assert_integers_equal ("policy set", tpl.Policy_keep_placeholder, tpl.missing_variable_policy)
		end

feature -- Test: Variables

	test_set_variable
			-- Test setting a variable.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_variable"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make
			tpl.set_variable ("name", "World")
			assert_true ("variable set", tpl.has_variable ("name"))
		end

	test_set_variables
			-- Test setting multiple variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_variables"
		local
			tpl: SIMPLE_TEMPLATE
			vars: HASH_TABLE [STRING, STRING]
		do
			create tpl.make
			create vars.make (2)
			vars.put ("Alice", "name")
			vars.put ("Paris", "city")
			tpl.set_variables (vars)
			assert_true ("has name", tpl.has_variable ("name"))
			assert_true ("has city", tpl.has_variable ("city"))
		end

	test_clear_variables
			-- Test clearing variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.clear_variables"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make
			tpl.set_variable ("name", "Test")
			assert_true ("has variable", tpl.has_variable ("name"))
			tpl.clear_variables
			assert_false ("cleared", tpl.has_variable ("name"))
		end

feature -- Test: Basic Rendering

	test_render_plain_text
			-- Test rendering plain text without variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, World!")
			assert_strings_equal ("plain text", "Hello, World!", tpl.render)
		end

	test_render_variable
			-- Test rendering with variable substitution.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{name}}!")
			tpl.set_variable ("name", "World")
			assert_strings_equal ("substituted", "Hello, World!", tpl.render)
		end

	test_render_multiple_variables
			-- Test rendering with multiple variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{greeting}}, {{name}}!")
			tpl.set_variable ("greeting", "Hello")
			tpl.set_variable ("name", "World")
			assert_strings_equal ("multiple vars", "Hello, World!", tpl.render)
		end

	test_render_variable_with_spaces
			-- Test variable names with surrounding spaces.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{ name }}!")
			tpl.set_variable ("name", "World")
			assert_strings_equal ("spaces ignored", "Hello, World!", tpl.render)
		end

feature -- Test: HTML Escaping

	test_html_escape
			-- Test HTML escaping of values.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{content}}")
			tpl.set_variable ("content", "<script>alert('xss')</script>")
			assert_strings_equal ("escaped", "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;", tpl.render)
		end

	test_html_escape_ampersand
			-- Test escaping ampersand.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{content}}")
			tpl.set_variable ("content", "A & B")
			assert_strings_equal ("ampersand escaped", "A &amp; B", tpl.render)
		end

	test_html_escape_quotes
			-- Test escaping quotes.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{content}}")
			tpl.set_variable ("content", "Say %"Hello%"")
			assert_strings_equal ("quotes escaped", "Say &quot;Hello&quot;", tpl.render)
		end

	test_raw_unescaped
			-- Test raw/unescaped output with triple braces.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{{content}}}")
			tpl.set_variable ("content", "<b>bold</b>")
			assert_strings_equal ("unescaped", "<b>bold</b>", tpl.render)
		end

	test_escape_disabled
			-- Test with escaping disabled.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{content}}")
			tpl.set_escape_html (False)
			tpl.set_variable ("content", "<b>bold</b>")
			assert_strings_equal ("not escaped", "<b>bold</b>", tpl.render)
		end

feature -- Test: Sections

	test_section_truthy
			-- Test section rendered when truthy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{#show}}Visible{{/show}}")
			tpl.set_section ("show", True)
			assert_strings_equal ("visible", "Visible", tpl.render)
		end

	test_section_falsy
			-- Test section not rendered when falsy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{#show}}Visible{{/show}}")
			tpl.set_section ("show", False)
			assert_strings_equal ("hidden", "", tpl.render)
		end

	test_section_missing_is_falsy
			-- Test undefined section is falsy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{#missing}}Content{{/missing}}")
			assert_strings_equal ("not rendered", "", tpl.render)
		end

	test_inverted_section_truthy
			-- Test inverted section not rendered when truthy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{^has_items}}No items{{/has_items}}")
			tpl.set_section ("has_items", True)
			assert_strings_equal ("hidden", "", tpl.render)
		end

	test_inverted_section_falsy
			-- Test inverted section rendered when falsy.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{^has_items}}No items{{/has_items}}")
			tpl.set_section ("has_items", False)
			assert_strings_equal ("visible", "No items", tpl.render)
		end

feature -- Test: Lists

	test_list_iteration
			-- Test iterating over a list.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
			items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			item1, item2: HASH_TABLE [STRING, STRING]
		do
			create tpl.make_from_string ("{{#items}}{{name}} {{/items}}")

			create items.make (2)
			create item1.make (1)
			item1.put ("Alice", "name")
			items.extend (item1)
			create item2.make (1)
			item2.put ("Bob", "name")
			items.extend (item2)

			tpl.set_list ("items", items)
			assert_strings_equal ("iterated", "Alice Bob ", tpl.render)
		end

	test_empty_list
			-- Test empty list renders nothing.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
			items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
		do
			create tpl.make_from_string ("{{#items}}{{name}}{{/items}}")
			create items.make (0)
			tpl.set_list ("items", items)
			assert_strings_equal ("empty", "", tpl.render)
		end

feature -- Test: Comments

	test_comment
			-- Test comments are not rendered.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello{{! This is a comment }}World")
			assert_strings_equal ("comment removed", "HelloWorld", tpl.render)
		end

	test_multiline_comment
			-- Test multiline comment.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("A{{! line 1%Nline 2 }}B")
			assert_strings_equal ("removed", "AB", tpl.render)
		end

feature -- Test: Missing Variables

	test_missing_variable_empty
			-- Test missing variable returns empty string (default).
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{missing}}!")
			assert_strings_equal ("empty for missing", "Hello, !", tpl.render)
		end

	test_missing_variable_placeholder
			-- Test missing variable keeps placeholder.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{missing}}!")
			tpl.set_missing_variable_policy (tpl.Policy_keep_placeholder)
			assert_strings_equal ("placeholder kept", "Hello, {{missing}}!", tpl.render)
		end

feature -- Test: Required Variables

	test_required_variables
			-- Test extracting required variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.required_variables"
		local
			tpl: SIMPLE_TEMPLATE
			vars: ARRAYED_LIST [STRING]
		do
			create tpl.make_from_string ("{{name}} lives in {{city}}")
			vars := tpl.required_variables
			assert_integers_equal ("two vars", 2, vars.count)
		end

feature -- Test: Partial Templates

	test_partial
			-- Test including a partial template.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
			header: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{>header}}Body")
			create header.make_from_string ("<h1>Title</h1>")
			tpl.register_partial ("header", header)
			assert_strings_equal ("partial included", "<h1>Title</h1>Body", tpl.render)
		end

feature -- Test: Nested Sections

	test_nested_sections
			-- Test nested sections.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{#outer}}A{{#inner}}B{{/inner}}C{{/outer}}")
			tpl.set_section ("outer", True)
			tpl.set_section ("inner", True)
			assert_strings_equal ("both rendered", "ABC", tpl.render)
		end

	test_nested_section_inner_false
			-- Test nested section with inner false.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("{{#outer}}A{{#inner}}B{{/inner}}C{{/outer}}")
			tpl.set_section ("outer", True)
			tpl.set_section ("inner", False)
			assert_strings_equal ("inner hidden", "AC", tpl.render)
		end

feature -- Test: Complex Templates

	test_complex_template
			-- Test a more complex template.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
			items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			item: HASH_TABLE [STRING, STRING]
		do
			create tpl.make_from_string ("[
				<h1>{{title}}</h1>
				{{#has_items}}
				<ul>
				{{#items}}<li>{{name}}</li>{{/items}}
				</ul>
				{{/has_items}}
				{{^has_items}}
				<p>No items</p>
				{{/has_items}}
			]")

			tpl.set_variable ("title", "My List")
			tpl.set_section ("has_items", True)

			create items.make (2)
			create item.make (1)
			item.put ("Item 1", "name")
			items.extend (item)
			create item.make (1)
			item.put ("Item 2", "name")
			items.extend (item)
			tpl.set_list ("items", items)

			assert_string_contains ("has title", tpl.render, "My List")
			assert_string_contains ("has item 1", tpl.render, "Item 1")
			assert_string_contains ("has item 2", tpl.render, "Item 2")
		end

end
