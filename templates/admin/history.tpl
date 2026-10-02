<div>
    <h2><?php echo isset($LANG['menu_history']) ? $LANG['menu_history'] : 'İşlem Geçmişi'; ?></h2>
    <p>Tüm WHOIS senkronizasyon işlemlerinin log geçmişi.</p>
    <table class="table table-list dataTable">
        <thead>
            <tr>
                <th>Op ID</th>
                <th><?php echo isset($LANG['domain']) ? $LANG['domain'] : 'Domain'; ?></th>
                <th>Client</th>
                <th><?php echo isset($LANG['registrar']) ? $LANG['registrar'] : 'Registrar'; ?></th>
                <th>Admin</th>
                <th>Tarih</th>
                <th>Sonuç</th>
                <th>Detay</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($logs)): ?>
                <tr><td colspan="8" class="text-center"><em><?php echo isset($LANG['no_records']) ? $LANG['no_records'] : 'Kayıt bulunamadı.'; ?></em></td></tr>
            <?php else: ?>
                <?php foreach ($logs as $log): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($log['operation_id']); ?></td>
                        <td><?php echo htmlspecialchars($log['domain']); ?></td>
                        <td><?php echo htmlspecialchars($log['client_id']); ?></td>
                        <td><?php echo htmlspecialchars($log['registrar']); ?></td>
                        <td><?php echo htmlspecialchars($log['admin_id']); ?></td>
                        <td><?php echo htmlspecialchars($log['timestamp']); ?></td>
                        <td>
                            <?php if ($log['status'] === 'success'): ?>
                                <span class="label label-success"><?php echo isset($LANG['success']) ? $LANG['success'] : 'Başarılı'; ?></span>
                            <?php else: ?>
                                <span class="label label-danger"><?php echo isset($LANG['error']) ? $LANG['error'] : 'Hata'; ?></span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <button type="button" class="btn btn-sm btn-default" onclick="alert('<?php echo addslashes(htmlspecialchars($log['error_message'])); ?>')">Detay</button>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
</div>
