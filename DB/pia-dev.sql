# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2017-06-28 17:56:11
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "job_levels"
#

DROP TABLE IF EXISTS `job_levels`;
CREATE TABLE `job_levels` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  `base_link` text NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `job_levels_unq` (`job_id`,`level`),
  CONSTRAINT `job_levels_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

#
# Data for table "job_levels"
#

INSERT INTO `job_levels` VALUES (2,1,1,'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83'),(3,1,2,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%81,_%D0%9C%D0%B5%D0%B9%D1%81%D0%BE%D0%BD');

#
# Structure for table "job_groups"
#

DROP TABLE IF EXISTS `job_groups`;
CREATE TABLE `job_groups` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `level_id` int(11) NOT NULL DEFAULT '0',
  `notes` varchar(255) DEFAULT '',
  PRIMARY KEY (`Id`),
  KEY `level_id` (`level_id`),
  CONSTRAINT `job_groups_ibfk_1` FOREIGN KEY (`level_id`) REFERENCES `job_levels` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

#
# Data for table "job_groups"
#

INSERT INTO `job_groups` VALUES (4,2,'Next Page'),(5,2,'Article Page'),(6,3,'Title'),(7,3,'content');

#
# Structure for table "job_rules"
#

DROP TABLE IF EXISTS `job_rules`;
CREATE TABLE `job_rules` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL DEFAULT '0',
  `notes` varchar(255) DEFAULT NULL,
  `container_offset` int(3) DEFAULT NULL,
  `critical_type` tinyint(3) DEFAULT NULL,
  `visual_color` int(11) DEFAULT NULL,
  `order_num` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `job_rules_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `job_groups` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

#
# Data for table "job_rules"
#

INSERT INTO `job_rules` VALUES (20,4,'next page',0,0,65280,0),(21,5,'article page',4,0,8421376,0),(22,6,'title',0,0,16776960,0),(23,7,'content',0,0,15780518,0),(24,7,'-1 div',1,0,255,0),(26,7,'right info box',0,0,0,0);

#
# Structure for table "job_rule_records"
#

DROP TABLE IF EXISTS `job_rule_records`;
CREATE TABLE `job_rule_records` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `key` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_rule_records_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_records"
#

INSERT INTO `job_rule_records` VALUES (1,22,'title'),(2,23,'content');

#
# Structure for table "job_rule_links"
#

DROP TABLE IF EXISTS `job_rule_links`;
CREATE TABLE `job_rule_links` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_rule_links_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_links"
#

INSERT INTO `job_rule_links` VALUES (13,20,1),(14,21,2);

#
# Structure for table "job_rule_cuts"
#

DROP TABLE IF EXISTS `job_rule_cuts`;
CREATE TABLE `job_rule_cuts` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_rule_cuts_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_cuts"
#

INSERT INTO `job_rule_cuts` VALUES (1,24,''),(3,26,'');

#
# Structure for table "job_nodes"
#

DROP TABLE IF EXISTS `job_nodes`;
CREATE TABLE `job_nodes` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `tag` varchar(255) NOT NULL DEFAULT '',
  `index` int(11) NOT NULL DEFAULT '0',
  `tag_id` varchar(255) DEFAULT NULL,
  `class` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_nodes_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8;

#
# Data for table "job_nodes"
#

INSERT INTO `job_nodes` VALUES (37,20,'HTML',1,'','client-js ve-available',''),(38,20,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',''),(39,20,'DIV',3,'content','mw-body',''),(40,20,'DIV',4,'bodyContent','mw-body-content',''),(41,20,'DIV',4,'mw-content-text','mw-content-ltr',''),(42,20,'DIV',2,'','mw-category-generated',''),(43,20,'DIV',2,'mw-pages','',''),(44,20,'A',1,'','',''),(45,21,'HTML',1,'','client-js ve-available',''),(46,21,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',''),(47,21,'DIV',3,'content','mw-body',''),(48,21,'DIV',4,'bodyContent','mw-body-content',''),(49,21,'DIV',4,'mw-content-text','mw-content-ltr',''),(50,21,'DIV',2,'','mw-category-generated',''),(51,21,'DIV',2,'mw-pages','',''),(52,21,'DIV',1,'','mw-content-ltr',''),(53,21,'DIV',1,'','mw-category',''),(54,21,'DIV',1,'','mw-category-group',''),(55,21,'UL',1,'','',''),(56,21,'LI',1,'','',''),(57,21,'A',1,'','',''),(58,22,'HTML',1,'','client-js ve-not-available',''),(59,22,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(60,22,'DIV',3,'content','mw-body',''),(61,22,'H1',1,'firstHeading','firstHeading',''),(70,23,'HTML',1,'','client-js ve-not-available',''),(71,23,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(72,23,'DIV',3,'content','mw-body',''),(73,23,'DIV',4,'bodyContent','mw-body-content',''),(74,23,'DIV',4,'mw-content-text','mw-content-ltr',''),(75,23,'DIV',1,'','mw-parser-output',''),(76,24,'HTML',1,'','client-js ve-not-available',''),(77,24,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(78,24,'DIV',3,'content','mw-body',''),(79,24,'DIV',4,'bodyContent','mw-body-content',''),(80,24,'DIV',4,'mw-content-text','mw-content-ltr',''),(81,24,'DIV',1,'','mw-parser-output',''),(82,24,'DIV',1,'','dablink noprint',''),(90,26,'HTML',1,'','client-js ve-not-available',''),(91,26,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(92,26,'DIV',3,'content','mw-body',''),(93,26,'DIV',4,'bodyContent','mw-body-content',''),(94,26,'DIV',4,'mw-content-text','mw-content-ltr',''),(95,26,'DIV',1,'','mw-parser-output',''),(96,26,'TABLE',1,'','infobox','');

#
# Structure for table "links"
#

DROP TABLE IF EXISTS `links`;
CREATE TABLE `links` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  `num` int(11) NOT NULL DEFAULT '0',
  `link` text NOT NULL,
  `link_hash` varchar(255) NOT NULL DEFAULT '',
  `handled` tinyint(3) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `link_unq` (`job_id`,`link_hash`,`level`),
  KEY `job_id` (`job_id`,`handled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# Data for table "links"
#

INSERT INTO `links` VALUES (9,1,1,1,'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83','f518495c4aeb7df47cd2dc0da0f045a2',0);

#
# Structure for table "users"
#

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(25) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `is_admin` tinyint(3) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

#
# Data for table "users"
#

INSERT INTO `users` VALUES (1,'admin','123',1);

#
# Structure for table "jobs"
#

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `caption` varchar(255) NOT NULL DEFAULT '',
  `zero_link` text NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

#
# Data for table "jobs"
#

INSERT INTO `jobs` VALUES (1,1,'Wikipedia Актёры','https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83');

#
# Trigger "DeleteCutRule"
#

DROP TRIGGER IF EXISTS `DeleteCutRule`;
pia-dev

#
# Trigger "DeleteLinkRule"
#

DROP TRIGGER IF EXISTS `DeleteLinkRule`;
pia-dev

#
# Trigger "DeleteRecRule"
#

DROP TRIGGER IF EXISTS `DeleteRecRule`;
pia-dev

#
# Trigger "HashWritter"
#

DROP TRIGGER IF EXISTS `HashWritter`;
pia-dev
