<?php

namespace WhoisContactSync\Service;

class BatchManager
{
    protected $syncService;

    public function __construct()
    {
        $this->syncService = new WhoisSyncService();
    }

    public function processBatch($domainIds, $delayMs = 500)
    {
        $results = [
            'total' => count($domainIds),
            'success' => 0,
            'error' => 0,
            'details' => []
        ];

        foreach ($domainIds as $id) {
            $id = (int) $id;
            if ($id <= 0)
                continue;

            $res = $this->syncService->syncDomain($id);

            if ($res['status'] == 'success') {
                $results['success']++;
            } else {
                $results['error']++;
            }
            $results['details'][$id] = $res;


            if ($delayMs > 0) {
                usleep($delayMs * 1000);
            }
        }

        return $results;
    }
}
