-- WARNING: This procedure requires the Analytics Toolbox and assumes it will be located
-- at the following path: carto-un.carto. If you want to deploy and
-- run it in a different location, you will need to update the code accordingly.
CREATE OR REPLACE PROCEDURE
  `YOUR_PROJECT.workflows_temp.wfproc_last_mile`(
)
BEGIN
  /*
   {"diagramJson":"{\"title\":\"The Last Mile: NYC Delivery Pressure (challenge)\",\"description\":\"SDSC 2026 workshop, challenge version. Loading and measuring are done. Build stages 3, 4 and 5 yourself: three Joins, two Create Column nodes, a Composite Score, a Join and a Create Builder Map.\",\"nodes\":[{\"id\":\"imp-violations\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import violations\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/violations_fy2026_by_precinct_month.csv\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":280},\"selected\":false},{\"id\":\"imp-precincts\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import precincts\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/precincts_study_area.geojson\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":440},\"selected\":false},{\"id\":\"imp-loading\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import loading zones\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/loading_zone_signs_manhattan.csv\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":760},\"selected\":false},{\"id\":\"n-population\",\"data\":{\"name\":\"native.customsql\",\"label\":\"Custom SQL Select\",\"title\":\"1. Population by precinct\",\"inputs\":[{\"name\":\"sourcea\",\"type\":\"Table\",\"title\":\"Source table a\",\"optional\":true,\"description\":\"Source table a\",\"value\":null},{\"name\":\"sourceb\",\"type\":\"Table\",\"title\":\"Source table b\",\"optional\":true,\"description\":\"Source table b\",\"value\":null},{\"name\":\"sourcec\",\"type\":\"Table\",\"title\":\"Source table c\",\"optional\":true,\"description\":\"Source table c\",\"value\":null},{\"name\":\"sql\",\"type\":\"StringSql\",\"title\":\"SQL SELECT statement\",\"mode\":\"multiline\",\"placeholder\":\"SELECT ST_Centroid(geom) AS geom,\\n  AVG(value) AS average_value,\\n  category\\nFROM $a\\nGROUP BY category\",\"allowExpressions\":false,\"description\":\"SQL SELECT statement\",\"value\":\"SELECT * FROM UNNEST(ARRAY<STRUCT<precinct STRING, population INT64>>[('1', 80892), ('5', 45946), ('6', 62800), ('7', 57405), ('9', 67739), ('10', 48183), ('13', 99451), ('14', 29357), ('17', 67132), ('18', 48161)])\"}],\"version\":\"2.0.0\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":600},\"selected\":false},{\"id\":\"n-loading-reproject\",\"data\":{\"name\":\"native.customsql\",\"label\":\"Custom SQL Select\",\"title\":\"1. Convert coordinates\",\"inputs\":[{\"name\":\"sourcea\",\"type\":\"Table\",\"title\":\"Source table a\",\"optional\":true,\"description\":\"Source table a\",\"value\":null},{\"name\":\"sourceb\",\"type\":\"Table\",\"title\":\"Source table b\",\"optional\":true,\"description\":\"Source table b\",\"value\":null},{\"name\":\"sourcec\",\"type\":\"Table\",\"title\":\"Source table c\",\"optional\":true,\"description\":\"Source table c\",\"value\":null},{\"name\":\"sql\",\"type\":\"StringSql\",\"title\":\"SQL SELECT statement\",\"mode\":\"multiline\",\"placeholder\":\"SELECT ST_Centroid(geom) AS geom,\\n  AVG(value) AS average_value,\\n  category\\nFROM $a\\nGROUP BY category\",\"allowExpressions\":false,\"description\":\"SQL SELECT statement\",\"value\":\"WITH p AS (\\n  SELECT order_number, on_street, from_street, to_street, sign_description,\\n    SAFE_CAST(sign_x_coord AS FLOAT64) * 0.3048006096012192 - 300000.0 AS dx,\\n    7462536.301142955 - SAFE_CAST(sign_y_coord AS FLOAT64) * 0.3048006096012192 AS dy\\n  FROM `$a`\\n  WHERE SAFE_CAST(sign_x_coord AS FLOAT64) IS NOT NULL AND SAFE_CAST(sign_y_coord AS FLOAT64) IS NOT NULL\\n), r AS (\\n  SELECT *, POW(SQRT(dx*dx + dy*dy) / 12287232.615120513, 1.0/0.6540820912037886) AS t, ATAN2(dx, dy)/0.6540820912037886 + (-1.2915436464758039) AS lam FROM p\\n), s_p0 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t) AS p0 FROM r),\\ns_p1 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p0))/(1+0.08181919104281579*SIN(p0)), 0.08181919104281579/2)) AS p1 FROM s_p0),\\ns_p2 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p1))/(1+0.08181919104281579*SIN(p1)), 0.08181919104281579/2)) AS p2 FROM s_p1),\\ns_p3 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p2))/(1+0.08181919104281579*SIN(p2)), 0.08181919104281579/2)) AS p3 FROM s_p2),\\ns_p4 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p3))/(1+0.08181919104281579*SIN(p3)), 0.08181919104281579/2)) AS p4 FROM s_p3)\\nSELECT order_number, on_street, from_street, to_street, sign_description,\\n  CASE WHEN UPPER(sign_description) LIKE '%TRUCK%' THEN 'Truck Loading Zone'\\n       WHEN UPPER(sign_description) LIKE '%NLZ%' OR UPPER(sign_description) LIKE '%NEIGHBORHOOD LOADING%' THEN 'Neighborhood Loading Zone'\\n       WHEN UPPER(sign_description) LIKE '%HOTEL%' THEN 'Hotel Loading Zone'\\n       ELSE 'Other Loading Zone' END AS zone_type,\\n  ST_GEOGPOINT(lam*180/ACOS(-1), p4*180/ACOS(-1)) AS geom\\nFROM s_p4\"}],\"version\":\"2.0.0\"},\"type\":\"generic\",\"position\":{\"x\":272,\"y\":760},\"selected\":false},{\"id\":\"n-precinct-filter\",\"data\":{\"name\":\"native.where\",\"label\":\"Where\",\"title\":\"2. Study area precincts\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Filter expression\",\"placeholder\":\"E.g.: area > 1000 AND area < 3000\",\"description\":\"Filter expression\",\"value\":\"CAST(precinct AS STRING) IN ('1','5','6','7','9','10','13','14','17','18')\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":440},\"selected\":false},{\"id\":\"n-violation-filter\",\"data\":{\"name\":\"native.where\",\"label\":\"Where\",\"title\":\"2. Filter codes and dates\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Filter expression\",\"placeholder\":\"E.g.: area > 1000 AND area < 3000\",\"description\":\"Filter expression\",\"value\":\"CAST(violation_code AS INT64) IN (11,14,16,31,46,47,89) AND CAST(month AS TIMESTAMP) >= CAST(@date_from AS TIMESTAMP) AND CAST(month AS TIMESTAMP) <= CAST(@date_to AS TIMESTAMP)\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":280},\"selected\":false},{\"id\":\"n-violation-groupby\",\"data\":{\"name\":\"native.groupby\",\"label\":\"Group by\",\"title\":\"2. Count by precinct\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"columns\",\"type\":\"SelectColumnAggregation\",\"title\":\"Aggregation\",\"parent\":\"source\",\"placeholder\":\"workflows.parameterForm.selectAField\",\"allowExpression\":false,\"description\":\"Aggregation\",\"value\":\"violations,sum\"},{\"name\":\"groupby\",\"type\":\"Column\",\"title\":\"Group by\",\"parent\":\"source\",\"mode\":\"multiple\",\"dataType\":[\"boolean\",\"number\",\"string\",\"date\",\"datetime\",\"time\",\"timestamp\"],\"noDefault\":true,\"maxSelectionsCount\":null,\"description\":\"Group by\",\"value\":\"violation_precinct\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":656,\"y\":280},\"selected\":false},{\"id\":\"n-violation-cast\",\"data\":{\"name\":\"native.cast\",\"label\":\"Cast\",\"title\":\"2. Precinct as text\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"optional\":true,\"description\":\"Source table\",\"value\":null},{\"name\":\"column\",\"type\":\"Column\",\"title\":\"Column\",\"parent\":\"source\",\"dataType\":[\"number\",\"string\",\"boolean\",\"date\",\"time\",\"datetime\",\"timestamp\",\"binary\"],\"providers\":[\"bigquery\",\"snowflake\",\"redshift\",\"postgres\",\"oracle\",\"databricksWarehouse\"],\"description\":\"Column\",\"value\":\"violation_precinct\"},{\"name\":\"newtype\",\"type\":\"SelectionType\",\"title\":\"New type\",\"parent\":\"column\",\"providers\":[\"bigquery\",\"snowflake\",\"redshift\",\"postgres\",\"oracle\",\"databricksWarehouse\"],\"description\":\"New type\",\"value\":\"STRING\"}],\"version\":\"2\"},\"type\":\"generic\",\"position\":{\"x\":848,\"y\":280},\"selected\":false},{\"id\":\"n-loading-spatialjoin\",\"data\":{\"name\":\"native.spatialjoin\",\"label\":\"Spatial Join\",\"title\":\"2. Zones in precincts\",\"inputs\":[{\"name\":\"maintable\",\"type\":\"Table\",\"title\":\"Left table\",\"description\":\"Left table\",\"value\":null},{\"name\":\"secondarytable\",\"type\":\"Table\",\"title\":\"Right table\",\"description\":\"Right table\",\"value\":null},{\"name\":\"maintablejoincolumn\",\"type\":\"Column\",\"parent\":\"maintable\",\"title\":\"Key geo column in left table\",\"dataType\":[\"geography\"],\"description\":\"Key geo column in left table\",\"value\":\"geom\"},{\"name\":\"maintablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Left table columns\",\"parent\":\"maintable\",\"optional\":true,\"description\":\"Left table columns\",\"value\":\"[{\\\"name\\\": \\\"order_number\\\", \\\"joinname\\\": \\\"order_number\\\"}]\"},{\"name\":\"secondarytablejoincolumn\",\"type\":\"Column\",\"parent\":\"secondarytable\",\"title\":\"Key geo column in right table\",\"dataType\":[\"geography\"],\"description\":\"Key geo column in right table\",\"value\":\"geom\"},{\"name\":\"secondarytablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Right table columns\",\"parent\":\"secondarytable\",\"optional\":true,\"description\":\"Right table columns\",\"value\":\"[{\\\"name\\\": \\\"precinct\\\", \\\"joinname\\\": \\\"precinct\\\"}]\"},{\"name\":\"jointype\",\"type\":\"Selection\",\"title\":\"Join type\",\"default\":\"inner\",\"options\":[\"inner\",\"left\",\"right\",\"full\"],\"description\":\"Join type\",\"value\":\"inner\"},{\"name\":\"predicate\",\"type\":\"Selection\",\"title\":\"Spatial predicate\",\"default\":\"intersects\",\"optional\":true,\"options\":[\"intersects\",\"contains\",\"touches\",\"covers\"],\"description\":\"Spatial predicate\",\"value\":\"intersects\"}],\"version\":\"2\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":760},\"selected\":false},{\"id\":\"n-loading-groupby\",\"data\":{\"name\":\"native.groupby\",\"label\":\"Group by\",\"title\":\"2. Count zones by precinct\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"columns\",\"type\":\"SelectColumnAggregation\",\"title\":\"Aggregation\",\"parent\":\"source\",\"placeholder\":\"workflows.parameterForm.selectAField\",\"allowExpression\":false,\"description\":\"Aggregation\",\"value\":\"order_number,count\"},{\"name\":\"groupby\",\"type\":\"Column\",\"title\":\"Group by\",\"parent\":\"source\",\"mode\":\"multiple\",\"dataType\":[\"boolean\",\"number\",\"string\",\"date\",\"datetime\",\"time\",\"timestamp\"],\"noDefault\":true,\"maxSelectionsCount\":null,\"description\":\"Group by\",\"value\":\"precinct\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":656,\"y\":760},\"selected\":false},{\"id\":\"9b6c4442-44a3-5d5e-97cd-af14c89d57fe\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":40,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#F6CF71\",\"genAi\":false,\"label\":\"\",\"width\":360,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## 1 · Load\\nWe bring in three open datasets: parking tickets for commercial vehicles, precinct boundaries and loading zone signs. A small table adds how many people live in each precinct. Sign locations are converted into map coordinates.\"},\"selected\":false},{\"id\":\"9444fa42-1eef-5fc5-9f89-0bbe9cbd22dc\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":420,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#9EB9F3\",\"genAi\":false,\"label\":\"\",\"width\":540,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## 2 · Measure\\nWe count what happens in each precinct: how many tickets were issued (demand) and how many legal loading zones exist (supply). Filters keep only our 10 precincts and the dates we care about. Change date_from and date_to in Variables to move the time window.\"},\"selected\":false},{\"id\":\"c1a11e46-0000-5000-8000-000000000001\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":1000,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#DCB0F2\",\"genAi\":false,\"label\":\"\",\"width\":1710,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## Your challenge: build stages 3, 4 and 5\\n1. Combine and rate: three Joins (population, tickets, loading zones), then two Create Column nodes for tickets and loading zones per 1,000 residents.\\n2. Score: a Composite Score Unsupervised node and a Join that attaches the score to the precinct shapes.\\n3. Map: a Create Builder Map node.\\nThe exact settings are in the challenge section of the workshop guide.\"},\"selected\":false}],\"edges\":[{\"id\":\"e1\",\"source\":\"imp-loading\",\"target\":\"n-loading-reproject\",\"sourceHandle\":\"result\",\"targetHandle\":\"sourcea\",\"animated\":true,\"className\":\"\"},{\"id\":\"e2\",\"source\":\"imp-precincts\",\"target\":\"n-precinct-filter\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e3\",\"source\":\"imp-violations\",\"target\":\"n-violation-filter\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e4\",\"source\":\"n-violation-filter\",\"target\":\"n-violation-groupby\",\"sourceHandle\":\"match\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e5\",\"source\":\"n-violation-groupby\",\"target\":\"n-violation-cast\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e6\",\"source\":\"n-loading-reproject\",\"target\":\"n-loading-spatialjoin\",\"sourceHandle\":\"result\",\"targetHandle\":\"maintable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e7\",\"source\":\"n-precinct-filter\",\"target\":\"n-loading-spatialjoin\",\"sourceHandle\":\"match\",\"targetHandle\":\"secondarytable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e8\",\"source\":\"n-loading-spatialjoin\",\"target\":\"n-loading-groupby\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"}],\"variables\":[{\"name\":\"date_from\",\"type\":\"String\",\"order\":0,\"value\":\"2025-07-01\",\"scopes\":[],\"helperText\":\"First month to count, as YYYY-MM-DD (use the first day of a month). Data covers 2025-07-01 to 2026-06-30.\",\"displayName\":\"Start date\"},{\"name\":\"date_to\",\"type\":\"String\",\"order\":1,\"value\":\"2026-06-30\",\"scopes\":[],\"helperText\":\"Last month to count, as YYYY-MM-DD.\",\"displayName\":\"End date\"}],\"procedure\":{},\"schedule\":{},\"viewport\":{\"x\":132.61217312659812,\"y\":28.034765519758537,\"zoom\":0.41974591403858186},\"schemaVersion\":\"1.0.0\",\"connectionProvider\":\"bigquery\",\"useCache\":false,\"mcpTool\":{\"id\":\"\",\"name\":\"\",\"draft\":{\"name\":\"\",\"inputs\":{},\"output\":{\"description\":\"\"},\"description\":\"\"},\"inputs\":[],\"output\":{\"method\":\"GET\",\"payload\":{\"q\":\"\",\"query\":\"\",\"queryParameters\":[]},\"endpoint\":\"\",\"description\":\"\"},\"enabled\":false,\"procedure\":null,\"description\":\"\"},\"viewerMode\":{},\"executionSettings\":{\"cacheModes\":{\"api\":false,\"mcp\":false,\"editor\":false,\"viewer\":false}}}"}
  */
  DECLARE `date_from` STRING DEFAULT '2025-07-01';
  DECLARE `date_to` STRING DEFAULT '2026-06-30';
  BEGIN
  CALL `carto-un.carto`.IMPORT_URL(
    'https://gcp-us-east1.api.carto.com',
    'API_ACCESS_TOKEN_REMOVED',
    'https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/violations_fy2026_by_precinct_month.csv',
    'carto_dw',
    'YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_cc7bbcb1a1e34055_result',
    '{"autoguessing": true}'
  );
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_eaaa9edc4e7d9f22_result`
  AS
    SELECT * FROM UNNEST(ARRAY<STRUCT<precinct STRING, population INT64>>[('1', 80892), ('5', 45946), ('6', 62800), ('7', 57405), ('9', 67739), ('10', 48183), ('13', 99451), ('14', 29357), ('17', 67132), ('18', 48161)]);
  END;
  BEGIN
  CALL `carto-un.carto`.IMPORT_URL(
    'https://gcp-us-east1.api.carto.com',
    'API_ACCESS_TOKEN_REMOVED',
    'https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/precincts_study_area.geojson',
    'carto_dw',
    'YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_7ee368c2a78e56dc_result',
    '{"autoguessing": true}'
  );
  END;
  BEGIN
  CALL `carto-un.carto`.IMPORT_URL(
    'https://gcp-us-east1.api.carto.com',
    'API_ACCESS_TOKEN_REMOVED',
    'https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/loading_zone_signs_manhattan.csv',
    'carto_dw',
    'YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_670768b8a2195d5e_result',
    '{"autoguessing": true}'
  );
  END;
  EXECUTE IMMEDIATE
    '''CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_d10e489e5156dab6_match`
    AS
      SELECT *
      FROM `YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_7ee368c2a78e56dc_result`
      WHERE CAST(precinct AS STRING) IN (\'1\',\'5\',\'6\',\'7\',\'9\',\'10\',\'13\',\'14\',\'17\',\'18\')'''
  ;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_dfd28c1ee24db4d7_result`
  AS
    WITH p AS (
      SELECT order_number, on_street, from_street, to_street, sign_description,
        SAFE_CAST(sign_x_coord AS FLOAT64) * 0.3048006096012192 - 300000.0 AS dx,
        7462536.301142955 - SAFE_CAST(sign_y_coord AS FLOAT64) * 0.3048006096012192 AS dy
      FROM `YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_670768b8a2195d5e_result`
      WHERE SAFE_CAST(sign_x_coord AS FLOAT64) IS NOT NULL AND SAFE_CAST(sign_y_coord AS FLOAT64) IS NOT NULL
    ), r AS (
      SELECT *, POW(SQRT(dx*dx + dy*dy) / 12287232.615120513, 1.0/0.6540820912037886) AS t, ATAN2(dx, dy)/0.6540820912037886 + (-1.2915436464758039) AS lam FROM p
    ), s_p0 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t) AS p0 FROM r),
    s_p1 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p0))/(1+0.08181919104281579*SIN(p0)), 0.08181919104281579/2)) AS p1 FROM s_p0),
    s_p2 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p1))/(1+0.08181919104281579*SIN(p1)), 0.08181919104281579/2)) AS p2 FROM s_p1),
    s_p3 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p2))/(1+0.08181919104281579*SIN(p2)), 0.08181919104281579/2)) AS p3 FROM s_p2),
    s_p4 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p3))/(1+0.08181919104281579*SIN(p3)), 0.08181919104281579/2)) AS p4 FROM s_p3)
    SELECT order_number, on_street, from_street, to_street, sign_description,
      CASE WHEN UPPER(sign_description) LIKE '%TRUCK%' THEN 'Truck Loading Zone'
           WHEN UPPER(sign_description) LIKE '%NLZ%' OR UPPER(sign_description) LIKE '%NEIGHBORHOOD LOADING%' THEN 'Neighborhood Loading Zone'
           WHEN UPPER(sign_description) LIKE '%HOTEL%' THEN 'Hotel Loading Zone'
           ELSE 'Other Loading Zone' END AS zone_type,
      ST_GEOGPOINT(lam*180/ACOS(-1), p4*180/ACOS(-1)) AS geom
    FROM s_p4;
  END;
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_8c9e74f443e1d888_result`
  AS
    WITH
    cte_1 AS (
      SELECT *
      FROM `YOUR_PROJECT.workflows_temp.WORKFLOW_b11b9e4a17029d76_cc7bbcb1a1e34055_result`
      WHERE CAST(violation_code AS INT64) IN (11,14,16,31,46,47,89) AND CAST(month AS TIMESTAMP) >= CAST(`date_from` AS TIMESTAMP) AND CAST(month AS TIMESTAMP) <= CAST(`date_to` AS TIMESTAMP)
    )
    SELECT violation_precinct,
      SUM(violations) violations_sum
    FROM cte_1
    GROUP BY violation_precinct;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_4514f9598aca5d7f_result`
  AS
    SELECT
      _main.order_number AS order_number, _joined.precinct AS precinct
    FROM
      `WORKFLOW_b11b9e4a17029d76_dfd28c1ee24db4d7_result` AS _main
    INNER JOIN
      `WORKFLOW_b11b9e4a17029d76_d10e489e5156dab6_match` AS _joined
    ON
      ST_INTERSECTS(
        _main.geom,
        _joined.geom
      );
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_cd8887aaff4562b9_result`
  AS
    SELECT * REPLACE (SAFE_CAST(violation_precinct
    AS STRING) AS violation_precinct)
    FROM `WORKFLOW_b11b9e4a17029d76_8c9e74f443e1d888_result`;
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_b1ff01053e1562d1_result`
  AS
    SELECT precinct,
      COUNT(order_number) order_number_count
    FROM `WORKFLOW_b11b9e4a17029d76_4514f9598aca5d7f_result`
    GROUP BY precinct;
  END;
END;