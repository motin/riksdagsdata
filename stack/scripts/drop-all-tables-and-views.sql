SET @database_name = DATABASE();
SET SESSION group_concat_max_len = 10240;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

/* DROP ALL TABLES */

SET @tbls = NULL;
SELECT
    GROUP_CONCAT(table_schema, '.', table_name)
INTO @tbls FROM
    information_schema.tables
WHERE
    table_schema = @database_name;

SET @drop_tbls_sql = IFNULL(CONCAT('DROP TABLE IF EXISTS ', @tbls), 'SELECT "No Tables"');
SELECT @drop_tbls_sql;

PREPARE stmt FROM @drop_tbls_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* DROP ALL VIEWS */

SET @views = NULL;
SELECT
    GROUP_CONCAT(table_schema, '.', table_name)
INTO @views FROM
    information_schema.views
WHERE
    table_schema = @database_name;

SET @drop_views_sql = IFNULL(CONCAT('DROP VIEW IF EXISTS ', @views), 'SELECT "No Views"');
SELECT @drop_views_sql;

PREPARE stmt FROM @drop_views_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
