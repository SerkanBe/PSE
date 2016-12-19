<?php

$dsn = 'mysql:dbname=pse;host=127.0.0.1;charset=UTF8';
$db = new PDO($dsn,'root');
var_dump($_GET);


$filter = array();
$group_by = array();

function column_exists($cols) {
	global $db;
	$tcols = $db->prepare('select COLUMN_NAME
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME=elec_net_gen');

	$tcols->execute();
	$tcols = $tcols->fetchAll(PDO::FETCH_COLUMN);
	if(count(array_diff($cols,$tcols)) > 0) {	
		return FALSE;
	}
	
	return TRUE;
}

$where_clause = '';
$group_clause = '';
$order_clause = '';
$select_clause = 'p.month,p.quarter,p.year, f.name, se.name, amount,st.name,unit';

$available_fields = array('year' => 'p.year','month'=>'p.month','quarter'=>'p.quarter','fuel'=>'f.name','sector'=>'se.name','state'=>'st.name');

$filters = array();
foreach($available_fields as $field => $col) {
	if(isset($_GET[$field])) {
		$filters[$field] = $col.' IN ('.implode(',', array_map(array($db,'quote'),$_GET[$field])).')';
	}
}
if(!empty($filters)) {
$where_clause = ' WHERE '.implode(' AND ',$filters);
}


if(isset($_GET['group_by'])) {
	$group_by = $_GET['group_by'];
	if(column_exists($group_by)) {
		echo json_encode('invalid group column');
		return FALSE;
	}
	$fields = array();
	foreach($available_fields as $field => $col) {
		if(in_array($field, $_GET['group_by'])) {
			$fields[$field] = $col;
		}
	}
	if(!empty($fields)) {
		$group_clause = ' GROUP BY '.implode($fields);
	}
}

if(isset($_GET['order_by'])) {
	$order_by = $_GET['order_by'];	
	if(column_exists($order_by	)) {
		echo json_encode('invalid order column');
		return FALSE;
	}
	$fields = array();
	foreach($available_fields as $field => $col) {		
		if(isset($_GET['order_by'][$field])) {			
			$fields[$field] = $col.' '.$_GET['order_by'][$field];
		}
	}	
	
	if(!empty($fields)) {
		$order_clause = ' ORDER BY '.implode($fields);
	}
}

if(isset($_GET['columns'])) {
	$fields = array();
	foreach($available_fields as $field => $col) {
		if(in_array($field, $_GET['columns'])) {
			$fields[$field] = $col.' as '.$field;
		}
	}
	// We want to aggregate fields?!
	if(isset($_GET['aggr'])) {
		foreach($_GET['aggr'] as $field => $func) {
			$fields[$field] = $func.'('.$field.') as '.$func.'_'.$field;
		}
	}
	
	
	if(!empty($fields)) {
		$select_clause = implode(', ',$fields);
	}
}

$q_str = 'SELECT '.$select_clause.'
FROM elec_net_gen eng
LEFT JOIN period p ON (p.id = eng.period)
LEFT JOIN fuel f ON (f.id = eng.fuel)
LEFT JOIN gen_cons_sector se ON (se.id = eng.sector)
LEFT JOIN state st ON (st.id = eng.state)';
(empty($where_clause)) ?: $q_str.= $where_clause;
(empty($group_clause)) ?: $q_str.= $group_clause;
(empty($order_clause)) ?: $q_str.= $order_clause;

echo $q_str;
echo "<br><br><br>";
$query = $db->prepare($q_str);
$query->execute(array('fuel'));

$result = $query->fetchAll(PDO::FETCH_ASSOC);
var_export($result);
echo json_encode(array_values($result));