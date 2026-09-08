<?php
function parseXmlFile($filename) {
    if (!file_exists($filename)) { die("Soubor $filename neexistuje!"); }

    $xml = simplexml_load_file($filename);

    if ($xml === false) { die("Nepodařilo se načíst XML soubor"); }

    echo "Struktura XML souboru: $filename\n";
    echo "----------------------------------------\n";
    print_r($xml);
    echo "\n\n";

    $xmlArray = json_decode(json_encode($xml), true);
    echo "Struktura XML jako pole:\n";
    echo "----------------------------------------\n";
    print_r($xmlArray);
}


parseXmlFile('xml/fakulta.xml');
?>