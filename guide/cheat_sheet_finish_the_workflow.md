# Cheat sheet: finish the workflow

You start from `1_last_mile_START_HERE.sql`. The last node on the canvas is `3. Supply per 1k`. Add these three nodes after it. To add a node, drag it from the **Components** tab onto the canvas (or search for it), then drag a connection from the output of the previous node to its input.

Run the whole workflow once before you start, so the earlier steps are already calculated.

## Node 1: Composite Score Unsupervised

Rename it `3. Priority index` (double click the title).

| Setting | Value |
| --- | --- |
| Input | output of `3. Supply per 1k` |
| Column with unique geographic identifier | `precinct` |
| Scoring method | `CUSTOM_WEIGHTS` |
| Variables and weights | Pick `demand_per_1k` and `loading_per_1k`, each with weight 1. Leave `demand_per_1k` on **Direct** and switch `loading_per_1k` to **Inverse** |
| Scaling function | `MIN_MAX_SCALER` |
| Aggregation function | `LINEAR` |
| Output formatting | `RETURN_RANGE`, from 0 to 100 |

The variable list only shows your columns once the previous nodes have run, so run the workflow once before you configure this node.

**Why inverse?** More loading zones per resident means less pressure, so that variable has to push the score down, not up. Direct means a higher value raises the score. Inverse means a higher value lowers it.

## Node 2: Join

Rename it `3. Attach index`.

| Setting | Value |
| --- | --- |
| Left table | output of `3. Supply per 1k` |
| Right table | output of `3. Priority index` |
| Key column in both tables | `precinct` |
| Join type | Left |
| Left table columns to keep | `precinct`, `geom`, `population`, `violations`, `loading_supply`, `demand_per_1k`, `loading_per_1k` |
| Right table columns to keep | `spatial_score`, renamed to `priority_index` |

## Node 3: Create Builder Map

Rename it `4. Create map`.

| Setting | Value |
| --- | --- |
| Sources | connect two nodes: `3. Attach index` (the precincts with the score) and `1. Convert coordinates` (the loading zone points) |
| Map name | `The Last Mile: NYC Delivery Pressure` |
| Re-running mode | Update |

Run the workflow. When it finishes, open the map from the link on the node.

## Check your result

With the default settings the ranking should be:

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

If your numbers differ, check that the `precinct` column is used as the key and that `loading_per_1k` is set to Inverse.
