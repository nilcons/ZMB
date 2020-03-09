#!/usr/bin/php
<?php

$provider_id = 1;
$topologie_file = "eRADN/Daten/topologie_20200131_0400.xml";
$topologie_xml = simplexml_load_file($topologie_file);
$input_file = "eRADN/Daten/eRADN_TEST/eRADN_1696_20191202_091131_000.xml";
$input_xml = simplexml_load_file($input_file);

# This database has to be created like this: CREATE DATABASE zmb CHARACTER SET utf8 COLLATE utf8_general_ci;
$conn = new mysqli("172.17.0.2", "root", "zmb", "zmb");
$conn->set_charset('utf8');
$conn->begin_transaction();

if (!$conn->query("REPLACE INTO Provider VALUES ($provider_id, 'eRADN')")) {
  print("Couldn't create provider:\n");
  print($conn->error . "\n");
  exit(1);
}
$stmt_station = $conn->prepare("REPLACE INTO Station (id, name) VALUES (?, ?)");
$stmt_provider_station = $conn->prepare("REPLACE INTO Provider_Station (station, provider) VALUES (?, ?)");
foreach($topologie_xml->betriebspunkt as $station) {
  if (strlen($station->bpAbkuerzung) && strlen($station->bezeichnung)) {
    $stmt_station->bind_param("ss", $station->bpAbkuerzung, $station->bezeichnung);
    $stmt_station->execute();
    $stmt_provider_station->bind_param("si", $station->bpAbkuerzung, $provider_id);
    $stmt_provider_station->execute();
  }
}

$stmt_railline = $conn->prepare("REPLACE INTO Railline (id, provider, name) VALUES (?, ?, ?)");
$stmt_railline_station = $conn->prepare("REPLACE INTO Railline_Station (railline, `order`, id, station, meter, km1, km2) VALUES (?, ?, ?, ?, ?, ?, ?)");
foreach($input_xml->strecken->strecke as $strecke) {
  foreach($strecke->teilstrecken->teilstrecke as $teilstrecke) {
    $next_railline_id = $teilstrecke["id"];
    $next_railline_provider = $provider_id;
    $next_railline_name = $strecke["bezeichnung"] . " (" . $teilstrecke["bezeichnung"]. ")";
    $stmt_railline->bind_param("sis", $next_railline_id, $next_railline_provider, $next_railline_name);
    $stmt_railline->execute();

    # We are going through the stations in the railline, the first one
    # is by definition at km zero, while the others are documented in
    # the XML with the km2-km1 logic (upper and below number in a
    # printed railline format).

    $order = 0;
    $real_meter = 0;
    $prev_meter = 0;
    $first_iteration = true;

    foreach($teilstrecke->teilstreckenBPe->teilstreckenBp as $station) {
      if (!strlen($station["km1"])) continue;

      $meter1 = intval(floatval($station["km1"]) * 1000);
      if ($first_iteration) {
        if (strlen($station["km2"])) {
          $prev_meter = intval(floatval($station["km2"]) * 1000);
        } else {
          $prev_meter = $meter1;
        }
        $first_iteration = false;
      } else {
        $real_meter = $real_meter + abs($meter1 - $prev_meter);
      }
      if (strlen($station["km2"])) {
        $prev_meter = intval(floatval($station["km2"]) * 1000);
      } else {
        $prev_meter = $meter1;
      }

      $next_railline_station_railline = $next_railline_id;
      $next_railline_station_order = $order; $order = $order + 1;
      $next_railline_station_id = $station["id"];
      $next_railline_station_station = $station["bpAbkuerzung"];
      $next_railline_station_meter = $real_meter;
      $next_railline_station_km1 = $station["km1"];
      $next_railline_station_km2 = $station["km2"];
      $stmt_railline_station->bind_param("sississ",
        $next_railline_station_railline,
        $next_railline_station_order,
        $next_railline_station_id,
        $next_railline_station_station,
        $next_railline_station_meter,
        $next_railline_station_km1,
        $next_railline_station_km2);
      $stmt_railline_station->execute();
    }
  }
}

$conn->commit();
$conn->close();

?>
