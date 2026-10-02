<?php

namespace WhoisContactSync\Service;

class JsonLogManager
{
    protected $logFile;

    public function __construct()
    {
        $this->logFile = __DIR__ . '/../../logs/history.json';

        $logDir = dirname($this->logFile);
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
        $htaccess = $logDir . '/.htaccess';
        if (!file_exists($htaccess)) {
            file_put_contents($htaccess, "Deny from all");
        }
    }

    public function logOperation($domainId, $domain, $clientId, $registrar, $status, $errorMsg = '', $changedFields = [], $rawPayload = null)
    {
        $adminId = isset($_SESSION['adminid']) ? $_SESSION['adminid'] : 0;

        $logEntry = [
            'operation_id' => uniqid('sync_'),
            'domain_id' => $domainId,
            'domain' => $domain,
            'client_id' => $clientId,
            'registrar' => $registrar,
            'status' => $status,
            'admin_id' => $adminId,
            'error_message' => $errorMsg,
            'changed_fields' => $changedFields,
            'raw_payload' => $rawPayload,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        $fp = fopen($this->logFile, 'a+');
        if (flock($fp, LOCK_EX)) {
            fwrite($fp, json_encode($logEntry) . PHP_EOL);
            flock($fp, LOCK_UN);
        }
        fclose($fp);

        return $logEntry['operation_id'];
    }

    public function getLogs()
    {
        if (!file_exists($this->logFile)) {
            return [];
        }

        $logs = [];
        $lines = file($this->logFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $logs[] = json_decode($line, true);
        }

        return array_reverse($logs);
    }
}
