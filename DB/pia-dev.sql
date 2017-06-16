# Host: 127.0.0.1  (Version 5.7.18-log)
# Date: 2017-06-16 17:27:35
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

#
# Data for table "job_levels"
#

INSERT INTO `job_levels` VALUES (1,1,1,'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83'),(6,1,2,'https://ru.wikipedia.org/wiki/50_Cent');

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

INSERT INTO `job_groups` VALUES (2,1,'Next Page'),(3,1,'Article Page'),(6,6,'title'),(7,6,'Content');

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

INSERT INTO `job_rules` VALUES (14,2,'Next Page Link',0,0,65280,1),(19,3,'Article Link',4,0,15780518,1),(23,6,'caption',0,0,15780518,1),(25,7,'content',0,0,15780518,1),(26,7,'cut',0,0,0,2);

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_records"
#

INSERT INTO `job_rule_records` VALUES (4,23,'title'),(6,25,'content');

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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_links"
#

INSERT INTO `job_rule_links` VALUES (11,14,1),(12,19,2);

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_cuts"
#

INSERT INTO `job_rule_cuts` VALUES (4,25,'first cut');

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
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8;

#
# Data for table "job_nodes"
#

INSERT INTO `job_nodes` VALUES (156,14,'HTML',1,'','client-js ve-available',''),(157,14,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',''),(158,14,'DIV',3,'content','mw-body',''),(159,14,'DIV',4,'bodyContent','mw-body-content',''),(160,14,'DIV',4,'mw-content-text','mw-content-ltr',''),(161,14,'DIV',2,'','mw-category-generated',''),(162,14,'DIV',2,'mw-pages','',''),(163,14,'A',1,'','',''),(164,19,'HTML',1,'','client-js ve-available',''),(165,19,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',''),(166,19,'DIV',3,'content','mw-body',''),(167,19,'DIV',4,'bodyContent','mw-body-content',''),(168,19,'DIV',4,'mw-content-text','mw-content-ltr',''),(169,19,'DIV',2,'','mw-category-generated',''),(170,19,'DIV',2,'mw-pages','',''),(171,19,'DIV',1,'','mw-content-ltr',''),(172,19,'DIV',1,'','mw-category',''),(173,19,'DIV',1,'','mw-category-group',''),(174,19,'UL',1,'','',''),(175,19,'LI',1,'','',''),(176,19,'A',1,'','',''),(225,23,'HTML',1,'','client-js ve-not-available',''),(226,23,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(227,23,'DIV',3,'content','mw-body',''),(228,23,'H1',1,'firstHeading','firstHeading',''),(236,25,'HTML',1,'','client-js ve-not-available',''),(237,25,'BODY',1,'','mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',''),(238,25,'DIV',3,'content','mw-body',''),(239,25,'DIV',4,'bodyContent','mw-body-content',''),(240,25,'DIV',4,'mw-content-text','mw-content-ltr',''),(241,25,'DIV',1,'','mw-parser-output','');

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
