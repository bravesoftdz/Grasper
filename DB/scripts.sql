# отключить проверку внешних ключей
SET foreign_key_checks = 0

CREATE DEFINER=`root`@`localhost` TRIGGER `pia-dev`.`DeleteLinkRule`
  AFTER DELETE ON `pia-dev`.`job_rule_links`
  FOR EACH ROW
BEGIN
	delete from job_rules where id = old.job_rule_id;
END;

CREATE DEFINER=`root`@`localhost` TRIGGER `pia-dev`.`DeleteRecRule`
  AFTER DELETE ON `pia-dev`.`job_rule_records`
  FOR EACH ROW
BEGIN
	delete from job_rules where id = old.job_rule_id;
END;

CREATE DEFINER=`root`@`localhost` TRIGGER `pia-dev`.`DeleteCutRule`
  AFTER DELETE ON `pia-dev`.`job_rule_cuts`
  FOR EACH ROW
BEGIN
	delete from job_rules where id = old.job_rule_id;
END;

CREATE DEFINER=`root`@`localhost` TRIGGER `pia-dev`.`HashWritter`
  BEFORE INSERT ON `pia-dev`.`links`
  FOR EACH ROW
BEGIN
  SET NEW.link_hash = md5(NEW.link);
END;