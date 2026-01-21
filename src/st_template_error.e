note
	description: "Structured template error with location information"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_TEMPLATE_ERROR

create
	make,
	make_with_location

feature {NONE} -- Initialization

	make (a_code: STRING; a_message: STRING)
			-- Create error with code and message.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
		do
			code := a_code
			message := a_message
			line := 0
			column := 0
			context := ""
		ensure
			code_set: code = a_code
			message_set: message = a_message
		end

	make_with_location (a_code: STRING; a_message: STRING; a_line, a_column: INTEGER; a_context: STRING)
			-- Create error with full location information.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
			context_attached: a_context /= Void
			valid_line: a_line >= 0
			valid_column: a_column >= 0
		do
			code := a_code
			message := a_message
			line := a_line
			column := a_column
			context := a_context
		ensure
			code_set: code = a_code
			message_set: message = a_message
			line_set: line = a_line
			column_set: column = a_column
			context_set: context = a_context
		end

feature -- Access

	code: STRING
			-- Error code (e.g., "E001", "SYNTAX", "MISSING_VAR").

	message: STRING
			-- Human-readable error message.

	line: INTEGER
			-- Line number where error occurred (1-based, 0 if unknown).

	column: INTEGER
			-- Column number where error occurred (1-based, 0 if unknown).

	context: STRING
			-- Source context around error (snippet of template).

feature -- Status

	has_location: BOOLEAN
			-- Is location information available?
		do
			Result := line > 0
		end

feature -- Output

	to_string: STRING
			-- Full error message with location.
		do
			create Result.make (100)
			Result.append ("[")
			Result.append (code)
			Result.append ("] ")
			Result.append (message)
			if has_location then
				Result.append (" (line ")
				Result.append (line.out)
				if column > 0 then
					Result.append (", column ")
					Result.append (column.out)
				end
				Result.append (")")
			end
			if not context.is_empty then
				Result.append ("%N  --> ")
				Result.append (context)
			end
		ensure
			result_attached: Result /= Void
		end

	to_json: STRING
			-- JSON representation of error.
		do
			create Result.make (200)
			Result.append ("{")
			Result.append ("%"code%": %"")
			Result.append (code)
			Result.append ("%", %"message%": %"")
			Result.append (escaped_json (message))
			Result.append ("%"")
			if has_location then
				Result.append (", %"line%": ")
				Result.append (line.out)
				if column > 0 then
					Result.append (", %"column%": ")
					Result.append (column.out)
				end
			end
			if not context.is_empty then
				Result.append (", %"context%": %"")
				Result.append (escaped_json (context))
				Result.append ("%"")
			end
			Result.append ("}")
		ensure
			result_attached: Result /= Void
		end

feature {NONE} -- Implementation

	escaped_json (a_str: STRING): STRING
			-- Escape string for JSON.
		local
			i: INTEGER
			c: CHARACTER
		do
			create Result.make (a_str.count)
			from i := 1 until i > a_str.count loop
				c := a_str.item (i)
				inspect c
				when '"' then Result.append ("\%"")
				when '\' then Result.append ("\\")
				when '%N' then Result.append ("\n")
				when '%R' then Result.append ("\r")
				when '%T' then Result.append ("\t")
				else Result.append_character (c)
				end
				i := i + 1
			end
		ensure
			result_attached: Result /= Void
		end

invariant
	code_attached: code /= Void
	message_attached: message /= Void
	context_attached: context /= Void
	valid_line: line >= 0
	valid_column: column >= 0

end
