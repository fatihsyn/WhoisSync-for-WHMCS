# WHMCS WHOIS Contact Sync Manager

A highly professional, multi-language supported WHMCS addon module that synchronizes WHOIS contact information from WHMCS client profiles directly to domain registrars without needing direct API usage.

## Features

- **Bulk WHOIS Synchronization**: Sync WHOIS contacts for all active domains with a single click.
- **Selective Sync**: Select specific domains to update their WHOIS details.
- **EPP / TRABIS Normalization**: Automatically converts Turkish characters and falls back to user names for empty company names to satisfy strict EPP and API validation rules (e.g., `.com.tr` domains).
- **Multi-Language Support**: Fully integrated with WHMCS language system. Includes 25 languages out-of-the-box (English, Turkish, German, French, Russian, etc.).
- **Live Contact Viewer**: Fetch and view current WHOIS contact details directly from the registrar via a modal interface.
- **Advanced Logging**: Flat-file JSON logging (`logs/history.json`) system that tracks successes and errors without bloating your WHMCS database.
- **AJAX Powered UI**: Seamless user experience with DataTables integration.

## Installation

1. Download or clone this repository.
2. Upload the `whois_contact_sync_manager` folder to your WHMCS installation under `/modules/addons/`.
3. Log in to your WHMCS Admin Panel.
4. Navigate to **System Settings > Addon Modules**.
5. Find **WHOIS Contact Sync Manager** and click **Activate**.
6. Click **Configure**, select the admin roles that have access, and save.
7. Access the module via the **Addons** menu in the top navigation bar.

## Requirements

- WHMCS v8.0 or higher
- PHP 7.4 or higher
- PDO Database Extension

## Architecture & Code Quality

- **Clean Architecture**: Built using a modern service-repository pattern, completely separating views, controllers, and logic.
- **Optimization**: Prevents rate-limiting with configurable delays and batch processing.
- **No Direct API Dependencies**: Leverages native WHMCS Registrar hooks (`RegGetContactDetails`, `RegSaveContactDetails`) ensuring 100% compatibility across all WHMCS supported registrars.

## Author

**Fatih SAYIN**

## License

This project is open-source and available under the MIT License.
