# Data

The workflows read these three files straight from this repo (through the raw file links), so nothing needs to be uploaded or downloaded by hand. They are snapshots of public NYC Open Data, prepared so the workshop does not depend on live servers.

| File | Rows | What it is |
| --- | --- | --- |
| `violations_fy2026_by_precinct_month.csv` | 689 | Parking tickets issued to commercial plates, counted by precinct, violation code and month |
| `precincts_study_area.geojson` | 10 | Boundaries of the 10 NYPD precincts in Manhattan below 60th Street |
| `loading_zone_signs_manhattan.csv` | 2,621 | NYC DOT parking signs in Manhattan that mention loading |

## Fields

**violations_fy2026_by_precinct_month.csv**
`violation_precinct` (precinct number), `violation_code` (NYC violation code), `month` (first day of the month), `violations` (number of tickets).

**precincts_study_area.geojson**
`precinct` (precinct number as text) and the polygon geometry.

**loading_zone_signs_manhattan.csv**
`order_number` (sign id), `on_street`, `from_street`, `to_street`, `sign_description`, `sign_x_coord` and `sign_y_coord` (location in the New York Long Island state plane system, EPSG:2263, in feet). The workflow converts them to longitude and latitude.

## How the files were prepared

- **Tickets:** NYC Open Data "Parking Violations Issued, Fiscal Year 2026" (dataset `9mwx-gamw`). Filters: commercial plates (`plate_type = COM`), county NY or MN, violation codes 11, 14, 16, 31, 46, 47 and 89 (double parking, no standing and similar curb violations), the 10 study precincts, issue dates from 2025-07-01 to 2026-06-30. Counted by precinct, code and month in the source query, so the file is small.
- **Precincts:** NYC Open Data "Police Precincts" (dataset `y76i-bdw7`), filtered to precincts 1, 5, 6, 7, 9, 10, 13, 14, 17 and 18.
- **Loading zone signs:** NYC DOT "Parking Regulation Locations and Signs" (dataset `nfid-uabd`), current records in Manhattan whose description contains LOAD.
- **Population:** US Census 2020 population per precinct. It is a small table typed directly into the workflow (node `1. Population by precinct`), so there is no file for it.

## Credits

NYC Open Data (City of New York), NYC DOT and the US Census Bureau. These datasets are published as open data by their owners. Check the original portals for current terms.
