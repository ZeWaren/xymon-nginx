xymon-nginx
===========
xymon-nginx is a perl script that you can use to monitor a nginx installation and graph its counters into your BB/Hobbit/Xymon server.

![A xymon page featuring some nginx counters](https://raw.github.com/ZeWaren/xymon-nginx/master/example_graphs/xymon_page.png "A xymon page featuring some nginx counters")

How it works
------------

`xymon_nginx.pl` connects to your nginx server status page to get the needed data.

The values are then posted into the host's trends data channel.

Some HTML code is also posted as a status, in order to be able to see the graphs alone on one page (ugly but works). If you only want the graphs to appear in the trends page, you can remove the line that send the status and then set the `TRENDS` variable in `xymonserver.cfg`.

Installation
------------
+ Copy `xymon_nginx.pl` somewhere executable by your xymon client (typically `$HOBBITCLIENTHOME/ext` or `$XYMONCLIENTHOME/ext`). Set the permissions accordingly.
 
Configure you nginx installation to have a status page:

```
    server {
        listen                  10.0.7.10:82 default;
        server_name             _;
        access_log              off;
        server_tokens           off;

        location / {
                stub_status on;
                access_log   off;
                allow 10.0.0.0/16;
                allow 198.51.100.42/28;
                deny all;
        }
    }
```

+ Edit the script to provide the url to the status page.
```
use constant NGINX_STATUS_PAGE => '"http://10.0.7.10:82/"';
```

+ Makes xymon execute the script periodically.
In `hobbitlaunch.cfg` (Hobbit)
```
[nginx]
    ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
    CMD $HOBBITCLIENTHOME/ext/nginx.pl
    LOGFILE $HOBBITCLIENTHOME/logs/hobbit-nginx.log
    INTERVAL 3m
```
or in `clientlaunch.cfg` (Xymon)
```
[nginx]
    ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
    CMD $XYMONCLIENTHOME/ext/nginx.pl
    LOGFILE $XYMONCLIENTLOGS/xymon-nginx.log
    INTERVAL 3m
```

+ Append or include the provided file to `graphs.cfg`.

+ Restart xymon-client.

Sample graphs:
--------------

![Nginx Connections](https://raw.github.com/ZeWaren/xymon-nginx/master/example_graphs/nginx_connections.png "Nginx Connections")

![Nginx Requests](https://raw.github.com/ZeWaren/xymon-nginx/master/example_graphs/nginx_requests.png "Nginx Requests")

Credits:
--------

xymon-nginx was written in February 2014 by: ZeWaren / Erwan Martin <<public@fzwte.net>>.

It is licensed under the MIT License.
