note
	description: "Abstract base class for template filters"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ST_FILTER

feature {NONE} -- Initialization

	make
			-- Create filter.
		do
		end

feature -- Access

	name: STRING
			-- Filter name.
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- Application

	apply (a_value: STRING; a_args: STRING): STRING
			-- Apply filter to value with optional arguments.
		require
			value_attached: a_value /= Void
			args_attached: a_args /= Void
		deferred
		ensure
			result_attached: Result /= Void
		end

end
