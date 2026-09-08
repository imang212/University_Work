<?php
// db.php - Konfigurace a připojení k relační databázi
$host = '127.0.0.1';
$db   = 'skladovy_system';
$user = 'root';
$pass = 'heslo';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Vyhazuje výjimky při chybě
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Vrací data jako asociativní pole
    PDO::ATTR_EMULATE_PREPARES   => false,                  // Zásadní pro prevenci SQL injection
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
    // V produkci chybu logujeme, nevypisujeme ji uživateli
    die(json_encode(['error' => 'Chyba připojení k databázi.']));
}
?>