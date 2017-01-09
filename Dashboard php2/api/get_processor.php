<?php

(isset($_GET['group_by'])) ?: $_GET['group_by'] = NULL;
(isset($_GET['order_by'])) ?: $_GET['order_by'] = NULL;
(isset($_GET['columns'])) ?: $_GET['columns'] = NULL;
(isset($_GET['aggr'])) ?: $_GET['aggr'] = NULL;

function do_where($get_values = NULL, $available_fields = array(), $where_clause = '')
{
	global $db;
  if ($get_values !== NULL) {
    $filters = array();
    foreach($available_fields as $field => $col) {
      if (isset($get_values[$field])) {
        $filters[$field] = $col . ' IN (' . implode(',', array_map(array(
          $db,
          'quote'
        ) , $get_values[$field])) . ')';
      }
    }

    if (!empty($filters)) {
      $where_clause = ' WHERE ' . implode(' AND ', $filters);
    }
  }

  return $where_clause;
}

function do_group_by($group_by = NULL, $available_fields = array(), $group_clause = '')
{
	global $db;
  if ($group_by !== NULL) {
    if (column_exists($group_by)) {
      echo json_encode('invalid group column');
      return FALSE;
    }

    $fields = array();
    foreach($available_fields as $field => $col) {
      if (in_array($field, $group_by)) {
        $fields[$field] = $col;
      }
    }

    if (!empty($fields)) {
      $group_clause = ' GROUP BY ' . implode(', ', $fields);
    }
  }

  return $group_clause;
}

function do_order_by($order_by = NULL, $available_fields = array(), $order_clause = '')
{
	global $db;
  if ($order_by !== NULL) {
    if (column_exists($order_by)) {
      echo json_encode('invalid order column');
      return FALSE;
    }

    $fields = array();
    foreach($available_fields as $field => $col) {
      if (isset($order_by[$field])) {
        $fields[$field] = $col . ' ' . $order_by[$field];
      }
    }

    if (!empty($fields)) {
      $order_clause = ' ORDER BY ' . implode(', ', $fields);
    }
  }

  return $order_clause;
}

function do_select($columns = NULL, $aggregations = array(), $available_fields = array(), $select_clause = '')
{
	global $db;	
  if ($columns !== NULL) {
    $fields = array();
    foreach($available_fields as $field => $col) {
      if (in_array($field, $columns)) {
        $fields[$field] = $col . ' as ' . $field;
      }
    }
	
    // We want to aggregate fields?!

    if (isset($aggregations)) {
      foreach($aggregations as $field => $func) {
        if ($field === '*') {
          $fields[$field] = $func . '(*) as count';
        }
        else {
          $fields[$field] = $func . '(' . $field . ') as ' . $func . '_' . $field;
        }
      }
    }

    if (!empty($fields)) {
      $select_clause = implode(', ', $fields);
    }
  }

  return $select_clause;
}
