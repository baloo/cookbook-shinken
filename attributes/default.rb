#
# Cookbook Name:: shinken
# Attributes:: default
#
# Copyright 2013, Arthur Gautier
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#


default["shinken"]["scheduler"  ]["port"] = 7768
default["shinken"]["reactionner"]["port"] = 7769
default["shinken"]["arbiter"    ]["port"] = 7770
default["shinken"]["poller"     ]["port"] = 7771
default["shinken"]["broker"     ]["port"] = 7772
default["shinken"]["receiver"   ]["port"] = 7773


default_variables = {
  "spare"              => 0,
  "weight"             => 1,
  "timeout"            => 3,
  "data_timeout"       => 120,
  "max_check_attempts" => 3,
  "check_interval"     => 60
}

default["shinken"]["scheduler"  ]["variables"] = default_variables
default["shinken"]["arbiter"    ]["variables"] = default_variables
default["shinken"]["poller"     ]["variables"] = default_variables
default["shinken"]["broker"     ]["variables"] = default_variables
default["shinken"]["receiver"   ]["variables"] = default_variables
default["shinken"]["reactionner"]["variables"] = default_variables.merge({
  "manage_sub_realms" => 0,
  "min_workers"       => 1,
  "max_workers"       => 15
})


