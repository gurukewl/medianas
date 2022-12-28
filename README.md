medianas - Webinterface
=======================

Browser Administration for Linux-Based NAS

FEATURES
 - browser interface for configuring WiFi, filesystem mountpoints, autostarts, display resolution, init-scripts, etc.
 - no need to ssh to your device any more
 - Plugin configuration to add new features and customize navigation
 - custom CSS and logo possible 
 - easy to use even for non-programmers (configure mount-points, samba-shares, start/stop programs)
 - responsive layout - optimized for mobile devices

HOW TO INSTALL
 - install & configure apache webserver with php5 support: "apt-get install apache2 php5 php5-json"
 - Enable mod_rewrite for Apache "a2enmod rewrite"
 - Add "/etc/apache2/sites_enabled/medianas.conf" from repository "CONFIG_SYSTEM/apache2/" to point to the medianas directory and remove default from "/etc/apache2/sites_enabled/"
 - drop the files from the medianas-Folder of this repository to "var/www/medianas/"
 - reload webserver "/etc/init.d/apache2 reload"

HOW TO CONFIGURE
 - every task for the browserinterface needs little setup to work properly
 - the browser interface itsself uses script-files and configuration-files located in "/opt/medianas"
 - some file-permissions and sudoer-configs need to be set in order to get wifi and other things working in the medianas-interface
 - activate or deactivate Plugins on "Reboot / Reset"-Tab of webinterface

FILESTRUCTURE OF medianas PROJECT
 - Webinterface is under /medianas
 - Config-Files for /etc/ under /CONFIG_SYSTEM
 - Config-Files for /home/USER under /CONFIG_USER
 - Packages with Scripts for /opt/ under /opt/

HOW TO CREATE NEW PLUGINS
- copy an existing Plugin (e.g. a small one that exists):
    <i>cp -r /var/www/medianas/application/plugins/squeezeplug /var/www/medianas/application/plugins/myplugin</i>
- change the Pluginname /var/www/medianas/application/plugins/myplugin/controller/Setup.php
- there is always a backend- (folder "controller") and a frontend-file (folder "view"). Both have the same name and go together (see MVC-Schema).
- if you want to call shell scripts best use the function $this->writeDynamicScript(array("SCRIPT GOES HERE")); 
- you can work with the return value of your script and pass it to the view 
- the view is used to place buttons and output data as well as take input data from forms
- to activate your new plugin go to "Reset/Reboot" and mark your new Plugin -> save and reload page -> now your Plugin should be visible in the navigation

This file is work in progress...
