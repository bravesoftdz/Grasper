# Host: 127.0.0.1  (Version 5.5.23)
# Date: 2017-04-19 10:16:09
# Generator: MySQL-Front 6.0  (Build 1.124)


#
# Structure for table "job_groups"
#

CREATE TABLE `job_groups` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_level_id` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `job_level_id` (`job_level_id`),
  CONSTRAINT `job_groups_ibfk_1` FOREIGN KEY (`job_level_id`) REFERENCES `job_levels` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

#
# Data for table "job_groups"
#

REPLACE INTO `job_groups` VALUES (1,1,'страна'),(2,2,NULL),(3,3,NULL),(4,3,NULL),(7,6,NULL),(8,6,NULL),(9,7,NULL),(10,7,NULL),(11,8,'актёр'),(12,8,'след стр.'),(14,9,'адрес'),(15,9,'сайт'),(16,9,'сайт 2'),(17,9,'контент');

#
# Structure for table "job_regexp_type_ref"
#

CREATE TABLE `job_regexp_type_ref` (
  `Id` tinyint(3) NOT NULL DEFAULT '0',
  `refval` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# Data for table "job_regexp_type_ref"
#

REPLACE INTO `job_regexp_type_ref` VALUES (1,'check if any match'),(2,'get matches'),(3,'delete matches');

#
# Structure for table "job_rules"
#

CREATE TABLE `job_rules` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL DEFAULT '0',
  `description` varchar(255) DEFAULT NULL,
  `container_offset` int(3) DEFAULT NULL,
  `critical_type` tinyint(3) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `job_rules_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `job_groups` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

#
# Data for table "job_rules"
#

REPLACE INTO `job_rules` VALUES (2,1,'ссылка на страну',2,1),(4,2,'ссылка на раздел Отели',0,2),(8,4,'ссылка на регион',8,1),(9,3,'след страница',0,2),(11,8,'ссылка на отель',9,2),(12,7,'след страница',0,2),(13,10,'альт название',0,0),(14,9,'название',0,2),(15,1,'страна',2,1),(16,11,'ссылка',4,0),(17,11,'имя рус',4,0),(18,12,'ссылка след стр.',1,0),(20,14,'адрес',1,0),(23,15,'сайт',1,0),(24,16,'сайт',2,0),(25,17,'контент рус.',0,0);

#
# Structure for table "job_rule_records"
#

CREATE TABLE `job_rule_records` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `key` varchar(255) NOT NULL DEFAULT '',
  `type_refid` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_rule_records_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_records"
#

REPLACE INTO `job_rule_records` VALUES (3,13,'alt_title',1),(4,14,'title',1),(5,15,'ru_country',1),(6,17,'ru_name',1),(7,25,'ru_content',1),(8,20,'ru_address',1),(11,23,'site',2),(12,24,'site',2);

#
# Structure for table "job_rule_links"
#

CREATE TABLE `job_rule_links` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_rule_links_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

#
# Data for table "job_rule_links"
#

REPLACE INTO `job_rule_links` VALUES (2,2,2),(4,4,3),(8,8,4),(9,9,3),(11,11,5),(12,12,4),(15,16,2),(16,18,1);

#
# Structure for table "job_regexp"
#

CREATE TABLE `job_regexp` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `regexp` varchar(255) NOT NULL DEFAULT '',
  `type_refid` tinyint(3) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Id`),
  KEY `job_rule_id` (`job_rule_id`),
  KEY `type_refid` (`type_refid`),
  CONSTRAINT `job_regexp_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `job_regexp_ibfk_2` FOREIGN KEY (`type_refid`) REFERENCES `job_regexp_type_ref` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

#
# Data for table "job_regexp"
#

REPLACE INTO `job_regexp` VALUES (1,2,'-g(\\d){3,}-',1),(2,4,'/Hotels-',1),(5,9,'-oa(\\d)+-',1),(7,18,'Следующая',1),(8,25,'\\[.*\\]',3),(9,20,'^Местоположение(.|\\n)+',2),(10,20,'^Местоположение\\s',3),(11,23,'http://[0-9a-zA-Z./?-]+',2),(12,24,'официальный сайт',1),(13,24,'http://[0-9a-zA-Z./?-]+',2);

#
# Structure for table "job_nodes"
#

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
) ENGINE=InnoDB AUTO_INCREMENT=302 DEFAULT CHARSET=utf8;

#
# Data for table "job_nodes"
#

REPLACE INTO `job_nodes` VALUES (2,2,'HTML',1,NULL,NULL,NULL),(3,2,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(4,2,'DIV',3,'PAGE',' non_hotels_like desktop scopedSearch',NULL),(5,2,'DIV',4,'MAINWRAP',' ',NULL),(6,2,'DIV',1,'MAIN','SiteIndex\r\n prodp13n_jfy_overflow_visible\r\n ',NULL),(7,2,'DIV',1,'BODYCON','col poolB adjust_padding new_meta_chevron_v2',NULL),(8,2,'DIV',2,NULL,'sectionCollection',NULL),(9,2,'DIV',1,NULL,'resizingMargins',NULL),(10,2,'DIV',1,'taplc_html_sitemap_payload_0','ppr_rup ppr_priv_html_sitemap_payload',NULL),(11,2,'DIV',1,NULL,'prw_rup prw_links_sitemap_container',NULL),(12,2,'DIV',1,NULL,'world_destinations container',NULL),(13,2,'UL',1,NULL,NULL,NULL),(14,2,'LI',1,NULL,NULL,NULL),(15,2,'A',1,NULL,NULL,NULL),(30,4,'HTML',1,NULL,NULL,NULL),(31,4,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(32,4,'DIV',3,'PAGE',' non_hotels_like desktop scopedSearch',NULL),(33,4,'DIV',1,'HEAD','',NULL),(34,4,'DIV',1,NULL,'masthead\r\n masthead_war_dropdown_enabled masthead_notification_enabled\r\n ',NULL),(35,4,'DIV',2,NULL,' tabsBar',NULL),(36,4,'UL',1,NULL,'tabs',NULL),(37,4,'LI',2,NULL,'tabItem hvrIE6',NULL),(38,4,'A',1,NULL,'tabLink pid4965',NULL),(85,8,'HTML',1,NULL,NULL,NULL),(86,8,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(87,8,'DIV',3,'PAGE',' hotels_like desktop scopedSearch withMapIcon bg_f8',NULL),(88,8,'DIV',3,'DEALSHOME',NULL,NULL),(89,8,'DIV',1,'MAIN',NULL,NULL),(90,8,'DIV',2,NULL,'maincontent rollup',NULL),(91,8,'DIV',1,'SDTOPDESTCONTENT','topdestinations rollup',NULL),(92,8,'DIV',1,'LOCATION_LIST','deckB',NULL),(93,8,'DIV',1,'BROAD_GRID',NULL,NULL),(94,8,'DIV',1,NULL,'geos_grid',NULL),(95,8,'DIV',1,NULL,'geos_row',NULL),(96,8,'DIV',1,NULL,'geo_wrap',NULL),(97,8,'DIV',1,NULL,'geo_entry',NULL),(98,8,'DIV',1,NULL,'geo_info',NULL),(99,8,'DIV',2,NULL,'geo_name',NULL),(100,8,'A',1,NULL,NULL,NULL),(101,9,'HTML',1,NULL,NULL,NULL),(102,9,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(103,9,'DIV',3,'PAGE',' hotels_like desktop scopedSearch withMapIcon bg_f8',NULL),(104,9,'DIV',3,'DEALSHOME',NULL,NULL),(105,9,'DIV',1,'MAIN',NULL,NULL),(106,9,'DIV',2,NULL,'maincontent rollup',NULL),(107,9,'DIV',1,'SDTOPDESTCONTENT','topdestinations rollup',NULL),(108,9,'DIV',2,NULL,'deckTools btm',NULL),(109,9,'DIV',1,NULL,'unified pagination ',NULL),(110,9,'A',1,NULL,'nav next rndBtn ui_button primary taLnk',NULL),(131,11,'HTML',1,NULL,NULL,NULL),(132,11,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(133,11,'DIV',3,'PAGE','meta_hotels hotels_like desktop scopedSearch withMapIcon bg_f8',NULL),(134,11,'DIV',6,'MAINWRAP',' hotels_lf_redesign flexChevron ',NULL),(135,11,'DIV',2,'MAIN','Hotels\r\n condense_filters prodp13n_jfy_overflow_visible\r\n ',NULL),(136,11,'DIV',1,'BODYCON','col poolA new_meta_chevron_v2',NULL),(137,11,'DIV',3,NULL,'gridA single_col_hotels txtLnkDropDown ',NULL),(138,11,'DIV',1,NULL,'col balance',NULL),(139,11,'DIV',5,'HAC_RESULTS',NULL,NULL),(140,11,'DIV',2,NULL,'hotels_list_placement',NULL),(141,11,'DIV',1,'taplc_hotels_list_short_cells2_0','ppr_rup ppr_priv_hotels_list_short_cells2',NULL),(142,11,'DIV',1,'ACCOM_OVERVIEW','deckA hacTabLIST shortCells long_prices noDates sbs txtLnkULHover bookingEnabled firstPage ',NULL),(143,11,'DIV',3,'hotel_3259472','listing easyClear p13n_imperfect ',NULL),(144,11,'DIV',1,NULL,'prw_rup prw_meta_short_cell_listing',NULL),(145,11,'DIV',1,NULL,'meta_listing easyClear metaCacheKey msk',NULL),(146,11,'DIV',1,NULL,'metaLocationInfo nonen',NULL),(147,11,'DIV',1,NULL,'property_details easyClear',NULL),(148,11,'DIV',1,NULL,'listing_info popIndexValidation styleguide_ratings',NULL),(149,11,'DIV',1,NULL,'listing_title',NULL),(150,11,'A',1,'property_3259472','property_title ',NULL),(151,12,'HTML',1,NULL,NULL,NULL),(152,12,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(153,12,'DIV',3,'PAGE','meta_hotels hotels_like desktop scopedSearch withMapIcon bg_f8',NULL),(154,12,'DIV',6,'MAINWRAP',' hotels_lf_redesign flexChevron ',NULL),(155,12,'DIV',2,'MAIN','Hotels\r\n condense_filters prodp13n_jfy_overflow_visible\r\n ',NULL),(156,12,'DIV',1,'BODYCON','col poolB new_meta_chevron_v2',NULL),(157,12,'DIV',3,NULL,'gridA single_col_hotels txtLnkDropDown ',NULL),(158,12,'DIV',1,NULL,'col balance',NULL),(159,12,'DIV',5,'HAC_RESULTS',NULL,NULL),(160,12,'DIV',2,NULL,'hotels_list_placement',NULL),(161,12,'DIV',1,'taplc_hotels_list_short_cells2_0','ppr_rup ppr_priv_hotels_list_short_cells2',NULL),(162,12,'DIV',1,'ACCOM_OVERVIEW','deckA hacTabLIST shortCells long_prices noDates sbs txtLnkULHover bookingEnabled firstPage ',NULL),(163,12,'DIV',40,NULL,'deckTools easyClear unified_pagination',NULL),(164,12,'DIV',2,NULL,'prw_rup prw_common_standard_pagination',NULL),(165,12,'DIV',1,NULL,'unified pagination standard_pagination',NULL),(166,12,'A',1,NULL,'nav next ui_button primary taLnk',NULL),(167,13,'HTML',1,NULL,NULL,NULL),(168,13,'BODY',1,NULL,' fall_2013_refresh_hr_top css_commerce_buttons ltr domn_ru lang_ru long_prices globalNav2011_reset hr_tabs_placement_test tabs_below_meta hr_tabs content_blocks flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(169,13,'DIV',3,'PAGE',' non_hotels_like desktop gutterAd scopedSearch bg_f8',NULL),(170,13,'DIV',5,'taplc_poi_header_0','ppr_rup ppr_priv_poi_header',NULL),(171,13,'DIV',1,NULL,'heading_2014 hr_heading',NULL),(172,13,'DIV',1,NULL,'header_container',NULL),(173,13,'DIV',1,NULL,'full_width',NULL),(174,13,'DIV',1,'HEADING_GROUP','',NULL),(175,13,'DIV',1,NULL,'headingWrapper easyClear ',NULL),(176,13,'DIV',1,NULL,'heading_name_wrapper',NULL),(177,13,'H1',1,'HEADING','heading_name with_alt_title limit_width_800',NULL),(178,13,'SPAN',1,NULL,'altHead',NULL),(179,14,'HTML',1,NULL,NULL,NULL),(180,14,'BODY',1,NULL,' fall_2013_refresh_hr_top css_commerce_buttons ltr domn_ru lang_ru long_prices globalNav2011_reset hr_tabs_placement_test tabs_below_meta hr_tabs content_blocks flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(181,14,'DIV',3,'PAGE',' non_hotels_like desktop gutterAd scopedSearch bg_f8',NULL),(182,14,'DIV',5,'taplc_poi_header_0','ppr_rup ppr_priv_poi_header',NULL),(183,14,'DIV',1,NULL,'heading_2014 hr_heading',NULL),(184,14,'DIV',1,NULL,'header_container',NULL),(185,14,'DIV',1,NULL,'full_width',NULL),(186,14,'DIV',1,'HEADING_GROUP','',NULL),(187,14,'DIV',1,NULL,'headingWrapper easyClear ',NULL),(188,14,'DIV',1,NULL,'heading_name_wrapper',NULL),(189,14,'H1',1,'HEADING','heading_name with_alt_title limit_width_800',NULL),(190,15,'HTML',1,NULL,NULL,NULL),(191,15,'BODY',1,NULL,'ltr domn_ru lang_ru long_prices globalNav2011_reset css_commerce_buttons flat_buttons sitewide xo_pin_user_review_to_top track_back',NULL),(192,15,'DIV',3,'PAGE',' non_hotels_like desktop scopedSearch',NULL),(193,15,'DIV',5,'MAINWRAP',' ',NULL),(194,15,'DIV',1,'MAIN','SiteIndex\r\n prodp13n_jfy_overflow_visible\r\n ',NULL),(195,15,'DIV',1,'BODYCON','col poolA adjust_padding new_meta_chevron_v2',NULL),(196,15,'DIV',2,NULL,'sectionCollection',NULL),(197,15,'DIV',1,NULL,'resizingMargins',NULL),(198,15,'DIV',1,'taplc_html_sitemap_payload_0','ppr_rup ppr_priv_html_sitemap_payload',NULL),(199,15,'DIV',1,NULL,'prw_rup prw_links_sitemap_container',NULL),(200,15,'DIV',1,NULL,'world_destinations container',NULL),(201,15,'UL',1,NULL,NULL,NULL),(202,15,'LI',1,NULL,NULL,NULL),(203,15,'A',1,NULL,NULL,NULL),(205,16,'HTML',1,NULL,'client-js ve-available',NULL),(206,16,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',NULL),(207,16,'DIV',3,'content','mw-body',NULL),(208,16,'DIV',3,'bodyContent','mw-body-content',NULL),(209,16,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(210,16,'DIV',2,NULL,'mw-category-generated',NULL),(211,16,'DIV',2,'mw-pages',NULL,NULL),(212,16,'DIV',1,NULL,'mw-content-ltr',NULL),(213,16,'DIV',1,NULL,'mw-category',NULL),(214,16,'DIV',1,NULL,'mw-category-group',NULL),(215,16,'UL',1,NULL,NULL,NULL),(216,16,'LI',1,NULL,NULL,NULL),(217,16,'A',1,NULL,NULL,NULL),(218,17,'HTML',1,NULL,'client-js ve-available',NULL),(219,17,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',NULL),(220,17,'DIV',3,'content','mw-body',NULL),(221,17,'DIV',3,'bodyContent','mw-body-content',NULL),(222,17,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(223,17,'DIV',2,NULL,'mw-category-generated',NULL),(224,17,'DIV',2,'mw-pages',NULL,NULL),(225,17,'DIV',1,NULL,'mw-content-ltr',NULL),(226,17,'DIV',1,NULL,'mw-category',NULL),(227,17,'DIV',1,NULL,'mw-category-group',NULL),(228,17,'UL',1,NULL,NULL,NULL),(229,17,'LI',1,NULL,NULL,NULL),(230,17,'A',1,NULL,NULL,NULL),(231,18,'HTML',1,NULL,'client-js ve-available',NULL),(232,18,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-14 ns-subject page-Категория_Актёры_по_алфавиту rootpage-Категория_Актёры_по_алфавиту skin-vector action-view',NULL),(233,18,'DIV',3,'content','mw-body',NULL),(234,18,'DIV',3,'bodyContent','mw-body-content',NULL),(235,18,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(236,18,'DIV',2,NULL,'mw-category-generated',NULL),(237,18,'DIV',2,'mw-pages',NULL,NULL),(238,18,'A',1,NULL,NULL,NULL),(243,25,'HTML',1,NULL,'client-js ve-available',NULL),(244,25,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-50_Cent rootpage-50_Cent skin-vector action-view',NULL),(245,25,'DIV',3,'content','mw-body',NULL),(246,25,'DIV',3,'bodyContent','mw-body-content',NULL),(247,25,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(248,20,'HTML',1,NULL,'client-js ve-available',NULL),(249,20,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-Атлант_стадион_Новополоцк rootpage-Атлант_стадион_Новополоцк skin-vector action-view',NULL),(250,20,'DIV',3,'content','mw-body',NULL),(251,20,'DIV',3,'bodyContent','mw-body-content',NULL),(252,20,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(253,20,'TABLE',1,NULL,'infobox',NULL),(254,20,'TBODY',1,NULL,NULL,NULL),(255,20,'TR',2,NULL,NULL,NULL),(283,23,'HTML',1,NULL,'client-js ve-available',NULL),(284,23,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-Sylvester rootpage-Sylvester skin-vector action-view',NULL),(285,23,'DIV',3,'content','mw-body',NULL),(286,23,'DIV',3,'bodyContent','mw-body-content',NULL),(287,23,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(288,23,'TABLE',1,NULL,'infobox',NULL),(289,23,'TBODY',1,NULL,NULL,NULL),(290,23,'TR',12,NULL,NULL,NULL),(295,24,'HTML',1,NULL,'client-js ve-available',NULL),(296,24,'BODY',1,NULL,'mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-Paradise_Oskar rootpage-Paradise_Oskar skin-vector action-view',NULL),(297,24,'DIV',3,'content','mw-body',NULL),(298,24,'DIV',3,'bodyContent','mw-body-content',NULL),(299,24,'DIV',4,'mw-content-text','mw-content-ltr',NULL),(300,24,'UL',1,NULL,NULL,NULL),(301,24,'LI',3,NULL,NULL,NULL);

#
# Structure for table "job_custom_procs"
#

CREATE TABLE `job_custom_procs` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_rule_id` int(10) NOT NULL DEFAULT '0',
  `script_lang_refid` int(11) NOT NULL DEFAULT '0',
  `custom_proc_name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `un_job_custom_proc` (`job_rule_id`,`script_lang_refid`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_custom_procs_ibfk_1` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

#
# Data for table "job_custom_procs"
#

REPLACE INTO `job_custom_procs` VALUES (1,25,2,'RomanParsers_procWikiContent'),(2,25,1,'custom_RomanParsers.procWikiContent');

#
# Structure for table "test_links"
#

CREATE TABLE `test_links` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `link` text NOT NULL,
  `lev` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

#
# Data for table "test_links"
#

REPLACE INTO `test_links` VALUES (1,'https://ru.wikipedia.org/wiki/50_Cent',1),(2,'https://ru.wikipedia.org/wiki/%D0%90%D1%82%D0%BB%D0%B0%D0%BD%D1%82_(%D1%81%D1%82%D0%B0%D0%B4%D0%B8%D0%BE%D0%BD,_%D0%9D%D0%BE%D0%B2%D0%BE%D0%BF%D0%BE%D0%BB%D0%BE%D1%86%D0%BA)',1),(3,'https://ru.wikipedia.org/wiki/%D0%92%D0%B8%D0%BB%D0%B0_%D0%9A%D0%B0%D0%BF%D0%B0%D0%BD%D0%B5%D0%BC%D0%B0',1),(4,'https://ru.wikipedia.org/wiki/%D0%93%D0%BB%D1%8E%D0%BA%D0%B0%D1%83%D1%84-%D0%9A%D0%B0%D0%BC%D0%BF%D1%84%D0%B1%D0%B0%D0%BD',1),(5,'https://ru.wikipedia.org/wiki/%D0%91%D0%B5%D1%80%D0%BD_%D0%90%D1%80%D0%B5%D0%BD%D0%B0_(%D1%84%D1%83%D1%82%D0%B1%D0%BE%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D1%81%D1%82%D0%B0%D0%B4%D0%B8%D0%BE%D0%BD)',1);

#
# Structure for table "users"
#

CREATE TABLE `users` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(25) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `email` varchar(60) NOT NULL DEFAULT '',
  `is_active` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

#
# Data for table "users"
#

REPLACE INTO `users` VALUES (1,'admin','$2a$08$jHZj/wJfcVKlIwr5AvR78euJxYK7Ku5kURNhNx.7.CSIJ3Pq6LEPC','admin@example.com',1);

#
# Structure for table "jobs"
#

CREATE TABLE `jobs` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `caption` varchar(255) NOT NULL DEFAULT '',
  `zero_link` text NOT NULL,
  PRIMARY KEY (`Id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

#
# Data for table "jobs"
#

REPLACE INTO `jobs` VALUES (4,1,'TripAdvisor','https://www.tripadvisor.ru/SiteIndex'),(5,1,'Wiki Actors','https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83');

#
# Structure for table "links"
#

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
  KEY `job_id` (`job_id`,`handled`),
  CONSTRAINT `links_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1105 DEFAULT CHARSET=utf8;

#
# Data for table "links"
#

REPLACE INTO `links` VALUES (904,5,1,1,'https://ru.wikipedia.org/wiki/%D0%9A%D0%B0%D1%82%D0%B5%D0%B3%D0%BE%D1%80%D0%B8%D1%8F:%D0%90%D0%BA%D1%82%D1%91%D1%80%D1%8B_%D0%BF%D0%BE_%D0%B0%D0%BB%D1%84%D0%B0%D0%B2%D0%B8%D1%82%D1%83','f518495c4aeb7df47cd2dc0da0f045a2',1),(905,5,2,1,'https://ru.wikipedia.org/wiki/50_Cent','afb51fefa2a88333e3a25bccc3397086',NULL),(906,5,2,2,'https://ru.wikipedia.org/wiki/%D0%90%D0%B0%D0%B2,_%D0%A2%D1%8B%D0%BD%D1%83','dde3799ade225324b10c875917642634',NULL),(907,5,2,3,'https://ru.wikipedia.org/wiki/%D0%90%D0%B0%D0%B2%D0%B8%D0%BA,_%D0%AD%D0%B2%D0%B0%D0%BB%D1%8C%D0%B4','d812239076188e7f43fb81f8e843828c',NULL),(908,5,2,4,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%B4%D0%B6%D1%8F%D0%BD,_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80_%D0%90%D0%BC%D0%B2%D1%80%D0%BE%D1%81%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','538d9a8ec6f378dcda82aa73e8513e13',NULL),(909,5,2,5,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%B7%D0%BE%D0%BF%D1%83%D0%BB%D0%BE,_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80_%D0%9A%D0%BE%D0%BD%D1%81%D1%82%D0%B0%D0%BD%D1%82%D0%B8%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','2b533980a2e3c3420cc774fe95d56eb7',NULL),(910,5,2,6,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%B7%D1%8F%D0%BD,_%D0%93%D0%B5%D0%B2%D0%BE%D1%80%D0%B3_%D0%9D%D0%B8%D0%BA%D0%BE%D0%BB%D0%B0%D0%B5%D0%B2%D0%B8%D1%87','d10bb46e25e3da2db688a067ddf9efbd',NULL),(911,5,2,7,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%B9%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%93%D0%B0%D0%BB%D0%B8_%D0%9C%D1%8F%D0%B3%D0%B0%D0%B7%D0%BE%D0%B2%D0%B8%D1%87','7c273c8668d0853d3d2f9caa465f63b1',NULL),(912,5,2,8,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%BA%D0%B0%D1%80%D0%BE%D0%B2,_%D0%90%D1%81%D1%85%D0%B0%D0%B1_%D0%A2%D0%B8%D0%BD%D0%B0%D0%BC%D0%B0%D0%B3%D0%BE%D0%BC%D0%B5%D0%B4%D0%BE%D0%B2%D0%B8%D1%87','9133d09813ae0a53cff3b19515cfe1f4',NULL),(913,5,2,9,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D0%BB%D1%8F%D0%BD,_%D0%AD%D0%B4%D1%83%D0%B0%D1%80%D0%B4_%D0%93%D0%B0%D0%B9%D0%BA%D0%BE%D0%B2%D0%B8%D1%87','baf0a4f47b44f13af6c5e77f9d734e0f',NULL),(914,5,2,10,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D1%88%D0%B5%D0%B2,_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B8%D1%87','9404c4d1b4a3e80a837a0c7f70b2f2b8',NULL),(915,5,2,11,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D1%88%D0%B8%D0%B4%D0%B7%D0%B5,_%D0%92%D0%B0%D1%81%D0%B8%D0%BB%D0%B8%D0%B9_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','615f3ca40fa4a71b927653374918e9af',NULL),(916,5,2,12,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D1%88%D0%B8%D0%B4%D0%B7%D0%B5,_%D0%94%D0%B0%D0%B2%D0%B8%D0%B4_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','9bbe027472ea9214a6981a1b93ff26ab',NULL),(917,5,2,13,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B0%D1%88%D0%B8%D0%B4%D0%B7%D0%B5,_%D0%9B%D0%B5%D0%B2%D0%B0%D0%BD','cd9666b1645e476d58be64d9df951e8c',NULL),(918,5,2,14,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B1%D0%B0%D1%81%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B0%D0%B4%D0%B4%D0%B8%D0%BD_%D0%90%D1%81%D0%BB%D0%B0%D0%BD_%D0%BE%D0%B3%D0%BB%D1%8B','3dc4b765f31ee333ae36e1c539066f89',NULL),(919,5,2,15,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B1%D0%B0%D1%81%D0%BE%D0%B2,_%D0%93%D0%B0%D0%B4%D0%B6%D0%B8_%D0%90%D0%B3%D0%B0_%D0%9C%D1%83%D1%82%D0%B0%D0%BB%D0%B8%D0%B1_%D0%BE%D0%B3%D0%BB%D1%8B','3b987121e0873fdfd4295f33db4919e4',NULL),(920,5,2,16,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B1%D0%B0%D1%81%D0%BE%D0%B2,_%D0%9C%D0%B8%D1%80%D0%B7%D0%B0_%D0%90%D0%BB%D0%B8','1b1250f4e7dde77dcd191511a3495627',NULL),(921,5,2,17,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D0%B5%D0%BB%D1%8C%D0%BC%D0%B0%D0%B4%D0%B6%D0%B8%D0%B4_%D0%9B%D0%B0%D1%85%D0%B0%D0%BB%D1%8C','e78b3fff5cb8112256e5460f13fc3cbc',NULL),(922,5,2,18,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D0%B8,_%D0%91%D0%B0%D1%80%D1%85%D0%B0%D0%B4','58fccc75b95e17f8184c12deeb9eb771',NULL),(923,5,2,19,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D0%B8%D0%BA%D0%B0%D1%80%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%9C%D1%83%D0%B7%D0%B4%D1%8B%D0%B1%D0%B5%D0%BA','6b9312ae3a3c4cba64b2d943822881c4',NULL),(924,5,2,20,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%80%D0%B0%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%A4%D0%B0%D1%80%D1%85%D0%B0%D1%82_%D0%9D%D1%83%D1%80%D1%81%D1%83%D0%BB%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','ca73739900a0a6ba8f6064e7529f4051',NULL),(925,5,2,21,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%80%D0%B0%D1%81%D1%83%D0%BB%D0%BE%D0%B2,_%D0%9A%D1%83%D1%80%D0%B2%D0%B0%D0%BD','af01603c69342b0e628b7bb4120c2e32',NULL),(926,5,2,22,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%80%D0%B0%D1%85%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%9C%D0%B0%D1%80%D0%B0%D1%82_%D0%A7%D1%83%D0%BB%D0%BF%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','a110ddc957e74086933b40dc1b5d9928',NULL),(927,5,2,23,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%80%D0%B0%D1%85%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2,_%D0%90%D0%B1%D0%B4%D1%80%D0%B0%D1%88%D0%B8%D1%82_%D0%A5%D0%B0%D0%BA%D0%B8%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','ed729df84736b19130d34f0d5c94f7a2',NULL),(928,5,2,24,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BA%D1%83%D0%BD%D0%B4%D1%83%D0%B7%D0%BE%D0%B2,_%D0%9C%D1%83%D1%85%D0%B0%D0%BC%D0%BC%D0%B0%D0%B4%D0%B0%D0%BB%D0%B8','d5880d7dfee2d661e317fe8a36301e2b',NULL),(929,5,2,25,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%B0%D0%B5%D0%B2,_%D0%90%D0%BD%D0%B0%D1%82%D0%BE%D0%BB%D0%B8%D0%B9_%D0%93%D0%B0%D1%84%D0%B0%D1%80%D0%BE%D0%B2%D0%B8%D1%87','12850afd2b7490ee7d297f6079a375ff',NULL),(930,5,2,26,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BB%D0%B0%D0%B5%D0%B2,_%D0%9B%D1%8E%D1%82%D1%84%D0%B0%D0%BB%D0%B8_%D0%90%D0%BC%D0%B8%D1%80_%D0%BE%D0%B3%D0%BB%D1%8B','6edea2db3f5f65d45d8061bc18cd7308',NULL),(931,5,2,27,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%93%D0%B0%D0%B2%D1%80%D0%B8%D0%B8%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','d5059354ec159eddac258ced0f6a4e7e',NULL),(932,5,2,28,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%92%D0%B8%D1%82%D0%B0%D0%BB%D0%B8%D0%B9_%D0%97%D0%B8%D0%BD%D1%83%D1%80%D0%BE%D0%B2%D0%B8%D1%87','e0296af6e223c9ad9283eef3a1244a76',NULL),(933,5,2,29,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%92%D1%81%D0%B5%D0%B2%D0%BE%D0%BB%D0%BE%D0%B4_%D0%9E%D1%81%D0%B8%D0%BF%D0%BE%D0%B2%D0%B8%D1%87','8a7dc8ee1c348da90fc64f4238f6d800',NULL),(934,5,2,30,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%93%D0%B0%D0%B2%D1%80%D0%B8%D0%B8%D0%BB_%D0%94%D0%B0%D0%BD%D0%B8%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','0c37f41267988c99c1760e6234c39582',NULL),(935,5,2,31,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D0%BE%D0%B2,_%D0%9E%D1%81%D0%B8%D0%BF_%D0%9D%D0%B0%D1%83%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','51942bf45ea68ff8afd029cedaedf50f',NULL),(936,5,2,32,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D1%85%D0%B0%D0%BB%D0%B8%D0%BA%D0%BE%D0%B2,_%D0%9C%D0%B0%D1%85%D0%BC%D1%83%D0%B4_%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D1%85%D0%B0%D0%BB%D0%B8%D0%BA%D0%BE%D0%B2%D0%B8%D1%87','fd8961dcbdddf1f069419999ee58b4da',NULL),(937,5,2,33,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D0%BB%D1%8C%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2,_%D0%A0%D0%B8%D0%BC_%D0%A1%D0%B0%D0%BB%D0%B8%D0%BC%D1%8C%D1%8F%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','fbac0c83815c25a69bc5ea05cd6551c1',NULL),(938,5,2,34,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D1%80%D0%B0%D1%85%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2,_%D0%9E%D1%81%D0%BC%D0%B0%D0%BD','d68d7ec798d07508d3a282463dc777f7',NULL),(939,5,2,35,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%83%D1%81%D0%B0%D0%BB%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%A8%D0%B0%D0%B2%D0%BA%D0%B0%D1%82_%D0%A4%D0%B0%D0%B7%D0%B8%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','7822fcc1a1b44aa3f54dcc17aff5ce32',NULL),(940,5,2,36,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B4%D1%8B%D0%B3%D0%B0%D0%BF%D0%B0%D1%80%D0%BE%D0%B2,_%D0%94%D0%B0%D1%83%D0%BB%D0%B5%D1%82_%D0%90%D0%B1%D0%B4%D1%8B%D1%85%D0%B0%D0%BB%D0%B8%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','246a534eca4985c1f277cff89d278493',NULL),(941,5,2,37,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B5%D0%BB%D1%8C,_%D0%94%D0%B6%D0%B5%D0%B9%D0%BA','fa7a00b85d0dfc56ed2592c5618ca6ed',NULL),(942,5,2,38,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B5%D0%BB%D1%8C,_%D0%97%D0%B0%D0%BA%D0%B0%D1%80%D0%B8','b461f3cdf621960429bd1d7d4908806d',NULL),(943,5,2,39,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B5%D0%BB%D1%8F%D0%BD,_%D0%9E%D0%B2%D0%B0%D0%BD%D0%B5%D1%81_%D0%90%D1%80%D1%82%D0%B5%D0%BC%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','d6bc3077780df74d86cf6b925a1a9817',NULL),(944,5,2,40,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%B6%D0%B0%D0%BB%D0%B8%D0%BB%D0%BE%D0%B2,_%D0%A5%D0%B0%D0%BB%D0%B8%D0%BB_%D0%93%D0%B0%D0%BB%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','9e74dea3cf2a7f2f3a452b86f9b872e2',NULL),(945,5,2,41,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%BA%D0%B0%D1%80%D1%8F%D0%BD,_%D0%A1%D0%B8%D0%BC%D0%BE%D0%BD','b19bd2da8c68227881cff9592b6dafd0',NULL),(946,5,2,42,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%BE%D0%BB%D0%B8%D0%BD%D1%8C%D1%88,_%D0%93%D1%83%D0%BD%D0%B4%D0%B0%D1%80%D1%81','3c0fc289eaa45492e6341a0a7467e872',NULL),(947,5,2,43,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D0%BE%D0%BB%D0%B8%D0%BD%D1%8C%D1%88,_%D0%A2%D0%B0%D0%BB%D0%B8%D0%B2%D0%B0%D0%BB%D0%B4%D0%B8%D1%81','ec1dbd21fefcd7456fe8b71076def2b8',NULL),(948,5,2,44,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%90%D0%BD%D0%B0%D1%82%D0%BE%D0%BB%D0%B8%D0%B9_%D0%92%D0%B0%D1%81%D0%B8%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','1899ce95eb7af266db11ecd0ce663275',NULL),(949,5,2,45,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%92%D0%B0%D0%B4%D0%B8%D0%BC_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2%D0%B8%D1%87','eb21376ab924fd963e0d0cefb119b352',NULL),(950,5,2,46,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%92%D0%B0%D0%BB%D0%B5%D0%BD%D1%82%D0%B8%D0%BD_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','49a752ae7b125e62a9883bd95dbdc981',NULL),(951,5,2,47,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%9F%D1%91%D1%82%D1%80_%D0%92%D0%B0%D0%BB%D0%B5%D1%80%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','4052f2f5b938a80ecd5b9b2ea2994bf5',NULL),(952,5,2,48,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D1%81,_%D0%90%D0%B0%D1%80%D0%BE%D0%BD','220757a7246c681dbc7d65a407c0e7eb',NULL),(953,5,2,49,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D1%81,_%D0%94%D0%B6%D0%B5%D1%84%D1%84%D1%80%D0%B8_%D0%94%D0%B6%D0%B5%D0%B9%D0%BA%D0%BE%D0%B1','a53d31be2e52ecb7ea3b0ef85f8e76e5',NULL),(954,5,2,50,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D0%BC%D1%8F%D0%BD,_%D0%A5%D0%BE%D1%80%D0%B5%D0%BD_%D0%91%D0%B0%D0%B1%D0%BA%D0%B5%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','14fd2392c69b715d116f0362681186e0',NULL),(955,5,2,51,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D1%85%D0%B0%D0%BC,_%D0%94%D0%B6%D0%BE%D0%BD','03d1c21e4e6aa6e0efca7a039749d138',NULL),(956,5,2,52,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D1%85%D0%B0%D0%BC,_%D0%A4._%D0%9C%D1%8E%D1%80%D1%80%D0%B5%D0%B9','b9ac1d7b076a1f36009778e91c166ebb',NULL),(957,5,2,53,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B0%D1%85%D0%B0%D0%BC%D1%81,_%D0%94%D0%B6%D0%BE%D0%BD','9a9d5ea913060a0219bcd54916a21807',NULL),(958,5,2,54,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B3%D0%B0%D0%BC,_%D0%99%D0%BE%D0%B7%D0%B5%D1%84','344df19854da09091431ddf3412656da',NULL),(959,5,2,55,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B8%D0%BA%D0%BE%D1%81%D0%BE%D0%B2,_%D0%90%D0%BD%D0%B4%D1%80%D0%B5%D0%B9_%D0%9B%D1%8C%D0%B2%D0%BE%D0%B2%D0%B8%D1%87','9f90c3df41672e4cf9812e0b6fa71440',NULL),(960,5,2,56,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%B8%D0%BA%D0%BE%D1%81%D0%BE%D0%B2,_%D0%93%D1%80%D0%B8%D0%B3%D0%BE%D1%80%D0%B8%D0%B9_%D0%90%D0%BD%D0%B4%D1%80%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','8edcd74c9f14eaede30b7da34ad750da',NULL),(961,5,2,57,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%BE%D0%BB%D0%B0%D1%82,_%D0%92%D0%B5%D1%80%D0%BD%D0%B5%D1%80','5ad1d589a1165a763880e0a9b51ff2a2',NULL),(962,5,2,58,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%BE%D1%81%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','de0073f93fd8075cafac74e406ca0b13',NULL),(963,5,2,59,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%80%D0%BE%D1%81%D0%BA%D0%B8%D0%BD,_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B9_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','7a20897e68006a00beecc50cf2a506b1',NULL),(964,5,2,60,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%82,_%D0%9A%D0%B0%D1%80%D0%BB_%D0%A4%D1%80%D0%B8%D0%B4%D1%80%D0%B8%D1%85','6288b9ced792af3d14873f8f12025325',NULL),(965,5,2,61,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%83%D1%88%D0%B0%D1%85%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2,_%D0%90%D1%85%D1%82%D1%8F%D0%BC_%D0%90%D1%85%D0%B0%D1%82%D0%BE%D0%B2%D0%B8%D1%87','6961fb84010a6d417c307300d46d2e37',NULL),(966,5,2,62,'https://ru.wikipedia.org/wiki/%D0%90%D0%B1%D1%8D,_%D0%AE%D1%82%D0%B0%D0%BA%D0%B0','f6287b00fd50196c1a0d5f11fceceaf1',NULL),(967,5,2,63,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B0%D0%BB%D0%B8%D0%B0%D0%BD%D0%B8,_%D0%9D%D0%BE%D0%B9_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','2f65f991425730e5f55860ca1246d34c',NULL),(968,5,2,64,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B0%D0%BB%D0%BE%D1%81,_%D0%9B%D1%83%D0%B8%D1%81','fda764c82c9c0d15011f9edc15d8331c',NULL),(969,5,2,65,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B0%D0%BD%D0%B4%D0%B8,_%D0%9C%D1%8F%D1%80%D1%82','3763574bff958b47a249d94808b6d2ff',NULL),(970,5,2,66,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B0%D1%80%D0%B8,_%D0%AD%D1%80%D0%B8%D0%BA','580a0cbd94b98f04fcf4bb6f373aa1ed',NULL),(971,5,2,67,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B4%D1%8E%D1%88%D0%BA%D0%BE,_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80_%D0%90%D0%BD%D1%82%D0%BE%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','5b777017df036d525c30cba8741d4c9a',NULL),(972,5,2,68,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D0%B4%D0%B8%D0%BA%D1%8F%D0%BD,_%D0%A1%D0%B5%D1%80%D0%B6','2c7ef171492420257863f90e22efb693',NULL),(973,5,2,69,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D0%BD%D1%81,_%D0%A5%D0%B0%D1%80%D0%B8%D0%B9','d435d3ad7aae280e0a87114c8b3fc171',NULL),(974,5,2,70,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D1%80%D0%B8%D0%BD,_%D0%9C%D0%B0%D0%BA%D1%81%D0%B8%D0%BC_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80%D0%BE%D0%B2%D0%B8%D1%87','b9777a6f3f53deeb8a655a70f1d0b7f2',NULL),(975,5,2,71,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D1%80%D0%B8%D0%BD,_%D0%AE%D1%80%D0%B8%D0%B9_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','e2c330a20306cc00bc1457a2f5c2ae9a',NULL),(976,5,2,72,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D1%80%D1%8E%D1%88%D0%BA%D0%B8%D0%BD,_%D0%9D%D0%B8%D0%BA%D0%BE%D0%BB%D0%B0%D0%B9_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B8%D1%87','47e8eab00c7d83d8cf41ea4d96e3917f',NULL),(977,5,2,73,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D1%82%D0%B8%D1%81%D1%8F%D0%BD,_%D0%90%D0%B2%D0%B5%D1%82_%D0%9C%D0%B0%D1%80%D0%BA%D0%BE%D1%81%D0%BE%D0%B2%D0%B8%D1%87','619fc1ee6f0f0a137593347c85c28948',NULL),(978,5,2,74,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B5%D1%82%D1%8F%D0%BD,_%D0%93%D1%80%D0%B8%D0%B3%D0%BE%D1%80_%D0%9A%D0%B0%D1%80%D0%B0%D0%BF%D0%B5%D1%82%D0%BE%D0%B2%D0%B8%D1%87','0c225b4a71ca10565e6bc366e0cf79d0',NULL),(979,5,2,75,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B8%D0%BB%D0%B5%D1%81,_%D0%A0%D0%B8%D0%BA','848b09d26795b84fa7d138511dbec5fe',NULL),(980,5,2,76,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%B8%D0%BB%D0%BE%D0%B2,_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80_%D0%92%D0%B0%D1%81%D0%B8%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','bda9759f7f1c022a2fb471c81e74ca2d',NULL),(981,5,2,77,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%BD%D0%B8,_%D0%90%D0%BA%D0%B8','ea8ce1e57be181fe79bdc4d2e6c17d2d',NULL),(982,5,2,78,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D0%BE%D1%82%D1%81,_%D0%AD%D0%BD%D1%80%D0%B8%D0%BA%D0%BE','da8266d02c7902c9d172ee1d2b180ae1',NULL),(983,5,2,79,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D1%80%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%98%D0%B2%D0%B0%D0%BD_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','491b19dbe16db3e53326c65019cd0092',NULL),(984,5,2,80,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D1%88%D0%B0%D1%80%D0%BE%D0%B2,_%D0%9C%D1%83%D1%85%D1%82%D0%B0%D1%80_%D0%93%D0%B0%D1%81%D0%B0%D0%BD_%D0%BE%D0%B3%D0%BB%D1%83','84a3987a76d9d527dca6e55babcccd8a',NULL),(985,5,2,81,'https://ru.wikipedia.org/wiki/%D0%90%D0%B2%D1%88%D0%B0%D1%80%D0%BE%D0%B2,_%D0%AE%D1%80%D0%B8%D0%B9_%D0%9C%D0%B8%D1%85%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','45d7df0e7f03117d2396d7646ce7b254',NULL),(986,5,2,82,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0-%D0%9C%D0%B8%D1%80%D0%B7%D0%B0%D0%B5%D0%B2,_%D0%9C%D1%83%D1%85%D1%82%D0%B0%D1%80_%D0%9A%D0%B0%D1%80%D0%B4%D0%B0%D1%88%D1%85%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','7423fd3863ddf3ea27152cea99579c3a',NULL),(987,5,2,83,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D0%B5%D0%B2,_%D0%90%D0%BB%D0%B8%D0%B0%D0%B3%D0%B0_%D0%98%D1%81%D0%BC%D0%B0%D0%B8%D0%BB_%D0%BE%D0%B3%D0%BB%D1%8B','39474a5bb565312233701912cb8eb681',NULL),(988,5,2,84,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D0%B5%D0%B2,_%D0%9E%D0%BA%D1%82%D0%B0%D0%B9_%D0%91%D0%B0%D1%85%D1%80%D0%B0%D0%BC_%D0%BE%D0%B3%D0%BB%D1%8B','2d1c21d633dc93428df240c505b0d26a',NULL),(989,5,2,85,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D0%BC%D0%B8%D1%80%D0%B7%D1%8F%D0%BD,_%D0%A0%D1%83%D0%B1%D0%B5%D0%BD_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','bbfceda6fc3336b434eb54be8378608f',NULL),(990,5,2,86,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D0%BF%D0%BE%D0%B2,_%D0%98%D0%B2%D0%B0%D0%BD_%D0%92%D0%B0%D0%BB%D0%B5%D1%80%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','c683eab9b0c1bfd8176876bcca64eaee',NULL),(991,5,2,87,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D1%80,_%D0%94%D0%B6%D0%BE%D0%BD','7ef67f64f6379864c5f42e2c8b212f80',NULL),(992,5,2,88,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B0%D1%84%D0%BE%D0%BD%D0%BE%D0%B2,_%D0%98%D0%B2%D0%B0%D0%BD_%D0%90%D0%B3%D0%B5%D0%B5%D0%B2%D0%B8%D1%87','18cca856c5a30faf457b1a555351ea0f',NULL),(993,5,2,89,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B2%D0%B0%D0%B0%D0%BD%D1%86%D1%8D%D1%80%D1%8D%D0%BD%D0%B3%D0%B8%D0%B9%D0%BD_%D0%AD%D0%BD%D1%85%D1%82%D0%B0%D0%B9%D0%B2%D0%B0%D0%BD','d13b11fe3e7c3bb6cf76ffe950aad5fb',NULL),(994,5,2,90,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B5%D0%B5%D0%B2,_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87_(%D0%B0%D0%BA%D1%82%D1%91%D1%80)','3a542f443a55dd31eb2ef9a1c8dcdf75',NULL),(995,5,2,91,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B5%D0%B5%D0%B2,_%D0%95%D0%B2%D0%B3%D0%B5%D0%BD%D0%B8%D0%B9_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','eda5b5e44140e42ecdb11d093ea3644c',NULL),(996,5,2,92,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B5%D0%B5%D0%B2,_%D0%98%D0%B3%D0%BE%D1%80%D1%8C_%D0%92%D0%B0%D0%BB%D0%B5%D0%BD%D1%82%D0%B8%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','df961e6936662ac685d9d41de2157ff0',NULL),(997,5,2,93,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B5%D0%B5%D0%B2,_%D0%A0%D0%BE%D0%BC%D0%B0%D0%BD_%D0%9E%D0%BB%D0%B5%D0%B3%D0%BE%D0%B2%D0%B8%D1%87','fa805788d4d0931a5c2502a2158ee24a',NULL),(998,5,2,94,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B7%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%93%D0%B0%D0%BD%D0%B8','5fa4864744b5a51197c9a7c71bdd739a',NULL),(999,5,2,95,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%B7%D0%B0%D0%BC%D0%BE%D0%B2,_%D0%AE%D0%BB%D0%B4%D0%B0%D1%88','69680e7ff777d7b318995b9a30cf6517',NULL),(1000,5,2,96,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D0%BE%D0%BF%D1%8C%D1%8F%D0%BD,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B5%D0%B9_%D0%9C%D0%B8%D0%B3%D1%80%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','ccbb70b2b7f7c7581233d9b6747fdd7a',NULL),(1001,5,2,97,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D1%80%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B5%D0%B9_%D0%9C%D0%B8%D1%85%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','d6c793eed4fc8e5795fd127b8c8dce2a',NULL),(1002,5,2,98,'https://ru.wikipedia.org/wiki/%D0%90%D0%B3%D1%83%D1%81%D1%82%D0%B8%D0%BD_%D0%9B%D0%B0%D1%80%D0%B0','6a00bc7f8ff4c678e9a5d2215f7102e7',NULL),(1003,5,2,99,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%B1%D0%B0%D1%88%D1%8C%D1%8F%D0%BD,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%90%D1%80%D1%82%D1%91%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','806a649a2687d22f3260ac9034a4a671',NULL),(1004,5,2,100,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC_%D0%90%D0%BD%D1%82','dec92d2bdda94996f985ad3cc64faeef',NULL),(1005,5,2,101,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D0%B1%D0%B0%D0%B5%D0%B2,_%D0%9D%D1%83%D1%80%D1%82%D0%B0%D1%81_%D0%90%D0%B1%D0%B0%D0%B5%D0%B2%D0%B8%D1%87','056bc802973c876791cfa6f4c26c067b',NULL),(1006,5,2,102,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D0%B5,_%D0%90%D0%BB%D1%8C%D1%84%D1%80%D0%B5%D0%B4%D0%BE','891c976010c8c45aebf8cc409603fa3e',NULL),(1007,5,2,103,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D0%B5%D0%BD%D0%BA%D0%BE,_%D0%93%D1%80%D0%B8%D0%B3%D0%BE%D1%80%D0%B8%D0%B9_%D0%90%D0%BD%D0%B0%D1%82%D0%BE%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','2bbdbb56be118f58213ae5bd61112875',NULL),(1008,5,2,104,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%81,_%D0%94%D0%B6%D0%BE%D0%BD%D0%B0%D1%82%D0%B0%D0%BD','61a422e55125114c09f6a7b802124206',NULL),(1009,5,2,105,'https://ru.wikipedia.org/wiki/%D0%94%D0%BE%D0%BD_%D0%90%D0%B4%D0%B0%D0%BC%D1%81','7f59a60d67cb4497d8f20284b240a29b',NULL),(1010,5,2,106,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%81,_%D0%9C%D0%B5%D0%B9%D1%81%D0%BE%D0%BD','337a11dfddfa71d3ea5699f257c5c66e',NULL),(1011,5,2,107,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%81,_%D0%9F%D0%B0%D1%82%D1%80%D0%B8%D0%BA_%D0%94%D0%B6%D0%B5%D0%B9','d07b6ad0ecb3f4704bfe55cbfbe7ac14',NULL),(1012,5,2,108,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%81,_%D0%A1%D0%B8_%D0%94%D0%B6%D0%B5%D0%B9','4514c9e2da144e4ff8afa7d2fc2388a1',NULL),(1013,5,2,109,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%82%D1%83%D1%8D%D0%B9%D1%82,_%D0%9C%D0%B0%D0%B9%D0%BA%D0%BB','9bff5c83bbe5df9f87ad234e49895d13',NULL),(1014,5,2,110,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D0%BC%D1%8F%D0%BD,_%D0%9F%D0%B5%D1%82%D1%80%D0%BE%D1%81_%D0%98%D0%B5%D1%80%D0%BE%D0%BD%D0%B8%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','b64eadf1dfa0f00e3c9fdc0e23617188',NULL),(1015,5,2,111,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D1%81%D0%B8%D0%BD%D1%81%D0%BA%D0%B8%D0%B9,_%D0%90%D0%BD%D1%82%D0%BE%D0%BD_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2%D0%B8%D1%87','aeab1165c866d0ef8005f84203b1aa3e',NULL),(1016,5,2,112,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D1%88%D0%B5%D0%B2,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%98%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','71f3611c1721915a420cb666d03f1b81',NULL),(1017,5,2,113,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D1%88%D0%B5%D0%B2,_%D0%A0%D0%B0%D0%B4%D0%B6%D0%B0%D0%B1_%D0%A5%D0%B0%D0%BB%D0%B8%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','127da9c688fff01b6ba6b1ff71defcbb',NULL),(1018,5,2,114,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B0%D1%88%D0%B5%D0%B2%D1%81%D0%BA%D0%B8%D0%B9,_%D0%9A%D0%BE%D0%BD%D1%81%D1%82%D0%B0%D0%BD%D1%82%D0%B8%D0%BD_%D0%98%D0%B3%D0%BD%D0%B0%D1%82%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','8db80f86198d4700186983928b2bb0f2',NULL),(1019,5,2,115,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B5%D0%BB%D1%8C_%D0%98%D0%BC%D0%B0%D0%BC','bda76415c3d244639547331ed7b5b48a',NULL),(1020,5,2,116,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B5%D0%BB%D1%8C%D1%88%D1%82%D0%B5%D0%B9%D0%BD,_%D0%9F%D0%BE%D0%BB','34cc2692d73575f27083e08420399df2',NULL),(1021,5,2,117,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B5%D1%80%D0%BC%D0%B0%D0%BD%D0%B8%D1%81,_%D0%98%D0%BC%D0%B0%D0%BD%D1%82%D1%81','60bcb50828e0a44f5dda0a9000837c29',NULL),(1022,5,2,118,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B6%D0%B5%D0%BC%D1%8F%D0%BD,_%D0%92%D0%B0%D1%80%D1%82%D0%B0%D0%BD_%D0%9C%D0%BA%D1%80%D1%82%D0%B8%D1%87%D0%B5%D0%B2%D0%B8%D1%87','4abfb9aa98550593e8a969da8a48995a',NULL),(1023,5,2,119,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%B7%D1%83%D0%BC%D0%B0,_%D0%A2%D0%B8%D1%91%D0%BD%D0%BE%D1%81%D1%83%D0%BA%D1%8D','4d70984cc05f0cbc760639adb068afc2',NULL),(1024,5,2,120,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%BB%D0%B5%D1%80,_%D0%AF%D0%BA%D0%BE%D0%B2','79e2c3847c331d5b08ea4d5a7d3f0c7d',NULL),(1025,5,2,121,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%BE%D0%BC%D0%B0%D0%B9%D1%82%D0%B8%D1%81,_%D0%A0%D0%B5%D0%B3%D0%B8%D0%BC%D0%B0%D0%BD%D1%82%D0%B0%D1%81_%D0%92%D0%B0%D0%B9%D1%82%D0%BA%D1%83%D1%81%D0%BE%D0%B2%D0%B8%D1%87','b9b27a7d29bad788dd79199ce0c1caeb',NULL),(1026,5,2,122,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%BE%D1%80%D1%84,_%D0%9C%D0%B0%D1%80%D0%B8%D0%BE','a760863456cf4376f7438f0b50a69647',NULL),(1027,5,2,123,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%BE%D1%81%D0%BA%D0%B8%D0%BD,_%D0%90%D0%BD%D0%B0%D1%82%D0%BE%D0%BB%D0%B8%D0%B9_%D0%9C%D0%B8%D1%85%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','44c3fb7fdd4d1ea797c3a22c6a4078e0',NULL),(1028,5,2,124,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D0%BE%D1%82%D0%B8,_%D0%A0%D0%B0%D0%B7%D0%B0%D0%B0%D0%BA','4e445fa7a16f50a04bb7cc3a05a58f72',NULL),(1029,5,2,125,'https://ru.wikipedia.org/wiki/%D0%90%D0%B4%D1%8B%D0%B3%D1%91%D0%B7%D0%B0%D0%BB%D0%BE%D0%B2,_%D0%A2%D0%B5%D0%BB%D1%8C%D0%BC%D0%B0%D0%BD_%D0%90%D0%B1%D0%B1%D0%B0%D1%81%D0%B3%D1%83%D0%BB%D1%83_%D0%BE%D0%B3%D0%BB%D1%8B','0d5dfb467a46ff2e8429df50147fbcdf',NULL),(1030,5,2,126,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B0%D1%80%D0%B8%D0%B0,_%D0%A5%D1%8D%D0%BD%D0%BA','1a0896239ec2d5664684ecc475759944',NULL),(1031,5,2,127,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B0%D1%80%D0%B8%D0%BD,_%D0%90%D0%B7%D0%B0%D1%80%D0%B8%D0%B9_%D0%9C%D0%B8%D1%85%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','ffddb09578c06a86296846c07c6e6613',NULL),(1032,5,2,128,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B8%D0%B7%D0%B8,_%D0%AD%D0%BD%D1%82%D0%BE%D0%BD%D0%B8','6e47739ee7732caf04a4e6fa69a0d4bd',NULL),(1033,5,2,129,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B8%D0%B7%D0%BE%D0%B2,_%D0%A2%D1%83%D1%80%D0%B3%D1%83%D0%BD_%D0%A2%D1%83%D1%80%D1%81%D1%83%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','9b1407f33519695ce3213fd4e7214be6',NULL),(1034,5,2,130,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B8%D0%B7%D0%BE%D0%B2,_%D0%AD%D0%BB%D1%8C%D1%87%D0%B8%D0%BD_%D0%AF%D1%88%D0%B0%D1%80_%D0%BE%D0%B3%D0%BB%D1%8B','db04b1e9d2a622a802da53cd0a0f7d51',NULL),(1035,5,2,131,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%A5%D0%B0%D0%BC%D0%B8%D1%82_%D0%9C%D1%83%D1%85%D0%B0%D0%BC%D0%B5%D1%82%D0%BE%D0%B2%D0%B8%D1%87','191bc6b4ecd0fbbb7688fddf12ea94a7',NULL),(1036,5,2,132,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%BD%D0%B0%D0%B2%D1%83%D1%80,_%D0%9C%D0%B8%D1%88%D0%B0','b5b89d7caaabc22c94d1e46a0b016be0',NULL),(1037,5,2,133,'https://ru.wikipedia.org/wiki/%D0%90%D0%B7%D0%BE,_%D0%90%D0%BD%D0%B0%D1%82%D0%BE%D0%BB%D0%B8%D0%B9_%D0%93%D0%B5%D0%BE%D1%80%D0%B3%D0%B8%D0%B5%D0%B2%D0%B8%D1%87','42f1acd42999e5c7645f4c178979e071',NULL),(1038,5,2,134,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9,_%D0%98%D1%85%D1%81%D0%B0%D0%BD','927b501866b30af662a61ef3987fd47b',NULL),(1039,5,2,135,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B2%D0%B0%D0%B7%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%AD%D0%BC%D0%B8%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','33de9d33fc7b2ea1de1e03c3dde74319',NULL),(1040,5,2,136,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B2%D0%B0%D0%B7%D1%8F%D0%BD,_%D0%91%D0%B0%D0%B3%D0%B4%D0%B0%D1%81%D0%B0%D1%80_%D0%90%D1%80%D1%82%D1%91%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','0b1cf358632f54d076112c8dfdc2646a',NULL),(1041,5,2,137,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B2%D0%B7,_%D0%91%D1%91%D1%80%D0%BB','24aedf9181c567b9570adadce46a6c65',NULL),(1042,5,2,138,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B3%D1%83%D0%BC%D0%BE%D0%B2,_%D0%90%D0%B9%D0%B3%D1%83%D0%BC_%D0%AD%D0%BB%D1%8C%D0%B4%D0%B0%D1%80%D0%BE%D0%B2%D0%B8%D1%87','9e7b341c2b4520323f75c66f19fc9a69',NULL),(1043,5,2,139,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B4%D0%B0%D1%80%D0%BE%D0%B2,_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B9_%D0%92%D0%B0%D1%81%D0%B8%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87','4151d2176227e8cb5c0bdab440d50f92',NULL),(1044,5,2,140,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B4%D0%BB,_%D0%AD%D1%80%D0%B8%D0%BA','7271a0391b53192c79621d76220a5391',NULL),(1045,5,2,141,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B5%D0%BB%D0%BB%D0%BE,_%D0%94%D1%8D%D0%BD%D0%BD%D0%B8','28f5af3f8474b6bc606379d46ba2a413',NULL),(1046,5,2,142,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B7%D0%B5%D0%BA,_%D0%9E%D1%81%D0%BA%D0%B0%D1%80','ad71db8ba51e0d4c9e66f9cb5cfdd262',NULL),(1047,5,2,143,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B7%D0%B5%D0%BA%D1%81,_%D0%94%D0%B6%D0%B5%D0%B9%D1%81%D0%BE%D0%BD','0d38f2956788129414fa6c9e9b458114',NULL),(1048,5,2,144,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B7%D0%B5%D0%BD%D0%B1%D0%B5%D1%80%D0%B3,_%D0%94%D0%B6%D0%B5%D1%81%D1%81%D0%B8','b63d0d89ce6bb260f6dc5639d0099d35',NULL),(1049,5,2,145,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B7%D0%B8%D0%BA%D0%BE%D0%B2%D0%B8%D1%87,_%D0%9C%D0%B0%D1%80%D0%BA_%D0%9B%D1%8C%D0%B2%D0%BE%D0%B2%D0%B8%D1%87','b26de39859c24d146c60dd4493fd3a1f',NULL),(1050,5,2,146,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%B7%D0%BC%D0%B0%D0%BD,_%D0%9D%D0%B8%D0%BA%D0%BE%D0%BB%D0%B0%D0%B9_%D0%A1%D0%BF%D0%B8%D1%80%D0%B8%D0%B4%D0%BE%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','f3f7a641fd99773a4e6cf2cfff2fa9a5',NULL),(1051,5,2,147,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2,_%D0%A8%D0%B0%D0%BA%D0%B5%D0%BD_%D0%9A%D0%B5%D0%BD%D0%B6%D0%B5%D1%82%D0%B0%D0%B5%D0%B2%D0%B8%D1%87','cfcaa2c3b9845594144c01b5f4c86e22',NULL),(1052,5,2,148,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%BD%D0%B5%D1%81%D0%BE%D0%BD,_%D0%A0%D0%B0%D0%BB%D1%8C%D1%84','97ac04098dbf4a3c83c609c98dfef110',NULL),(1053,5,2,149,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D0%BE%D0%B0%D0%B4%D0%B8,_%D0%A0%D0%B8%D1%87%D0%B0%D1%80%D0%B4','b402983f2eb74c98ae66df36d9bea440',NULL),(1054,5,2,150,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%80%D0%BB%D0%B5%D0%BD%D0%B4,_%D0%94%D0%B6%D0%BE%D0%BD_(%D0%B0%D0%BA%D1%82%D1%91%D1%80)','099c2312b9e67b771556a6b9d7b1e38e',NULL),(1055,5,2,151,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%80%D0%BE%D0%BD%D1%81,_%D0%94%D0%B6%D0%B5%D1%80%D0%B5%D0%BC%D0%B8','e8028f0f7c198f3430edb215756924da',NULL),(1056,5,2,152,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%80%D0%BE%D0%BD%D1%81,_%D0%9C%D0%B0%D0%BA%D1%81','b8ed0f2d0a3840ee63eae0ec4fe7c936',NULL),(1057,5,2,153,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%80%D0%BE%D0%BD%D1%81%D0%B0%D0%B9%D0%B4,_%D0%9C%D0%B0%D0%B9%D0%BA%D0%BB','a7fed1554cc3b82104659c7c38154626',NULL),(1058,5,2,154,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%82%D0%BE%D1%80_%D0%9B%D1%83%D0%BD%D0%B0','b9776b0e670c089bbcbe6f870320075a',NULL),(1059,5,2,155,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%85%D0%B3%D0%BE%D1%80%D0%BD,_%D0%92%D0%B5%D1%80%D0%BD%D0%B5%D1%80','8ff4f9008bcd93df20a84b0edf93b77f',NULL),(1060,5,2,156,'https://ru.wikipedia.org/wiki/%D0%90%D0%B9%D1%85%D0%B3%D0%BE%D1%80%D0%BD,_%D0%9A%D1%80%D0%B8%D1%81%D1%82%D0%BE%D1%84','982305643dbe4449028484ad34c038a8',NULL),(1061,5,2,157,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B0%D0%BD%D0%B8%D1%81%D0%B8,_%D0%94%D0%B7%D0%B8%D0%BD','5c2ed24e56f9af5620f688f2175798a3',NULL),(1062,5,2,158,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B0%D1%80%D1%81%D1%83,_%D0%91%D0%B0%D1%80%D1%8B%D1%88','738dcd72ee79a85b50fb5a600dbf9246',NULL),(1063,5,2,159,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B0%D1%88%D0%BA%D0%B8%D0%BD,_%D0%92%D1%8F%D1%87%D0%B5%D1%81%D0%BB%D0%B0%D0%B2_%D0%9F%D0%B0%D0%B2%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','f083bff96d91d8ac75a0b2d698eec640',NULL),(1064,5,2,160,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B4%D0%B5%D0%BD%D0%B8%D0%B7,_%D0%94%D0%B5%D0%BD%D0%B8%D0%B7','b050b0053f62d617d082415e4d836c9f',NULL),(1065,5,2,161,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B4%D1%8E%D0%BB%D1%8C%D0%B3%D0%B5%D1%80,_%D0%9C%D0%B5%D1%82%D0%B8%D0%BD','8d8114fff7756548a534ae05e74de54a',NULL),(1066,5,2,162,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B8%D0%BC%D0%BA%D0%B8%D0%BD,_%D0%9F%D0%B0%D0%B2%D0%B5%D0%BB_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B8%D1%87','a0c065aed60c3e7f5b6bb7c10d4804a0',NULL),(1067,5,2,163,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B8%D0%BC%D0%BE%D0%B2,_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80_%D0%90%D0%BA%D0%B8%D0%BC%D0%BE%D0%B2%D0%B8%D1%87','3f44ed6b45ed82ef38e57f2e2b204970',NULL),(1068,5,2,164,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B8%D0%BD,_%D0%A4%D0%B0%D1%82%D0%B8%D1%85','5740330e83aeab9c27ef769a1a068e4d',NULL),(1069,5,2,165,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%B8%D0%BD%D0%BD%D1%83%D0%BE%D0%B9%D0%B5-%D0%90%D0%B3%D0%B1%D0%B0%D0%B4%D0%B6%D0%B5,_%D0%90%D0%B4%D0%B5%D0%B2%D0%B0%D0%BB%D0%B5','314be10a2abf4ab8109470f09ce1bffb',NULL),(1070,5,2,166,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BA%D0%B5%D1%80%D0%BC%D0%B0%D0%BD,_%D0%9A%D0%BE%D0%BD%D1%80%D0%B0%D0%B4_%D0%AD%D1%80%D0%BD%D1%81%D1%82','c915e9cbe72d943a62d863b34b59e0d4',NULL),(1071,5,2,167,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BA%D0%B8%D0%BD%D0%B5%D0%BD%D0%B8_%D0%9D%D0%B0%D0%B3%D0%B0%D1%80%D0%B4%D0%B6%D1%83%D0%BD%D0%B0','d1be4fa351c0cf0c0a0696241b414db2',NULL),(1072,5,2,168,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BA%D0%B8%D0%BD%D0%B5%D0%BD%D0%B8_%D0%9D%D0%B0%D0%B3%D0%B5%D1%81%D0%B2%D0%B0%D1%80%D0%B0_%D0%A0%D0%B0%D0%BE','9eddba1a2fe4f1c9728d2d531e4fdbe1',NULL),(1073,5,2,169,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BE%D0%BF%D1%8F%D0%BD,_%D0%90%D0%BC%D0%B0%D1%8F%D0%BA_%D0%90%D1%80%D1%83%D1%82%D1%8E%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','7f2c685f125bd1ea1bdbd36e3cc4a487',NULL),(1074,5,2,170,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BE%D0%BF%D1%8F%D0%BD,_%D0%90%D1%80%D1%83%D1%82%D1%8E%D0%BD_%D0%90%D0%BC%D0%B0%D1%8F%D0%BA%D0%BE%D0%B2%D0%B8%D1%87','8bd477fcd4161b1620711421a97b5782',NULL),(1075,5,2,171,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D0%BE%D0%BF%D1%8F%D0%BD,_%D0%A0%D0%BE%D0%B1%D0%B5%D1%80%D1%82_%D0%94%D1%83%D1%80%D0%BC%D0%B8%D1%88%D1%85%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','eede570ad9ec4d65c827159e6d397e81',NULL),(1076,5,2,172,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%80%D0%B0%D1%87%D0%BA%D0%BE%D0%B2,_%D0%98%D0%B3%D0%BD%D0%B0%D1%82%D0%B8%D0%B9_%D0%A0%D0%BE%D0%BC%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','6a8d19b29a6f770db2f8a9b5e2630492',NULL),(1077,5,2,173,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%81%D0%B5%D0%BB%D1%8C_%D1%84%D0%BE%D0%BD_%D0%90%D0%BC%D0%B1%D1%80%D0%B5%D1%81%D1%81%D0%B5%D1%80','492824d85dc753e478c4d2410374ed2e',NULL),(1078,5,2,174,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%81%D1%91%D0%BD%D0%BE%D0%B2,_%D0%91%D1%8D%D0%BD%D0%BE_%D0%9C%D0%B0%D0%BA%D1%81%D0%BE%D0%B2%D0%B8%D1%87','b9d33cefb91cd5564fd9093baaeb6fc3',NULL),(1079,5,2,175,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%81%D1%91%D0%BD%D0%BE%D0%B2,_%D0%92%D1%81%D0%B5%D0%B2%D0%BE%D0%BB%D0%BE%D0%B4_%D0%9D%D0%B8%D0%BA%D0%BE%D0%BB%D0%B0%D0%B5%D0%B2%D0%B8%D1%87','97d2a553ea80349bdd4c7638a0763eda',NULL),(1080,5,2,176,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%83%D0%BB%D0%B8%D1%87,_%D0%9E%D0%BB%D0%B5%D0%B3_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2%D0%B8%D1%87','e1b0cba5653d3e2ea8f5e99c692f9fc4',NULL),(1081,5,2,177,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%83%D0%BD%D1%8C%D1%8F,_%D0%94%D0%B6%D0%B5%D0%B9%D1%81%D0%BE%D0%BD','d74e6fa1f42ebf4e150f3322e6b8082f',NULL),(1082,5,2,178,'https://ru.wikipedia.org/wiki/%D0%90%D0%BA%D1%83%D1%80%D0%B0%D1%82%D0%B5%D1%80%D1%81,_%D0%92%D0%BE%D0%BB%D0%B4%D0%B5%D0%BC%D0%B0%D1%80','f9655fb2cfe7544c7dbc2205a54f9d5f',NULL),(1083,5,2,179,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%B7%D1%80%D0%B0%D0%BA%D0%B8,_%D0%9A%D0%B0%D1%80%D0%BB%D0%BE%D1%81','411d18b3a480e583e4a27cfd64b84929',NULL),(1084,5,2,180,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%B9%D0%BC%D0%BE,_%D0%9C%D0%B0%D1%80%D0%BA','cae8dbd6e9379d8caf5246213d1b8d51',NULL),(1085,5,2,181,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%BC%D0%B3%D0%B8%D1%80_(%D0%B0%D0%BA%D1%82%D1%91%D1%80)','2336287aa7625b5f9ab1a93e699106e3',NULL),(1086,5,2,182,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%BC%D0%BE,_%D0%A0%D0%BE%D0%B1%D0%B5%D1%80%D1%82%D0%BE','e08f1b650740aa6aef922ce02dd43989',NULL),(1087,5,2,183,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%BD_%D0%9A%D1%91%D1%80%D1%82%D0%B8%D1%81','47471bf9feeeb042c720972aadacb700',NULL),(1088,5,2,184,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%BD_%D0%9C%D0%B0%D1%83%D0%B1%D1%80%D1%8D%D0%B9','7b94da21bc245eb0be0b38c2f85d3da5',NULL),(1089,5,2,185,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D1%81%D0%BA%D0%B8,_%D0%94%D0%B6%D0%BE','202919e8e643fef690a40fd379f749ba',NULL),(1090,5,2,186,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B1%D0%B0%D1%80%D0%BD,_%D0%94%D0%B5%D0%B9%D0%BC%D0%BE%D0%BD','2ad1cedb9fad2a806aa25746b1fdce65',NULL),(1091,5,2,187,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B1%D1%83%D0%BB%D0%B5%D1%81%D0%BA%D1%83,_%D0%9C%D0%B8%D1%80%D1%87%D0%B0','53f2ff7b197f3050a8fb7a0c830774c4',NULL),(1092,5,2,188,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B0%D0%BD_%D0%90%D0%BB%D0%B4%D0%B0','18f4f11cc6bbb51dae0cd2bce5c6a7a5',NULL),(1093,5,2,189,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B4%D0%BE%D1%88%D0%B8%D0%BD,_%D0%92%D0%B8%D0%BA%D1%82%D0%BE%D1%80_%D0%9F%D0%B0%D0%B2%D0%BB%D0%BE%D0%B2%D0%B8%D1%87','ddf766b39991b8b0bece9afbd9bb26cf',NULL),(1094,5,2,190,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%B9%D0%BD%D0%B8%D0%BA%D0%BE%D0%B2,_%D0%9F%D1%91%D1%82%D1%80_%D0%9C%D0%B0%D1%80%D1%82%D1%8B%D0%BD%D0%BE%D0%B2%D0%B8%D1%87','ac609cf0fdd54f1af5c75aac60c46f13',NULL),(1095,5,2,191,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D0%BF%D0%B5%D1%80%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B5%D1%81%D0%BA%D0%B5%D1%80_%D0%93%D0%B0%D0%B4%D0%B6%D0%B8_%D0%90%D0%B3%D0%B0_%D0%BE%D0%B3%D0%BB%D1%8B','feb1070cc8547c5c54dfbbda9fe27856',NULL),(1096,5,2,192,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D0%BF%D0%B5%D1%80%D0%BE%D0%B2,_%D0%A8%D0%B0%D1%85%D0%BC%D0%B0%D1%80_%D0%97%D1%83%D0%BB%D1%8C%D1%84%D1%83%D0%B3%D0%B0%D1%80_%D0%BE%D0%B3%D0%BB%D1%8B','b92985051a8fdf8174a5c077d9e8eb2d',NULL),(1097,5,2,193,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D0%B5%D1%80,_%D0%94%D0%B6%D0%B5%D0%B9%D1%81%D0%BE%D0%BD','a2564c94f6b498865a4d949ea5908fd2',NULL),(1098,5,2,194,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D0%B5%D1%80,_%D0%9E%D0%BB%D0%BB%D0%B8','8c9690846c7a601b2c6c539addb5b967',NULL),(1099,5,2,195,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D0%B5%D1%80,_%D0%9F%D0%B5%D1%82%D0%B5%D1%80','8766c26bd25aceec0b2245e31a7fe6ac',NULL),(1100,5,2,196,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80,_%D0%94%D0%B6%D0%BE%D0%BD_(%D0%B0%D0%BA%D1%82%D1%91%D1%80)','a6f511fc1c21474faba7805e3b2fd58e',NULL),(1101,5,2,197,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%B8%D0%BD,_%D0%90%D0%BD%D0%B4%D1%80%D0%B5%D0%B9_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2%D0%B8%D1%87','b402ba0fcdb535edca31e13c0eda51fb',NULL),(1102,5,2,198,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%9B%D0%B5%D0%BE%D0%BD%D0%B0%D1%80%D0%B4%D0%BE%D0%B2%D0%B8%D1%87','176f1e57c9491d7e9b266209aed13baa',NULL),(1103,5,2,199,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2,_%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80_%D0%A1%D0%B5%D1%80%D0%B3%D0%B5%D0%B5%D0%B2%D0%B8%D1%87_(%D0%B0%D0%BA%D1%82%D1%91%D1%80)','e439611127a2b4d8b2a8fd981468dc61',NULL),(1104,5,2,200,'https://ru.wikipedia.org/wiki/%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%D0%BE%D0%B2,_%D0%91%D0%BE%D1%80%D0%B8%D1%81_%D0%92%D0%BB%D0%B0%D0%B4%D0%B8%D0%BC%D0%B8%D1%80%D0%BE%D0%B2%D0%B8%D1%87','a8eed385ec8f6ca8cf3bafb0e9a9861f',NULL);

#
# Structure for table "records"
#

CREATE TABLE `records` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `link_id` int(11) NOT NULL DEFAULT '0',
  `num` int(11) unsigned NOT NULL DEFAULT '1',
  `key` varchar(255) NOT NULL DEFAULT '',
  `value` longtext NOT NULL,
  `value_hash` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `record_unq` (`link_id`,`key`,`value_hash`),
  CONSTRAINT `records_ibfk_1` FOREIGN KEY (`link_id`) REFERENCES `links` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# Data for table "records"
#


#
# Structure for table "job_messages"
#

CREATE TABLE `job_messages` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `mtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `link_id` int(11) NOT NULL DEFAULT '0',
  `job_rule_id` int(11) NOT NULL DEFAULT '0',
  `message` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id`),
  KEY `link_id` (`link_id`),
  KEY `job_rule_id` (`job_rule_id`),
  CONSTRAINT `job_messages_ibfk_1` FOREIGN KEY (`link_id`) REFERENCES `links` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `job_messages_ibfk_2` FOREIGN KEY (`job_rule_id`) REFERENCES `job_rules` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# Data for table "job_messages"
#


#
# Structure for table "link2link"
#

CREATE TABLE `link2link` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `master_link_id` int(11) NOT NULL DEFAULT '0',
  `slave_link_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  KEY `master_link_id` (`master_link_id`),
  KEY `slave_link_id` (`slave_link_id`),
  CONSTRAINT `link2link_ibfk_1` FOREIGN KEY (`master_link_id`) REFERENCES `links` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `link2link_ibfk_2` FOREIGN KEY (`slave_link_id`) REFERENCES `links` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=893 DEFAULT CHARSET=utf8;

#
# Data for table "link2link"
#

REPLACE INTO `link2link` VALUES (693,904,905),(694,904,906),(695,904,907),(696,904,908),(697,904,909),(698,904,910),(699,904,911),(700,904,912),(701,904,913),(702,904,914),(703,904,915),(704,904,916),(705,904,917),(706,904,918),(707,904,919),(708,904,920),(709,904,921),(710,904,922),(711,904,923),(712,904,924),(713,904,925),(714,904,926),(715,904,927),(716,904,928),(717,904,929),(718,904,930),(719,904,931),(720,904,932),(721,904,933),(722,904,934),(723,904,935),(724,904,936),(725,904,937),(726,904,938),(727,904,939),(728,904,940),(729,904,941),(730,904,942),(731,904,943),(732,904,944),(733,904,945),(734,904,946),(735,904,947),(736,904,948),(737,904,949),(738,904,950),(739,904,951),(740,904,952),(741,904,953),(742,904,954),(743,904,955),(744,904,956),(745,904,957),(746,904,958),(747,904,959),(748,904,960),(749,904,961),(750,904,962),(751,904,963),(752,904,964),(753,904,965),(754,904,966),(755,904,967),(756,904,968),(757,904,969),(758,904,970),(759,904,971),(760,904,972),(761,904,973),(762,904,974),(763,904,975),(764,904,976),(765,904,977),(766,904,978),(767,904,979),(768,904,980),(769,904,981),(770,904,982),(771,904,983),(772,904,984),(773,904,985),(774,904,986),(775,904,987),(776,904,988),(777,904,989),(778,904,990),(779,904,991),(780,904,992),(781,904,993),(782,904,994),(783,904,995),(784,904,996),(785,904,997),(786,904,998),(787,904,999),(788,904,1000),(789,904,1001),(790,904,1002),(791,904,1003),(792,904,1004),(793,904,1005),(794,904,1006),(795,904,1007),(796,904,1008),(797,904,1009),(798,904,1010),(799,904,1011),(800,904,1012),(801,904,1013),(802,904,1014),(803,904,1015),(804,904,1016),(805,904,1017),(806,904,1018),(807,904,1019),(808,904,1020),(809,904,1021),(810,904,1022),(811,904,1023),(812,904,1024),(813,904,1025),(814,904,1026),(815,904,1027),(816,904,1028),(817,904,1029),(818,904,1030),(819,904,1031),(820,904,1032),(821,904,1033),(822,904,1034),(823,904,1035),(824,904,1036),(825,904,1037),(826,904,1038),(827,904,1039),(828,904,1040),(829,904,1041),(830,904,1042),(831,904,1043),(832,904,1044),(833,904,1045),(834,904,1046),(835,904,1047),(836,904,1048),(837,904,1049),(838,904,1050),(839,904,1051),(840,904,1052),(841,904,1053),(842,904,1054),(843,904,1055),(844,904,1056),(845,904,1057),(846,904,1058),(847,904,1059),(848,904,1060),(849,904,1061),(850,904,1062),(851,904,1063),(852,904,1064),(853,904,1065),(854,904,1066),(855,904,1067),(856,904,1068),(857,904,1069),(858,904,1070),(859,904,1071),(860,904,1072),(861,904,1073),(862,904,1074),(863,904,1075),(864,904,1076),(865,904,1077),(866,904,1078),(867,904,1079),(868,904,1080),(869,904,1081),(870,904,1082),(871,904,1083),(872,904,1084),(873,904,1085),(874,904,1086),(875,904,1087),(876,904,1088),(877,904,1089),(878,904,1090),(879,904,1091),(880,904,1092),(881,904,1093),(882,904,1094),(883,904,1095),(884,904,1096),(885,904,1097),(886,904,1098),(887,904,1099),(888,904,1100),(889,904,1101),(890,904,1102),(891,904,1103),(892,904,1104);

#
# Structure for table "job_levels"
#

CREATE TABLE `job_levels` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `job_level_unq` (`job_id`,`level`),
  KEY `job_id` (`job_id`),
  CONSTRAINT `job_levels_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

#
# Data for table "job_levels"
#

REPLACE INTO `job_levels` VALUES (1,4,1),(2,4,2),(3,4,3),(6,4,4),(7,4,5),(8,5,1),(9,5,2);
