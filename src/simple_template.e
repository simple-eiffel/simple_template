note
	description: "Mustache-style template engine with auto-escaping"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Mustache Specification", "protocol=URI", "src=https://mustache.github.io/"

class
	SIMPLE_TEMPLATE

create
	make,
	make_from_string,
	make_from_file

feature {NONE} -- Initialization

	make
			-- Create empty template.
		do
			template_source := ""
			create variables.make (10)
			create sections.make (5)
			create lists.make (5)
			create partials.make (3)
			escape_html_enabled := True
			missing_variable_policy := Policy_empty_string
		ensure
			empty_source: template_source.is_empty
			escape_enabled: escape_html_enabled
		end

	make_from_string (a_template: STRING)
			-- Create template from `a_template` string.
		require
			template_not_void: a_template /= Void
		do
			make
			template_source := a_template.twin
		ensure
			source_set: template_source.same_string (a_template)
		end

	make_from_file (a_path: STRING)
			-- Create template from file at `a_path`.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
		do
			make
			create l_file.make_open_read (a_path)
			if l_file.exists and l_file.is_readable then
				create l_content.make (l_file.count)
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				template_source := l_content
			else
				template_source := ""
				last_error := "Cannot read file: " + a_path
			end
			l_file.close
		end

feature -- Configuration

	set_escape_html (a_enabled: BOOLEAN)
			-- Enable or disable HTML escaping.
			-- Default is True (escape enabled).
		do
			escape_html_enabled := a_enabled
		ensure
			set: escape_html_enabled = a_enabled
		end

	set_missing_variable_policy (a_policy: INTEGER)
			-- Set policy for missing variables.
		require
			valid_policy: a_policy = Policy_empty_string or
						  a_policy = Policy_raise_exception or
						  a_policy = Policy_keep_placeholder
		do
			missing_variable_policy := a_policy
		ensure
			policy_set: missing_variable_policy = a_policy
		end

	register_partial (a_name: STRING; a_template: SIMPLE_TEMPLATE)
			-- Register a partial template with `a_name`.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			template_not_void: a_template /= Void
		do
			partials.force (a_template, a_name)
		ensure
			registered: partials.has (a_name)
		end

feature -- Context Building

	set_variable (a_name: STRING; a_value: STRING)
			-- Set variable `a_name` to `a_value`.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			value_not_void: a_value /= Void
		do
			variables.force (a_value, a_name)
		ensure
			variable_set: has_variable (a_name)
		end

	set_variables (a_table: HASH_TABLE [STRING, STRING])
			-- Set multiple variables from `a_table`.
		require
			table_not_void: a_table /= Void
		do
			from
				a_table.start
			until
				a_table.after
			loop
				set_variable (a_table.key_for_iteration, a_table.item_for_iteration)
				a_table.forth
			end
		end

	set_section (a_name: STRING; a_visible: BOOLEAN)
			-- Set section `a_name` visibility.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
		do
			sections.force (a_visible, a_name)
		ensure
			section_set: sections.has (a_name)
		end

	set_list (a_name: STRING; a_items: ARRAYED_LIST [HASH_TABLE [STRING, STRING]])
			-- Set list `a_name` with `a_items`.
			-- Each item is a table of variable -> value.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			items_not_void: a_items /= Void
		do
			lists.force (a_items, a_name)
		ensure
			list_set: lists.has (a_name)
		end

	clear_variables
			-- Clear all variables, sections, and lists.
		do
			variables.wipe_out
			sections.wipe_out
			lists.wipe_out
		ensure
			variables_empty: variables.is_empty
			sections_empty: sections.is_empty
			lists_empty: lists.is_empty
		end

feature -- Rendering

	render: STRING
			-- Render template with current context.
		do
			Result := render_template (template_source, variables)
		ensure
			result_attached: Result /= Void
		end

	render_to_file (a_path: STRING)
			-- Render template and write to file at `a_path`.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_output: STRING
		do
			l_output := render
			create l_file.make_create_read_write (a_path)
			l_file.put_string (l_output)
			l_file.close
		end

feature -- Query

	has_variable (a_name: STRING): BOOLEAN
			-- Is `a_name` defined as a variable?
		require
			name_not_void: a_name /= Void
		do
			Result := variables.has (a_name)
		end

	required_variables: ARRAYED_LIST [STRING]
			-- List of variables used in template.
		do
			Result := extract_variables (template_source)
		ensure
			result_attached: Result /= Void
		end

	is_valid: BOOLEAN
			-- Is template syntactically valid?
		do
			Result := last_error = Void
		end

	last_error: detachable STRING
			-- Last error message, if any.

	template_source: STRING
			-- The template source string.

	escape_html_enabled: BOOLEAN
			-- Is HTML escaping enabled?

	missing_variable_policy: INTEGER
			-- Policy for missing variables.

feature -- Constants

	Policy_empty_string: INTEGER = 1
	Policy_raise_exception: INTEGER = 2
	Policy_keep_placeholder: INTEGER = 3

	Variable_start: STRING = "{{"
	Variable_end: STRING = "}}"
	Section_start: STRING = "{{#"
	Section_end: STRING = "{{/"
	Inverted_section: STRING = "{{^"
	Comment_start: STRING = "{{!"
	Raw_start: STRING = "{{{"
	Raw_end: STRING = "}}}"
	Partial_start: STRING = "{{>"

feature {NONE} -- Implementation

	variables: HASH_TABLE [STRING, STRING]
			-- Variable name -> value map.

	sections: HASH_TABLE [BOOLEAN, STRING]
			-- Section name -> visible map.

	lists: HASH_TABLE [ARRAYED_LIST [HASH_TABLE [STRING, STRING]], STRING]
			-- List name -> items map.

	partials: HASH_TABLE [SIMPLE_TEMPLATE, STRING]
			-- Partial name -> template map.

	render_template (a_source: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
			-- Render `a_source` with `a_context`.
		require
			source_not_void: a_source /= Void
			context_not_void: a_context /= Void
		local
			i, j, k: INTEGER
			l_source: STRING
			l_tag_start, l_tag_end: INTEGER
			l_tag_content: STRING
			l_var_name: STRING
			l_value: STRING
			l_section_name: STRING
			l_section_content: STRING
			l_section_end_tag: STRING
		do
			create Result.make (a_source.count)
			l_source := a_source
			i := 1

			from
			until
				i > l_source.count
			loop
				-- Look for comment
				if i + 2 <= l_source.count and then l_source.substring (i, i + 2).same_string ("{{!") then
					-- Comment: find closing }}
					j := l_source.substring_index ("}}", i + 3)
					if j > 0 then
						i := j + 2
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				-- Look for raw/unescaped
				elseif i + 2 <= l_source.count and then l_source.substring (i, i + 2).same_string ("{{{") then
					j := l_source.substring_index ("}}}", i + 3)
					if j > 0 then
						l_var_name := l_source.substring (i + 3, j - 1)
						l_var_name.adjust
						l_value := get_variable (l_var_name, a_context)
						Result.append (l_value) -- No escaping
						i := j + 3
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				-- Look for inverted section
				elseif i + 2 <= l_source.count and then l_source.substring (i, i + 2).same_string ("{{^") then
					j := l_source.substring_index ("}}", i + 3)
					if j > 0 then
						l_section_name := l_source.substring (i + 3, j - 1)
						l_section_name.adjust
						l_section_end_tag := "{{/" + l_section_name + "}}"
						k := l_source.substring_index (l_section_end_tag, j + 2)
						if k > 0 then
							l_section_content := l_source.substring (j + 2, k - 1)
							-- Render only if section is falsy
							if not is_section_truthy (l_section_name, a_context) then
								Result.append (render_template (l_section_content, a_context))
							end
							i := k + l_section_end_tag.count
						else
							Result.append_character (l_source.item (i))
							i := i + 1
						end
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				-- Look for section start
				elseif i + 2 <= l_source.count and then l_source.substring (i, i + 2).same_string ("{{#") then
					j := l_source.substring_index ("}}", i + 3)
					if j > 0 then
						l_section_name := l_source.substring (i + 3, j - 1)
						l_section_name.adjust
						l_section_end_tag := "{{/" + l_section_name + "}}"
						k := l_source.substring_index (l_section_end_tag, j + 2)
						if k > 0 then
							l_section_content := l_source.substring (j + 2, k - 1)
							Result.append (render_section (l_section_name, l_section_content, a_context))
							i := k + l_section_end_tag.count
						else
							Result.append_character (l_source.item (i))
							i := i + 1
						end
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				-- Look for partial
				elseif i + 2 <= l_source.count and then l_source.substring (i, i + 2).same_string ("{{>") then
					j := l_source.substring_index ("}}", i + 3)
					if j > 0 then
						l_var_name := l_source.substring (i + 3, j - 1)
						l_var_name.adjust
						if attached partials.item (l_var_name) as l_partial then
							-- Render partial with current context
							from
								a_context.start
							until
								a_context.after
							loop
								l_partial.set_variable (a_context.key_for_iteration, a_context.item_for_iteration)
								a_context.forth
							end
							Result.append (l_partial.render)
						end
						i := j + 2
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				-- Look for variable
				elseif i + 1 <= l_source.count and then l_source.substring (i, i + 1).same_string ("{{") then
					j := l_source.substring_index ("}}", i + 2)
					if j > 0 then
						l_var_name := l_source.substring (i + 2, j - 1)
						l_var_name.adjust
						l_value := get_variable (l_var_name, a_context)
						if escape_html_enabled then
							Result.append (escape_html (l_value))
						else
							Result.append (l_value)
						end
						i := j + 2
					else
						Result.append_character (l_source.item (i))
						i := i + 1
					end

				else
					Result.append_character (l_source.item (i))
					i := i + 1
				end
			variant
				l_source.count - i + 2
			end
		end

	render_section (a_name: STRING; a_content: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
			-- Render section `a_name` with `a_content`.
		require
			name_not_void: a_name /= Void
			content_not_void: a_content /= Void
			context_not_void: a_context /= Void
		local
			l_list: detachable ARRAYED_LIST [HASH_TABLE [STRING, STRING]]
			l_item_context: HASH_TABLE [STRING, STRING]
			l_item: HASH_TABLE [STRING, STRING]
		do
			create Result.make (a_content.count)

			-- Check if it's a list
			l_list := lists.item (a_name)
			if attached l_list as ll then
				-- Iterate over list items
				across ll as list_cursor loop
					l_item := list_cursor
					-- Create merged context
					create l_item_context.make (a_context.count + l_item.count)
					from
						a_context.start
					until
						a_context.after
					loop
						l_item_context.force (a_context.item_for_iteration, a_context.key_for_iteration)
						a_context.forth
					end
					from
						l_item.start
					until
						l_item.after
					loop
						l_item_context.force (l_item.item_for_iteration, l_item.key_for_iteration)
						l_item.forth
					end
					Result.append (render_template (a_content, l_item_context))
				end
			elseif is_section_truthy (a_name, a_context) then
				-- Render once if section is truthy
				Result.append (render_template (a_content, a_context))
			end
		end

	is_section_truthy (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): BOOLEAN
			-- Is section `a_name` truthy?
		require
			name_not_void: a_name /= Void
		local
			l_value: detachable STRING
		do
			-- Check explicit sections first
			if sections.has (a_name) then
				Result := sections.item (a_name)
			elseif lists.has (a_name) then
				-- List is truthy if not empty
				if attached lists.item (a_name) as ll then
					Result := not ll.is_empty
				end
			else
				-- Check context variable
				l_value := a_context.item (a_name)
				if l_value /= Void then
					Result := not l_value.is_empty and then
							  not l_value.same_string ("false") and then
							  not l_value.same_string ("0")
				else
					l_value := variables.item (a_name)
					if l_value /= Void then
						Result := not l_value.is_empty and then
								  not l_value.same_string ("false") and then
								  not l_value.same_string ("0")
					end
				end
			end
		end

	get_variable (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
			-- Get value of variable `a_name`.
		require
			name_not_void: a_name /= Void
			context_not_void: a_context /= Void
		local
			l_value: detachable STRING
		do
			-- Check context first
			l_value := a_context.item (a_name)
			if l_value = Void then
				-- Check global variables
				l_value := variables.item (a_name)
			end

			if l_value /= Void then
				Result := l_value
			else
				inspect missing_variable_policy
				when Policy_empty_string then
					Result := ""
				when Policy_keep_placeholder then
					Result := "{{" + a_name + "}}"
				when Policy_raise_exception then
					Result := ""
					last_error := "Missing variable: " + a_name
				else
					Result := ""
				end
			end
		ensure
			result_attached: Result /= Void
		end

	escape_html (a_value: STRING): STRING
			-- HTML escape `a_value`.
		require
			value_not_void: a_value /= Void
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_value.count)
			from
				i := 1
			until
				i > a_value.count
			loop
				c := a_value.item (i)
				inspect c
				when '&' then
					Result.append ("&amp;")
				when '<' then
					Result.append ("&lt;")
				when '>' then
					Result.append ("&gt;")
				when '"' then
					Result.append ("&quot;")
				when '%'' then
					Result.append ("&#39;")
				else
					Result.append_character (c)
				end
				i := i + 1
			variant
				a_value.count - i + 1
			end
		ensure
			result_attached: Result /= Void
		end

	extract_variables (a_source: STRING): ARRAYED_LIST [STRING]
			-- Extract variable names from `a_source`.
		require
			source_not_void: a_source /= Void
		local
			i, j: INTEGER
			l_name: STRING
		do
			create Result.make (10)
			i := 1

			from
			until
				i > a_source.count
			loop
				if i + 1 <= a_source.count and then a_source.substring (i, i + 1).same_string ("{{") then
					-- Skip special tags
					if i + 2 <= a_source.count and then
					   (a_source.item (i + 2) = '#' or
					    a_source.item (i + 2) = '/' or
					    a_source.item (i + 2) = '^' or
					    a_source.item (i + 2) = '!' or
					    a_source.item (i + 2) = '>' or
					    a_source.item (i + 2) = '{')
					then
						i := i + 3
					else
						j := a_source.substring_index ("}}", i + 2)
						if j > 0 then
							l_name := a_source.substring (i + 2, j - 1)
							l_name.adjust
							if not list_has_string (Result, l_name) then
								Result.extend (l_name)
							end
							i := j + 2
						else
							i := i + 1
						end
					end
				else
					i := i + 1
				end
			variant
				a_source.count - i + 2
			end
		end

	list_has_string (a_list: ARRAYED_LIST [STRING]; a_string: STRING): BOOLEAN
			-- Does `a_list` contain `a_string`?
		require
			list_not_void: a_list /= Void
			string_not_void: a_string /= Void
		do
			across a_list as item loop
				if item.same_string (a_string) then
					Result := True
				end
			end
		end

invariant
	template_source_attached: template_source /= Void
	variables_attached: variables /= Void
	sections_attached: sections /= Void
	lists_attached: lists /= Void
	partials_attached: partials /= Void

end
