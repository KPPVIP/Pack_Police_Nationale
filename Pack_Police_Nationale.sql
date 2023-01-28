INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_pn', 'Police Nationale', 1);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('society_pn', 'Police Nationale', 1);

INSERT INTO `jobs` (`name`, `label`) VALUES
('pn', 'Police Nationale');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('pn', 100, 'novice', 'Recrue', 100, '', ''),
('pn', 101, 'experimente', 'Expérimenté', 100, '', ''),
('pn', 102, 'boss', 'Patron', 100, '', '');
