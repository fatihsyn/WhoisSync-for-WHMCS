<?php

namespace WhoisContactSync\Service;

class ContactBuilder
{
    private function cleanTrChars($text)
    {
        $tr = ['ş', 'Ş', 'ı', 'I', 'İ', 'ğ', 'Ğ', 'ü', 'Ü', 'ö', 'Ö', 'ç', 'Ç'];
        $eng = ['s', 'S', 'i', 'i', 'I', 'g', 'G', 'u', 'U', 'o', 'O', 'c', 'C'];
        return str_replace($tr, $eng, $text);
    }

    public function buildContactData($client)
    {
        $rawPhone = $client->phonenumber;
        $countryCode = '90';
        $phone = $rawPhone;

        if (strpos($rawPhone, '.') !== false) {
            $parts = explode('.', $rawPhone, 2);
            $countryCode = preg_replace('/[^0-9]/', '', $parts[0]);
            $phone = preg_replace('/[^0-9]/', '', $parts[1]);
        } else {
            $phoneNumeric = preg_replace('/[^0-9]/', '', $rawPhone);
            if (strlen($phoneNumeric) > 10 && substr($phoneNumeric, 0, 2) == '90') {
                $countryCode = '90';
                $phone = substr($phoneNumeric, 2);
            } else {
                $phone = $phoneNumeric;
            }
        }

        $firstName = $this->cleanTrChars($client->firstname);
        $lastName = $this->cleanTrChars($client->lastname);
        $companyName = $this->cleanTrChars($client->companyname);

        if (empty(trim($companyName))) {
            $companyName = $firstName . ' ' . $lastName;
        }

        $contactData = [
            'First Name' => $firstName,
            'Last Name' => $lastName,
            'Company Name' => $companyName,
            'Email Address' => $client->email,
            'Address 1' => $this->cleanTrChars($client->address1),
            'Address 2' => $this->cleanTrChars($client->address2 ?: ''),
            'City' => $this->cleanTrChars($client->city),
            'State' => $this->cleanTrChars($client->state),
            'Postcode' => $client->postcode,
            'Country' => $client->country,
            'Phone Number' => $phone,
            'Phone Country Code' => $countryCode,
        ];

        return $contactData;
    }
}
