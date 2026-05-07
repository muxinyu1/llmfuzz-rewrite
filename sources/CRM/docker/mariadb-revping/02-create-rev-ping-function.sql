USE churchcrm;

DROP FUNCTION IF EXISTS rev_ping;
CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';
