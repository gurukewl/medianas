<?php

/**
 XBMC Administration Controller
 
 @Copyright 2014 Stefan Rick
 @author Stefan Rick
 Mail: stefan@rick-software.de
 Web: http://www.netzberater.de
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along
 with this program; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
class Xbmc extends Service
{

    protected $pname = 'xbmc';

    public $viewname = 'Kodi (Video)';

    private $_autostartfile = '/home/odroid/.config/lxsession/Lubuntu/autostart';

    // private $_autostartfile = '/home/odroid/.config/autostart_off/XBMC.desktop'; DEBIAN-Version
    public function __construct()
    {
        parent::__construct();
        $this->pluginname = _('Kodi / XBMC');
        
        if (file_exists('/usr/local/bin/kodi') || file_exists('/usr/bin/kodi'))
            $this->pname = 'kodi';
        
        $this->binaryname = '';        
        if (file_exists('/usr/lib/arm-linux-gnueabihf/kodi/kodi_v7.bin')) {
            $this->binaryname = '_v7.bin';
        }elseif (file_exists('/usr/lib/arm-linux-gnueabihf/kodi/kodi-rbpi_v7')) {
            $this->binaryname = '-rbpi_v7';
        }elseif (file_exists('/usr/bin/kodi-rpi4')) {
            $this->binaryname = '-rpi4';
        }
        else{
            $this->binaryname = '.bin';
        }
        
        if ($_REQUEST['ajax'] == 1 && strpos($_REQUEST['action'], 'install') !== FALSE) {
            // Function to get Progress of Installation
            $this->installXBMC(1);
            ob_end_clean();
            echo implode('<br />', $this->view->message);
            ob_flush();
            die();
        }
        
        if (isset($_GET['action'])) {
            if ($_GET['action'] == 'start') {
                // Check auf Lightdm
                if ($_GET['reinitx'] != FALSE) {
                    $script = array(
                        '/etc/init.d/lightdm stop > /dev/null 2>&1 &',
                        'sleep 2',
                        '/etc/init.d/lightdm start > /dev/null 2>&1 &'
                    );
                    // $script = array('kill `cat /tmp/.X0-lock`', 'lightdm > /dev/null 2>&1 &');
                    $output = $this->writeDynamicScript($script);
                    sleep(5);
                    $this->view->message[] = _('Restart Desktop-Manager completed (initialized Display)');
                }
                
                if ($this->getSystemUser() == 'pi') {
                    // auf Rasbperry PI 1/2
                    $this->view->message[] = $this->start($this->pname, 'export DISPLAY=\':0\';sudo -u pi -H -E -s /opt/medianas/start_xbmc.sh >> /dev/null 2>&1 &', '', true);
                    sleep(3);
                } elseif ($this->getSystemUser() != '') {
                    // Methode odroid
                    $this->view->message[] = $this->start($this->pname, $command = 'export DISPLAY=\':0\';sudo -u ' . $this->getSystemUser() . ' -H -s /opt/medianas/start_xbmc.sh 2>&1', '', $rootstart = true, $background = '/tmp/kodi.txt');
                    sleep(3);
                } else {
                    // Methode odroid
                    $this->view->message[] = $this->start($this->pname, $command = 'export DISPLAY=\':0\';sudo -u odroid -H -s /opt/medianas/start_xbmc.sh 2>&1', '', $rootstart = true, $background = '/tmp/kodi.txt');
                    sleep(3);
                }
            }
            
            if ($_GET['action'] == 'stop') {
                $this->stop('kodi-standalone', 'sudo kill -9 $PID');
                if($this->binaryname == '-rpi4'){
                    // for buster additional stop                    
                    $this->view->message[] = $this->stop('kodi-gbm', 'sudo kill -9 $PID');
                    $this->writeDynamicScript(array('export DISPLAY=:0;chvt 2;'));
                }else{
                    $this->view->message[] = $this->stop($this->pname . $this->binaryname, 'sudo kill -9 $PID');
                }
                
                /*
                 * if($this->getHardwareInfo() == 'ODROID-XU3'){
                 * //on XU reinitX after stopping Kodi - TODO: Ubuntu 15.4 special?
                 * $script = array('/etc/init.d/lightdm stop > /dev/null 2>&1 &','sleep 2', '/etc/init.d/lightdm start > /dev/null 2>&1 &');
                 * $this->writeDynamicScript($script);
                 * sleep(5);
                 * $this->view->message[] = _('Restart Desktop-Manager completed (initialized Display)');
                 * }
                 */
            }
            
            if ($_GET['action'] == 'save') {
                $this->selectAutostart(isset($_GET['autostart']) ? 1 : 0);
            }
            if ($_GET['action'] == 'install') {
                $this->installXBMC();
            }
            if ($_GET['action'] == 'getaddon') {
                $this->getAddon($_GET['addonurl']);
            }
        }
        $this->view->autostart = $this->checkAutostart($this->pname, true);
        $this->view->pid = $this->status($this->pname . $this->binaryname);
        $this->getXbmcVersion();
        $this->showHelpSidebar();
        $this->getAllLogs();
    }

    public function installXBMC($ajax = 0)
    {
        ignore_user_abort(true);
        set_time_limit(7200);
        
        if ($ajax == 0) {
            if ($_GET['downloadurl'] == '') {
                $this->view->message[] = _('No Link for download given');
                return false;
            } else {
                $downurl = $_GET['downloadurl'];
            }
            $this->view->message[] = _('Installationspaket: ') . $downurl;
            
            if ($this->getProgressWithAjax('/opt/medianas/cache/install_xbmc.txt', 1, 0, 40)) {
                // Run installer as Deamon
                sleep(1);
                $shellanswer = $this->writeDynamicScript(array(
                    "/opt/medianas/install_xbmc.sh update " . $downurl . " > /opt/medianas/cache/install_xbmc.txt 2>&1"
                ), false, true);
            }
        } else {
            $status = $this->getProgressWithAjax('/opt/medianas/cache/install_xbmc.txt', 0, 0, 25);
            
            $this->view->message[] = nl2br($status);
            if (strpos($status, 'finished') !== FALSE) {
                // Finished Progress - did not delete progressfile yet
                $this->view->message[] = _('Installation abgeschlossen!');
                shell_exec('rm /opt/medianas/cache/install_xbmc.txt');
            }
        }
    }

    public function getXbmcVersion()
    {
        $this->xbmcversion = trim($this->writeDynamicScript(array(
            'dpkg -s ' . $this->pname . ' | grep Version'
        )));

        // Check for Buster and Beta Kodi        
        $this->getHardwareInfo();
        if($this->info->hardware == 'Raspberry PI' && strpos($this->info->boardname, 'Raspberry PI 4B') !== FALSE){
            $version = $this->getLinuxVersion();
            if(isset($version[1]) && $version[1] == 'buster'){
                if($this->binaryname != '-rpi4'){
                    $this->view->error[] = _('A Beta version of Kodi for RPI-4 is available for installation! <a href="/plugins/medianas_settings/controller/Xbmc.php?action=install&downloadurl=kodiupgradepi">Click here to install now</a>.');
                }else{
                    $this->xbmcversion = trim($this->writeDynamicScript(array(
                        'dpkg -s ' . $this->pname . '-rpi4 | grep Version'
                    )));
                }
            }
        }
        
        if ($this->xbmcversion == '')
            $this->xbmcversion = $this->writeDynamicScript(array(
                'dpkg -s xbmc | grep Version'
            ));
        return true;
    }

    /**
     * function to save Addon to /opt/medianas/cache
     * Example: https://addonscriptorde-beta-repo.googlecode.com/files/repository.addonscriptorde-beta.zip
     */
    public function getAddon($url)
    {
        if ($url != '' && $this->checkLicense(true) == true) {
            if (! (file_exists('/home/' . $this->getSystemUser() . '/.kodi') || file_exists('/home/' . $this->getSystemUser() . '/.xbmc'))) {
                // make sure addon directory exists
                $this->writeDynamicScript(array(
                    'mkdir -p /home/' . $this->getSystemUser() . '/.kodi/addons; chown -R ' . $this->getSystemUser() . ' /home/' . $this->getSystemUser() . '/.kodi'
                ));
            }
            if (strpos($url, 'repository.addonscriptorde') !== FALSE) {
                $this->writeDynamicScript(array(
                    'wget -O /opt/medianas/cache/amazonprime.tar "shop.medianas.com/media/downloadable/beta/amazonprime.tar";if [ -e "/home/' . $this->getSystemUser() . '/.kodi" ]; then sudo -u ' . $this->getSystemUser() . ' tar -xf /opt/medianas/cache/amazonprime.tar -C /home/' . $this->getSystemUser() . '/.kodi/addons; else tar -xf /opt/medianas/cache/amazonprime.tar -C /home/' . $this->getSystemUser() . '/.xbmc/addons;fi;'
                ));
                $this->view->message[] = _('Plugin installed');
            } elseif (strpos($url, 'repository.xlordkx') !== FALSE) {
                $this->writeDynamicScript(array(
                    'wget -O /opt/medianas/cache/repository.xlordkx-1.0.0.zip "https://github.com/XLordKX/kodi/raw/master/zip/repository.xlordkx/repository.xlordkx-1.0.0.zip";if [ -e "/home/' . $this->getSystemUser() . '/.kodi" ]; then sudo -u ' . $this->getSystemUser() . ' unzip /opt/medianas/cache/repository.xlordkx-1.0.0.zip -d /home/' . $this->getSystemUser() . '/.kodi/addons; else unzip /opt/medianas/cache/repository.xlordkx-1.0.0.zip -d /home/' . $this->getSystemUser() . '/.xbmc/addons;fi;'
                ));
                $this->view->message[] = _('Plugin installed');
            } elseif (strpos($url, 'medianas-u3-repository') !== FALSE) {
                $this->writeDynamicScript(array(
                    'wget -O /opt/medianas/cache/medianas-u3-repository.zip "http://cdn.medianas.com/kodi-15-pvr/medianas-u3-repository.zip";if [ -e "/home/' . $this->getSystemUser() . '/.kodi" ]; then sudo -u ' . $this->getSystemUser() . ' unzip /opt/medianas/cache/medianas-u3-repository.zip -d /home/' . $this->getSystemUser() . '/.kodi/addons; else unzip /opt/medianas/cache/medianas-u3-repository.zip -d /home/' . $this->getSystemUser() . '/.xbmc/addons;fi;'
                ));
                $this->view->message[] = _('Plugin installed');
            } elseif (strpos($url, 'medianas-rpi-repository') !== FALSE) {
                $this->writeDynamicScript(array(
                    'wget -O /opt/medianas/cache/medianas-rpi-repository.zip "http://cdn.medianas.com/kodi-15-pvr/rpi/medianas-rpi-repository.zip";if [ -e "/home/' . $this->getSystemUser() . '/.kodi" ]; then sudo -u ' . $this->getSystemUser() . ' unzip /opt/medianas/cache/medianas-rpi-repository.zip -d /home/' . $this->getSystemUser() . '/.kodi/addons; else unzip /opt/medianas/cache/medianas-rpi-repository.zip -d /home/' . $this->getSystemUser() . '/.xbmc/addons;fi;'
                ));
                $this->view->message[] = _('Plugin installed');
            } elseif (strpos($url, 'plugin.video.youtube') !== FALSE) {
                $this->writeDynamicScript(array(
                    'curl -L https://github.com/kolinger/plugin.video.youtube/archive/master.zip > /opt/medianas/cache/plugin.video.youtube-master.zip;if [ -e "/home/' . $this->getSystemUser() . '/.kodi" ]; then rm -r /home/' . $this->getSystemUser() . '/.kodi/userdata/addon_data/plugin.video.youtube;rm -r /home/' . $this->getSystemUser() . '/.kodi/addons/plugin.video.youtube;sudo -u ' . $this->getSystemUser() . ' unzip /opt/medianas/cache/plugin.video.youtube-master.zip -d /home/' . $this->getSystemUser() . '/.kodi/addons; else unzip /opt/medianas/cache/plugin.video.youtube-master.zip -d /home/' . $this->getSystemUser() . '/.xbmc/addons;fi;'
                ));
                $this->view->message[] = _('Plugin installed');
            } elseif (strpos($url, 'kodi-platform-pi-jessie') !== FALSE) {
                $this->view->message[] = nl2br($this->writeDynamicScript(array(
                    'sudo /var/www/medianas/application/plugins/medianas_settings/scripts/installkodiplatform-jessie-pi.sh'
                )));
            } elseif (strpos($url, 'kodi-17-pvr') !== FALSE) {
                $this->view->message[] = nl2br($this->writeDynamicScript(array(
                    'sudo apt-get update && apt-get install kodi-pvr-demo kodi-pvr-iptvsimple kodi-pvr-hts kodi-pvr-dvblink kodi-pvr-mythtv kodi-pvr-stalker kodi-pvr-nextpvr -y'
                )));
                $this->view->message[] = _('Plugin installed');
            } else {
                shell_exec('wget -P /opt/medianas/cache "' . $url . '" -o /opt/medianas/cache/download.txt');
                $this->view->message[] = nl2br(shell_exec('cat /opt/medianas/cache/download.txt'));
                $this->view->message[] = _('Plugin downloaded to path /opt/medianas/cache');
            }
            // TODO Check for Kodi Plattform Files - No PVR Plugins working if Kodi Platform not present            
        }
        
        return true;
    }

    private function getAllLogs()
    {
        $out['KODI_LOG'] = shell_exec('cat /home/' . $this->getSystemUser() . '/.kodi/temp/kodi.log');
        $this->view->debug = $out;
        return true;
    }
    public function showHelpSidebar()
    {
        global $helpSidebar;
        $helpSidebar['title'] = _('Help - Kodi');
        $helpSidebar['content'] = _('<ul><li>Activate CEC on your TV to use your normal IR-Remote of your TV to control Kodi.</li><li>Use an App for your Smartphone (search for Kodi on Appstore) to control Kodi - this needs the Webservice in System-Services to be activated! Otherwise use mouse/keyboard attached to your Raspberry.</li><li>If you want to use Kodi and squeezeplayer simultanously (e.g. autostart) make sure to enable the checkbox on Audioplayer Squeezelite advanced settings "Use USB-Soundcard" and add the parameter "-C 5" to the commandline options of Squeezelite</li></ul>');
        $helpSidebar['wikilink'] = 'https://www.medianas.com/en/wiki/audioplayer-squeezelites-shairport/';
        return true;
    }
}

$sp = new Xbmc();
include_once (dirname(__FILE__) . '/../view/xbmc.php');