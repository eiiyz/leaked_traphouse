CREATE TABLE IF NOT EXISTS `trap_house_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item` varchar(255) DEFAULT NULL,
  `stock` int(11) NOT NULL,
  `trapId` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `trap_houses` (
  `trapId` tinyint(2) NOT NULL,
  `owner` varchar(50) DEFAULT NULL,
  `pin` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`trapId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `trap_houses` (`trapId`, `owner`, `pin`) VALUES
	(1, 'steam:ADMINSTEAM', 1234),
	(2, 'steam:ADMINSTEAM', 1234),
	(3, 'steam:ADMINSTEAM', 1234),
	(4, 'steam:ADMINSTEAM', 1234),
	(5, 'steam:ADMINSTEAM', 1234),
	(6, 'steam:ADMINSTEAM', 1234),
	(7, 'steam:ADMINSTEAM', 1234);