\o /tmp/output
-- Load the data
DROP TABLE IF EXISTS TEST;
CREATE UNLOGGED TABLE TEST(CITY TEXT, TEMPERATURE FLOAT);
CREATE INDEX test_idx_city_temperature ON "test" ("city","temperature");
COPY TEST(CITY, TEMPERATURE) FROM '/1brc/measurements.txt' DELIMITER ';' CSV;

-- Run calculations
WITH AGG AS(
    SELECT city,
           MIN(temperature) min_measure,
           cast(AVG(temperature) AS DECIMAL(8,1)) mean_measure,
           MAX(temperature) max_measure
    FROM test
    GROUP BY city
    )
SELECT STRING_AGG(CITY || '=' || CONCAT(min_measure,'/', mean_measure,'/', max_measure),', ' ORDER BY CITY)
FROM AGG
;
