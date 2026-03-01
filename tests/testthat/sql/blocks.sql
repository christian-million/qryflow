-- @query: block1
-- Comment
-- @tag: TRUE
SELECT *
FROM mtcars

-- @query: block2
-- @tag: another
SELECT *
FROM df_mtcars
-- @query: block3
SELECT *
FROM mtcars;

-- @query: solo

-- Starting comment
-- @query: block5
-- @tag: TRUE
SELECT *
FROM mtcars
