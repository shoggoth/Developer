<?php
   if ($database = new SQLite3('test.db')) {

      $query = $database->query('select * from users');

      while ($array = $query->fetchArray(SQLITE3_ASSOC)) {

         print_r($array);
      }
   }
?>
