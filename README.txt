NDGTS Excel-fed Website Test

This package removes the Google Sheet CSV URLs from the dashboard.

Files:
  index.html
  website_data/dashboard_data.csv
  website_data/metric_dictionary.csv
  website_data/narrative.csv
  website_data/board_briefing.csv
  website_data/index_rules.csv
  website_data/metric_map.csv

IMPORTANT: metric_map.csv is intentionally not guessed.

The current board dashboard uses these metric keys:
  students_impacted
  population_reached
  schools_reached
  earned_revenue_ratio
  program_spending
  revenue_diversity
  non_local_participation
  outreach_participation
  strategic_partnerships

The weekly Gateway workbook contains different operational measures, such as
Gallery Visitors, Onsite Participants, Community Memberships, Overdue A/R, etc.

metric_map.csv is the bridge. Put the appropriate dashboard metric_key beside
the source metric that should feed it. The website will then use the End Date
as snapshot_date and the weekly Value as the dashboard value.

This mapping must be decided rather than inferred, because several board-level
metrics are not equivalent to any single weekly measure.

TESTING:
Because browsers commonly block CSV fetches from file:// pages, test this folder
through a local web server or upload it to the web host/GitHub Pages. Do not
double-click index.html and expect local CSV loading to work in every browser.
