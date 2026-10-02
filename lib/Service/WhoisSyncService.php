<?php

namespace WhoisContactSync\Service;

use WhoisContactSync\Repository\DomainRepository;
use WhoisContactSync\Repository\ClientRepository;
use WHMCS\Database\Capsule;

class WhoisSyncService
{
    protected $domainRepo;
    protected $clientRepo;
    protected $contactBuilder;
    protected $registrarService;
    protected $logManager;

    public function __construct()
    {
        $this->domainRepo = new DomainRepository();
        $this->clientRepo = new ClientRepository();
        $this->contactBuilder = new ContactBuilder();
        $this->registrarService = new RegistrarService();
        $this->logManager = new JsonLogManager();
    }

    public function syncDomain($domainId)
    {
        $domain = $this->domainRepo->getDomain($domainId);
        if (!$domain) {
            return ['status' => 'error', 'message' => 'Domain not found'];
        }

        $client = $this->clientRepo->getClient($domain->userid);
        if (!$client) {
            return ['status' => 'error', 'message' => 'Client not found'];
        }

        try {
            $contactData = $this->contactBuilder->buildContactData($client);
            
            if (empty($contactData['Email Address']) || empty($contactData['Phone Number'])) {
                throw new \Exception("Required client profile fields (Email, Phone) are missing.");
            }

            $this->registrarService->updateWhoisContact($domainId, $contactData);
            
            $this->logManager->logOperation(
                $domainId, 
                $domain->domain, 
                $client->id, 
                $domain->registrar, 
                'success', 
                '', 
                array_keys($contactData)
            );

            return ['status' => 'success'];
        } catch (\Exception $e) {
            $errMsg = $e->getMessage();
            $rawPayload = null;
            
            $decoded = json_decode($errMsg, true);
            if (is_array($decoded) && isset($decoded['msg'])) {
                $errMsg = $decoded['msg'];
                $rawPayload = $decoded['payload'];
            }
            
            $this->logManager->logOperation(
                $domainId, 
                $domain->domain, 
                $client->id, 
                $domain->registrar, 
                'error', 
                $errMsg,
                [],
                $rawPayload
            );

            return ['status' => 'error', 'message' => $errMsg];
        }
    }
}
