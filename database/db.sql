-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server Version:               5.5.27 - MySQL Community Server (GPL)
-- Server Betriebssystem:        Win32
-- HeidiSQL Version:             9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Exportiere Datenbank Struktur für pse
CREATE DATABASE IF NOT EXISTS `pse` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `pse`;

-- Exportiere Struktur von Tabelle pse.category
CREATE TABLE IF NOT EXISTS `category` (
  `id` int(11) NOT NULL,
  `parent` int(11) DEFAULT NULL,
  `path` varchar(50) DEFAULT NULL,
  `path_depth` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `notes` text,
  `childseries` text,
  PRIMARY KEY (`id`),
  KEY `category_parent` (`parent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.category_tree
CREATE TABLE IF NOT EXISTS `category_tree` (
  `parent` int(11) DEFAULT NULL,
  `child` int(11) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `weight` int(11) NOT NULL AUTO_INCREMENT,
  KEY `order` (`weight`)
) ENGINE=InnoDB AUTO_INCREMENT=52401 DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.consumption
CREATE TABLE IF NOT EXISTS `consumption` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `series_id` varchar(50) DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `fuel` int(11) DEFAULT NULL,
  `sector` int(11) DEFAULT NULL,
  `amount` decimal(20,3) DEFAULT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cons_fuel` (`fuel`),
  KEY `cons_period` (`period`),
  KEY `cons_sector` (`sector`),
  KEY `cons_state` (`state`),
  CONSTRAINT `cons_fuel` FOREIGN KEY (`fuel`) REFERENCES `fuel` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `cons_period` FOREIGN KEY (`period`) REFERENCES `period` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `cons_sector` FOREIGN KEY (`sector`) REFERENCES `gen_cons_sector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `cons_state` FOREIGN KEY (`state`) REFERENCES `state` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2447684 DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.elec_net_gen
CREATE TABLE IF NOT EXISTS `elec_net_gen` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `series_id` varchar(50) DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `fuel` int(11) DEFAULT NULL,
  `sector` int(11) DEFAULT NULL,
  `amount` decimal(20,3) DEFAULT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gen_period` (`period`),
  KEY `gen_fuel` (`fuel`),
  KEY `gen_sector` (`sector`),
  KEY `gen_state` (`state`),
  CONSTRAINT `gen_fuel` FOREIGN KEY (`fuel`) REFERENCES `fuel` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_period` FOREIGN KEY (`period`) REFERENCES `period` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_sector` FOREIGN KEY (`sector`) REFERENCES `gen_cons_sector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `gen_state` FOREIGN KEY (`state`) REFERENCES `state` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1397658 DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.elec_retail
CREATE TABLE IF NOT EXISTS `elec_retail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `series_id` varchar(50) DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `sector` int(11) DEFAULT NULL,
  `amount` decimal(20,3) DEFAULT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `retail_period` (`period`),
  KEY `retail_sector` (`sector`),
  KEY `retail_state` (`state`),
  CONSTRAINT `retail_period` FOREIGN KEY (`period`) REFERENCES `period` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `retail_sector` FOREIGN KEY (`sector`) REFERENCES `retail_sector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `retail_state` FOREIGN KEY (`state`) REFERENCES `state` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92914 DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.fuel
CREATE TABLE IF NOT EXISTS `fuel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `parent` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fuel_parent` (`parent`),
  CONSTRAINT `fuel_parent` FOREIGN KEY (`parent`) REFERENCES `fuel` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.gen_cons_sector
CREATE TABLE IF NOT EXISTS `gen_cons_sector` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `parent` int(11) DEFAULT '0',
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gc_sector_parent` (`parent`),
  CONSTRAINT `gc_sector_parent` FOREIGN KEY (`parent`) REFERENCES `gen_cons_sector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.period
CREATE TABLE IF NOT EXISTS `period` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `month` int(2) DEFAULT NULL,
  `quarter` int(2) DEFAULT NULL,
  `year` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.retail_sector
CREATE TABLE IF NOT EXISTS `retail_sector` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `parent` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ret_sector_parent` (`parent`),
  CONSTRAINT `ret_sector_parent` FOREIGN KEY (`parent`) REFERENCES `retail_sector` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle pse.state
CREATE TABLE IF NOT EXISTS `state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Daten Export vom Benutzer nicht ausgewählt
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
