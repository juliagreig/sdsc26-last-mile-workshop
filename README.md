# The Last Mile: Mapping NYC's Delivery Pressure Points

Hands-on workshop for SDSC 2026 New York. In about an hour you will go from open data to an interactive map with an AI agent, using a CARTO workflow.

**What you will build:** a score from 0 to 100 for 10 NYPD precincts in Manhattan below 60th Street. High scores mean delivery trucks get lots of parking tickets while legal loading zones are scarce.

## Before you start

You need a CARTO account. If you do not have one, sign up for a free trial at [app.carto.com](https://app.carto.com) (the workshop help desk can also set one up). Log in and check that you can see the **Workflows** and **Maps** sections in the left menu. Everything runs in the **CARTO Data Warehouse** that comes with your account, so there is nothing to install or connect.

## What is in this repo

| Path | What it is |
| --- | --- |
| `workflow/1_last_mile_START_HERE.sql` | The partial workflow. Data loading, measuring and per resident rates are done. You finish it live. |
| `workflow/2_last_mile_COMPLETE.sql` | The complete workflow. Import this one if you get stuck or want to see the end result. |
| `guide/cheat_sheet_finish_the_workflow.md` | Exact settings for the three nodes you add |
| `guide/prompts.md` | Text to copy and paste (AI agent prompt, starter questions, styling steps) |
| `data/` | The three source datasets (the workflows read them from this repo). Details in [data/README.md](data/README.md) |
| `workflow/advanced/` | The same workflows as JSON bundles for the CARTO CLI (optional) |

## Step by step

### 1. Import the workflow (about 3 minutes)

1. Download `workflow/1_last_mile_START_HERE.sql` from this repo (open the file, then use the download button).
2. In CARTO, go to **Workflows**. Click the import button next to **+ New workflow** (or drag the file onto the page).
3. Pick the **CARTO Data Warehouse** connection and create the workflow.

### 2. Run it (about 2 to 3 minutes)

Click **Run**. The workflow downloads the three datasets from this repo, counts parking tickets and loading zones in each precinct and calculates tickets and loading zones per 1,000 residents. While it runs, look at the stages on the canvas: the node titles start with 1 (load), 2 (measure) and 3 (per resident).

### 3. Finish the workflow together (about 10 minutes)

Add three nodes at the end of the workflow. Follow along on screen or use the [cheat sheet](guide/cheat_sheet_finish_the_workflow.md):

1. **Composite Score Unsupervised** called `3. Priority index`: combines demand and supply into one 0 to 100 score.
2. **Join** called `3. Attach index`: adds the score back to the precinct shapes.
3. **Create Builder Map** called `4. Create map`: builds the map from your results.

**Predict first:** which precinct do you think will rank number one? Write it down, then run the workflow.

### 4. Try two experiments

1. In **Variables**, set `date_from` to `2026-01-01` and run again. Does the ranking change?
2. Select the `3. Priority index` node, give `demand_per_1k` a weight of 2 and run again.

### 5. Style the map (about 10 minutes)

Open the map the workflow created (use the link on the Create Map node, or find it in **Maps**). Color the precincts by `priority_index`, restyle the loading zones and add a histogram widget. Steps are in [guide/prompts.md](guide/prompts.md).

### 6. Add an AI agent (about 10 minutes)

In your map open the **AI** tab, then the agent configuration. Use the Assistant tab and paste the prompt from [guide/prompts.md](guide/prompts.md). Then ask it questions.

### If you get stuck

Import `workflow/2_last_mile_COMPLETE.sql` the same way as in step 1. It already contains everything.

## Good to know

- A run takes about 2 to 3 minutes the first time. While a run is in progress the map shows a source error, because its tables are rebuilt. It recovers when the run finishes, and your styles and widgets are kept.
- The tables a workflow creates are temporary and expire after 30 days.
- The ticket data covers one fixed fiscal year (July 2025 to June 2026), so everyone should get the same results.

## Data sources

All data is free and public. See [data/README.md](data/README.md) for fields, how each file was prepared and credits.

## After the workshop

Ideas to explore on your own: add the NYC DOT microhub pilot sites as a layer (most are north of 60th Street, outside this study area), enrich the precincts with more Census data from the CARTO Data Observatory, or swap the NYC datasets for your own city's open data.
