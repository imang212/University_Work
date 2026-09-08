<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Skladový systém</title>
    <!-- Využití doporučeného frameworku Bootstrap 5[cite: 1] -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <h1 class="mb-4">Přehled skladu</h1>
        <div class="card shadow-sm">
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Název produktu</th>
                            <th>Množství na skladě</th>
                            <th>Cena</th>
                            <th>Akce</th>
                        </tr>
                    </thead>
                    <tbody id="tabulka-produktu">
                        <!-- Zde se dynamicky přes JavaScript / API načtou data -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <!-- Příklad načítání dat z API pomocí čistého JS -->
    <script>
        fetch('api.php')
            .then(response => response.json())
            .then(data => {
                let html = '';
                data.forEach(produkt => {
                    html += `
                        <tr>
                            <td>${produkt.id}</td>
                            <td>${produkt.nazev}</td>
                            <td>${produkt.mnozstvi} ks</td>
                            <td>${produkt.cena} Kč</td>
                            <td><button class="btn btn-sm btn-danger">Smazat</button></td>
                        </tr>
                    `;
                });
                document.getElementById('tabulka-produktu').innerHTML = html;
            });
    </script>
</body>
</html>