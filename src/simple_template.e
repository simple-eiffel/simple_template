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
			create variables.make (Default_variables_capacity)
			create sections.make (Default_sections_capacity)
			create lists.make (Default_lists_capacity)
			create partials.make (Default_partials_capacity)
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
			-- ASSAULT: expose V15 path traversal vulnerability
			no_parent_traversal: not a_path.has_substring ("..")
			no_absolute_unix: a_path.count > 0 implies a_path.item (1) /= '/'
			no_windows_drive: a_path.count >= 2 implies not (a_path.item (2) = ':')
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

feature -- Encoding Detection (simple_encoding integration)

	detect_file_encoding (a_path: STRING): STRING
			-- Detect encoding of template file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
			l_detector: SIMPLE_ENCODING_DETECTOR
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				create l_content.make (l_file.count.min (1024))
				l_file.read_stream (l_file.count.min (1024))
				l_content := l_file.last_string
				l_file.close
				create l_detector.make
				if attached l_detector.detect_encoding (l_content) as l_enc then
					Result := l_enc.to_string_8
				else
					Result := "Unknown"
				end
			else
				Result := "Unknown"
			end
		ensure
			result_exists: Result /= Void
		end

	has_utf8_bom (a_content: STRING): BOOLEAN
			-- Does `a_content` start with UTF-8 BOM?
		require
			content_not_void: a_content /= Void
		local
			l_detector: SIMPLE_ENCODING_DETECTOR
		do
			create l_detector.make
			Result := l_detector.has_utf8_bom (a_content)
		end

	strip_bom (a_content: STRING): STRING
			-- Return `a_content` with BOM removed if present.
		require
			content_not_void: a_content /= Void
		local
			l_detector: SIMPLE_ENCODING_DETECTOR
		do
			create l_detector.make
			Result := l_detector.strip_bom (a_content)
		ensure
			result_exists: Result /= Void
		end

feature -- Object Rendering (simple_reflection integration)

	set_variables_from_object (a_object: ANY)
			-- Set template variables from object fields.
			-- Each field becomes a variable with its value converted to string.
		require
			object_exists: a_object /= Void
		local
			l_reflected: SIMPLE_REFLECTED_OBJECT
			l_field: SIMPLE_FIELD_INFO
			l_value: detachable ANY
			i: INTEGER
		do
			create l_reflected.make (a_object)
			from
				i := 1
			until
				i > l_reflected.type_info.fields.count
			loop
				l_field := l_reflected.type_info.fields [i]
				l_value := l_field.value (a_object)
				set_variable (l_field.name.to_string_8, value_to_string (l_value))
				i := i + 1
			end
		end

	render_with_object (a_object: ANY): STRING
			-- Render template using object fields as variables.
		require
			object_exists: a_object /= Void
		do
			clear_variables
			set_variables_from_object (a_object)
			Result := render
		ensure
			result_exists: Result /= Void
		end

feature {NONE} -- Value Conversion

	value_to_string (a_value: detachable ANY): STRING
			-- Convert value to string representation for templates.
		do
			if a_value = Void then
				Result := ""
			elseif attached {BOOLEAN} a_value as l_bool then
				Result := if l_bool then "true" else "false" end
			elseif attached {READABLE_STRING_GENERAL} a_value as l_str then
				Result := l_str.to_string_8
			else
				Result := a_value.out
			end
		ensure
			result_exists: Result /= Void
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

	set_variable_any (a_name: STRING; a_value: ANY)
			-- Set variable `a_name` from any value (converts via `.out`).
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			value_not_void: a_value /= Void
		do
			set_variable (a_name, a_value.out)
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

	remove_variable (a_name: STRING)
			-- Remove variable `a_name` if present.
			-- FIX for V10: Allows cleanup of partial state after render.
		require
			name_not_void: a_name /= Void
		do
			variables.remove (a_name)
		ensure
			removed: not has_variable (a_name)
		end

feature -- Rendering

	render: STRING
			-- Render template with current context.
		do
			Result := render_with_depth (0)
		ensure
			result_attached: Result /= Void
			-- ASSAULT: render is a query, should not modify state
			source_unchanged: template_source.same_string (old template_source.twin)
			variables_count_unchanged: variables.count = old variables.count
			sections_count_unchanged: sections.count = old sections.count
			lists_count_unchanged: lists.count = old lists.count
			partials_count_unchanged: partials.count = old partials.count
			-- ASSAULT: expose V11 stale error - empty template can't generate errors
			error_cleared_on_empty: template_source.is_empty implies is_valid
		end

feature {SIMPLE_TEMPLATE} -- Internal rendering

	render_with_depth (a_depth: INTEGER): STRING
			-- Render template with current context at given partial depth.
		require
			valid_depth: a_depth >= 0
		do
			partial_depth := a_depth
			Result := render_template (template_source, variables)
		ensure
			result_attached: Result /= Void
		end

feature -- Rendering (continued)

	render_to_file (a_path: STRING)
			-- Render template and write to file at `a_path`.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
			-- ASSAULT: expose V16 CRITICAL path traversal vulnerability for writes
			no_parent_traversal: not a_path.has_substring ("..")
			no_absolute_unix: a_path.count > 0 implies a_path.item (1) /= '/'
			no_windows_drive: a_path.count >= 2 implies not (a_path.item (2) = ':')
		local
			l_file: PLAIN_TEXT_FILE
			l_output: STRING
		do
			l_output := render
			create l_file.make_create_read_write (a_path)
			l_file.put_string (l_output)
			l_file.close
		end

feature -- Compilation (Phase 3)

	compile: ST_COMPILED_TEMPLATE
			-- Compile this template into an AST for fast repeated rendering.
		local
			l_compiler: ST_TEMPLATE_COMPILER
		do
			create l_compiler.make
			Result := l_compiler.compile (template_source)
		ensure
			result_attached: Result /= Void
		end

	render_compiled: STRING
			-- Render using pre-compiled template (caches compilation).
		do
			if not attached compiled_template then
				compiled_template := compile
			end
			if attached compiled_template as ct then
				Result := ct.render (create_execution_context)
			else
				Result := ""
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Compilation Support

	compiled_template: detachable ST_COMPILED_TEMPLATE
			-- Cached compiled template (lazy initialization).

	create_execution_context: ST_EXECUTION_CONTEXT
			-- Create execution context from current state.
		do
			create Result.make
			Result.set_escape_html (escape_html_enabled)
			Result.set_missing_policy (missing_variable_policy)
			-- Transfer variables
			from variables.start until variables.after loop
				Result.set_variable (variables.key_for_iteration, variables.item_for_iteration)
				variables.forth
			end
			-- Transfer sections
			from sections.start until sections.after loop
				Result.set_section (sections.key_for_iteration, sections.item_for_iteration)
				sections.forth
			end
			-- Transfer lists
			from lists.start until lists.after loop
				Result.set_list (lists.key_for_iteration, lists.item_for_iteration)
				lists.forth
			end
		ensure
			result_attached: Result /= Void
		end

	invalidate_compiled
			-- Invalidate compiled template (call when source changes).
		do
			compiled_template := Void
		ensure
			invalidated: compiled_template = Void
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

	Max_partial_depth: INTEGER = 100
			-- Maximum allowed partial nesting depth (prevents circular partials).

	Default_variables_capacity: INTEGER = 10
			-- Default initial capacity for variables hash table

	Default_sections_capacity: INTEGER = 5
			-- Default initial capacity for sections hash table

	Default_lists_capacity: INTEGER = 5
			-- Default initial capacity for lists hash table

	Default_partials_capacity: INTEGER = 3
			-- Default initial capacity for partials hash table

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

	partial_depth: INTEGER
			-- Current partial nesting depth (for circular detection).

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
			l_i, l_j, l_k: INTEGER
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
			l_i := 1

			from
			until
				l_i > l_source.count
			loop
				-- Look for comment
				if l_i + 2 <= l_source.count and then l_source.substring (l_i, l_i + 2).same_string ("{{!") then
					-- Comment: find closing }}
					l_j := l_source.substring_index ("}}", l_i + 3)
					if l_j > 0 then
						l_i := l_j + 2
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				-- Look for raw/unescaped
				elseif l_i + 2 <= l_source.count and then l_source.substring (l_i, l_i + 2).same_string ("{{{") then
					l_j := l_source.substring_index ("}}}", l_i + 3)
					if l_j > 0 then
						l_var_name := l_source.substring (l_i + 3, l_j - 1)
						l_var_name.adjust
						l_value := get_variable (l_var_name, a_context)
						Result.append (l_value) -- No escaping
						l_i := l_j + 3
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				-- Look for inverted section
				elseif l_i + 2 <= l_source.count and then l_source.substring (l_i, l_i + 2).same_string ("{{^") then
					l_j := l_source.substring_index ("}}", l_i + 3)
					if l_j > 0 then
						l_section_name := l_source.substring (l_i + 3, l_j - 1)
						l_section_name.adjust
						l_section_end_tag := "{{/" + l_section_name + "}}"
						l_k := l_source.substring_index (l_section_end_tag, l_j + 2)
						if l_k > 0 then
							l_section_content := l_source.substring (l_j + 2, l_k - 1)
							-- Render only if section is falsy
							if not is_section_truthy (l_section_name, a_context) then
								Result.append (render_template (l_section_content, a_context))
							end
							l_i := l_k + l_section_end_tag.count
						else
							Result.append_character (l_source.item (l_i))
							l_i := l_i + 1
						end
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				-- Look for section start
				elseif l_i + 2 <= l_source.count and then l_source.substring (l_i, l_i + 2).same_string ("{{#") then
					l_j := l_source.substring_index ("}}", l_i + 3)
					if l_j > 0 then
						l_section_name := l_source.substring (l_i + 3, l_j - 1)
						l_section_name.adjust
						l_section_end_tag := "{{/" + l_section_name + "}}"
						l_k := l_source.substring_index (l_section_end_tag, l_j + 2)
						if l_k > 0 then
							l_section_content := l_source.substring (l_j + 2, l_k - 1)
							Result.append (render_section (l_section_name, l_section_content, a_context))
							l_i := l_k + l_section_end_tag.count
						else
							Result.append_character (l_source.item (l_i))
							l_i := l_i + 1
						end
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				-- Look for partial
				elseif l_i + 2 <= l_source.count and then l_source.substring (l_i, l_i + 2).same_string ("{{>") then
					l_j := l_source.substring_index ("}}", l_i + 3)
					if l_j > 0 then
						l_var_name := l_source.substring (l_i + 3, l_j - 1)
						l_var_name.adjust
						if partial_depth >= Max_partial_depth then
							-- Circular partial protection
							last_error := "Partial depth exceeded (max " + Max_partial_depth.out + "): " + l_var_name
						elseif attached partials.item (l_var_name) as l_partial then
							-- Render partial with current context, passing depth
							-- FIX V10: Track which variables we add so we can remove them after
							from
								a_context.start
							until
								a_context.after
							loop
								l_partial.set_variable (a_context.key_for_iteration, a_context.item_for_iteration)
								a_context.forth
							end
							Result.append (l_partial.render_with_depth (partial_depth + 1))
							-- Propagate any error from partial back to this template
							if attached l_partial.last_error as l_err then
								last_error := l_err
							end
							-- FIX V10: Clean up partial state by removing context variables we added
							from
								a_context.start
							until
								a_context.after
							loop
								l_partial.remove_variable (a_context.key_for_iteration)
								a_context.forth
							end
						end
						l_i := l_j + 2
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				-- Look for variable
				elseif l_i + 1 <= l_source.count and then l_source.substring (l_i, l_i + 1).same_string ("{{") then
					l_j := l_source.substring_index ("}}", l_i + 2)
					if l_j > 0 then
						l_var_name := l_source.substring (l_i + 2, l_j - 1)
						l_var_name.adjust
						l_value := get_variable (l_var_name, a_context)
						if escape_html_enabled then
							Result.append (escape_html (l_value))
						else
							Result.append (l_value)
						end
						l_i := l_j + 2
					else
						Result.append_character (l_source.item (l_i))
						l_i := l_i + 1
					end

				else
					Result.append_character (l_source.item (l_i))
					l_i := l_i + 1
				end
			variant
				l_source.count - l_i + 2
			end
		ensure
			result_attached: Result /= Void
		end

	render_section (a_name: STRING; a_content: STRING; a_context: HASH_TABLE [STRING, STRING]): STRING
			-- Render section `a_name` with `a_content`.
		require
			name_not_void: a_name /= Void
			-- ASSAULT: expose V09 - empty section name in render
			name_not_empty: not a_name.is_empty
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
				across ll as ic_list loop
					l_item := ic_list
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
		ensure
			result_attached: Result /= Void
		end

	is_section_truthy (a_name: STRING; a_context: HASH_TABLE [STRING, STRING]): BOOLEAN
			-- Is section `a_name` truthy?
		require
			name_not_void: a_name /= Void
			-- ASSAULT: expose V09 - empty section name should never reach here
			name_not_empty: not a_name.is_empty
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
			-- ASSAULT: expose V08 - empty variable name should never reach here
			name_not_empty: not a_name.is_empty
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
			l_i: INTEGER
			l_c: CHARACTER
		do
			create Result.make (a_value.count)
			from
				l_i := 1
			until
				l_i > a_value.count
			loop
				l_c := a_value.item (l_i)
				inspect l_c
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
					Result.append_character (l_c)
				end
				l_i := l_i + 1
			variant
				a_value.count - l_i + 1
			end
		ensure
			result_attached: Result /= Void
		end

	extract_variables (a_source: STRING): ARRAYED_LIST [STRING]
			-- Extract variable names from `a_source`.
		require
			source_not_void: a_source /= Void
		local
			l_i, l_j: INTEGER
			l_name: STRING
		do
			create Result.make (Default_variables_capacity)
			l_i := 1

			from
			until
				l_i > a_source.count
			loop
				if l_i + 1 <= a_source.count and then a_source.substring (l_i, l_i + 1).same_string ("{{") then
					-- Skip special tags
					if l_i + 2 <= a_source.count and then
					   (a_source.item (l_i + 2) = '#' or
					    a_source.item (l_i + 2) = '/' or
					    a_source.item (l_i + 2) = '^' or
					    a_source.item (l_i + 2) = '!' or
					    a_source.item (l_i + 2) = '>' or
					    a_source.item (l_i + 2) = '{')
					then
						l_i := l_i + 3
					else
						l_j := a_source.substring_index ("}}", l_i + 2)
						if l_j > 0 then
							l_name := a_source.substring (l_i + 2, l_j - 1)
							l_name.adjust
							if not list_has_string (Result, l_name) then
								Result.extend (l_name)
							end
							l_i := l_j + 2
						else
							l_i := l_i + 1
						end
					end
				else
					l_i := l_i + 1
				end
			variant
				a_source.count - l_i + 2
			end
		ensure
			result_attached: Result /= Void
		end

	list_has_string (a_list: ARRAYED_LIST [STRING]; a_string: STRING): BOOLEAN
			-- Does `a_list` contain `a_string`?
		require
			list_not_void: a_list /= Void
			string_not_void: a_string /= Void
		do
			across a_list as ic_item loop
				if ic_item.same_string (a_string) then
					Result := True
				end
			end
		end

feature -- Directive Rendering (evolicity-style)

	render_with_directives: STRING
			-- Render template processing both directives (#if, #foreach, etc.) and Mustache syntax.
			-- This combines evolicity-style directives with standard Mustache rendering.
		local
			l_processed: STRING
		do
			-- First pass: process directives
			l_processed := process_directives (template_source)
			-- Second pass: standard Mustache rendering
			Result := render_template (l_processed, variables)
		ensure
			result_attached: Result /= Void
		end

	has_directives: BOOLEAN
			-- Does the template contain any directives?
		do
			Result := template_source.has_substring ("#if ") or
					  template_source.has_substring ("#foreach ") or
					  template_source.has_substring ("#across ") or
					  template_source.has_substring ("#include ") or
					  template_source.has_substring ("#evaluate ")
		end

feature {NONE} -- Directive Processing

	process_directives (a_text: STRING): STRING
			-- Process all directives in text and return result.
		local
			l_parser: ST_DIRECTIVE_PARSER
			l_context: ST_CONTEXT
			l_result: STRING
			l_pos: INTEGER
			l_directive_start: INTEGER
			l_directive_end: INTEGER
			l_directive_text: STRING
			l_rendered: STRING
		do
			if not has_directives_in (a_text) then
				Result := a_text
			else
				create l_parser.make
				l_context := create_directive_context

				create l_result.make (a_text.count)
				l_pos := 1

				from until l_pos > a_text.count loop
					-- Find next directive
					l_directive_start := find_next_directive (a_text, l_pos)

					if l_directive_start > 0 then
						-- Add text before directive
						if l_directive_start > l_pos then
							l_result.append (a_text.substring (l_pos, l_directive_start - 1))
						end

						-- Find and process directive
						l_directive_end := find_directive_end (a_text, l_directive_start)
						if l_directive_end > 0 then
							l_directive_text := a_text.substring (l_directive_start, l_directive_end)
							l_rendered := execute_directive (l_parser, l_context, l_directive_text)
							l_result.append (l_rendered)
							l_pos := l_directive_end + 1
						else
							-- Malformed directive, keep as-is
							l_result.append_character (a_text.item (l_directive_start))
							l_pos := l_directive_start + 1
						end
					else
						-- No more directives, append rest
						l_result.append (a_text.substring (l_pos, a_text.count))
						l_pos := a_text.count + 1
					end
				end

				Result := l_result
			end
		ensure
			result_attached: Result /= Void
		end

	has_directives_in (a_text: STRING): BOOLEAN
			-- Does text contain any directives?
		do
			Result := a_text.has_substring ("#if ") or
					  a_text.has_substring ("#foreach ") or
					  a_text.has_substring ("#across ") or
					  a_text.has_substring ("#include ") or
					  a_text.has_substring ("#evaluate ")
		end

	create_directive_context: ST_CONTEXT
			-- Create directive context from current template state.
		do
			create Result.make
			-- Transfer variables
			from variables.start until variables.after loop
				Result.set_variable (variables.key_for_iteration, variables.item_for_iteration)
				variables.forth
			end
			-- Transfer lists
			from lists.start until lists.after loop
				Result.set_list (lists.key_for_iteration, lists.item_for_iteration)
				lists.forth
			end
		end

	find_next_directive (a_text: STRING; a_start: INTEGER): INTEGER
			-- Find position of next directive starting at or after a_start.
			-- Returns 0 if no directive found.
		local
			l_if, l_foreach, l_across, l_include, l_evaluate: INTEGER
			l_min: INTEGER
		do
			l_if := a_text.substring_index ("#if ", a_start)
			l_foreach := a_text.substring_index ("#foreach ", a_start)
			l_across := a_text.substring_index ("#across ", a_start)
			l_include := a_text.substring_index ("#include ", a_start)
			l_evaluate := a_text.substring_index ("#evaluate ", a_start)

			-- Find minimum non-zero position
			l_min := 0
			if l_if > 0 and then (l_min = 0 or l_if < l_min) then l_min := l_if end
			if l_foreach > 0 and then (l_min = 0 or l_foreach < l_min) then l_min := l_foreach end
			if l_across > 0 and then (l_min = 0 or l_across < l_min) then l_min := l_across end
			if l_include > 0 and then (l_min = 0 or l_include < l_min) then l_min := l_include end
			if l_evaluate > 0 and then (l_min = 0 or l_evaluate < l_min) then l_min := l_evaluate end

			Result := l_min
		end

	find_directive_end (a_text: STRING; a_start: INTEGER): INTEGER
			-- Find end position of directive starting at a_start.
		local
			l_end_pos: INTEGER
			l_newline_pos: INTEGER
		do
			-- Check which directive type
			if a_text.substring_index ("#if ", a_start) = a_start or
			   a_text.substring_index ("#foreach ", a_start) = a_start or
			   a_text.substring_index ("#across ", a_start) = a_start then
				-- Block directive - find matching #end
				l_end_pos := find_matching_directive_end (a_text, a_start)
				if l_end_pos > 0 then
					Result := l_end_pos + 3 -- Include "#end"
				end
			else
				-- Line directive (#include, #evaluate) - find end of line
				l_newline_pos := a_text.index_of ('%N', a_start)
				if l_newline_pos > 0 then
					Result := l_newline_pos - 1
				else
					Result := a_text.count
				end
			end
		end

	find_matching_directive_end (a_text: STRING; a_start: INTEGER): INTEGER
			-- Find matching #end for directive starting at a_start.
		local
			l_depth: INTEGER
			l_pos: INTEGER
		do
			l_depth := 1
			l_pos := a_start + 1

			from until l_pos > a_text.count or l_depth = 0 loop
				if l_pos + 3 <= a_text.count then
					if a_text.substring (l_pos, l_pos + 3).same_string ("#if ") or
					   a_text.substring_index ("#foreach ", l_pos) = l_pos or
					   a_text.substring_index ("#across ", l_pos) = l_pos then
						l_depth := l_depth + 1
					end
					if a_text.substring (l_pos, l_pos + 3).same_string ("#end") then
						l_depth := l_depth - 1
						if l_depth = 0 then
							Result := l_pos
						end
					end
				end
				l_pos := l_pos + 1
			end
		end

	execute_directive (a_parser: ST_DIRECTIVE_PARSER; a_context: ST_CONTEXT; a_text: STRING): STRING
			-- Execute a single directive and return result.
		do
			if a_text.substring_index ("#if ", 1) = 1 then
				if attached a_parser.parse_if (a_text) as d then
					Result := d.execute (a_context)
				else
					Result := ""
				end
			elseif a_text.substring_index ("#foreach ", 1) = 1 then
				if attached a_parser.parse_foreach (a_text) as d then
					Result := d.execute (a_context)
				else
					Result := ""
				end
			elseif a_text.substring_index ("#across ", 1) = 1 then
				if attached a_parser.parse_across (a_text) as d then
					Result := d.execute (a_context)
				else
					Result := ""
				end
			elseif a_text.substring_index ("#include ", 1) = 1 then
				if attached a_parser.parse_include (a_text) as d then
					Result := d.execute (a_context)
				else
					Result := ""
				end
			elseif a_text.substring_index ("#evaluate ", 1) = 1 then
				if attached a_parser.parse_evaluate (a_text) as d then
					Result := d.execute (a_context)
				else
					Result := ""
				end
			else
				Result := ""
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	template_source_attached: template_source /= Void
	variables_attached: variables /= Void
	sections_attached: sections /= Void
	lists_attached: lists /= Void
	partials_attached: partials /= Void
	valid_policy: missing_variable_policy >= Policy_empty_string and missing_variable_policy <= Policy_keep_placeholder
	non_negative_depth: partial_depth >= 0

end
