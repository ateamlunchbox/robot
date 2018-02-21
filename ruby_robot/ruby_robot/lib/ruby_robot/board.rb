#
# This class is a board which is essentially a 2D
# array even though Ruby doesn't support 2D arrays
# like in other languages.
#
# As per the API instructions, (0,0) is considered
# to be the SOUTH WEST most corner.
#
class Board
	def initialize(width, height)
		@playing_field = Array.new(width) { Array.new(height) }
	end
end
