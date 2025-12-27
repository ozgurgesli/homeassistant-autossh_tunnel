# homeassistant-autossh_tunnel

this thing is to create an (auto)ssh connection to a public ip server, and create a remote port forwarding, so that, httpD can act as a proxy to give access to homeassistant behind a NAT.

Created for myself, so minimal documentation.

Change the settings / system / network / name first and decide on what to use as local name for your HA. (default: homeassistant)

1. INSTALLATION

on HA Web UI:
 
Settings → Add-ons → Add-on Store
(top right) ⋮ → Repositories

Add this exact URL:

''https://github.com/ozgurgesli/homeassistant-autossh_tunnel''

Then refresh the page and check if “AutoSSH Tunnel” appears under add-ons. Install it. 

After install switch to config tab, and do the settings. (username and server name, port etc. use the local name for target_address like homeassistant:8123)

Start it, and see the logs to obtain the pubkey to put on your server's authorized_keys.

Now when you run it logs should show connection succeed.


setup your server's http proxy config, so that requests to certain VHOST/domain route to your target_addr:target_port 


Test the http://vhostaddress/  if proxy and SSH tunnel works, you should get a 400 Bad Request. This is because homeassistant is not accepting requests forwarded by your proxy. Goto settings/system/logs you should see something like :
A request from a reverse proxy was received from 192.168.0.121, but your HTTP integration is not set-up for reverse proxies



2 ENABLE HTTP PORT FORWARDING 

at the end of your configuration.yaml, put the following block. (use addon File Editor to edit that file)

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.0.0/24


Then you need to restart. Config reload doesn't work.


