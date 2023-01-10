<?php

/**
 Start Controller with functions to configure and initially setup purpose
 
 Extend this class for custom start pages and use custom view file
 
 @Copyright 2017 Stefan Rick   
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
class Start extends Service
{

    public $scriptPath = '';

    public function __construct()
    {
        parent::__construct();
        $this->pluginname = _('Start');
        
        $this->checkPicturesAndHeader();
        
        if ($this->checkForUpdate() === FALSE) {
            // probalby no internet connection!
            $this->view->nointernet = true;
            // Check for Accesspoint Mode
            if (intval(trim($this->shell_exec('ps -Al | grep hostapd | wc -l'))) > 0)
                $this->view->message[] = _('Accesspoint Mode Active: Go to WiFi/LAN page to setup your local WiFi for this device.');
        }
        
        if (isset($_REQUEST['action'])) {
            if ($_REQUEST['action'] == 'save_purpose') {
                $this->_savePurpose($_REQUEST['purpose']);
            }
            if ($_REQUEST['action'] == 'skipsetupstartpage') {
                $this->saveConfigFileParameter('/opt/medianas/options.conf', 'setupstartpage', 0);
            }
            if ($_REQUEST['action'] == 'installstartpageplugin') {
                if ($this->installPlugin('https://shop.medianas.com/media/downloadable/currentversion/' . $_REQUEST['hardware'] . '.tar', true, 1, true)) {
                    $this->saveConfigFileParameter('/opt/medianas/options.conf', 'setupstartpage', 0);
                    $this->removePlugins(array(
                        'Start'
                    ));
                    // Redirect to new Plugin
                    header('Location: /plugins/' . $_REQUEST['hardware'] . '/controller/Setup.php');
                    exit();
                }
            }
        }
        
        if ($this->getFreeDiskSpace()) {
            if ($this->info->freespace < 300) {
                $this->view->message[] = str_replace('$FREESPACE', $this->info->freespace, _('Only $FREESPACE MB of free space left on the device! Did you already expand the filesystem?'));
            }
        }
        
        // Decide to Show Easy Installer
        // $this->easyinstaller = true;
        $this->showHelpSidebar();
        
        $this->view->purpose = $this->getConfigFileParameter('/opt/medianas/options.conf', 'purpose');
        
        $this->view->setupstartpage = $this->getConfigFileParameter('/opt/medianas/options.conf', 'setupstartpage');
    }

    /**
     * Function for Special Images - Implement this to check for Imageupdates and Custom View Header
     * 
     * @param string $custom
     *            Name of Specialimage
     */
    public function checkPicturesAndHeader($custom = '', $path = '')
    {
        if ($custom != '' && ! file_exists(APPLICATION_PATH . '/../public/addons/' . $custom . '/' . $custom . '-logo-450.jpg')) {
            if ($path == '') {
                $this->view->message[] = 'Error creating View-Files';
            }
            $this->saveConfigFileParameter('/opt/medianas/options.conf', 'specialimage', $custom);
            $this->writeDynamicScript(array(
                'mkdir ' . APPLICATION_PATH . '/../public/addons/' . $custom . '/',
                'cp ' . $path . '/../scripts/images/* ' . APPLICATION_PATH . '/../public/addons/' . $custom . '/',
                'cp ' . $path . '/../scripts/custom.css ' . APPLICATION_PATH . '/../public/custom.css',
                'cp ' . $path . '/../view/header_custom.php ' . APPLICATION_PATH . '/view/header_custom.php'
            ));
            $this->view->message[] = _('Created View-Files');
        }
    }

    /**
     * Easy Installation Handler
     * Function to save special purpose
     * 
     * @param string $purpose
     */
    public function _savePurpose($purpose = '')
    {
        if ($purpose == 'mpd') {
            // Install MPD Plugin
            $this->installPlugin('http://shop.medianas.com/media/downloadable/beta/mpd.tar', true, 2, false);
            
            // Disable Squeezebox-Server, Audioplayer, Remove Autostart Audioplayer
            $this->removePlugins(array(
                'Audioplayer',
                'Squeezebox Server'
            ));
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'squeezelite', 0);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'shairport', 0);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'mpd', 1);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'ympd', 1);
            $this->stop('squeezelite');
            $this->stop('shairport');
            
            // Create Sambashare for /var/lib/mpd
            include_once (APPLICATION_PATH . '/model/Samba.php');
            $smb = new Samba();
            $test1 = $smb->setName('medianas-Music');
            $test2 = $smb->setOption('path', '/var/lib/mpd');
            $test3 = $smb->setOption('comment', 'medianas Music MPD');
            $test4 = $smb->setOption('writeable', 'yes');
            $test5 = $smb->setOption('create mode', '777');
            shell_exec("echo '" . $smb->getShareConf() . "' >> /opt/medianas/samba.conf");
            $output = shell_exec('sudo /opt/medianas/setSambaPass.sh "medianas"');
            shell_exec("sudo /etc/init.d/samba restart");
            $this->view->message[] = _t('You can access your Music-Folder from other computers via network. Password is "medianas".');
            
            $this->view->message[] = _t('Music Player can be installed / started on Music Player (MPD) tab.');
        }
        
        if ($purpose == 'squeeze') {
            $this->enablePlugin('Audioplayer', 2);
            $this->enablePlugin('Squeezebox Server', 4);
            $this->enablePlugin('Jivelite', 6);
            $this->loadViewHeader(true);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'squeezelite', 1);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'mpd', 0);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'shairport', 0);
            $this->stop('shairport');
            $this->view->message[] = _t('Audioplayer Squeezelite is enabled and can be configured on Audioplayer-tab. Install a Squeezebox Server, if you do not already have one running.');
        }
        
        if ($purpose == 'airplay') {
            $this->enablePlugin('Audioplayer', 2);
            $this->removePlugins(array(
                'Squeezebox Server'
            ));
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'squeezelite', 0);
            $this->stop('squeezelite');
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'shairport', 1);
            $this->saveConfigFileParameter('/opt/medianas/autostart.conf', 'mpd', 0);
            $this->view->message[] = _t('Airplay is now enabled by default.');
        }
        $this->saveConfigFileParameter('/opt/medianas/options.conf', 'purpose', $purpose);
        $this->view->message[] = str_replace('$SERVERIP', (strpos($_SERVER['SERVER_ADDR'], ':') !== FALSE) ? '[' . $_SERVER['SERVER_ADDR'] . ']' : $_SERVER['SERVER_ADDR'], _('Please restart your device! To restart now <a href="http://$SERVERIP/plugins/medianas_settings/controller/Basic.php?action=reboot&redirecturl=' . urlencode('http://') . '$SERVERIP">just click here</a>.'));
    }

    /**
     * Function should be overwritten by special Image File
     * 
     * @return boolean
     */
    public function showHelpSidebar()
    {
        global $helpSidebar;
        $helpSidebar['title'] = _('Help - Introduction');
        $helpSidebar['content'] = _('<ul><li>This is medianas - The easiest way to setup a audio and video player! You may watch <a target="_blank" href="https://www.youtube.com/channel/UCu2JHGI142fLrkoUN8dUkRA">our video tutorials about the settings in this web interface</a>.</li></ul>');
        $helpSidebar['toppicture'] = '/images/start-toppicture.jpg';
        return true;
    }
}