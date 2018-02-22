require 'ruby_robot/tabletop'

#
# A Tabletop which is 5x5
#
module RubyRobot
class NetflixTabletop < Tabletop
	def initialize
  	# The instructions say that a Netflix Tabletop
  	# is 5x5
  	super(5, 5)
	end
end
end
