create database protobench;
use protobench;

CREATE TABLE `experiment` (
  `id` int(11) NOT NULL auto_increment,
  `started` datetime DEFAULT NULL,
  `ended` datetime DEFAULT NULL,
  `protocol` varchar(45) DEFAULT NULL,
  `ncli` int(11) DEFAULT 0,
  `nsrv` int(11) DEFAULT 0,
  `replication` int(11) DEFAULT 0,
  `bandwidth` float DEFAULT 0,
  `mse` float default 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `measurement` (
  `id` int(11) NOT NULL auto_increment,
  `experiment_id` int(11) DEFAULT NULL,
  `run_id` int(11) DEFAULT NULL,
  `client_host` varchar(45) DEFAULT NULL,
  `bandwidth` float DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `experiment_id` (`experiment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
