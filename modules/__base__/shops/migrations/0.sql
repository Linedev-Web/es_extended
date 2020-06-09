
INSERT INTO `shops` (`store`, `item`, `price`) VALUES
	('TwentyFourSeven','bread',30),
	('TwentyFourSeven','water',15),
	('RobsLiquor','bread',30),
	('RobsLiquor','water',15),
	('LTDgasoline','bread',30),
	('LTDgasoline','water',15)
;

create TABLE `items`
(
    `name`       VARCHAR(50) NOT NULL,
    `label`      VARCHAR(50) NOT NULL,
    `weight`     INT(11)     NOT NULL DEFAULT 1,
    `rare`       TINYINT(1)  NOT NULL DEFAULT 0,
    `can_remove` TINYINT(1)  NOT NULL DEFAULT 1,

    PRIMARY KEY (`name`)
);

insert into `items` (`name`, `label`, `weight`,`rare`,`can_remove`)
VALUES ('bread', 'Bread', 20,0,1),
       ('water', 'Water', 20,0,1)
;
