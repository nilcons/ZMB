CREATE TABLE `Provider` (
  `id` int PRIMARY KEY,
  `name` varchar(255)
);

CREATE TABLE `Provider_Station` (
  `station` char(4),
  `provider` int,
  PRIMARY KEY (`station`, `provider`)
);

CREATE TABLE `Station` (
  `id` char(4) PRIMARY KEY,
  `name` varchar(255)
);

CREATE TABLE `Railline` (
  `id` varchar(255) PRIMARY KEY,
  `provider` int,
  `name` varchar(255)
);

CREATE TABLE `Railline_Station` (
  `railline` varchar(255),
  `order` int,
  `id` varchar(255),
  `station` char(4),
  `meter` int,
  PRIMARY KEY (`railline`, `order`)
);

CREATE TABLE `Trip` (
  `id` int PRIMARY KEY,
  `name` varchar(255),
  `computed_meter` int
);

CREATE TABLE `Trip_Railline` (
  `id` int,
  `order` int,
  `railline` varchar(255),
  `from` int,
  `to` int,
  PRIMARY KEY (`id`, `order`)
);

ALTER TABLE `Provider_Station` ADD FOREIGN KEY (`station`) REFERENCES `Station` (`id`);

ALTER TABLE `Provider_Station` ADD FOREIGN KEY (`provider`) REFERENCES `Provider` (`id`);

ALTER TABLE `Railline` ADD FOREIGN KEY (`provider`) REFERENCES `Provider` (`id`);

ALTER TABLE `Railline_Station` ADD FOREIGN KEY (`railline`) REFERENCES `Railline` (`id`);

ALTER TABLE `Railline_Station` ADD FOREIGN KEY (`station`) REFERENCES `Station` (`id`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`id`) REFERENCES `Trip` (`id`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`railline`) REFERENCES `Railline_Station` (`railline`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`from`) REFERENCES `Railline_Station` (`order`);

ALTER TABLE `Trip_Railline` ADD FOREIGN KEY (`to`) REFERENCES `Railline_Station` (`order`);

