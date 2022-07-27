<?php
include 'connection.php';

$nim = $_POST['nim'];
$sql = "SELECT * from tb_mahasiswa WHERE nim='".$nim."'";
$result = $connect->query($sql);

if($result->num_rows > 0) {
    echo json_encode(array("ada"=>true));
} else {
    echo json_encode(array("ada"=>false));
}