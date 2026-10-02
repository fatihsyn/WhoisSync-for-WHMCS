<style>
.whois-menu { margin-bottom: 20px; }
.whois-menu a { margin-right: 15px; text-decoration: none; padding: 10px 15px; border-radius: 4px; background: #f8f9fa; color: #333; display: inline-block; }
.whois-menu a.active { background: #007bff; color: #fff; }
</style>
<div class="whois-menu">
    <a href="<?php echo $modulelink; ?>&action=domains" class="<?php echo $active == 'domains' ? 'active' : ''; ?>"><?php echo isset($LANG['menu_domains']) ? $LANG['menu_domains'] : 'Domainler'; ?></a>
    <a href="<?php echo $modulelink; ?>&action=updated" class="<?php echo $active == 'updated' ? 'active' : ''; ?>"><?php echo isset($LANG['menu_updated']) ? $LANG['menu_updated'] : 'Güncellenenler'; ?></a>
    <a href="<?php echo $modulelink; ?>&action=history" class="<?php echo $active == 'history' ? 'active' : ''; ?>"><?php echo isset($LANG['menu_history']) ? $LANG['menu_history'] : 'İşlem Geçmişi'; ?></a>
    <a href="<?php echo $modulelink; ?>&action=errors" class="<?php echo $active == 'errors' ? 'active' : ''; ?>"><?php echo isset($LANG['menu_errors']) ? $LANG['menu_errors'] : 'Hatalar'; ?></a>
    <a href="<?php echo $modulelink; ?>&action=settings" class="<?php echo $active == 'settings' ? 'active' : ''; ?>"><?php echo isset($LANG['menu_settings']) ? $LANG['menu_settings'] : 'Ayarlar'; ?></a>
</div>
