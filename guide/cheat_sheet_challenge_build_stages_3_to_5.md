# Cheat sheet: challenge track

You start from `3_last_mile_CHALLENGE.sql`. Loading and measuring are done (stages 1 and 2). You build stages 3, 4 and 5 inside the big purple **Your challenge** panel: 8 nodes in total.

To add a node, drag it from the **Components** tab onto the canvas (or search for it), then drag a connection from the output of the upstream node to its input. Double click a node title to rename it. Run the workflow once before you start, so the earlier steps are calculated and the column lists are available.

The upstream nodes you will connect are already on the canvas:

| Node on the canvas | What it gives you |
| --- | --- |
| `2. Study area precincts` | the 10 precinct shapes (`precinct`, `geom`) |
| `1. Population by precinct` | residents per precinct (`precinct`, `population`) |
| `2. Precinct as text` | tickets per precinct (`violation_precinct`, `violations_sum`) |
| `2. Count zones by precinct` | loading zones per precinct (`precinct`, `order_number_count`) |
| `1. Convert coordinates` | the loading zone points (used again for the map) |

## Stage 3: Combine and rate

Three Joins bring everything into one table with one row per precinct. Two Create Column nodes divide by population so small and large precincts can be compared fairly.

### Node 1: Join, called `3. Add population`

| Setting | Value |
| --- | --- |
| Left table | output of `2. Study area precincts` |
| Right table | output of `1. Population by precinct` |
| Key column in left table | `precinct` |
| Key column in right table | `precinct` |
| Join type | `Left` |
| Left table columns to keep | `precinct`, renamed to `geoid` (type the new name next to it), and `geom` |
| Right table columns to keep | `population` |

Why rename? The score node you add later only accepts an identifier column called `geoid`, `h3`, `quadbin` or `index`. Renaming once here means every node after it uses `geoid`.

### Node 2: Join, called `3. Add violations`

| Setting | Value |
| --- | --- |
| Left table | output of `3. Add population` |
| Right table | output of `2. Precinct as text` |
| Key column in left table | `geoid` |
| Key column in right table | `violation_precinct` (the name differs from the left key) |
| Join type | `Left` |
| Left table columns to keep | `geoid`, `geom`, `population` |
| Right table columns to keep | `violations_sum`, renamed to `violations` |

### Node 3: Join, called `3. Add loading zones`

| Setting | Value |
| --- | --- |
| Left table | output of `3. Add violations` |
| Right table | output of `2. Count zones by precinct` |
| Key column in left table | `geoid` |
| Key column in right table | `precinct` |
| Join type | `Left` |
| Left table columns to keep | `geoid`, `geom`, `population`, `violations` |
| Right table columns to keep | `order_number_count`, renamed to `loading_supply` |

### Node 4: Create Column, called `3. Demand per 1k`

| Setting | Value |
| --- | --- |
| Input | output of `3. Add loading zones` |
| Name for new column | `demand_per_1k` |
| Expression | `violations / population * 1000` |

### Node 5: Create Column, called `3. Supply per 1k`

| Setting | Value |
| --- | --- |
| Input | output of `3. Demand per 1k` |
| Name for new column | `loading_per_1k` |
| Expression | `COALESCE(loading_supply, 0) / population * 1000` |

`COALESCE` turns a missing value into 0, for a precinct with no loading zones at all.

Run the workflow and check the **Data** tab of `3. Supply per 1k`: 10 rows with `population`, `violations`, `loading_supply`, `demand_per_1k` and `loading_per_1k`.

## Stage 4: Score

Follow the same settings as in [the core cheat sheet](cheat_sheet_finish_the_workflow.md), starting after `3. Supply per 1k`:

- Node 6, Composite Score Unsupervised, called `3. Priority index`
- Node 7, Join, called `3. Attach index`

## Stage 5: Map

- Node 8, Create Builder Map, called `4. Create map` (sources: `3. Attach index` and `1. Convert coordinates`)

## Check your result

The ranking should be the same as in the core path:

| Precinct | priority_index |
| --- | --- |
| 13 | 100 |
| 14 | 87.8 |
| 7 | 87.8 |
| 9 | 85.9 |
| 6 | 85.1 |
| 10 | 67.7 |
| 18 | 47.0 |
| 17 | 45.9 |
| 1 | 18.5 |
| 5 | 0 |

If a count looks wrong, check the join keys (`violation_precinct` in the second Join) and that every Join is a **Left** join.
