#!/usr/bin/env sh
set -e

scripts_dir="/var/www/html/scripts"
  if [ -d "$scripts_dir" ]; then
    if [ -z "$SKIP_CHMOD" ]; then
      # make scripts executable incase they aren't
      chmod -Rf 750 $scripts_dir; sync;
    fi
    # run scripts in number order
    for i in `ls $scripts_dir`; do $scripts_dir/$i ; done
  else
    echo "Can't find script directory"
  fi

# exec /usr/bin/supervisord -n -c /etc/supervisord.conf

echo "Starting services..."
php-fpm -D
nginx -g "daemon off;"
echo "Ready."