<?php

/**
 Basic Administration Controller
 
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
include_once (APPLICATION_PATH . '/controller/Start.php');
// $this->pluginname = _('Start');
$start = new Start();
$start->easyinstaller = false;

include_once (dirname(__FILE__) . '/../view/index.php');
