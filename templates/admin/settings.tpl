<div>
    <h2>Ayarlar</h2>
    <form method="post" action="">
        <table class="form" width="100%" border="0" cellspacing="2" cellpadding="3">
            <tr>
                <td class="fieldlabel" width="200">Batch Size</td>
                <td class="fieldarea">
                    <input type="number" name="batch_size" value="10" class="form-control input-100">
                    <span class="text-muted">Toplu işlemlerde tek seferde işlenecek domain sayısı</span>
                </td>
            </tr>
            <tr>
                <td class="fieldlabel">Request Delay (ms)</td>
                <td class="fieldarea">
                    <input type="number" name="request_delay" value="500" class="form-control input-100">
                    <span class="text-muted">Registrar API limitlerine takılmamak için beklenen süre (milisaniye)</span>
                </td>
            </tr>
            <tr>
                <td class="fieldlabel">Güncellenecek Contact Tipleri</td>
                <td class="fieldarea">
                    <label><input type="checkbox" name="contacts[]" value="Registrant" checked> Registrant</label><br>
                    <label><input type="checkbox" name="contacts[]" value="Admin" checked> Admin</label><br>
                    <label><input type="checkbox" name="contacts[]" value="Technical" checked> Technical</label><br>
                    <label><input type="checkbox" name="contacts[]" value="Billing" checked> Billing</label>
                </td>
            </tr>
        </table>
        <div style="margin-top: 15px;">
            <button type="submit" class="btn btn-primary">Ayarları Kaydet</button>
        </div>
    </form>
</div>
