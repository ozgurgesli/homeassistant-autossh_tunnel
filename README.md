# homeassistant-autossh_tunnel

this thing is to create an (auto)ssh connection to a public ip server, and create a remote port forwarding, so that, httpD can act as a proxy to give access to homeassistant behind a NAT.

Created for myself, so minimal documentation.

==INSTALLATION==
on HA Web UI:
 
Settings → Add-ons → Add-on Store
⋮ → Repositories

Add this exact URL:
ohttps://github.com/ozgurgesli/homeassistant-autossh_tunnel

Then refresh the page and check if “AutoSSH Tunnel” appears under add-ons.

