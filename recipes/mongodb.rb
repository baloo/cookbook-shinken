include_recipe "mongodb::10gen_repo"
include_recipe "mongodb"
include_recipe "python::pip"

package "gcc"
package "python-devel"

python_pip "pymongo" do
  action :install
end

