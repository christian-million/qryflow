-- @exec: drop_cyl_6
DROP TABLE IF EXISTS cyl_6;

-- @exec: prep_cyl_6
CREATE TABLE cyl_6 AS
SELECT *
FROM mtcars
WHERE cyl = 6;

-- @unknown: df_unknown
SELECT *
FROM mtcars;

-- @query: df_cyl_6
SELECT *
FROM cyl_6;

