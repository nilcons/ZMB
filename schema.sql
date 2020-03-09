CREATE TABLE `Provider` (
  `id` int PRIMARY KEY,
  `name` varchar(255) UNIQUE NOT NULL
);

CREATE TABLE `Provider_Station` (
  `station` char(4) NOT NULL,
  `provider` int NOT NULL,
  PRIMARY KEY (`station`, `provider`)
);

CREATE TABLE `Station` (
  `id` char(4) PRIMARY KEY,
  `name` varchar(255) UNIQUE NOT NULL
);

CREATE TABLE `Railline` (
  `id` varchar(255) PRIMARY KEY,
  `provider` int NOT NULL,
  `name` varchar(255)
);

CREATE TABLE `Railline_Station` (
  `railline` varchar(255) NOT NULL,
  `order` int NOT NULL,
  `id` varchar(255),
  `station` char(4) NOT NULL,
  `meter` int NOT NULL,
  `km1` char(20),
  `km2` char(20),
  PRIMARY KEY (`railline`, `order`)
);

CREATE TABLE `Trip` (
  `id` int PRIMARY KEY,
  `name` varchar(255),
  `computed_meter` int
);

CREATE TABLE `Trip_Railline` (
  `trip` int NOT NULL,
  `order` int NOT NULL,
  `railline` varchar(255),
  `from` int,
  `to` int,
  PRIMARY KEY (`trip`, `order`)
);

ALTER TABLE `Provider_Station` ADD FOREIGN KEY (`station`) REFERENCES `Station` (`id`);

ALTER TABLE `Provider_Station` ADD FOREIGN KEY (`provider`) REFERENCES `Provider` (`id`);

ALTER TABLE `Railline` ADD FOREIGN KEY (`provider`) REFERENCES `Provider` (`id`);

ALTER TABLE `Railline_Station` ADD FOREIGN KEY (`railline`) REFERENCES `Railline` (`id`);

ALTER TABLE `Railline_Station` ADD FOREIGN KEY (`station`) REFERENCES `Station` (`id`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`trip`) REFERENCES `Trip` (`id`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`railline`, `from`) REFERENCES `Railline_Station` (`railline`, `order`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`railline`, `to`) REFERENCES `Railline_Station` (`railline`, `order`);
