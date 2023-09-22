-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema egzamin_zawodowy
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema egzamin_zawodowy
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `egzamin_zawodowy` DEFAULT CHARACTER SET utf8mb4 ;
USE `egzamin_zawodowy` ;

-- -----------------------------------------------------
-- Table `egzamin_zawodowy`.`questions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `egzamin_zawodowy`.`questions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `content` MEDIUMTEXT NOT NULL,
  `image_path` TINYTEXT NULL DEFAULT NULL,
  `next_repetition_time` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `egzamin_zawodowy`.`answers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `egzamin_zawodowy`.`answers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `content` MEDIUMTEXT NOT NULL,
  `is_correct` TINYINT(1) NOT NULL DEFAULT 0,
  `ques_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `FK_anrs_ques_idx` (`ques_id` ASC) VISIBLE,
  CONSTRAINT `FK_answ_ques`
    FOREIGN KEY (`ques_id`)
    REFERENCES `egzamin_zawodowy`.`questions` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `egzamin_zawodowy`.`users_data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `egzamin_zawodowy`.`users_data` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `answ_id` INT NULL,
  `view_date_time` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `FK_udat_answ_idx` (`answ_id` ASC) VISIBLE,
  CONSTRAINT `FK_udat_answ`
    FOREIGN KEY (`answ_id`)
    REFERENCES `egzamin_zawodowy`.`answers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `egzamin_zawodowy` ;

-- -----------------------------------------------------
-- procedure addQuestion
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `addQuestion` (IN in_content MEDIUMTEXT, IN in_has_img TINYINT(1), IN in_img_path TINYTEXT)
BEGIN
	IF in_has_img = 0 THEN
		INSERT INTO `questions` (`content`) VALUES (in_content);
    ELSEIF in_has_img = 1 THEN
		INSERT INTO `questions` (`content`, `image_path`) VALUES (in_content, in_img_path);
    ELSE
		SELECT "Nie udało się dodać pytania.";
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure addAnswer
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `addAnswer`(IN in_ques_id INT, IN in_content MEDIUMTEXT, IN in_is_correct BOOLEAN)
BEGIN
	INSERT INTO `answers` (`content`, `is_correct`, `ques_id`) VALUES (in_content, in_is_correct, in_ques_id);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure addQuestionReply
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `addQuestionReply`(IN in_ques_id INT, IN in_answer_content MEDIUMTEXT)
BEGIN
    DECLARE answer_id INT;
	IF (in_answer_content != "Nie wiem") THEN 
		SET answer_id = (SELECT `answers`.`id` FROM `answers` WHERE `content` = in_answer_content AND `ques_id` = in_ques_id LIMIT 1);
		INSERT INTO `users_data` (`answ_id`, `view_date_time`) VALUES (answer_id, NOW());
	-- ELSE
		-- INSERT INTO `users_data` (`ques_id`, `view_date_time`) VALUES (in_ques_id, NOW());
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getAnswersRelatedToQuestion
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `getAnswersRelatedToQuestion`(IN in_ques_id INT)
BEGIN
	SELECT `id`, `content`, `is_correct` FROM `answers` WHERE `ques_id` = in_ques_id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getLatestAddedQuestionId
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `getLatestAddedQuestionId`()
BEGIN
	SELECT `id` FROM `questions` ORDER BY `id` DESC LIMIT 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getRandomQuestion
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `getRandomQuestion` ()
BEGIN
SELECT * FROM `questions`order by rand() limit 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getAnswerCorrectness
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `getAnswerCorrectness` (IN question_id INT, IN answer_content MEDIUMTEXT)
BEGIN
	DECLARE answer_id INT;
    
	IF answer_content != "Nie wiem" THEN
		SET answer_id = (SELECT answers.id FROM answers WHERE `content` = answer_content AND `ques_id` = question_id LIMIT 1);
		SELECT `is_correct` FROM answers WHERE `id` = answer_id;
    ELSE 
		SELECT "0" AS `is_correct`;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getCorrectAnswerForQuestion
-- -----------------------------------------------------

DELIMITER $$
USE `egzamin_zawodowy`$$
CREATE PROCEDURE `getCorrectAnswerForQuestion` (IN question_id INT)
BEGIN
	SELECT `content` FROM `answers` WHERE `is_correct` = 1 AND `ques_id` = question_id;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
