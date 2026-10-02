<div>
    <h2><?php echo isset($LANG['title']) ? $LANG['title'] : 'Domainler'; ?></h2>
    <p><?php echo isset($LANG['desc']) ? $LANG['desc'] : 'Burada WHMCS üzerindeki domainlerin listesi bulunacaktır. Arama ve filtreleme özellikleri ile domainlerin WHOIS bilgilerini senkronize edebilirsiniz.'; ?></p>
    
    <div style="margin-bottom: 20px;">
        <button class="btn btn-primary" onclick="alert('Toplu güncelleme onay popup\'ı çıkacak.')"><?php echo isset($LANG['sync_all']) ? $LANG['sync_all'] : 'Tümünü Güncelle'; ?></button>
        <button class="btn btn-default" onclick="alert('Seçilenler güncellenecek.')"><?php echo isset($LANG['sync_selected']) ? $LANG['sync_selected'] : 'Seçilenleri Güncelle'; ?></button>
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
