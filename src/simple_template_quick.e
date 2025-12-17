note
	description: "[
		Zero-configuration template facade for beginners.

		One-liner template rendering with Mustache syntax.
		For full control, use SIMPLE_TEMPLATE directly.

		Quick Start Examples:
			create tpl.make

			-- One-liner render with variables
			html := tpl.render ("Hello {{name}}!", <<["name", "World"]>>)

			-- Render from file
			html := tpl.file ("templates/email.html", vars)

			-- Quick string substitution (no Mustache, just replace)
			msg := tpl.substitute ("Hello $name!", <<["$name", "Alice"]>>)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_TEMPLATE_QUICK

create
	make

feature {NONE} -- Initialization

	make
			-- Create quick template facade.
		do
			create logger.make
		ensure
			logger_exists: logger /= Void
		end

feature -- One-Liner Rendering

	render (a_template: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
			-- Render template string with variables.
			-- Example: tpl.render ("Hello {{name}}!", <<["name", "World"]>>)
		require
			template_not_empty: not a_template.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			logger.debug_log ("Rendering template (" + a_template.count.out + " chars)")
			create l_tpl.make_from_string (a_template)
			across a_vars as v loop
				l_tpl.set_variable (v.name, v.value)
			end
			Result := l_tpl.render
		ensure
			result_exists: Result /= Void
		end

	render_raw (a_template: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
			-- Render template without HTML escaping.
		require
			template_not_empty: not a_template.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			create l_tpl.make_from_string (a_template)
			l_tpl.set_escape_html (False)
			across a_vars as v loop
				l_tpl.set_variable (v.name, v.value)
			end
			Result := l_tpl.render
		ensure
			result_exists: Result /= Void
		end

	file (a_path: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
			-- Render template from file with variables.
		require
			path_not_empty: not a_path.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			logger.debug_log ("Rendering file: " + a_path)
			create l_tpl.make_from_file (a_path)
			across a_vars as v loop
				l_tpl.set_variable (v.name, v.value)
			end
			Result := l_tpl.render
		ensure
			result_exists: Result /= Void
		end

feature -- Simple Substitution (no Mustache)

	substitute (a_template: STRING; a_replacements: ARRAY [TUPLE [find: STRING; replace: STRING]]): STRING
			-- Simple find-replace substitution.
			-- Example: tpl.substitute ("Hello $name!", <<["$name", "Alice"]>>)
		require
			template_not_empty: not a_template.is_empty
		do
			Result := a_template.twin
			across a_replacements as r loop
				Result.replace_substring_all (r.find, r.replace)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Conditional Rendering

	render_if (a_condition: BOOLEAN; a_template: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
			-- Render template only if condition is true, otherwise return empty string.
		do
			if a_condition then
				Result := render (a_template, a_vars)
			else
				Result := ""
			end
		ensure
			result_exists: Result /= Void
		end

	render_choice (a_condition: BOOLEAN; a_true_template, a_false_template: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]): STRING
			-- Render one of two templates based on condition.
		do
			if a_condition then
				Result := render (a_true_template, a_vars)
			else
				Result := render (a_false_template, a_vars)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- List Rendering

	render_list (a_template: STRING; a_items: ARRAY [ARRAY [TUPLE [name: STRING; value: STRING]]]): STRING
			-- Render template once for each item set, concatenate results.
			-- Example: render_list ("<li>{{name}}</li>", <<vars1, vars2, vars3>>)
		require
			template_not_empty: not a_template.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			create Result.make_empty
			across a_items as item loop
				create l_tpl.make_from_string (a_template)
				across item as v loop
					l_tpl.set_variable (v.name, v.value)
				end
				Result.append (l_tpl.render)
			end
		ensure
			result_exists: Result /= Void
		end

feature -- File Output

	render_to_file (a_template: STRING; a_vars: ARRAY [TUPLE [name: STRING; value: STRING]]; a_output_path: STRING)
			-- Render template and write to file.
		require
			template_not_empty: not a_template.is_empty
			path_not_empty: not a_output_path.is_empty
		local
			l_content: STRING
			l_file: PLAIN_TEXT_FILE
		do
			l_content := render (a_template, a_vars)
			create l_file.make_create_read_write (a_output_path)
			l_file.put_string (l_content)
			l_file.close
			logger.info ("Wrote template output to: " + a_output_path)
		end

feature -- Validation

	variables_in (a_template: STRING): ARRAYED_LIST [STRING]
			-- Extract variable names from template.
		require
			template_not_empty: not a_template.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			create l_tpl.make_from_string (a_template)
			Result := l_tpl.required_variables
		ensure
			result_exists: Result /= Void
		end

	is_valid (a_template: STRING): BOOLEAN
			-- Is template syntactically valid?
		require
			template_not_empty: not a_template.is_empty
		local
			l_tpl: SIMPLE_TEMPLATE
		do
			create l_tpl.make_from_string (a_template)
			Result := l_tpl.is_valid
		end

feature {NONE} -- Implementation

	logger: SIMPLE_LOGGER
			-- Logger for debugging.

invariant
	logger_exists: logger /= Void

end
