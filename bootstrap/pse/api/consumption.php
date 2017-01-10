<?php

$dsn = 'mysql:dbname=pse;host=127.0.0.1;charset=UTF8';
$db = new PDO($dsn,'root');

$filter = array();
$group_by = array();

function column_exists($cols) {
	global $db;
	$tcols = $db->prepare('select COLUMN_NAME
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME=consumption');

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
$select_clause = 'p.month,p.quarter,p.year, f.name as fuel, se.name as sector, amount,st.name as state,unit';

$available_fields = array('year' => 'p.year','month'=>'p.month','quarter'=>'p.quarter','fuel'=>'f.name','sector'=>'se.name','state'=>'st.name');

require_once('get_processor.php');
$where_clause = do_where($_GET,$available_fields);
$group_clause = do_group_by($_GET['group_by'],$available_fields);
$order_clause = do_order_by($_GET['order_by'],$available_fields);
$select_clause = do_select($_GET['columns'],$_GET['aggr'],$available_fields,$select_clause);

$q_str = 'SELECT '.$select_clause.'
FROM consumption t
LEFT JOIN period p ON (p.id = t.period)
LEFT JOIN fuel f ON (f.id = t.fuel)
LEFT JOIN gen_cons_sector se ON (se.id = t.sector)
LEFT JOIN state st ON (st.id = t.state)';

(empty($where_clause)) ?: $q_str.= $where_clause;
(empty($group_clause)) ?: $q_str.= $group_clause;
(empty($order_clause)) ?: $q_str.= $order_clause;

$query = $db->prepare($q_str);
$query->execute(array('fuel'));

$result = $query->fetchAll(PDO::FETCH_ASSOC);
echo json_encode(array_values($result));