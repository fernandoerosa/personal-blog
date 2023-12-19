#!/bin/bash
    php composer.phar run-script post-root-package-install && \
    php artisan migrate && \
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
