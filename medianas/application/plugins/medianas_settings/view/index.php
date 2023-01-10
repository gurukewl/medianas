<h1 class="entry-header">
	<?php echo _("MediaBase") ?>
</h1>

<div class="entry-content">
    <?php 
	$message = $fs->view->message;
	$error = $fs->view->error;
	include (APPLICATION_PATH . '/view/messages.php');
     ?>
	
	<h2><?php echo _("Welcome to MediaBase - Your easy to use Interface for NAS Media Server Setup!")?></h2>
	<br />
	<h2><?php echo _("All required Media Apps are installed via docker installs.")?></h2>
	<br />
	<?php echo _("Use  appropriate option for installing/updating the Media App")?>
	<br />
	<br />
	<?php echo _("i) Install/Update DOCKER configurations") ?> &nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="<?php echo _('Install') ?>"
			name="save"
			onclick="document.getElementById('action').value='installDocker';submit();" />
	<br />
	<br />
	<?php echo _("ii) Update Docker base location in a external storage location") ?><br \>
	&nbsp;&nbsp;&nbsp <?php echo _("Define the external path of the docker storage") ?>&nbsp;&nbsp 
	<input id="dockerpath" type="text" value=""
			name="dockerpath" />&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="install"
			onclick="changeFormMethod('GET').document.getElementById('action').value='changeLocation';submit();" />
	<br />
	<br />
	<?php echo _("iii) Install/Update Qbittorrent Docker") ?>&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Install') ?>"
			name="save"
			onclick="document.getElementById('action').value='installQbittorrent';submit();" />&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="save"
			onclick="document.getElementById('action').value='updateQbittorrent';submit();" />
    <br />
	<br />
	<?php echo _("iv) Install/Update Emby Server Docker") ?>&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Install') ?>"
			name="install"
			onclick="document.getElementById('action').value='installEmby';submit();" />&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="save"
			onclick="document.getElementById('action').value='updateEmby';submit();" />
	<br />
	<br />
	<?php echo _("v) Install/Update NextCloud Server Docker") ?>&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Install') ?>"
			name="save"
			onclick="document.getElementById('action').value='installNextCloud';submit();" />&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="save"
			onclick="document.getElementById('action').value='updateNextCloud';submit();" />		
	<br />
	<br />
	<?php echo _("vi) Install/Update Jackett Server Docker") ?>&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Install') ?>"
			name="save"
			onclick="document.getElementById('action').value='installJackett';submit();" />&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="save"
			onclick="document.getElementById('action').value='updateJackett';submit();" />
	<br />
	<br />
	<?php echo _("vii) Install/Update Sonarr Server Docker") ?>&nbsp;&nbsp;&nbsp;&nbsp
	<input type="button" value="<?php echo _('Install') ?>"
			name="save"
			onclick="document.getElementById('action').value='installSonarr';submit();" />&nbsp;&nbsp
	<input type="button" value="<?php echo _('Update') ?>"
			name="save"
			onclick="document.getElementById('action').value='updateSonarr';submit();" />
	<br />
	<br />
	<br />
	<!--<h2><?php echo _("Reboot / Shutdown Settings")?></h2>-->
	<!--<br />-->
	<!--<input type="button" value="<?php echo _("Reboot") ?>" name="reboot"-->
	<!--		onclick="doReboot();document.getElementById('action').value='reboot';" />&nbsp;&nbsp;-->
	<!--<input type="button" value="<?php echo _("Shutdown") ?>"-->
	<!--		name="shutdown"-->
	<!--		onclick="document.getElementById('action').value='shutdown';submit();" />&nbsp;&nbsp;-->
	<!--<input type="button" value="<?php echo _("Expand Filesystem") ?>"-->
	<!--		name="expandfs"-->
	<!--		onclick="document.getElementById('action').value='expandfs';submit();" />&nbsp;&nbsp;-->
	<!--<br />-->
	
</div>
