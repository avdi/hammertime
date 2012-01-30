# IN A WORLD... where ruby-debug and IRB is not in the load
# path... one man will raise an exception.
require 'rubygems'
require '../lib/hammertime'

# Clear out load path. Now LoadError will be raised when
# Hammertime tries to load IRB or the debugger.
$:.clear

include Hammertime
raise "Holy smokes!"
