# Resilient Against the Odds: Positive-Deviant Regencies in East Java's Food-Energy-Water Nexus

Residual-based machine learning to find regencies in East Java (Indonesia) whose rice productivity is well above what their biophysical and infrastructure conditions predict. Companion repository to an extended abstract submitted to the 2nd YES Conference 2026 (WRI Indonesia).

**Status:** work in progress. Results are exploratory screening results, not tests of effects, and should be read together with the limitations below.

## Question

Which regencies reach rice productivity well above model predictions, and how robust is that result to model choice, feature set and data vintage?

## Data (2019-2022; 38 regencies/cities, main analysis uses the 29 kabupaten)

| Variable | Source | File |
|---|---|---|
| Rice harvested area, production, productivity | BPS Jawa Timur tables (2019-2020, 2021-2022). 2022 is provisional: October-December harvested area is a potential figure from the September 2022 survey, and September-December production is computed from the 2018-2021 average productivity, so part of the 2022 yield is projected | `data/raw/bps/` |
| Annual and dry-season (Jun-Sep) rainfall | CHIRPS daily, via Google Earth Engine | `data/raw/satellite/` |
| NDVI (whole regency and cropland-masked), cropland share | MODIS MOD13Q1 and MCD12Q1 cropland mask; ESA WorldCover 2021 (cropland share is constant across years) | `data/raw/satellite/` |
| Night-time lights (proxy for economic activity and electrification intensity; not validated as energy access) | VIIRS monthly composites, via Google Earth Engine | `data/raw/satellite/` |
| Paddy land by irrigation (2017 only, treated as static) | Dinas Pertanian Tanaman Pangan Jawa Timur, 2017 | `data/raw/bps/` |

Check each source's terms of use before reusing the data.

## Repository layout

```
data/raw/        source tables and extracted indicators (CSV)
sql/             schema for the PostgreSQL/PostGIS raw layer
notebooks/       01 Earth Engine extraction, 02 model, residuals and stability
results/         per-regency residuals and flags (CSV)
figures/         figures for the paper and presentation
docker-compose.yml, .env.example
```

## How to reproduce

The analysis itself runs from CSV files in this repository. The PostGIS database stores a copy of the same tables and is not read by the notebooks. Some steps are manual.

1. Optional: copy `.env.example` to `.env`, start the database with `docker compose up -d`, and load the CSVs with the commands in `sql/01_create_raw_tables.sql` (expected row counts: 152, 152, 152, 38).
2. `notebooks/01_earth_engine_extraction.ipynb` re-creates the satellite indicators. It needs your own Google Earth Engine project (noncommercial use is free). The notebook downloads the CSVs through the browser; move them to `data/raw/satellite/`.
3. `notebooks/02_model_residual.ipynb` reads the CSVs from this repository, fits the models and produces `residual_kabupaten.csv` (a browser download; move it to `results/`).

## Method in brief

- Outcome: rice productivity (production / harvested area), standardised (z-score) within each year across the 38 units.
- Predictors: annual and dry-season rainfall, NDVI (whole and cropland-masked), cropland share, log night lights, irrigated share (2017); standardised within each year.
- Model: random forest (500 trees, min leaf 3) with leave-one-regency-out validation, so each regency is scored by a model that never saw it. A ridge regression is the linear baseline.
- Residual: observed minus predicted productivity, averaged over 2019-2022 per regency (in SD units).
- **Flagged** regency: mean residual at or above +0.5 SD in the full model. The cut-off is a screening choice, not a statistical test.
- Robustness: eight specifications (full model, without cropland share, without night lights, without irrigation; each with and without 2022), plus 30 random-forest configurations (5 seeds x 3 leaf sizes x 2 max-feature settings) on the full feature set. A regency is **robust** if its residual is at or above +0.5 SD in all eight specifications (`robust_all` in the results file).

## Main results (see the notebook for exact numbers)

- Predictive skill is modest: median R2 0.38 (range 0.35-0.41 across the 30 configurations; ridge baseline about 0.04). R2 is about zero without cropland share and 0.38 without irrigation.
- Seven regencies are flagged in the full model: Gresik, Tulungagung, Blitar, Ponorogo, Sidoarjo, Jombang and Banyuwangi.
- Three are robust in all eight specifications: Sidoarjo, Jombang and Blitar (Blitar is closest to the cut-off, minimum 0.51).
- Gresik, Tulungagung and Ponorogo depend on a feature. Gresik falls below the cut-off when irrigation is omitted (0.47; 0.09 without 2022), so its status holds relative to regencies with similar, low irrigation. Tulungagung and Ponorogo are deviant only when cropland share is included.
- Banyuwangi is fragile: 0.26 without 2022 and 0.18 without irrigation.
- Results for the nine cities are inconclusive because their harvested rice areas are very small (about 700-2,200 ha in 2022) and their conditions lie outside the range of the kabupaten.
- Because the cut-off is applied to a standardised residual, it is expected to flag a sizeable share of regencies even when residuals are mostly noise. Consistency across specifications, not the number flagged, is the finding.

## Limitations

- Residuals reflect unmeasured factors and model error, not demonstrated practices. They sit above a conditional mean, not an efficiency frontier.
- Irrigation data are from 2017 and treated as static; only irrigated vs non-irrigated paddy land is available.
- 2022 BPS figures are provisional and partly projected from earlier years.
- Satellite indicators are coarse for small areas, and cropland share covers all cropland, not only paddy.
- Night lights capture activity and urbanisation more than energy access.
- Only 29 regencies and four years; time-invariant predictors (cropland share, irrigation) act partly as regency identifiers.
- Candidates are for follow-up (for example field studies of varieties, cropping intensity and water management), not proven models.

## License

See `LICENSE`.
