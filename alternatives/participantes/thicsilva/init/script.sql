/*
SQLyog Community
MySQL - 10.4.27-MariaDB : Database - rinha
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`rinha` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `rinha`;

/*Table structure for table `members` */

DROP TABLE IF EXISTS `members`;

CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) DEFAULT NULL,
  `limit` int(11) NOT NULL,
  `current_balance` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `members` */

insert  into `members`(`id`,`nome`,`limit`,`current_balance`) values (1,'o barato sai caro',100000,0);
insert  into `members`(`id`,`nome`,`limit`,`current_balance`) values (2,'zan corp ltda',80000,0);
insert  into `members`(`id`,`nome`,`limit`,`current_balance`) values (3,'les cruders',1000000,0);
insert  into `members`(`id`,`nome`,`limit`,`current_balance`) values (4,'padaria joia de cocaia',10000000,0);
insert  into `members`(`id`,`nome`,`limit`,`current_balance`) values (5,'kid mais',500000,0);

/*Table structure for table `transactions` */

DROP TABLE IF EXISTS `transactions`;

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `kind` char(1) DEFAULT NULL,
  `description` varchar(10) DEFAULT NULL,
  `submitted_at` timestamp(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  PRIMARY KEY (`id`),
  KEY `fk_transacao_cliente` (`cliente_id`),
  KEY `idx_realizada` (`submitted_at`),
  CONSTRAINT `fk_transacao_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `members` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `transactions` */

/* Procedure structure for procedure `Salvartransactions` */

/*!50003 DROP PROCEDURE IF EXISTS  `Salvartransactions` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `Salvartransactions`(p_cliente_id INT, p_amount INT, p_kind CHAR(1), p_description VARCHAR(10), OUT o_current_balance INT, out o_limit int)
BEGIN	
	DECLARE diff INT;
        DECLARE res INT;    
        declare n_current_balance int;    
        SET autocommit=0;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        start transaction;
        
        IF (p_kind='d') THEN
            SET diff = -p_amount;
        ELSE
            SET diff = p_amount;
        END IF;
        SELECT current_balance, limit, current_balance+diff into o_current_balance, o_limit, n_current_balance from members where id=p_cliente_id FOR UPDATE;
        if (n_current_balance<-o_limit) then
            SET o_current_balance=-1;
            set o_limit=-1;
            SELECT 'SALDO INDISPONIVEL' AS Msg;
            ROLLBACK;
        else        
            UPDATE members SET current_balance = n_current_balance WHERE id=p_cliente_id;               
            INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (p_cliente_id, p_amount, p_kind, p_description);
            SELECT current_balance, limit INTO o_current_balance, o_limit FROM members WHERE id=p_cliente_id;
            COMMIT;
        END IF;
	END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
