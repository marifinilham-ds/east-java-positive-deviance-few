-- 01_create_raw_tables.sql
-- Raw-layer tables for the East Java positive-deviance rice study.
-- Run against database pd_eastjava (PostgreSQL/PostGIS container pd_postgis).
-- Source CSVs are in data/raw/. Load commands (PowerShell) are listed at the bottom.

CREATE SCHEMA IF NOT EXISTS raw;

-- BPS rice statistics, 38 regencies/cities x 2019-2022 (2022 is provisional)
CREATE TABLE IF NOT EXISTS raw.padi_bps (
    kabupaten_kota            text,
    jenis                     text,      -- 'kabupaten' or 'kota'
    tahun                     int,
    luas_panen_ha             numeric,
    produktivitas_bps_kuha    numeric,
    produktivitas_hitung_kuha numeric,   -- production / harvested area x 10 (used as outcome)
    produksi_ton              numeric,
    status_data               text,
    PRIMARY KEY (kabupaten_kota, jenis, tahun)
);

-- CHIRPS rainfall and MODIS NDVI (Google Earth Engine), regency means
CREATE TABLE IF NOT EXISTS raw.iklim_ndvi (
    kabupaten_kota  text,
    jenis           text,
    tahun           int,
    rain_annual_mm  numeric,
    rain_dry_mm     numeric,             -- June-September total
    ndvi_mean       numeric,
    ndvi_max        numeric,
    PRIMARY KEY (kabupaten_kota, jenis, tahun)
);

-- VIIRS night lights, WorldCover cropland share, cropland-masked NDVI
CREATE TABLE IF NOT EXISTS raw.viirs_cropndvi (
    kabupaten_kota  text,
    jenis           text,
    tahun           int,
    ntl_mean        numeric,
    crop_share      numeric,
    ndvi_crop_mean  numeric,
    ndvi_crop_max   numeric,
    PRIMARY KEY (kabupaten_kota, jenis, tahun)
);

-- Paddy land by irrigation (BPS Jawa Timur / Dinas Pertanian), 2017 only
CREATE TABLE IF NOT EXISTS raw.sawah_pengairan (
    kabupaten_kota  text,
    jenis           text,
    irigasi_ha      numeric,
    non_irigasi_ha  numeric,
    sawah_total_ha  numeric,
    irig_share      numeric,
    tahun_sumber    int,
    PRIMARY KEY (kabupaten_kota, jenis)
);

-- Load commands (PowerShell, from the project folder):
--   Get-Content data\raw\bps\padi_jatim_2019_2022.csv | docker exec -i pd_postgis psql -U pd_user -d pd_eastjava -c "\copy raw.padi_bps FROM STDIN WITH (FORMAT csv, HEADER true)"
--   Get-Content data\raw\satellite\iklim_ndvi_jatim_2019_2022.csv | docker exec -i pd_postgis psql -U pd_user -d pd_eastjava -c "\copy raw.iklim_ndvi FROM STDIN WITH (FORMAT csv, HEADER true)"
--   Get-Content data\raw\satellite\viirs_cropndvi_jatim_2019_2022.csv | docker exec -i pd_postgis psql -U pd_user -d pd_eastjava -c "\copy raw.viirs_cropndvi FROM STDIN WITH (FORMAT csv, HEADER true)"
--   Get-Content data\raw\bps\sawah_pengairan_jatim_2017.csv | docker exec -i pd_postgis psql -U pd_user -d pd_eastjava -c "\copy raw.sawah_pengairan FROM STDIN WITH (FORMAT csv, HEADER true)"
-- Expected row counts: 152, 152, 152, 38.
