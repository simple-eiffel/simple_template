note
	description: "Collects and reports template errors"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	ST_ERROR_COLLECTOR

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty error collector.
		do
			create errors.make (5)
			create warnings.make (5)
		ensure
			no_errors: not has_errors
			no_warnings: not has_warnings
		end

feature -- Access

	errors: ARRAYED_LIST [ST_TEMPLATE_ERROR]
			-- Collected errors.

	warnings: ARRAYED_LIST [ST_TEMPLATE_ERROR]
			-- Collected warnings.

	error_count: INTEGER
			-- Number of errors.
		do
			Result := errors.count
		end

	warning_count: INTEGER
			-- Number of warnings.
		do
			Result := warnings.count
		end

	first_error: detachable ST_TEMPLATE_ERROR
			-- First error, if any.
		do
			if not errors.is_empty then
				Result := errors.first
			end
		end

feature -- Status

	has_errors: BOOLEAN
			-- Are there any errors?
		do
			Result := not errors.is_empty
		end

	has_warnings: BOOLEAN
			-- Are there any warnings?
		do
			Result := not warnings.is_empty
		end

feature -- Error Registration

	add_error (a_code: STRING; a_message: STRING)
			-- Add error without location.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
		do
			errors.extend (create {ST_TEMPLATE_ERROR}.make (a_code, a_message))
		ensure
			error_added: error_count = old error_count + 1
		end

	add_error_at (a_code: STRING; a_message: STRING; a_line, a_column: INTEGER; a_context: STRING)
			-- Add error with location.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
			context_attached: a_context /= Void
		do
			errors.extend (create {ST_TEMPLATE_ERROR}.make_with_location (a_code, a_message, a_line, a_column, a_context))
		ensure
			error_added: error_count = old error_count + 1
		end

	add_warning (a_code: STRING; a_message: STRING)
			-- Add warning without location.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
		do
			warnings.extend (create {ST_TEMPLATE_ERROR}.make (a_code, a_message))
		ensure
			warning_added: warning_count = old warning_count + 1
		end

	add_warning_at (a_code: STRING; a_message: STRING; a_line, a_column: INTEGER; a_context: STRING)
			-- Add warning with location.
		require
			code_attached: a_code /= Void
			message_attached: a_message /= Void
			context_attached: a_context /= Void
		do
			warnings.extend (create {ST_TEMPLATE_ERROR}.make_with_location (a_code, a_message, a_line, a_column, a_context))
		ensure
			warning_added: warning_count = old warning_count + 1
		end

feature -- Common Errors

	add_syntax_error (a_message: STRING; a_line: INTEGER; a_context: STRING)
			-- Add syntax error.
		require
			message_attached: a_message /= Void
			context_attached: a_context /= Void
		do
			add_error_at ("SYNTAX", a_message, a_line, 0, a_context)
		end

	add_missing_variable (a_name: STRING; a_line: INTEGER)
			-- Add missing variable error.
		require
			name_attached: a_name /= Void
		do
			add_error_at ("MISSING_VAR", "Undefined variable: " + a_name, a_line, 0, "{{" + a_name + "}}")
		end

	add_unclosed_tag (a_tag: STRING; a_line: INTEGER)
			-- Add unclosed tag error.
		require
			tag_attached: a_tag /= Void
		do
			add_error_at ("UNCLOSED", "Unclosed tag: " + a_tag, a_line, 0, a_tag)
		end

	add_invalid_expression (a_expr: STRING; a_line: INTEGER)
			-- Add invalid expression error.
		require
			expr_attached: a_expr /= Void
		do
			add_error_at ("INVALID_EXPR", "Invalid expression: " + a_expr, a_line, 0, a_expr)
		end

	add_unknown_filter (a_name: STRING; a_line: INTEGER)
			-- Add unknown filter warning.
		require
			name_attached: a_name /= Void
		do
			add_warning_at ("UNKNOWN_FILTER", "Unknown filter: " + a_name, a_line, 0, "|" + a_name)
		end

	add_division_by_zero (a_expr: STRING; a_line: INTEGER)
			-- Add division by zero error.
		require
			expr_attached: a_expr /= Void
		do
			add_error_at ("DIV_ZERO", "Division by zero in expression", a_line, 0, a_expr)
		end

feature -- Output

	to_string: STRING
			-- Format all errors and warnings as string.
		do
			create Result.make (200)
			if has_errors then
				Result.append ("Errors (" + error_count.out + "):%N")
				across errors as e loop
					Result.append ("  ")
					Result.append (e.to_string)
					Result.append ("%N")
				end
			end
			if has_warnings then
				Result.append ("Warnings (" + warning_count.out + "):%N")
				across warnings as w loop
					Result.append ("  ")
					Result.append (w.to_string)
					Result.append ("%N")
				end
			end
			if not has_errors and not has_warnings then
				Result.append ("No errors or warnings.")
			end
		ensure
			result_attached: Result /= Void
		end

	to_json: STRING
			-- Format all errors as JSON.
		local
			i: INTEGER
		do
			create Result.make (500)
			Result.append ("{%"errors%": [")
			from i := 1 until i > errors.count loop
				if i > 1 then Result.append (", ") end
				Result.append (errors.i_th (i).to_json)
				i := i + 1
			end
			Result.append ("], %"warnings%": [")
			from i := 1 until i > warnings.count loop
				if i > 1 then Result.append (", ") end
				Result.append (warnings.i_th (i).to_json)
				i := i + 1
			end
			Result.append ("]}")
		ensure
			result_attached: Result /= Void
		end

feature -- Clearing

	clear
			-- Remove all errors and warnings.
		do
			errors.wipe_out
			warnings.wipe_out
		ensure
			cleared: not has_errors and not has_warnings
		end

invariant
	errors_attached: errors /= Void
	warnings_attached: warnings /= Void

end
