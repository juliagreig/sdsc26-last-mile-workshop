-- WARNING: This procedure requires the Analytics Toolbox and assumes it will be located
-- at the following path: carto-un.carto. If you want to deploy and
-- run it in a different location, you will need to update the code accordingly.
CREATE OR REPLACE PROCEDURE
  `YOUR_PROJECT.workflows_temp.wfproc_last_mile`(
)
BEGIN
  /*
   {"diagramJson":"{\"title\":\"The Last Mile: NYC Delivery Pressure (start here)\",\"description\":\"SDSC 2026 workshop, start here. Data loading, measuring and per resident rates are done. Add three nodes: Priority index, Attach index and Create map.\",\"nodes\":[{\"id\":\"imp-violations\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import violations\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/violations_fy2026_by_precinct_month.csv\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":280},\"selected\":false},{\"id\":\"imp-precincts\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import precincts\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/precincts_study_area.geojson\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":440},\"selected\":false},{\"id\":\"imp-loading\",\"data\":{\"name\":\"native.importurl\",\"label\":\"Import from URL\",\"title\":\"1. Import loading zones\",\"inputs\":[{\"name\":\"url\",\"type\":\"String\",\"title\":\"Source URL\",\"placeholder\":\"E.g.: https://storage.googleapis.com/carto_test_tables/places.zip\",\"description\":\"Source URL\",\"value\":\"https://raw.githubusercontent.com/juliagreig/sdsc26-last-mile-workshop/main/data/loading_zone_signs_manhattan.csv\"},{\"name\":\"autoguessing\",\"type\":\"Boolean\",\"title\":\"Automatically guess column data types in the imported table\",\"default\":true,\"description\":\"Automatically guess column data types in the imported table\",\"value\":true}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":760},\"selected\":false},{\"id\":\"n-population\",\"data\":{\"name\":\"native.customsql\",\"label\":\"Custom SQL Select\",\"title\":\"1. Population by precinct\",\"inputs\":[{\"name\":\"sourcea\",\"type\":\"Table\",\"title\":\"Source table a\",\"optional\":true,\"description\":\"Source table a\",\"value\":null},{\"name\":\"sourceb\",\"type\":\"Table\",\"title\":\"Source table b\",\"optional\":true,\"description\":\"Source table b\",\"value\":null},{\"name\":\"sourcec\",\"type\":\"Table\",\"title\":\"Source table c\",\"optional\":true,\"description\":\"Source table c\",\"value\":null},{\"name\":\"sql\",\"type\":\"StringSql\",\"title\":\"SQL SELECT statement\",\"mode\":\"multiline\",\"placeholder\":\"SELECT ST_Centroid(geom) AS geom,\\n  AVG(value) AS average_value,\\n  category\\nFROM $a\\nGROUP BY category\",\"allowExpressions\":false,\"description\":\"SQL SELECT statement\",\"value\":\"SELECT * FROM UNNEST(ARRAY<STRUCT<precinct STRING, population INT64>>[('1', 80892), ('5', 45946), ('6', 62800), ('7', 57405), ('9', 67739), ('10', 48183), ('13', 99451), ('14', 29357), ('17', 67132), ('18', 48161)])\"}],\"version\":\"2.0.0\"},\"type\":\"generic\",\"position\":{\"x\":80,\"y\":600},\"selected\":false},{\"id\":\"n-loading-reproject\",\"data\":{\"name\":\"native.customsql\",\"label\":\"Custom SQL Select\",\"title\":\"1. Convert coordinates\",\"inputs\":[{\"name\":\"sourcea\",\"type\":\"Table\",\"title\":\"Source table a\",\"optional\":true,\"description\":\"Source table a\",\"value\":null},{\"name\":\"sourceb\",\"type\":\"Table\",\"title\":\"Source table b\",\"optional\":true,\"description\":\"Source table b\",\"value\":null},{\"name\":\"sourcec\",\"type\":\"Table\",\"title\":\"Source table c\",\"optional\":true,\"description\":\"Source table c\",\"value\":null},{\"name\":\"sql\",\"type\":\"StringSql\",\"title\":\"SQL SELECT statement\",\"mode\":\"multiline\",\"placeholder\":\"SELECT ST_Centroid(geom) AS geom,\\n  AVG(value) AS average_value,\\n  category\\nFROM $a\\nGROUP BY category\",\"allowExpressions\":false,\"description\":\"SQL SELECT statement\",\"value\":\"WITH p AS (\\n  SELECT order_number, on_street, from_street, to_street, sign_description,\\n    SAFE_CAST(sign_x_coord AS FLOAT64) * 0.3048006096012192 - 300000.0 AS dx,\\n    7462536.301142955 - SAFE_CAST(sign_y_coord AS FLOAT64) * 0.3048006096012192 AS dy\\n  FROM `$a`\\n  WHERE SAFE_CAST(sign_x_coord AS FLOAT64) IS NOT NULL AND SAFE_CAST(sign_y_coord AS FLOAT64) IS NOT NULL\\n), r AS (\\n  SELECT *, POW(SQRT(dx*dx + dy*dy) / 12287232.615120513, 1.0/0.6540820912037886) AS t, ATAN2(dx, dy)/0.6540820912037886 + (-1.2915436464758039) AS lam FROM p\\n), s_p0 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t) AS p0 FROM r),\\ns_p1 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p0))/(1+0.08181919104281579*SIN(p0)), 0.08181919104281579/2)) AS p1 FROM s_p0),\\ns_p2 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p1))/(1+0.08181919104281579*SIN(p1)), 0.08181919104281579/2)) AS p2 FROM s_p1),\\ns_p3 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p2))/(1+0.08181919104281579*SIN(p2)), 0.08181919104281579/2)) AS p3 FROM s_p2),\\ns_p4 AS (SELECT *, ACOS(-1)/2 - 2*ATAN(t*POW((1-0.08181919104281579*SIN(p3))/(1+0.08181919104281579*SIN(p3)), 0.08181919104281579/2)) AS p4 FROM s_p3)\\nSELECT order_number, on_street, from_street, to_street, sign_description,\\n  CASE WHEN UPPER(sign_description) LIKE '%TRUCK%' THEN 'Truck Loading Zone'\\n       WHEN UPPER(sign_description) LIKE '%NLZ%' OR UPPER(sign_description) LIKE '%NEIGHBORHOOD LOADING%' THEN 'Neighborhood Loading Zone'\\n       WHEN UPPER(sign_description) LIKE '%HOTEL%' THEN 'Hotel Loading Zone'\\n       ELSE 'Other Loading Zone' END AS zone_type,\\n  ST_GEOGPOINT(lam*180/ACOS(-1), p4*180/ACOS(-1)) AS geom\\nFROM s_p4\"}],\"version\":\"2.0.0\"},\"type\":\"generic\",\"position\":{\"x\":272,\"y\":760},\"selected\":false},{\"id\":\"n-precinct-filter\",\"data\":{\"name\":\"native.where\",\"label\":\"Where\",\"title\":\"2. Study area precincts\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Filter expression\",\"placeholder\":\"E.g.: area > 1000 AND area < 3000\",\"description\":\"Filter expression\",\"value\":\"CAST(precinct AS STRING) IN ('1','5','6','7','9','10','13','14','17','18')\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":440},\"selected\":false},{\"id\":\"n-violation-filter\",\"data\":{\"name\":\"native.where\",\"label\":\"Where\",\"title\":\"2. Filter codes and dates\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Filter expression\",\"placeholder\":\"E.g.: area > 1000 AND area < 3000\",\"description\":\"Filter expression\",\"value\":\"CAST(violation_code AS INT64) IN (11,14,16,31,46,47,89) AND CAST(month AS TIMESTAMP) >= CAST(@date_from AS TIMESTAMP) AND CAST(month AS TIMESTAMP) <= CAST(@date_to AS TIMESTAMP)\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":280},\"selected\":false},{\"id\":\"n-violation-groupby\",\"data\":{\"name\":\"native.groupby\",\"label\":\"Group by\",\"title\":\"2. Count by precinct\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"columns\",\"type\":\"SelectColumnAggregation\",\"title\":\"Aggregation\",\"parent\":\"source\",\"placeholder\":\"workflows.parameterForm.selectAField\",\"allowExpression\":false,\"description\":\"Aggregation\",\"value\":\"violations,sum\"},{\"name\":\"groupby\",\"type\":\"Column\",\"title\":\"Group by\",\"parent\":\"source\",\"mode\":\"multiple\",\"dataType\":[\"boolean\",\"number\",\"string\",\"date\",\"datetime\",\"time\",\"timestamp\"],\"noDefault\":true,\"maxSelectionsCount\":null,\"description\":\"Group by\",\"value\":\"violation_precinct\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":656,\"y\":280},\"selected\":false},{\"id\":\"n-violation-cast\",\"data\":{\"name\":\"native.cast\",\"label\":\"Cast\",\"title\":\"2. Precinct as text\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"optional\":true,\"description\":\"Source table\",\"value\":null},{\"name\":\"column\",\"type\":\"Column\",\"title\":\"Column\",\"parent\":\"source\",\"dataType\":[\"number\",\"string\",\"boolean\",\"date\",\"time\",\"datetime\",\"timestamp\",\"binary\"],\"providers\":[\"bigquery\",\"snowflake\",\"redshift\",\"postgres\",\"oracle\",\"databricksWarehouse\"],\"description\":\"Column\",\"value\":\"violation_precinct\"},{\"name\":\"newtype\",\"type\":\"SelectionType\",\"title\":\"New type\",\"parent\":\"column\",\"providers\":[\"bigquery\",\"snowflake\",\"redshift\",\"postgres\",\"oracle\",\"databricksWarehouse\"],\"description\":\"New type\",\"value\":\"STRING\"}],\"version\":\"2\"},\"type\":\"generic\",\"position\":{\"x\":848,\"y\":280},\"selected\":false},{\"id\":\"n-loading-spatialjoin\",\"data\":{\"name\":\"native.spatialjoin\",\"label\":\"Spatial Join\",\"title\":\"2. Zones in precincts\",\"inputs\":[{\"name\":\"maintable\",\"type\":\"Table\",\"title\":\"Left table\",\"description\":\"Left table\",\"value\":null},{\"name\":\"secondarytable\",\"type\":\"Table\",\"title\":\"Right table\",\"description\":\"Right table\",\"value\":null},{\"name\":\"maintablejoincolumn\",\"type\":\"Column\",\"parent\":\"maintable\",\"title\":\"Key geo column in left table\",\"dataType\":[\"geography\"],\"description\":\"Key geo column in left table\",\"value\":\"geom\"},{\"name\":\"maintablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Left table columns\",\"parent\":\"maintable\",\"optional\":true,\"description\":\"Left table columns\",\"value\":\"[{\\\"name\\\": \\\"order_number\\\", \\\"joinname\\\": \\\"order_number\\\"}]\"},{\"name\":\"secondarytablejoincolumn\",\"type\":\"Column\",\"parent\":\"secondarytable\",\"title\":\"Key geo column in right table\",\"dataType\":[\"geography\"],\"description\":\"Key geo column in right table\",\"value\":\"geom\"},{\"name\":\"secondarytablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Right table columns\",\"parent\":\"secondarytable\",\"optional\":true,\"description\":\"Right table columns\",\"value\":\"[{\\\"name\\\": \\\"precinct\\\", \\\"joinname\\\": \\\"precinct\\\"}]\"},{\"name\":\"jointype\",\"type\":\"Selection\",\"title\":\"Join type\",\"default\":\"inner\",\"options\":[\"inner\",\"left\",\"right\",\"full\"],\"description\":\"Join type\",\"value\":\"inner\"},{\"name\":\"predicate\",\"type\":\"Selection\",\"title\":\"Spatial predicate\",\"default\":\"intersects\",\"optional\":true,\"options\":[\"intersects\",\"contains\",\"touches\",\"covers\"],\"description\":\"Spatial predicate\",\"value\":\"intersects\"}],\"version\":\"2\"},\"type\":\"generic\",\"position\":{\"x\":464,\"y\":760},\"selected\":false},{\"id\":\"n-loading-groupby\",\"data\":{\"name\":\"native.groupby\",\"label\":\"Group by\",\"title\":\"2. Count zones by precinct\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"columns\",\"type\":\"SelectColumnAggregation\",\"title\":\"Aggregation\",\"parent\":\"source\",\"placeholder\":\"workflows.parameterForm.selectAField\",\"allowExpression\":false,\"description\":\"Aggregation\",\"value\":\"order_number,count\"},{\"name\":\"groupby\",\"type\":\"Column\",\"title\":\"Group by\",\"parent\":\"source\",\"mode\":\"multiple\",\"dataType\":[\"boolean\",\"number\",\"string\",\"date\",\"datetime\",\"time\",\"timestamp\"],\"noDefault\":true,\"maxSelectionsCount\":null,\"description\":\"Group by\",\"value\":\"precinct\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":656,\"y\":760},\"selected\":false},{\"id\":\"n-join-pop\",\"data\":{\"name\":\"native.joinv2\",\"label\":\"Join\",\"title\":\"3. Add population\",\"inputs\":[{\"name\":\"lefttable\",\"type\":\"Table\",\"title\":\"Left table\",\"description\":\"Left table\",\"value\":null},{\"name\":\"righttable\",\"type\":\"Table\",\"title\":\"Right table\",\"description\":\"Right table\",\"value\":null},{\"name\":\"lefttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in left table\",\"parent\":\"lefttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in left table\",\"value\":\"precinct\"},{\"name\":\"lefttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Left table columns\",\"parent\":\"lefttable\",\"optional\":true,\"description\":\"Left table columns\",\"value\":\"[{\\\"name\\\": \\\"precinct\\\", \\\"joinname\\\": \\\"geoid\\\"}, {\\\"name\\\": \\\"geom\\\", \\\"joinname\\\": \\\"geom\\\"}]\"},{\"name\":\"righttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in right table\",\"parent\":\"righttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in right table\",\"value\":\"precinct\"},{\"name\":\"righttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Right table columns\",\"parent\":\"righttable\",\"optional\":true,\"description\":\"Right table columns\",\"value\":\"[{\\\"name\\\": \\\"population\\\", \\\"joinname\\\": \\\"population\\\"}]\"},{\"name\":\"jointype\",\"type\":\"Selection\",\"title\":\"Join type\",\"options\":[\"Inner\",\"Left\",\"Right\",\"Full outer\"],\"default\":\"Inner\",\"description\":\"Join type\",\"value\":\"Left\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":1088,\"y\":440},\"selected\":false},{\"id\":\"n-join-violations\",\"data\":{\"name\":\"native.joinv2\",\"label\":\"Join\",\"title\":\"3. Add violations\",\"inputs\":[{\"name\":\"lefttable\",\"type\":\"Table\",\"title\":\"Left table\",\"description\":\"Left table\",\"value\":null},{\"name\":\"righttable\",\"type\":\"Table\",\"title\":\"Right table\",\"description\":\"Right table\",\"value\":null},{\"name\":\"lefttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in left table\",\"parent\":\"lefttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in left table\",\"value\":\"geoid\"},{\"name\":\"lefttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Left table columns\",\"parent\":\"lefttable\",\"optional\":true,\"description\":\"Left table columns\",\"value\":\"[{\\\"name\\\": \\\"geoid\\\", \\\"joinname\\\": \\\"geoid\\\"}, {\\\"name\\\": \\\"geom\\\", \\\"joinname\\\": \\\"geom\\\"}, {\\\"name\\\": \\\"population\\\", \\\"joinname\\\": \\\"population\\\"}]\"},{\"name\":\"righttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in right table\",\"parent\":\"righttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in right table\",\"value\":\"violation_precinct\"},{\"name\":\"righttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Right table columns\",\"parent\":\"righttable\",\"optional\":true,\"description\":\"Right table columns\",\"value\":\"[{\\\"name\\\": \\\"violations_sum\\\", \\\"joinname\\\": \\\"violations\\\"}]\"},{\"name\":\"jointype\",\"type\":\"Selection\",\"title\":\"Join type\",\"options\":[\"Inner\",\"Left\",\"Right\",\"Full outer\"],\"default\":\"Inner\",\"description\":\"Join type\",\"value\":\"Left\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":1280,\"y\":440},\"selected\":false},{\"id\":\"n-join-supply\",\"data\":{\"name\":\"native.joinv2\",\"label\":\"Join\",\"title\":\"3. Add loading zones\",\"inputs\":[{\"name\":\"lefttable\",\"type\":\"Table\",\"title\":\"Left table\",\"description\":\"Left table\",\"value\":null},{\"name\":\"righttable\",\"type\":\"Table\",\"title\":\"Right table\",\"description\":\"Right table\",\"value\":null},{\"name\":\"lefttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in left table\",\"parent\":\"lefttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in left table\",\"value\":\"geoid\"},{\"name\":\"lefttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Left table columns\",\"parent\":\"lefttable\",\"optional\":true,\"description\":\"Left table columns\",\"value\":\"[{\\\"name\\\": \\\"geoid\\\", \\\"joinname\\\": \\\"geoid\\\"}, {\\\"name\\\": \\\"geom\\\", \\\"joinname\\\": \\\"geom\\\"}, {\\\"name\\\": \\\"population\\\", \\\"joinname\\\": \\\"population\\\"}, {\\\"name\\\": \\\"violations\\\", \\\"joinname\\\": \\\"violations\\\"}]\"},{\"name\":\"righttablekeycolumn\",\"type\":\"Column\",\"title\":\"Key column in right table\",\"parent\":\"righttable\",\"dataType\":[\"boolean\",\"date\",\"datetime\",\"time\",\"timestamp\",\"number\",\"string\"],\"description\":\"Key column in right table\",\"value\":\"precinct\"},{\"name\":\"righttablecolumns\",\"type\":\"ColumnsForJoin\",\"title\":\"Right table columns\",\"parent\":\"righttable\",\"optional\":true,\"description\":\"Right table columns\",\"value\":\"[{\\\"name\\\": \\\"order_number_count\\\", \\\"joinname\\\": \\\"loading_supply\\\"}]\"},{\"name\":\"jointype\",\"type\":\"Selection\",\"title\":\"Join type\",\"options\":[\"Inner\",\"Left\",\"Right\",\"Full outer\"],\"default\":\"Inner\",\"description\":\"Join type\",\"value\":\"Left\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":1472,\"y\":440},\"selected\":false},{\"id\":\"n-create-demand\",\"data\":{\"name\":\"native.selectexpression\",\"label\":\"Create Column\",\"title\":\"3. Demand per 1k\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"column\",\"type\":\"String\",\"title\":\"Name for new column\",\"placeholder\":\"E.g.: distance_in_meters\",\"validation\":\"^[a-zA-Z_][a-zA-Z0-9_]*$\",\"allowExpressions\":false,\"description\":\"Name for new column\",\"value\":\"demand_per_1k\"},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Expression\",\"placeholder\":\"E.g.: distance_in_km * 1000\",\"description\":\"Expression\",\"value\":\"violations / population * 1000\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":1664,\"y\":440},\"selected\":false},{\"id\":\"n-create-supply-ratio\",\"data\":{\"name\":\"native.selectexpression\",\"label\":\"Create Column\",\"title\":\"3. Supply per 1k\",\"inputs\":[{\"name\":\"source\",\"type\":\"Table\",\"title\":\"Source table\",\"description\":\"Source table\",\"value\":null},{\"name\":\"column\",\"type\":\"String\",\"title\":\"Name for new column\",\"placeholder\":\"E.g.: distance_in_meters\",\"validation\":\"^[a-zA-Z_][a-zA-Z0-9_]*$\",\"allowExpressions\":false,\"description\":\"Name for new column\",\"value\":\"loading_per_1k\"},{\"name\":\"expression\",\"type\":\"StringSql\",\"title\":\"Expression\",\"placeholder\":\"E.g.: distance_in_km * 1000\",\"description\":\"Expression\",\"value\":\"COALESCE(loading_supply, 0) / population * 1000\"}],\"version\":\"1\"},\"type\":\"generic\",\"position\":{\"x\":1856,\"y\":440},\"selected\":false},{\"id\":\"9b6c4442-44a3-5d5e-97cd-af14c89d57fe\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":40,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#F6CF71\",\"genAi\":false,\"label\":\"\",\"width\":360,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## 1 · Load\\nWe bring in three open datasets: parking tickets for commercial vehicles, precinct boundaries and loading zone signs. A small table adds how many people live in each precinct. Sign locations are converted into map coordinates.\"},\"selected\":false},{\"id\":\"9444fa42-1eef-5fc5-9f89-0bbe9cbd22dc\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":420,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#9EB9F3\",\"genAi\":false,\"label\":\"\",\"width\":540,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## 2 · Measure\\nWe count what happens in each precinct: how many tickets were issued (demand) and how many legal loading zones exist (supply). Filters keep only our 10 precincts and the dates we care about. Change date_from and date_to in Variables to move the time window.\"},\"selected\":false},{\"id\":\"a4029d49-ccc9-5354-9db8-2f66ae8619e5\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":1000,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#8BE0A4\",\"genAi\":false,\"label\":\"\",\"width\":960,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## 3 · Combine and rate\\nEverything goes into one table with one row per precinct. Then we divide by population: tickets per 1,000 residents and loading zones per 1,000 residents. Now small and large precincts can be compared fairly.\"},\"selected\":false},{\"id\":\"bcf175da-6ecb-5910-93f4-990588b24a49\",\"type\":\"note\",\"zIndex\":-1,\"position\":{\"x\":2000,\"y\":40},\"data\":{\"name\":\"Note\",\"color\":\"#DCB0F2\",\"genAi\":false,\"label\":\"\",\"width\":710,\"height\":840,\"inputs\":[],\"markdown\":\"---\\nlabel:\\n---\\n## Your turn: add three nodes here\\n1. Priority index (Composite Score Unsupervised): combine demand and supply into one score.\\n2. Attach index (Join): add the score back to the precinct shapes.\\n3. Create map (Create Builder Map): build the map from your results.\\nThe exact settings are in the cheat sheet in the workshop repo.\"},\"selected\":false}],\"edges\":[{\"id\":\"e1\",\"source\":\"imp-loading\",\"target\":\"n-loading-reproject\",\"sourceHandle\":\"result\",\"targetHandle\":\"sourcea\",\"animated\":true,\"className\":\"\"},{\"id\":\"e2\",\"source\":\"imp-precincts\",\"target\":\"n-precinct-filter\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e3\",\"source\":\"imp-violations\",\"target\":\"n-violation-filter\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e4\",\"source\":\"n-violation-filter\",\"target\":\"n-violation-groupby\",\"sourceHandle\":\"match\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e5\",\"source\":\"n-violation-groupby\",\"target\":\"n-violation-cast\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e6\",\"source\":\"n-loading-reproject\",\"target\":\"n-loading-spatialjoin\",\"sourceHandle\":\"result\",\"targetHandle\":\"maintable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e7\",\"source\":\"n-precinct-filter\",\"target\":\"n-loading-spatialjoin\",\"sourceHandle\":\"match\",\"targetHandle\":\"secondarytable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e8\",\"source\":\"n-loading-spatialjoin\",\"target\":\"n-loading-groupby\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e9\",\"source\":\"n-precinct-filter\",\"target\":\"n-join-pop\",\"sourceHandle\":\"match\",\"targetHandle\":\"lefttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e10\",\"source\":\"n-population\",\"target\":\"n-join-pop\",\"sourceHandle\":\"result\",\"targetHandle\":\"righttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e11\",\"source\":\"n-join-pop\",\"target\":\"n-join-violations\",\"sourceHandle\":\"result\",\"targetHandle\":\"lefttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e12\",\"source\":\"n-violation-cast\",\"target\":\"n-join-violations\",\"sourceHandle\":\"result\",\"targetHandle\":\"righttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e13\",\"source\":\"n-join-violations\",\"target\":\"n-join-supply\",\"sourceHandle\":\"result\",\"targetHandle\":\"lefttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e14\",\"source\":\"n-loading-groupby\",\"target\":\"n-join-supply\",\"sourceHandle\":\"result\",\"targetHandle\":\"righttable\",\"animated\":true,\"className\":\"\"},{\"id\":\"e15\",\"source\":\"n-join-supply\",\"target\":\"n-create-demand\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"},{\"id\":\"e16\",\"source\":\"n-create-demand\",\"target\":\"n-create-supply-ratio\",\"sourceHandle\":\"result\",\"targetHandle\":\"source\",\"animated\":true,\"className\":\"\"}],\"variables\":[{\"name\":\"date_from\",\"type\":\"String\",\"order\":0,\"value\":\"2025-07-01\",\"scopes\":[],\"helperText\":\"First month to count, as YYYY-MM-DD (use the first day of a month). Data covers 2025-07-01 to 2026-06-30.\",\"displayName\":\"Start date\"},{\"name\":\"date_to\",\"type\":\"String\",\"order\":1,\"value\":\"2026-06-30\",\"scopes\":[],\"helperText\":\"Last month to count, as YYYY-MM-DD.\",\"displayName\":\"End date\"}],\"procedure\":{},\"schedule\":{},\"viewport\":{\"x\":132.61217312659812,\"y\":28.034765519758537,\"zoom\":0.41974591403858186},\"schemaVersion\":\"1.0.0\",\"connectionProvider\":\"bigquery\",\"useCache\":false,\"mcpTool\":{\"id\":\"\",\"name\":\"\",\"draft\":{\"name\":\"\",\"inputs\":{},\"output\":{\"description\":\"\"},\"description\":\"\"},\"inputs\":[],\"output\":{\"method\":\"GET\",\"payload\":{\"q\":\"\",\"query\":\"\",\"queryParameters\":[]},\"endpoint\":\"\",\"description\":\"\"},\"enabled\":false,\"procedure\":null,\"description\":\"\"},\"viewerMode\":{},\"executionSettings\":{\"cacheModes\":{\"api\":false,\"mcp\":false,\"editor\":false,\"viewer\":false}}}"}
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
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_dda0e192372d84d8_result`
  AS
    SELECT 
      _left.precinct AS geoid, _left.geom AS geom, _right.population AS population
    FROM
      `WORKFLOW_b11b9e4a17029d76_d10e489e5156dab6_match` AS _left
    LEFT JOIN
      `WORKFLOW_b11b9e4a17029d76_eaaa9edc4e7d9f22_result` AS _right
    ON
      _left.precinct = _right.precinct;
  END;
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
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_c4acb0eefa201e78_result`
  AS
    SELECT 
      _left.geoid AS geoid, _left.geom AS geom, _left.population AS population, _right.violations_sum AS violations
    FROM
      `WORKFLOW_b11b9e4a17029d76_dda0e192372d84d8_result` AS _left
    LEFT JOIN
      `WORKFLOW_b11b9e4a17029d76_cd8887aaff4562b9_result` AS _right
    ON
      _left.geoid = _right.violation_precinct;
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_62c1289420e8b589_result`
  AS
    SELECT 
      _left.geoid AS geoid, _left.geom AS geom, _left.population AS population, _left.violations AS violations, _right.order_number_count AS loading_supply
    FROM
      `WORKFLOW_b11b9e4a17029d76_c4acb0eefa201e78_result` AS _left
    LEFT JOIN
      `WORKFLOW_b11b9e4a17029d76_b1ff01053e1562d1_result` AS _right
    ON
      _left.geoid = _right.precinct;
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_6a42cda8136407a4_result`
  AS
    SELECT *,
      violations / population * 1000 AS demand_per_1k
    FROM `WORKFLOW_b11b9e4a17029d76_62c1289420e8b589_result`;
  END;
  BEGIN
  CREATE TEMPORARY TABLE `WORKFLOW_b11b9e4a17029d76_2b79a79087338274_result`
  AS
    SELECT *,
      COALESCE(loading_supply, 0) / population * 1000 AS loading_per_1k
    FROM `WORKFLOW_b11b9e4a17029d76_6a42cda8136407a4_result`;
  END;
END;