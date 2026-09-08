<?php
// api.php - Vstupní bod pro API požadavky[cite: 1]
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");

require_once 'db.php';

// Získání typu HTTP požadavku
$method = $_SERVER['REQUEST_METHOD'];
// Jednoduchý router pro produkty
switch ($method) {
    case 'GET':
        // Získání seznamu produktů
        $stmt = $pdo->query('SELECT id, nazev, mnozstvi, cena FROM produkty');
        $produkty = $stmt->fetchAll();
        echo json_encode($produkty);
        break;
    case 'POST':
        // Přidání nového produktu ze zaslaných JSON dat
        $data = json_decode(file_get_contents("php://input"));
        if (isset($data->nazev) && isset($data->mnozstvi)) {
            $sql = "INSERT INTO produkty (nazev, mnozstvi, cena) VALUES (?, ?, ?)";
            $stmt = $pdo->prepare($sql); // Prevence SQL injection[cite: 1]
            $stmt->execute([$data->nazev, $data->mnozstvi, $data->cena ?? 0]);
            http_response_code(201);
            echo json_encode(['message' => 'Produkt úspěšně přidán.']);
        } else {
            http_response_code(400);
            echo json_encode(['error' => 'Chybí povinná data.']);
        }
        break;
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Nepodporovaná metoda.']);
        break;
}
?>