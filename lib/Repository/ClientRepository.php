<?php

namespace WhoisContactSync\Repository;

use WHMCS\Database\Capsule;

class ClientRepository
{
    public function getClient($clientId)
    {
        return Capsule::table('tblclients')
            ->where('id', $clientId)
            ->first();
    }
}
