<?php

namespace WhoisContactSync\Service;

class ValidationService
{
    public static function checkAdminPermission()
    {
        if (!isset($_SESSION['adminid'])) {
            die("Unauthorized admin access");
        }
    }

    public static function verifyCsrfToken($token)
    {
        $validToken = generate_token('plain');
        if (!hash_equals($validToken, $token)) {
            die("Invalid CSRF token");
        }
    }
}
