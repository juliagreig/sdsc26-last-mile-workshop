# Cheat sheet: finish the workflow

You start from `1_last_mile_START_HERE.sql`. The last node on the canvas is `3. Supply per 1k`. Add these three nodes after it, inside the purple **Your turn** panel. To add a node, drag it from the **Components** tab onto the canvas (or search for it), then drag a connection from the output of the previous node to its input.

Run the whole workflow once before you start, so the earlier steps are already calculated.

## Node 1: Composite Score Unsupervised

Search the Components tab for `composite score` and pick **Composite Score Unsupervised** (not Supervised). Rename it `3. Priority index` (double click the title).

| Setting | Value |
| --- | --- |
| Input | output of `3. Supply per 1k` |
| Column with unique geographic identifier | `geoid` (the only column the list offers) |
| Scoring method | `CUSTOM_WEIGHTS` |
| Variables and weights | `demand_per_1k` weight 1, left on **Direct**. `loading_per_1k` weight 1, switched to **Inverse** (hover the row and click the arrow next to it). Set `population`, `violations` and `loading_supply` to weight **0** so they do not count |
| Scaling function | `MIN_MAX_SCALER` (already selected) |
| Aggregation function | `LINEAR` (already selected) |
| Output formatting | `RETURN_RANGE`, then set the range from 0 to 100 (the Max box starts at 1) |

The variable list only shows your columns once the previous nodes have run, so run the workflow once before you configure this node. Only the two rates should count: if you forget to zero the other columns the ranking changes.

**Why these settings?**

- **Identifier column `geoid`:** the node needs a column that names the area each row describes. It only accepts a column called `geoid`, `h3`, `quadbin` or `index`, so the precinct number was renamed `geoid` earlier in the workflow (in `3. Add population`). If the list is empty, check that you imported the latest file.
- **CUSTOM_WEIGHTS:** you decide how much each variable counts (the other methods let the data decide).
- **Weights 0 and 1:** a weight of 0 takes a column out of the score. Population, violations and loading_supply are raw counts that would reward big precincts, so only the two rates per 1,000 residents count.
- **MIN_MAX_SCALER:** squeezes each variable onto the same 0 to 1 scale, so tickets per 1,000 (thousands) do not drown out loading zones per 1,000 (single digits).
- **LINEAR:** combines the scaled variables as a weighted average.
- **RETURN_RANGE 0 to 100:** stretches the final score so the lowest precinct is 0 and the highest 100.

**Why inverse?** More loading zones per resident means less pressure, so that variable has to push the score down, not up. Direct means a higher value raises the score. Inverse means a higher value lowers it.

## Node 2: Join

Rename it `3. Attach index`.

| Setting | Value |
| --- | --- |
| Left table | output of `3. Supply per 1k` |
| Right table | output of `3. Priority index` |
| Key column in left table | `geoid` |
| Key column in right table | `geoid` (the list starts on `spatial_score`: change it) |
| Join type | `Left` (it starts on Inner) |
| Left table columns to keep | all seven: `geoid`, `geom`, `population`, `violations`, `loading_supply`, `demand_per_1k`, `loading_per_1k` (tick **Select all**, press **Add**) |
| Right table columns to keep | `spatial_score` only, renamed to `priority_index` |

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

If your numbers differ, check that both keys are `geoid` and that `loading_per_1k` is set to Inverse.

## If the score node says UNEXECUTABLE

"No value assigned" and an empty identifier list mean the table has no column called `geoid`. Check that the node is connected to `3. Supply per 1k` and that you imported the latest start file. A run that fails with "Retrying may solve the problem" just needs another click on Run.
