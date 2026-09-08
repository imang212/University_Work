<?php
// Přesměrujeme chyby XML z prohlížeče do interní paměti PHP
libxml_use_internal_errors(true);
// Inicializace DOM parseru
$dom = new DOMDocument();
$dom->preserveWhiteSpace = false;
// Pokus o načtení XML souboru
if (!$dom->load('vzor_data.xml')) die("Kritická chyba: Nepodařilo se načíst soubor vzor_data.xml");
// Samotná validace vůči XSD schématu
if ($dom->schemaValidate('schema.xsd')) {
    echo "<h2 style='color: green;'>XML je validní!</h2>";
    echo "<h3>Načtená data:</h3>";
    // Pokud je XML validní, je nejpohodlnější ho převést na SimpleXML objekt pro snadné čtení
    $xml = simplexml_import_dom($dom);
    echo "<ul>";
    foreach ($xml->Kniha as $kniha) {
        // K atributům přistupujeme přes pole ['id'], k elementům přes šipku ->
        $id = $kniha['id'];
        $nazev = $kniha->Nazev;
        $autor = $kniha->Autor;
        $rok = $kniha->RokVydani;
        echo "<li><strong>$nazev</strong> od $autor (vydáno $rok) - ID: $id</li>";
    }
    echo "</ul>";
} else {
    // Zpracování a výpis chyb, pokud XML není validní
    echo "<h2 style='color: red;'>XML není validní! Nalezené chyby:</h2>";
    $errors = libxml_get_errors();
    echo "<ul>";
    foreach ($errors as $error) echo "<li>Řádek {$error->line}: {$error->message}</li>";  // Vypíše řádek a přesný popis chyby, co ve struktuře chybí nebo je špatně
    echo "</ul>";
    libxml_clear_errors(); // Vyčištění paměti od chyb
}
?>