note
	description: "Test class for template object rendering"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_PERSON

create
	make,
	default_create

feature {NONE} -- Initialization

	make (a_name: STRING; a_age: INTEGER)
			-- Create person with name and age.
		require
			name_not_empty: not a_name.is_empty
			age_positive: a_age >= 0
		do
			name := a_name
			age := a_age
		ensure
			name_set: name = a_name
			age_set: age = a_age
		end

feature -- Access

	name: STRING
			-- Person's name.
		attribute
			create Result.make_empty
		end

	age: INTEGER
			-- Person's age.

invariant
	name_exists: name /= Void

end
