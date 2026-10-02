<?php
/**
 * WHOIS Contact Sync Manager
 *
 * @author Fatih SAYIN
 */

if (!defined("WHMCS")) {
    die("This file cannot be accessed directly");
}

require_once __DIR__ . '/bootstrap.php';

use WHMCS\Database\Capsule;
use WhoisContactSync\Controller\AdminController;

function whois_contact_sync_manager_config()
{
    return [
        'name' => 'WHOIS Contact Sync Manager',
        'description' => 'Synchronizes WHOIS contact information from WHMCS client profile without direct API usage.',
        'version' => '1.0',
        'author' => 'Fatih SAYIN',
        'fields' => [
            'batch_size' => [
                'FriendlyName' => 'Batch Processing Size',
                'Type' => 'text',
                'Size' => '25',
                'Default' => '10',
                'Description' => 'Number of domains to process in each batch.',
            ],
            'request_delay' => [
                'FriendlyName' => 'Request Delay (ms)',
                'Type' => 'text',
                'Size' => '25',
                'Default' => '500',
                'Description' => 'Delay between calls to avoid API rate limits.',
            ],
        ]
    ];
}

function whois_contact_sync_manager_activate()
{
    try {
        Capsule::schema()->create(
            'mod_whois_contact_sync_log',
            function ($table) {
                $table->increments('id');
                $table->integer('domain_id');
                $table->integer('client_id');
                $table->string('registrar');
                $table->string('status');
                $table->text('error_message')->nullable();
                $table->timestamps();
            }
        );

        return [
            'status' => 'success',
            'description' => 'Module activated successfully. Database tables created.'
        ];
    } catch (\Exception $e) {
        return [
            'status' => 'error',
            'description' => 'Could not create database tables: ' . $e->getMessage()
        ];
    }
}

function whois_contact_sync_manager_deactivate()
{
    try {
        // Do not drop the log table to keep history, or drop it based on a setting.
        // Capsule::schema()->dropIfExists('mod_whois_contact_sync_log');
        return [
            'status' => 'success',
            'description' => 'Module deactivated successfully.'
        ];
    } catch (\Exception $e) {
        return [
            'status' => 'error',
            'description' => 'Could not drop database tables: ' . $e->getMessage()
        ];
    }
}

function whois_contact_sync_manager_output($vars)
{
    $action = isset($_GET['action']) ? $_GET['action'] : 'domains';

    $controller = new AdminController($vars);

    switch ($action) {
        case 'ajax_sync':
            $controller->ajaxSync();
            break;
        case 'ajax_domains':
            $controller->ajaxDomains();
            break;
        case 'ajaxViewContacts':
            $controller->ajaxViewContacts();
            break;
        case 'ajax_get_sync_queue':
            $controller->ajaxGetSyncQueue();
            break;
        case 'updated':
            echo $controller->updated();
            break;
        case 'history':
            echo $controller->history();
            break;
        case 'errors':
            echo $controller->errors();
            break;
        case 'settings':
            echo $controller->settings();
            break;
        case 'domains':
        default:
            echo $controller->domains();
            break;
    }
}
