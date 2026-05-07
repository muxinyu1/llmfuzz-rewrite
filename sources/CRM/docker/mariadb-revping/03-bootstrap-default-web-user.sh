#!/usr/bin/env bash
set -euo pipefail

db_name="${MYSQL_DATABASE:-churchcrm}"
default_user="${WEB_DEFAULT_USER:-admin}"
default_password="${WEB_DEFAULT_PASSWORD:-Admin@123456}"

mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" "${db_name}" <<SQL
UPDATE user_usr
SET usr_UserName = '${default_user}',
    usr_Password = SHA2(CONCAT('${default_password}', usr_per_ID), 256),
    usr_NeedPasswordChange = 0,
    usr_FailedLogins = 0
WHERE usr_per_ID = (
    SELECT admin_usr_per_ID FROM (
        SELECT usr_per_ID AS admin_usr_per_ID
        FROM user_usr
        WHERE usr_Admin = 1
        ORDER BY usr_per_ID ASC
        LIMIT 1
    ) AS t
);
SQL
