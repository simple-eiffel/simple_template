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

feature {NONE} -- Test Fixtures

	Test_template_path: STRING = "test_quick_template.txt"
			-- Path to test template file.

	Test_output_path: STRING = "test_quick_output.txt"
			-- Path to test output file.

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

	test_set_variable_any
			-- Test setting variable from ANY value.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_variable_any"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("Count: {{count}}, Pi: {{pi}}")
			tpl.set_variable_any ("count", 42)
			tpl.set_variable_any ("pi", 3.14159)
			assert_true ("has count", tpl.has_variable ("count"))
			assert_true ("has pi", tpl.has_variable ("pi"))
			assert_string_contains ("count rendered", tpl.render, "42")
			assert_string_contains ("pi rendered", tpl.render, "3.14")
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

	test_partial_depth_limit
			-- Test circular partial detection.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render"
		local
			tpl: SIMPLE_TEMPLATE
			recursive: SIMPLE_TEMPLATE
			l_output: STRING
		do
			-- Create a partial that references itself (circular)
			create tpl.make_from_string ("Start{{>recurse}}End")
			create recursive.make_from_string ("X{{>recurse}}")
			tpl.register_partial ("recurse", recursive)
			recursive.register_partial ("recurse", recursive)

			-- Render - should stop at max depth, not hang
			l_output := tpl.render
			-- If we get here without hanging, depth limit worked
			if attached tpl.last_error as l_err then
				assert_true ("depth limit worked", l_err.has_substring ("depth"))
			else
				assert_true ("should have error", False)
			end
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

feature -- Test: File Output

	test_render_to_file
			-- Test rendering to file.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render_to_file"
		local
			tpl: SIMPLE_TEMPLATE
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
			l_path: STRING
		do
			l_path := "test_template_output.txt"
			create tpl.make_from_string ("Hello, {{name}}!")
			tpl.set_variable ("name", "File")
			tpl.render_to_file (l_path)

			-- Verify file exists and has correct content
			create l_file.make_open_read (l_path)
			l_file.read_stream (l_file.count)
			l_content := l_file.last_string
			l_file.close

			assert_strings_equal ("file content", "Hello, File!", l_content)

			-- Cleanup
			create l_file.make_with_name (l_path)
			if l_file.exists then
				l_file.delete
			end
		end

feature -- Test: Encoding Detection (simple_encoding integration)

	test_has_utf8_bom
			-- Test UTF-8 BOM detection.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.has_utf8_bom"
		local
			tpl: SIMPLE_TEMPLATE
			bom_content: STRING
		do
			create tpl.make
			-- Create content with UTF-8 BOM
			create bom_content.make (10)
			bom_content.append_character ((0xEF).to_character_8)
			bom_content.append_character ((0xBB).to_character_8)
			bom_content.append_character ((0xBF).to_character_8)
			bom_content.append ("Hello")
			assert_true ("has bom", tpl.has_utf8_bom (bom_content))
			assert_false ("no bom", tpl.has_utf8_bom ("Hello"))
		end

	test_strip_bom
			-- Test BOM stripping.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.strip_bom"
		local
			tpl: SIMPLE_TEMPLATE
			bom_content: STRING
		do
			create tpl.make
			create bom_content.make (10)
			bom_content.append_character ((0xEF).to_character_8)
			bom_content.append_character ((0xBB).to_character_8)
			bom_content.append_character ((0xBF).to_character_8)
			bom_content.append ("Hello")
			assert_strings_equal ("bom stripped", "Hello", tpl.strip_bom (bom_content))
			assert_strings_equal ("no bom unchanged", "Hello", tpl.strip_bom ("Hello"))
		end

feature -- Test: Object Rendering (simple_reflection integration)

	test_set_variables_from_object
			-- Test setting variables from object fields.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.set_variables_from_object"
		local
			tpl: SIMPLE_TEMPLATE
			person: TEST_PERSON
		do
			create tpl.make_from_string ("{{name}} is {{age}} years old")
			create person.make ("Alice", 30)
			tpl.set_variables_from_object (person)
			assert_true ("has name", tpl.has_variable ("name"))
			assert_true ("has age", tpl.has_variable ("age"))
		end

	test_render_with_object
			-- Test rendering template from object.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render_with_object"
		local
			tpl: SIMPLE_TEMPLATE
			person: TEST_PERSON
			l_result: STRING
		do
			create tpl.make_from_string ("{{name}} is {{age}} years old")
			create person.make ("Bob", 25)
			l_result := tpl.render_with_object (person)
			assert_string_contains ("has name", l_result, "Bob")
			assert_string_contains ("has age", l_result, "25")
		end

feature -- Test: Directive Integration

	test_render_with_directives_basic
			-- Test render_with_directives with basic #if directive.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render_with_directives"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("#if show then%NVisible%N#end")
			tpl.set_variable ("show", "true")
			l_result := tpl.render_with_directives
			assert_string_contains ("has visible", l_result, "Visible")
		end

	test_render_with_directives_combined
			-- Test render_with_directives combining directives with Mustache.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render_with_directives"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("#if active then%NHello {{name}}!%N#end")
			tpl.set_variable ("active", "yes")
			tpl.set_variable ("name", "World")
			l_result := tpl.render_with_directives
			assert_string_contains ("has greeting", l_result, "Hello World!")
		end

	test_has_directives
			-- Test has_directives detection.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.has_directives"
		local
			tpl: SIMPLE_TEMPLATE
		do
			create tpl.make_from_string ("#if x then y #end")
			assert_true ("has directive", tpl.has_directives)

			create tpl.make_from_string ("Hello {{name}}")
			assert_false ("no directive", tpl.has_directives)
		end

feature -- Test: Compilation (Phase 3)

	test_compile_basic
			-- Test basic template compilation.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.compile"
		local
			tpl: SIMPLE_TEMPLATE
			compiled: ST_COMPILED_TEMPLATE
		do
			create tpl.make_from_string ("Hello, {{name}}!")
			compiled := tpl.compile
			assert_true ("compiled not empty", not compiled.is_empty)
			assert_true ("has nodes", compiled.node_count > 0)
		end

	test_render_compiled
			-- Test rendering via compiled template.
		note
			testing: "covers/{SIMPLE_TEMPLATE}.render_compiled"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("Hello, {{name}}!")
			tpl.set_variable ("name", "World")
			l_result := tpl.render_compiled
			assert_strings_equal ("compiled render", "Hello, World!", l_result)
		end

	test_compiled_escaping
			-- Test HTML escaping in compiled render.
		note
			testing: "covers/{ST_VARIABLE_NODE}.execute"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("{{content}}")
			tpl.set_variable ("content", "<script>")
			l_result := tpl.render_compiled
			assert_strings_equal ("escaped", "&lt;script&gt;", l_result)
		end

	test_compiled_raw
			-- Test raw output in compiled render.
		note
			testing: "covers/{ST_VARIABLE_NODE}.execute"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("{{{content}}}")
			tpl.set_variable ("content", "<b>bold</b>")
			l_result := tpl.render_compiled
			assert_strings_equal ("not escaped", "<b>bold</b>", l_result)
		end

	test_compiled_sections
			-- Test sections in compiled render.
		note
			testing: "covers/{ST_SECTION_NODE}.execute"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("{{#show}}Visible{{/show}}")
			tpl.set_section ("show", True)
			l_result := tpl.render_compiled
			assert_strings_equal ("visible", "Visible", l_result)

			tpl.set_section ("show", False)
			l_result := tpl.render_compiled
			assert_strings_equal ("hidden", "", l_result)
		end

	test_compiled_inverted_section
			-- Test inverted sections in compiled render.
		note
			testing: "covers/{ST_SECTION_NODE}.execute"
		local
			tpl: SIMPLE_TEMPLATE
			l_result: STRING
		do
			create tpl.make_from_string ("{{^items}}Empty{{/items}}")
			l_result := tpl.render_compiled
			assert_strings_equal ("shows when empty", "Empty", l_result)
		end

	test_template_compiler
			-- Test ST_TEMPLATE_COMPILER directly.
		note
			testing: "covers/{ST_TEMPLATE_COMPILER}.compile"
		local
			compiler: ST_TEMPLATE_COMPILER
			compiled: ST_COMPILED_TEMPLATE
			ctx: ST_EXECUTION_CONTEXT
			l_result: STRING
		do
			create compiler.make
			compiled := compiler.compile ("Hello, {{name}}!")
			assert_false ("no error", compiler.has_error)

			create ctx.make
			ctx.set_variable ("name", "Test")
			l_result := compiled.render (ctx)
			assert_strings_equal ("rendered", "Hello, Test!", l_result)
		end

	test_template_cache
			-- Test ST_TEMPLATE_CACHE.
		note
			testing: "covers/{ST_TEMPLATE_CACHE}.get_or_compile"
		local
			cache: ST_TEMPLATE_CACHE
			t1, t2: ST_COMPILED_TEMPLATE
			ctx: ST_EXECUTION_CONTEXT
		do
			create cache.make (10)
			assert_true ("empty", cache.is_empty)

			-- First access - miss
			t1 := cache.get_or_compile ("key1", "Hello {{x}}")
			assert_integers_equal ("misses", 1, cache.misses)
			assert_integers_equal ("hits", 0, cache.hits)

			-- Second access - hit
			t2 := cache.get_or_compile ("key1", "Hello {{x}}")
			assert_integers_equal ("hits now 1", 1, cache.hits)
			assert_true ("same object", t1 = t2)

			-- Render cached template
			create ctx.make
			ctx.set_variable ("x", "World")
			assert_strings_equal ("render", "Hello World", t1.render (ctx))
		end

	test_cache_eviction
			-- Test cache eviction when full.
		note
			testing: "covers/{ST_TEMPLATE_CACHE}.put"
		local
			cache: ST_TEMPLATE_CACHE
			i: INTEGER
		do
			create cache.make (3)

			from i := 1 until i > 5 loop
				cache.get_or_compile ("key" + i.out, "Template " + i.out).do_nothing
				i := i + 1
			end

			-- Should have evicted some entries
			assert_integers_equal ("at capacity", 3, cache.count)
		end

feature -- Test QUICK: Basic Rendering

	test_quick_make
			-- Test quick facade initialization.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.make"
		local
			q: SIMPLE_TEMPLATE_QUICK
		do
			create q.make
			-- Just verify it creates without error
			assert ("created", q /= Void)
		end

	test_quick_render_basic
			-- Test basic one-liner render with variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render ("Hello {{name}}!", <<["name", "World"]>>)
			assert_strings_equal ("render_basic", "Hello World!", l_result)
		end

	test_quick_render_multiple_vars
			-- Test render with multiple variables.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render ("{{greeting}}, {{name}}! Welcome to {{place}}.",
				<<["greeting", "Hello"], ["name", "Alice"], ["place", "Eiffel"]>>)
			assert_strings_equal ("multiple_vars", "Hello, Alice! Welcome to Eiffel.", l_result)
		end

	test_quick_render_empty_vars
			-- Test render with no variables needed.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render ("Plain text, no variables.", <<>>)
			assert_strings_equal ("no_vars", "Plain text, no variables.", l_result)
		end

	test_quick_render_html_escaping
			-- Test that HTML is escaped by default.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render ("Value: {{val}}", <<["val", "<script>alert('xss')</script>"]>>)
			assert ("html_escaped", not l_result.has_substring ("<script>"))
			assert ("has_lt", l_result.has_substring ("&lt;"))
		end

	test_quick_render_raw
			-- Test render without HTML escaping.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_raw"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render_raw ("Value: {{val}}", <<["val", "<b>bold</b>"]>>)
			assert ("not_escaped", l_result.has_substring ("<b>bold</b>"))
		end

feature -- Test QUICK: File Operations

	test_quick_file_basic
			-- Test rendering from file.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.file"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
			l_file: SIMPLE_FILE
		do
			-- Setup: create test template file
			create l_file.make (Test_template_path)
			l_file.set_content ("Hello {{name}}, welcome to {{place}}!").do_nothing

			-- Test
			create q.make
			l_result := q.file (Test_template_path, <<["name", "Alice"], ["place", "Eiffel"]>>)
			assert_strings_equal ("file_render", "Hello Alice, welcome to Eiffel!", l_result)

			-- Cleanup
			l_file.delete.do_nothing
		end

	test_quick_render_to_file
			-- Test rendering to file.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_to_file"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_file: SIMPLE_FILE
			l_content: STRING_32
		do
			create q.make
			q.render_to_file ("Output: {{value}}", <<["value", "42"]>>, Test_output_path)

			-- Verify file was created with correct content
			create l_file.make (Test_output_path)
			l_content := l_file.content

			assert_strings_equal ("file_content", "Output: 42", l_content)

			-- Cleanup
			l_file.delete.do_nothing
		end

	test_quick_render_to_file_overwrites
			-- Test that render_to_file overwrites existing file.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_to_file"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_file: SIMPLE_FILE
			l_content: STRING_32
		do
			create q.make

			-- Write first content
			q.render_to_file ("First: {{val}}", <<["val", "1"]>>, Test_output_path)

			-- Overwrite with second content
			q.render_to_file ("Second: {{val}}", <<["val", "2"]>>, Test_output_path)

			-- Verify file has second content
			create l_file.make (Test_output_path)
			l_content := l_file.content

			assert_strings_equal ("overwritten", "Second: 2", l_content)

			-- Cleanup
			l_file.delete.do_nothing
		end

feature -- Test QUICK: Substitution

	test_quick_substitute_basic
			-- Test simple string substitution.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.substitute"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.substitute ("Hello $name!", <<["$name", "Alice"]>>)
			assert_strings_equal ("substitute_basic", "Hello Alice!", l_result)
		end

	test_quick_substitute_multiple
			-- Test multiple substitutions.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.substitute"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.substitute ("$greeting $name, welcome to $place!",
				<<["$greeting", "Hi"], ["$name", "Bob"], ["$place", "the party"]>>)
			assert_strings_equal ("substitute_multi", "Hi Bob, welcome to the party!", l_result)
		end

	test_quick_substitute_no_match
			-- Test substitution when pattern not found.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.substitute"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.substitute ("Hello world!", <<["$notfound", "ignored"]>>)
			assert_strings_equal ("no_match", "Hello world!", l_result)
		end

feature -- Test QUICK: Conditional Rendering

	test_quick_render_if_true
			-- Test conditional render when condition is true.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_if"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render_if (True, "Hello {{name}}!", <<["name", "World"]>>)
			assert_strings_equal ("if_true", "Hello World!", l_result)
		end

	test_quick_render_if_false
			-- Test conditional render when condition is false.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_if"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render_if (False, "Hello {{name}}!", <<["name", "World"]>>)
			assert_strings_equal ("if_false", "", l_result)
		end

	test_quick_render_choice_true
			-- Test choice render when condition is true.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_choice"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render_choice (True, "Yes: {{val}}", "No: {{val}}", <<["val", "X"]>>)
			assert_strings_equal ("choice_true", "Yes: X", l_result)
		end

	test_quick_render_choice_false
			-- Test choice render when condition is false.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_choice"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
		do
			create q.make
			l_result := q.render_choice (False, "Yes: {{val}}", "No: {{val}}", <<["val", "X"]>>)
			assert_strings_equal ("choice_false", "No: X", l_result)
		end

feature -- Test QUICK: List Rendering

	test_quick_render_list_basic
			-- Test list rendering with multiple items.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_list"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
			l_items: ARRAY [ARRAY [TUPLE [name: STRING; value: STRING]]]
		do
			create q.make
			l_items := <<
				<<["name", "Alice"]>>,
				<<["name", "Bob"]>>,
				<<["name", "Charlie"]>>
			>>
			l_result := q.render_list ("<li>{{name}}</li>", l_items)
			assert_strings_equal ("list_basic", "<li>Alice</li><li>Bob</li><li>Charlie</li>", l_result)
		end

	test_quick_render_list_empty
			-- Test list rendering with empty list.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_list"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
			l_items: ARRAY [ARRAY [TUPLE [name: STRING; value: STRING]]]
		do
			create q.make
			create l_items.make_empty
			l_result := q.render_list ("<li>{{name}}</li>", l_items)
			assert_strings_equal ("list_empty", "", l_result)
		end

	test_quick_render_list_multiple_vars
			-- Test list rendering with multiple variables per item.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.render_list"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_result: STRING
			l_items: ARRAY [ARRAY [TUPLE [name: STRING; value: STRING]]]
		do
			create q.make
			l_items := <<
				<<["product", "Apple"], ["price", "$1.00"]>>,
				<<["product", "Banana"], ["price", "$0.50"]>>
			>>
			l_result := q.render_list ("{{product}}: {{price}}%N", l_items)
			assert_strings_equal ("list_multi_vars", "Apple: $1.00%NBanana: $0.50%N", l_result)
		end

feature -- Test QUICK: Validation

	test_quick_variables_in
			-- Test extracting variable names from template.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.variables_in"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_vars: ARRAYED_LIST [STRING]
			l_found_name, l_found_order: BOOLEAN
			l_var: STRING
		do
			create q.make
			l_vars := q.variables_in ("Hello {{name}}, your order {{order_id}} is ready!")
			assert_integers_equal ("var_count", 2, l_vars.count)
			-- Check using string comparison since has() may use reference equality
			from l_vars.start until l_vars.after loop
				l_var := l_vars.item
				if l_var.same_string ("name") then
					l_found_name := True
				elseif l_var.same_string ("order_id") then
					l_found_order := True
				end
				l_vars.forth
			end
			assert ("has_name", l_found_name)
			assert ("has_order_id", l_found_order)
		end

	test_quick_variables_in_no_vars
			-- Test extracting variables from template with none.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.variables_in"
		local
			q: SIMPLE_TEMPLATE_QUICK
			l_vars: ARRAYED_LIST [STRING]
		do
			create q.make
			l_vars := q.variables_in ("Plain text, no variables here.")
			assert_integers_equal ("no_vars", 0, l_vars.count)
		end

	test_quick_is_valid_good
			-- Test validity check on good template.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.is_valid"
		local
			q: SIMPLE_TEMPLATE_QUICK
		do
			create q.make
			assert ("valid_template", q.is_valid ("Hello {{name}}!"))
		end

	test_quick_is_valid_plain
			-- Test validity check on plain text.
		note
			testing: "covers/{SIMPLE_TEMPLATE_QUICK}.is_valid"
		local
			q: SIMPLE_TEMPLATE_QUICK
		do
			create q.make
			assert ("valid_plain", q.is_valid ("Plain text, no tags."))
		end

feature {NONE} -- In-system

	quick: detachable SIMPLE_TEMPLATE_QUICK
			-- Bring class in system.

end
