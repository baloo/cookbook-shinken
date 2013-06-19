case node['platform_family']
when 'rhel'
  default["shinken"]["pnp"]["fpm"] = "php-fpm"
else
  default["shinken"]["pnp"]["fpm"] = "php5-fpm"
end
