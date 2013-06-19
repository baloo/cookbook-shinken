include_recipe "mongodb::10gen_repo"
include_recipe "mongodb"
include_recipe "python"

package "gcc"

python_pip "pymongo" do
  action :install
end

