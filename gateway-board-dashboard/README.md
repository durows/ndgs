# Gateway of Science Board Dashboard

Starter GitHub Pages dashboard for board-level reporting.

## Files
- `index.html` - main dashboard page
- `css/styles.css` - styling
- `js/app.js` - loads data and renders dashboard components
- `data/board_metrics.json` - sample data source

## Publish on GitHub Pages
1. Create a GitHub repository.
2. Upload these files.
3. In GitHub, open **Settings > Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select the `main` branch and `/ (root)` folder.
6. Save.
7. Your site will publish to a GitHub Pages URL.

## Updating data
Replace the values in `data/board_metrics.json` with current spreadsheet-derived values.

## Next improvement ideas
- Add annual trend charts from a second JSON file.
- Add a board note/date stamp showing when the data was last refreshed.
- Replace manual JSON updates with a Google Sheets export or Apps Script endpoint.
