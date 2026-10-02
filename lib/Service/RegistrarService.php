<?php

namespace WhoisContactSync\Service;

class RegistrarService
{

    public function getExistingContacts($domainId)
    {
        $domain = \WHMCS\Database\Capsule::table('tbldomains')->where('id', $domainId)->first();
        if (!$domain || empty($domain->registrar)) {
            throw new \Exception("Domain or registrar not found");
        }

        $registrar = $domain->registrar;

        if (!function_exists('RegGetContactDetails')) {
            require_once ROOTDIR . '/includes/registrarfunctions.php';
        }

        $params = \getregistrarconfigoptions($registrar);
        $params['domainid'] = $domain->id;
        $params['domain'] = $domain->domain;
        $sld_tld = explode('.', $domain->domain, 2);
        $params['sld'] = $sld_tld[0];
        $params['tld'] = isset($sld_tld[1]) ? $sld_tld[1] : '';

        $existingContacts = \RegGetContactDetails($params);
        if (isset($existingContacts['error'])) {
            throw new \Exception("GetContactDetails Error: " . $existingContacts['error']);
        }

        return $existingContacts;
    }

    public function updateWhoisContact($domainId, $contactDetailsArray)
    {
        $command = 'DomainUpdateWhoisinfo';

        $domain = \WHMCS\Database\Capsule::table('tbldomains')->where('id', $domainId)->first();
        if (!$domain || empty($domain->registrar)) {
            throw new \Exception("Domain or registrar not found");
        }

        $registrar = $domain->registrar;

        if (!function_exists('RegSaveContactDetails')) {
            require_once ROOTDIR . '/includes/registrarfunctions.php';
        }

        $params = \getregistrarconfigoptions($registrar);
        $params['domainid'] = $domain->id;
        $params['domain'] = $domain->domain;

        $sld_tld = explode('.', $domain->domain, 2);
        $params['sld'] = $sld_tld[0];
        $params['tld'] = isset($sld_tld[1]) ? $sld_tld[1] : '';

        $existingContacts = \RegGetContactDetails($params);
        if (isset($existingContacts['error'])) {
            throw new \Exception("GetContactDetails Error: " . $existingContacts['error']);
        }

        $mappedContacts = [];

        if (is_array($existingContacts) && count($existingContacts) > 0) {
            foreach ($existingContacts as $type => $fields) {
                if (is_array($fields)) {
                    $mappedContacts[$type] = [];
                    foreach ($fields as $key => $value) {
                        $lowerKey = strtolower(preg_replace('/[^a-z0-9]/i', '', $key));

                        if (strpos($lowerKey, 'first') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['First Name'];
                        } elseif (strpos($lowerKey, 'last') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Last Name'];
                        } elseif (strpos($lowerKey, 'company') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Company Name'];
                        } elseif (strpos($lowerKey, 'email') !== false || $lowerKey == 'mail') {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Email Address'];
                        } elseif (strpos($lowerKey, 'address1') !== false || $lowerKey == 'address') {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Address 1'];
                        } elseif (strpos($lowerKey, 'address2') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Address 2'];
                        } elseif (strpos($lowerKey, 'city') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['City'];
                        } elseif (strpos($lowerKey, 'state') !== false || strpos($lowerKey, 'county') !== false || strpos($lowerKey, 'province') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['State'];
                        } elseif (strpos($lowerKey, 'postcode') !== false || strpos($lowerKey, 'zip') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Postcode'];
                        } elseif (strpos($lowerKey, 'fax') !== false) {
                            $mappedContacts[$type][$key] = ''; // We don't sync fax, keep it empty
                        } elseif (strpos($lowerKey, 'countrycode') !== false || strpos($lowerKey, 'phonecountry') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Phone Country Code'];
                        } elseif (strpos($lowerKey, 'country') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Country'];
                        } elseif (strpos($lowerKey, 'phone') !== false || strpos($lowerKey, 'tel') !== false) {
                            $mappedContacts[$type][$key] = $contactDetailsArray['Phone Number'];
                        } else {
                            $mappedContacts[$type][$key] = $value;
                        }
                    }
                }
            }
        }

        if (empty($mappedContacts)) {
            $mappedContacts = [
                'Registrant' => $contactDetailsArray,
                'Admin' => $contactDetailsArray,
                'Technical' => $contactDetailsArray,
                'Billing' => $contactDetailsArray,
            ];
        }

        $params['contactdetails'] = $mappedContacts;

        $result = \RegSaveContactDetails($params);

        if (function_exists('logModuleCall')) {
            logModuleCall(
                $registrar,
                'whois_contact_sync',
                $params['contactdetails'],
                $result,
                '',
                []
            );
        }

        if ($result && isset($result['error'])) {
            $errorData = [
                'msg' => $result['error'],
                'payload' => $params['contactdetails']
            ];
            throw new \Exception(json_encode($errorData));
        }

        return true;
    }
}
