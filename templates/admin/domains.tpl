<div>
    <h2><?php echo isset($LANG['title']) ? $LANG['title'] : 'Domainler'; ?></h2>
    <p><?php echo isset($LANG['desc']) ? $LANG['desc'] : 'Burada WHMCS üzerindeki domainlerin listesi bulunacaktır. Arama ve filtreleme özellikleri ile domainlerin WHOIS bilgilerini senkronize edebilirsiniz.'; ?></p>
    
    <div style="margin-bottom: 20px;">
        <button class="btn btn-primary" onclick="startBulkSync('all')"><?php echo isset($LANG['sync_all']) ? $LANG['sync_all'] : 'Tümünü Güncelle'; ?></button>
        <button class="btn btn-default" onclick="startBulkSync('selected')"><?php echo isset($LANG['sync_selected']) ? $LANG['sync_selected'] : 'Seçilenleri Güncelle'; ?></button>
    </div>

    <table class="table table-list dataTable">
        <thead>
            <tr>
                <th><input type="checkbox" id="selectAll"></th>
                <th><?php echo isset($LANG['domain']) ? $LANG['domain'] : 'Domain'; ?></th>
                <th>Client ID</th>
                <th><?php echo isset($LANG['client_name']) ? $LANG['client_name'] : 'Müşteri Adı'; ?></th>
                <th><?php echo isset($LANG['registrar']) ? $LANG['registrar'] : 'Registrar'; ?></th>
                <th><?php echo isset($LANG['status']) ? $LANG['status'] : 'Durum'; ?></th>
                <th><?php echo isset($LANG['last_update']) ? $LANG['last_update'] : 'Son Güncelleme'; ?></th>
                <th><?php echo isset($LANG['action']) ? $LANG['action'] : 'İşlem'; ?></th>
            </tr>
        </thead>
        <tbody>
            <!-- DataTables will fill this -->
        </tbody>
    </table>
</div>

<script>
jQuery(document).ready(function() {
    var table = jQuery('.dataTable').DataTable({
        "processing": true,
        "serverSide": true,
        "ajax": {
            "url": "<?php echo $modulelink; ?>&action=ajax_domains",
            "type": "POST"
        },
        "pageLength": 25,
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.13.6/i18n/tr.json"
        },
        "columnDefs": [
            { "orderable": false, "targets": [0, 7] }
        ]
    });

    jQuery('#selectAll').on('click', function() {
        var rows = table.rows({ 'search': 'applied' }).nodes();
        jQuery('input[type="checkbox"]', rows).prop('checked', this.checked);
    });
});

function syncSingle(domainId) {
    if (!confirm('<?php echo isset($LANG['sync_confirm']) ? addslashes($LANG['sync_confirm']) : 'Emin misiniz?'; ?>')) {
        return;
    }
    
    jQuery.ajax({
        url: '<?php echo $modulelink; ?>&action=ajax_sync',
        type: 'POST',
        data: { domain_id: domainId },
        success: function(response) {
            if (response && response.status === 'success') {
                alert('<?php echo isset($LANG['sync_success']) ? addslashes($LANG['sync_success']) : 'Başarılı!'; ?>');
                jQuery('.dataTable').DataTable().ajax.reload(null, false);
            } else {
                alert('<?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Hata'; ?>: ' + (response.message ? response.message : '<?php echo isset($LANG['unknown_error']) ? addslashes($LANG['unknown_error']) : 'Bilinmeyen hata'; ?>'));
            }
        },
        error: function() {
            alert('<?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Sunucu Hatası'; ?>');
        }
    });
}

function viewContacts(domainId) {
    jQuery('#viewContactsModalBody').html('<?php echo isset($LANG['loading']) ? addslashes($LANG['loading']) : 'Yükleniyor...'; ?>');
    jQuery('#viewContactsModal').modal('show');
    
    jQuery.ajax({
        url: '<?php echo $modulelink; ?>&action=ajaxViewContacts',
        type: 'POST',
        data: { domain_id: domainId },
        success: function(response) {
            if (response && response.status === 'success') {
                var html = '<ul class="nav nav-tabs" role="tablist">';
                var tabsContent = '<div class="tab-content" style="padding-top:15px;">';
                var index = 0;
                
                jQuery.each(response.data, function(contactType, fields) {
                    var activeClass = index === 0 ? 'active' : '';
                    
                    html += '<li role="presentation" class="' + activeClass + '">';
                    html += '<a href="#contactTab' + index + '" role="tab" data-toggle="tab">' + contactType + '</a>';
                    html += '</li>';
                    
                    tabsContent += '<div role="tabpanel" class="tab-pane ' + activeClass + '" id="contactTab' + index + '">';
                    tabsContent += '<table class="table table-bordered table-striped" style="margin-bottom:0;">';
                    tabsContent += '<tbody>';
                    
                    if (typeof fields === 'object' && fields !== null) {
                        jQuery.each(fields, function(key, val) {
                            tabsContent += '<tr><td style="width: 30%; font-weight:bold;">' + key + '</td><td>' + (val || '<em>-</em>') + '</td></tr>';
                        });
                    } else {
                        tabsContent += '<tr><td colspan="2">' + fields + '</td></tr>';
                    }
                    
                    tabsContent += '</tbody></table></div>';
                    index++;
                });
                
                html += '</ul>';
                tabsContent += '</div>';
                
                jQuery('#viewContactsModalBody').html(html + tabsContent);
            } else {
                var errMsg = response.message ? response.message : '<?php echo isset($LANG['unknown_error']) ? addslashes($LANG['unknown_error']) : 'Bilinmeyen hata'; ?>';
                jQuery('#viewContactsModalBody').html('<div class="alert alert-danger"><?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Hata'; ?>: ' + errMsg + '</div>');
            }
        },
        error: function() {
            jQuery('#viewContactsModalBody').html('<div class="alert alert-danger"><?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Sunucu Hatası'; ?></div>');
        }
    });
}
</script>

<!-- View Contacts Modal -->
<div class="modal fade" id="viewContactsModal" tabindex="-1" role="dialog" aria-labelledby="viewContactsModalLabel">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="<?php echo isset($LANG['close']) ? $LANG['close'] : 'Kapat'; ?>"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="viewContactsModalLabel"><?php echo isset($LANG['current_whois']) ? $LANG['current_whois'] : 'Mevcut WHOIS Bilgileri'; ?></h4>
      </div>
      <div class="modal-body" id="viewContactsModalBody">
        <?php echo isset($LANG['loading']) ? $LANG['loading'] : 'Yükleniyor...'; ?>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal"><?php echo isset($LANG['close']) ? $LANG['close'] : 'Kapat'; ?></button>
      </div>
    </div>
  </div>
</div>

<!-- Bulk Sync Modal -->
<div class="modal fade" id="bulkSyncModal" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title"><?php echo isset($LANG['sync']) ? $LANG['sync'] : 'Senkronizasyon İşlemi'; ?> (<span id="bulkSyncProgress">0/0</span>)</h4>
      </div>
      <div class="modal-body">
        <div style="max-height: 400px; overflow-y: auto;">
            <ul id="bulkSyncLogList" class="list-group">
                <!-- Logs will appear here -->
            </ul>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" id="bulkSyncCloseBtn" disabled onclick="window.location.reload()"><?php echo isset($LANG['close']) ? $LANG['close'] : 'Kapat'; ?></button>
      </div>
    </div>
  </div>
</div>

<script>
var syncQueue = [];
var isSyncing = false;

function startBulkSync(type) {
    if (isSyncing) return;
    
    if (type === 'selected') {
        syncQueue = [];
        jQuery('.domain-checkbox:checked').each(function() {
            syncQueue.push(jQuery(this).val());
        });
        
        if (syncQueue.length === 0) {
            alert("Lütfen en az bir domain seçin."); // Need language var here, but keeping it simple for now
            return;
        }
        
        startQueueProcess();
    } else if (type === 'all') {
        jQuery.ajax({
            url: '<?php echo $modulelink; ?>&action=ajax_get_sync_queue',
            type: 'GET',
            success: function(res) {
                if (res && res.status === 'success' && res.data.length > 0) {
                    syncQueue = res.data;
                    startQueueProcess();
                } else {
                    alert('Senkronize edilecek uygun domain bulunamadı.');
                }
            },
            error: function() {
                alert('Liste alınırken hata oluştu.');
            }
        });
    }
}

function startQueueProcess() {
    isSyncing = true;
    jQuery('#bulkSyncLogList').empty();
    jQuery('#bulkSyncProgress').text('0/' + syncQueue.length);
    jQuery('#bulkSyncCloseBtn').prop('disabled', true);
    jQuery('#bulkSyncModal').modal('show');
    
    processNextInQueue(0, syncQueue.length);
}

function processNextInQueue(currentIndex, totalCount) {
    if (currentIndex >= totalCount) {
        isSyncing = false;
        jQuery('#bulkSyncCloseBtn').prop('disabled', false);
        jQuery('#bulkSyncLogList').append('<li class="list-group-item list-group-item-info"><strong>Tüm işlemler tamamlandı!</strong></li>');
        return;
    }
    
    var domainId = syncQueue[currentIndex];
    
    jQuery.ajax({
        url: '<?php echo $modulelink; ?>&action=ajax_sync',
        type: 'POST',
        data: { domain_id: domainId },
        success: function(response) {
            var badge = '';
            var msg = '';
            if (response && response.status === 'success') {
                badge = '<span class="badge" style="background-color: #5cb85c;"><?php echo isset($LANG['success']) ? addslashes($LANG['success']) : 'Başarılı'; ?></span>';
                msg = 'Domain ID: ' + domainId + ' başarıyla güncellendi.';
            } else {
                badge = '<span class="badge" style="background-color: #d9534f;"><?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Hata'; ?></span>';
                msg = 'Domain ID: ' + domainId + ' - ' + (response.message ? response.message : '<?php echo isset($LANG['unknown_error']) ? addslashes($LANG['unknown_error']) : 'Bilinmeyen Hata'; ?>');
            }
            
            jQuery('#bulkSyncLogList').append('<li class="list-group-item">' + badge + msg + '</li>');
            
            // Scroll to bottom
            var elem = document.getElementById('bulkSyncLogList').parentElement;
            elem.scrollTop = elem.scrollHeight;
            
        },
        error: function() {
            var badge = '<span class="badge" style="background-color: #d9534f;"><?php echo isset($LANG['error']) ? addslashes($LANG['error']) : 'Hata'; ?></span>';
            jQuery('#bulkSyncLogList').append('<li class="list-group-item">' + badge + 'Domain ID: ' + domainId + ' - Sunucu Bağlantı Hatası</li>');
        },
        complete: function() {
            jQuery('#bulkSyncProgress').text((currentIndex + 1) + '/' + totalCount);
            
            // Add a small delay between requests to avoid rate limits
            setTimeout(function() {
                processNextInQueue(currentIndex + 1, totalCount);
            }, 1000); // 1 second delay
        }
    });
}
</script>
