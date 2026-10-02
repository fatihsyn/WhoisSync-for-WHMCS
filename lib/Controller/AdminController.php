<?php

namespace WhoisContactSync\Controller;

use WHMCS\Database\Capsule;

class AdminController
{
    protected $modulelink;
    protected $vars;
    protected $lang;

    public function __construct($vars)
    {
        $this->vars = $vars;
        $this->modulelink = $vars['modulelink'];
        $this->lang = isset($vars['_lang']) ? $vars['_lang'] : [];
    }

    protected function render($template, $data = [])
    {
        $data['modulelink'] = $this->modulelink;
        $data['LANG'] = $this->lang;
        
        extract($data);
        ob_start();
        $file = __DIR__ . '/../../templates/admin/' . $template . '.tpl';
        if (file_exists($file)) {
            include $file;
        } else {
            echo "Template not found: {$template}";
        }
        return ob_get_clean();
    }

    public function domains()
    {
        $html = $this->renderMenu('domains');
        $html .= $this->render('domains', []);
        return $html;
    }

    public function updated()
    {
        $logManager = new \WhoisContactSync\Service\JsonLogManager();
        $allLogs = $logManager->getLogs();
        $updatedDomains = [];
        
        foreach ($allLogs as $log) {
            if ($log['status'] === 'success' && !isset($updatedDomains[$log['domain_id']])) {
                $updatedDomains[$log['domain_id']] = $log;
            }
        }

        $html = $this->renderMenu('updated');
        $html .= $this->render('updated', ['logs' => $updatedDomains]);
        return $html;
    }

    public function history()
    {
        $logManager = new \WhoisContactSync\Service\JsonLogManager();
        $logs = $logManager->getLogs();

        $html = $this->renderMenu('history');
        $html .= $this->render('history', ['logs' => $logs]);
        return $html;
    }

    public function errors()
    {
        $logManager = new \WhoisContactSync\Service\JsonLogManager();
        $allLogs = $logManager->getLogs();
        
        $activeErrors = [];
        $seenDomains = [];
        
        foreach ($allLogs as $log) {
            $did = $log['domain_id'];
            if (!in_array($did, $seenDomains)) {
                $seenDomains[] = $did;
                if ($log['status'] === 'error') {
                    $activeErrors[] = $log;
                }
            }
        }

        $html = $this->renderMenu('errors');
        $html .= $this->render('errors', ['logs' => $activeErrors]);
        return $html;
    }

    public function settings()
    {
        $html = $this->renderMenu('settings');
        $html .= $this->render('settings', []);
        return $html;
    }

    public function ajaxDomains()
    {
        while (ob_get_level()) {
            ob_end_clean();
        }
        header('Content-Type: application/json');

        $repo = new \WhoisContactSync\Repository\DomainRepository();
        
        $start = isset($_REQUEST['start']) ? (int)$_REQUEST['start'] : 0;
        $length = isset($_REQUEST['length']) ? (int)$_REQUEST['length'] : 10;
        
        $logManager = new \WhoisContactSync\Service\JsonLogManager();
        $allLogs = $logManager->getLogs();
        $successfulDomainIds = [];
        $latestUpdates = [];
        foreach ($allLogs as $log) {
            $did = $log['domain_id'];
            if ($log['status'] === 'success') {
                $successfulDomainIds[] = $did;
            } elseif (!isset($latestUpdates[$did])) {
                $latestUpdates[$did] = $log['timestamp'];
            }
        }
        $successfulDomainIds = array_unique($successfulDomainIds);

        $filters = ['status' => 'Active', 'exclude_ids' => $successfulDomainIds];
        if (!empty($_REQUEST['search']['value'])) {
            $filters['domain'] = $_REQUEST['search']['value'];
        }

        $result = $repo->getDomainsList($start, $length, $filters);
        
        $data = [];
        foreach ($result['data'] as $domain) {
            $syncBtn = isset($this->lang['sync']) ? $this->lang['sync'] : 'Sync';
            $viewBtn = isset($this->lang['view']) ? $this->lang['view'] : 'View';
            
            $buttons = '<button type="button" class="btn btn-sm btn-info" onclick="syncSingle('.$domain->id.')">'.$syncBtn.'</button> ';
            $buttons .= '<button type="button" class="btn btn-sm btn-default" onclick="viewContacts('.$domain->id.')">'.$viewBtn.'</button>';
            
            $lastUpdateStr = isset($latestUpdates[$domain->id]) ? $latestUpdates[$domain->id] : (isset($this->lang['unknown_error']) ? str_replace(' Error', '', $this->lang['unknown_error']) : 'Unknown');

            $data[] = [
                '<input type="checkbox" class="domain-checkbox" name="domain_ids[]" value="'.$domain->id.'">',
                $domain->domain,
                $domain->client_id,
                trim($domain->firstname . ' ' . $domain->lastname . ' ' . ($domain->companyname ? '('.$domain->companyname.')' : '')),
                $domain->registrar,
                $domain->status,
                $lastUpdateStr,
                $buttons
            ];
        }

        echo json_encode([
            "draw" => isset($_REQUEST['draw']) ? intval($_REQUEST['draw']) : 1,
            "recordsTotal" => $result['total'],
            "recordsFiltered" => $result['total'],
            "data" => $data
        ]);
        exit;
    }

    public function ajaxSync()
    {
        while (ob_get_level()) {
            ob_end_clean();
        }
        header('Content-Type: application/json');

        $domainId = isset($_POST['domain_id']) ? (int)$_POST['domain_id'] : 0;
        
        if ($domainId > 0) {
            $syncService = new \WhoisContactSync\Service\WhoisSyncService();
            $result = $syncService->syncDomain($domainId);
            echo json_encode($result);
        } else {
            $msg = isset($this->lang['invalid_domain_id']) ? $this->lang['invalid_domain_id'] : 'Invalid Domain ID';
            echo json_encode(['status' => 'error', 'message' => $msg]);
        }
        exit;
    }

    public function ajaxViewContacts()
    {
        while (ob_get_level()) {
            ob_end_clean();
        }
        header('Content-Type: application/json');

        $domainId = isset($_POST['domain_id']) ? (int)$_POST['domain_id'] : 0;
        
        if ($domainId > 0) {
            try {
                $service = new \WhoisContactSync\Service\RegistrarService();
                $contacts = $service->getExistingContacts($domainId);
                echo json_encode(['status' => 'success', 'data' => $contacts]);
            } catch (\Exception $e) {
                echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
            }
        } else {
            $msg = isset($this->lang['invalid_domain_id']) ? $this->lang['invalid_domain_id'] : 'Invalid Domain ID';
            echo json_encode(['status' => 'error', 'message' => $msg]);
        }
        exit;
    }

    protected function renderMenu($active)
    {
        return $this->render('menu', ['active' => $active]);
    }
}
