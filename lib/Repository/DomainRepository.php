<?php

namespace WhoisContactSync\Repository;

use WHMCS\Database\Capsule;

class DomainRepository
{
    public function getDomain($domainId)
    {
        return Capsule::table('tbldomains')
            ->where('id', $domainId)
            ->first();
    }

    public function getDomainsList($offset = 0, $limit = 50, $filters = [])
    {
        $query = Capsule::table('tbldomains')
            ->join('tblclients', 'tbldomains.userid', '=', 'tblclients.id')
            ->select(
                'tbldomains.id',
                'tbldomains.domain',
                'tbldomains.registrar',
                'tbldomains.status',
                'tbldomains.userid as client_id',
                'tblclients.firstname',
                'tblclients.lastname',
                'tblclients.companyname'
            );

        if (!empty($filters['domain'])) {
            $query->where('tbldomains.domain', 'like', '%' . $filters['domain'] . '%');
        }
        if (!empty($filters['status'])) {
            $query->where('tbldomains.status', $filters['status']);
        }
        if (!empty($filters['registrar'])) {
            $query->where('tbldomains.registrar', $filters['registrar']);
        }

        $total = $query->count();
        $domains = $query->offset($offset)->limit($limit)->get();

        return [
            'total' => $total,
            'data' => $domains
        ];
    }
}
