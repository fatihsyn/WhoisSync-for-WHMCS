<div>
    <h2><?php echo isset($LANG['menu_errors']) ? $LANG['menu_errors'] : 'Hatalar'; ?></h2>
    <p>Başarısız WHOIS senkronizasyon işlemlerinin listesi.</p>
    <button class="btn btn-warning" onclick="alert('Tüm başarısızlar tekrar denenecek.')" style="margin-bottom: 20px;"><?php echo isset($LANG['retry']) ? $LANG['retry'] : 'Tekrar Dene'; ?></button>
    <table class="table table-list dataTable">
        <thead>
            <tr>
                <th><?php echo isset($LANG['domain']) ? $LANG['domain'] : 'Domain'; ?></th>
                <th><?php echo isset($LANG['registrar']) ? $LANG['registrar'] : 'Registrar'; ?></th>
                <th><?php echo isset($LANG['error']) ? $LANG['error'] : 'Hata'; ?></th>
                <th>Tarih</th>
                <th><?php echo isset($LANG['action']) ? $LANG['action'] : 'İşlem'; ?></th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($logs)): ?>
                <tr><td colspan="5" class="text-center"><em><?php echo isset($LANG['no_records']) ? $LANG['no_records'] : 'Kayıt bulunamadı.'; ?></em></td></tr>
            <?php else: ?>
                <?php foreach ($logs as $log): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($log['domain']); ?></td>
                        <td><?php echo htmlspecialchars($log['registrar']); ?></td>
                        <td><?php echo htmlspecialchars($log['error_message']); ?></td>
                        <td><?php echo htmlspecialchars($log['timestamp']); ?></td>
                        <td>
                            <button type="button" class="btn btn-sm btn-info" onclick="syncSingle(<?php echo $log['domain_id']; ?>)"><?php echo isset($LANG['retry']) ? $LANG['retry'] : 'Tekrar Dene'; ?></button>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>
<script>
function syncSingle(domainId) {
    if (!confirm('<?php echo isset($LANG['sync_confirm']) ? addslashes($LANG['sync_confirm']) : 'Emin misiniz?'; ?>')) return;
    jQuery.post('<?php echo $modulelink; ?>&action=ajax_sync', { domain_id: domainId }, function(res) {
        if (res && res.status === 'success') {
            alert('<?php echo isset($LANG['sync_success']) ? addslashes($LANG['sync_success']) : 'Başarılı!'; ?>'); location.reload();
        } else {
            alert('<?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Hata'; ?>: ' + (res.message || '<?php echo isset($LANG['unknown_error']) ? addslashes($LANG['unknown_error']) : 'Bilinmeyen hata'; ?>'));
        }
    });
}
</script>
