note
	description: "Compiles template source into AST nodes"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_TEMPLATE_COMPILER

create
	make

feature {NONE} -- Initialization

	make
			-- Create compiler.
		do
			last_error := Void
		end

feature -- Access

	last_error: detachable STRING
			-- Last compilation error, if any.

feature -- Status

	has_error: BOOLEAN
			-- Did last compilation produce an error?
		do
			Result := last_error /= Void
		end

feature -- Compilation

	compile (a_source: STRING): ST_COMPILED_TEMPLATE
			-- Compile template source into AST.
		require
			source_attached: a_source /= Void
		local
			l_nodes: ARRAYED_LIST [ST_NODE]
		do
			last_error := Void
			l_nodes := parse_template (a_source)
			create Result.make (l_nodes)
			Result.set_source_hash (compute_hash (a_source))
		ensure
			result_attached: Result /= Void
		end

	compile_from_file (a_path: STRING): ST_COMPILED_TEMPLATE
			-- Compile template from file.
		require
			path_attached: a_path /= Void
			path_not_empty: not a_path.is_empty
			no_traversal: not a_path.has_substring ("..")
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				create l_content.make (l_file.count)
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				l_file.close
				Result := compile (l_content)
			else
				last_error := "Cannot read file: " + a_path
				create Result.make (create {ARRAYED_LIST [ST_NODE]}.make (0))
			end
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Parsing

	parse_template (a_source: STRING): ARRAYED_LIST [ST_NODE]
			-- Parse template into nodes.
		require
			source_attached: a_source /= Void
		local
			pos, tag_start, tag_end: INTEGER
			tag_content, var_name, section_name: STRING
			section_end_tag: STRING
			section_end_pos: INTEGER
			section_content: STRING
			child_nodes: ARRAYED_LIST [ST_NODE]
		do
			create Result.make (10)
			pos := 1

			from until pos > a_source.count loop
				-- Look for comment {{!
				if pos + 2 <= a_source.count and then a_source.substring (pos, pos + 2).same_string ("{{!") then
					tag_end := a_source.substring_index ("}}", pos + 3)
					if tag_end > 0 then
						tag_content := a_source.substring (pos + 3, tag_end - 1)
						Result.extend (create {ST_COMMENT_NODE}.make (tag_content))
						pos := tag_end + 2
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Look for raw {{{
				elseif pos + 2 <= a_source.count and then a_source.substring (pos, pos + 2).same_string ("{{{") then
					tag_end := a_source.substring_index ("}}}", pos + 3)
					if tag_end > 0 then
						var_name := a_source.substring (pos + 3, tag_end - 1)
						var_name.adjust
						Result.extend (create {ST_VARIABLE_NODE}.make (var_name, False))
						pos := tag_end + 3
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Look for inverted section {{^
				elseif pos + 2 <= a_source.count and then a_source.substring (pos, pos + 2).same_string ("{{^") then
					tag_end := a_source.substring_index ("}}", pos + 3)
					if tag_end > 0 then
						section_name := a_source.substring (pos + 3, tag_end - 1)
						section_name.adjust
						section_end_tag := "{{/" + section_name + "}}"
						section_end_pos := a_source.substring_index (section_end_tag, tag_end + 2)
						if section_end_pos > 0 then
							section_content := a_source.substring (tag_end + 2, section_end_pos - 1)
							child_nodes := parse_template (section_content)
							Result.extend (create {ST_SECTION_NODE}.make (section_name, child_nodes, True))
							pos := section_end_pos + section_end_tag.count
						else
							last_error := "Missing closing tag for inverted section: " + section_name
							add_text_char (Result, a_source.item (pos))
							pos := pos + 1
						end
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Look for section {{#
				elseif pos + 2 <= a_source.count and then a_source.substring (pos, pos + 2).same_string ("{{#") then
					tag_end := a_source.substring_index ("}}", pos + 3)
					if tag_end > 0 then
						section_name := a_source.substring (pos + 3, tag_end - 1)
						section_name.adjust
						section_end_tag := "{{/" + section_name + "}}"
						section_end_pos := find_matching_section_end (a_source, section_name, tag_end + 2)
						if section_end_pos > 0 then
							section_content := a_source.substring (tag_end + 2, section_end_pos - 1)
							child_nodes := parse_template (section_content)
							Result.extend (create {ST_SECTION_NODE}.make (section_name, child_nodes, False))
							pos := section_end_pos + section_end_tag.count
						else
							last_error := "Missing closing tag for section: " + section_name
							add_text_char (Result, a_source.item (pos))
							pos := pos + 1
						end
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Look for partial {{>
				elseif pos + 2 <= a_source.count and then a_source.substring (pos, pos + 2).same_string ("{{>") then
					tag_end := a_source.substring_index ("}}", pos + 3)
					if tag_end > 0 then
						var_name := a_source.substring (pos + 3, tag_end - 1)
						var_name.adjust
						Result.extend (create {ST_PARTIAL_NODE}.make (var_name))
						pos := tag_end + 2
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Look for variable {{
				elseif pos + 1 <= a_source.count and then a_source.substring (pos, pos + 1).same_string ("{{") then
					tag_end := a_source.substring_index ("}}", pos + 2)
					if tag_end > 0 then
						var_name := a_source.substring (pos + 2, tag_end - 1)
						var_name.adjust
						Result.extend (create {ST_VARIABLE_NODE}.make (var_name, True))
						pos := tag_end + 2
					else
						add_text_char (Result, a_source.item (pos))
						pos := pos + 1
					end

				-- Plain text
				else
					add_text_char (Result, a_source.item (pos))
					pos := pos + 1
				end
			end
		ensure
			result_attached: Result /= Void
		end

	find_matching_section_end (a_source: STRING; a_name: STRING; a_start: INTEGER): INTEGER
			-- Find position of matching {{/name}} accounting for nested sections.
		local
			depth, pos: INTEGER
			end_tag, start_tag: STRING
		do
			depth := 1
			pos := a_start
			end_tag := "{{/" + a_name + "}}"
			start_tag := "{{#" + a_name + "}}"

			from until pos > a_source.count or depth = 0 loop
				if a_source.substring_index (start_tag, pos) = pos then
					depth := depth + 1
					pos := pos + start_tag.count
				elseif a_source.substring_index (end_tag, pos) = pos then
					depth := depth - 1
					if depth = 0 then
						Result := pos
					else
						pos := pos + end_tag.count
					end
				else
					pos := pos + 1
				end
			end
		end

	add_text_char (a_nodes: ARRAYED_LIST [ST_NODE]; a_char: CHARACTER)
			-- Add character to current text node, or create new one.
		local
			l_text: ST_TEXT_NODE
		do
			if not a_nodes.is_empty and then attached {ST_TEXT_NODE} a_nodes.last as t then
				-- Append to existing text node
				t.text.append_character (a_char)
			else
				-- Create new text node
				create l_text.make (create {STRING}.make_filled (a_char, 1))
				a_nodes.extend (l_text)
			end
		end

	compute_hash (a_source: STRING): STRING
			-- Compute simple hash of source for cache validation.
		require
			source_attached: a_source /= Void
		local
			h: INTEGER
			i: INTEGER
		do
			h := 0
			from i := 1 until i > a_source.count loop
				h := ((h * 31) + a_source.item (i).code) \\ 2147483647
				i := i + 1
			end
			Result := h.out
		ensure
			result_attached: Result /= Void
		end

end
