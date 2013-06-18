package "python-xmpp"

cookbook_file "/usr/local/bin/xmppsend" do
  mode 0755
end

template "/usr/local/etc/xmppsend.ini" do
  mode 0644
end
