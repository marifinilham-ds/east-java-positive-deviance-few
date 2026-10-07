# Resilient Against the Odds: Positive-Deviant Regencies in East Java's Food-Energy-Water Nexus

Residual-based machine learning to find regencies in East Java (Indonesia) whose rice productivity is well above what their biophysical and infrastructure conditions predict. Companion repository to an extended abstract submitted to YES Conference 2026 (WRI Indonesia).

**Status:** work in progress. Results are exploratory and should be read together with the limitations below.

## Question

Which regencies reach rice productivity well above model predictions, and how robust is that result to model choice, feature set and data vintage?

## Data (2019-2022, 38 regencies/cities; main analysis uses the 29 kabupaten)

| Variable | Source | File |
|---|---|---|
| Rice harvested area, production, productivity | BPS Jawa Timur tables (2019-2020, 2021-2022; 2022 provisional) | `data/raw/bps/` |
| Annual and dry-season rainfall (Jun-Sep) | CHIRPS daily, via Google Earth Engine | `data/raw/satellite/` |
| NDVI (whole regency and cropland-masked), cropland share | MODIS MOD13Q1, ESA WorldCover 2021 | `data/raw/satellite/` |
| Night-time lights (proxy for energy access and economic activity) | VIIRS, via Google Earth Engine | `data/raw/satellite/` |
| Paddy land by irrigation (2017 only) | BPS Jawa Timur / Dinas Pertanian | `data/raw/bps/` |

Check each source's terms of use before reusing the data.

## Repository layout

```
data/raw/        source tables and extracted indicators (CSV)
sql/             schema for the PostgreSQL/PostGIS raw layer
notebooks/       01 Earth Engine extraction, 02 model, residuals and stability
results/         per-regency residuals (CSV)
figures/         figures used in the abstract
docker-compose.yml, .env.example
```

## How to reproduce

1. Copy `.env.example` to `.env` and set your own credentials.
2. Start the database: `docker compose up -d` (PostgreSQL/PostGIS and pgAdmin).
3. Create the tables and load the CSVs with the commands in `sql/01_create_raw_tables.sql` (expected row counts: 152, 152, 152, 38).
4. `notebooks/01_earth_engine_extraction.ipynb` re-creates the satellite indicators. It needs your own Google Earth Engine project (noncommercial use is free).
5. `notebooks/02_model_residual.ipynb` reads the CSVs from this repository, fits the models and writes `results/residual_kabupaten.csv`.

## Method in brief

- Outcome: rice productivity (production / harvested area), standardised within each year.
- Predictors: rainfall, NDVI, cropland share, night lights, irrigated share (2017); standardised within each year.
- Model: random forest with leave-one-regency-out validation, so each regency is scored by a model that never saw it.
- Positive deviant: mean residual at or above +0.5 SD across three feature sets, with and without 2022, and across 30 random-forest configurations.

## Main results (see the notebook for exact numbers)

- Predictive skill is modest (median R2 about 0.38) and depends almost entirely on cropland share; without it R2 is about zero.
- Gresik, Sidoarjo, Jombang and (marginally) Blitar stay above the threshold in every specification.
- Tulungagung and Ponorogo are stable across model runs but deviant only when cropland share is included.
- Results for the nine cities are inconclusive because their rice areas are very small.

## Limitations

- Residuals reflect unmeasured factors, not demonstrated practices.
- Irrigation data are from 2017 and treated as static; only irrigated vs non-irrigated is available.
- 2022 BPS figures are provisional.
- Satellite indicators are coarse for small areas, and cropland share covers all cropland, not only paddy.
- Only 29 regencies and four years.

## License

See `LICENSE`.
