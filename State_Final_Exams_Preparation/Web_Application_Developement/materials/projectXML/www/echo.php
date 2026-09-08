<!DOCTYPE html>
<html>

<body>
  <?
  // header('Content-Type: text/xml'); // NOT possible
  echo file_get_contents('xml/cdcatalog.xml');
  ?>
  <form method="get">
  <label for="file">Vyberte XML soubor:</label>
  <select name="file" id="file">
    <?php
    foreach (glob(__DIR__ . '/xml/*.xml') as $file) {
      $filename = basename($file);
      echo "<option value=\"$filename\">$filename</option>";
    }
    ?>
  </select>
  <button type="submit">Zobrazit</button>
</form>

<?php
if (isset($_GET['file'])) {
    $selectedFile = 'xml/' . basename($_GET['file']);
    if (file_exists($selectedFile)) {
        echo file_get_contents($selectedFile);
    } else {
        echo "Soubor nenalezen.";
    }
}
?>
</body>

</html>
