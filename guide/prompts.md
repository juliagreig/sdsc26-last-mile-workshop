# Copy and paste text

## Assistant prompt (AI agent, Assistant tab)

I am building an assistant for urban planners and logistics teams who explore last-mile delivery pressure in Manhattan below 60th Street. The map has one row per NYPD precinct with priority_index (0 to 100, higher means more pressure), violations, loading_supply, demand_per_1k and loading_per_1k. It should answer which precincts have the highest pressure, compare supply and demand, and use the map's widgets and filters to show its answers.

## Starter questions

- Which precincts have the highest delivery pressure?
- Show me high-pressure precincts with few loading zones
- What is driving the score in precinct 14?
- Chart demand per capita against loading supply per capita for every precinct

## Experiments in the workflow

1. Open Variables, set `date_from` to `2026-01-01`, press Run and compare the ranking.
2. Select the Priority Index node, change the weight of `demand_per_1k` to 2, press Run and compare.

## Map styling steps

1. Open the map the workflow created (link on the Create Map node, or find it in Maps).
2. Layer 1 (precincts): fill color by `priority_index`, yellow to red palette, opacity about 70%.
3. Layer 2 (loading zones): small points in a bright color.
4. Add a histogram widget on `priority_index` and click a bar to filter.
