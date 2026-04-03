# Pharmaceutical Industry (Pharma) Tutorial

This tutorial walks you through building a complete Pharma data pipeline using your coding assistant and Databricks.

> **Before you begin:** Make sure you've completed all steps in the [Prerequisites](README.md#1-prerequisites) section of the main README.

> **Important:** Throughout the exercises, replace `<your_username>` with your actual username (e.g., `user01`). Replace `<your_catalog>` with the catalog name assigned to you in the workspace.

---

## Exercise 1: Set Up Your Catalog and Schema

First, let's find out what catalogs are available. In your coding assistant, type:

```
List the catalogs available in my Databricks workspace using the Databricks CLI with the WORKSHOP profile
```

Note down your catalog name from the output.

> **Using a shared workspace?** If you're running this tutorial on a shared workspace (not your own personal Databricks Free Edition workspace), you may want to create your own catalog to avoid conflicts with other participants. Use the following prompt:
>
> ```
> Using the Databricks CLI with the WORKSHOP profile, create a catalog called
> <your_username>_catalog in my Databricks workspace
> ```
>
> Then use `<your_username>_catalog` as your `<your_catalog>` for the rest of this tutorial.

Now, create a schema for the workshop:

```
Using the Databricks CLI with the WORKSHOP profile, create a schema called
<your_username>_demo under the <your_catalog> catalog in my Databricks workspace
```

**Validate in the workspace:**
1. Go to your Databricks workspace
2. Navigate to **Catalog** in the left sidebar
3. Expand your catalog (or `<your_username>_catalog` if you created one)
4. Confirm the `<your_username>_demo` schema exists

---

## Exercise 2: Create a Landing Volume

Next, create a Unity Catalog Volume to store the raw CSV files:

```
Using the Databricks CLI with the WORKSHOP profile, create a volume called
"landing" of type MANAGED under the schema <your_catalog>.<your_username>_demo
```

**Validate in the workspace:**
1. In **Catalog**, navigate to `<your_catalog>` → `<your_username>_demo`
2. Click on **Volumes**
3. Confirm the `landing` volume is listed

---

## Exercise 3: Upload Data to Volume

Upload the Pharma sample data to your landing volume:

```
Upload all CSV files from the data/pharma/ directory to my Databricks volume at
/Volumes/<your_catalog>/<your_username>_demo/landing/ using the Databricks CLI
with the WORKSHOP profile.
Each CSV file should be placed under its own subdirectory matching the source
directory name. For example, retail_sales.csv should go to
/Volumes/<your_catalog>/<your_username>_demo/landing/retail_sales/retail_sales.csv
```

**Validate in the workspace:**
1. In **Catalog**, navigate to your volume: `<your_catalog>` → `<your_username>_demo` → `landing`
2. Browse the volume and confirm all subdirectories and CSV files are present

---

## Exercise 4: Create the Pipeline and Bronze Layer

Create the pipeline and ingest raw data into bronze streaming tables:

```
Create a Databricks Spark Declarative Pipeline called <your_username>_ingestion
targeting the schema <your_catalog>.<your_username>_demo.

Create a SQL file called 01_bronze.sql that ingests raw CSV data from
/Volumes/<your_catalog>/<your_username>_demo/landing/ into bronze streaming tables.
Create one streaming table per CSV source. Tables should be prefixed with "01_"
(e.g., 01_manufacturing_batches, 01_manufacturing_quality, 01_distribution_cold_chains,
01_distribution_warehouses, 01_retail_outlets, 01_retail_inventory, 01_retail_sales,
01_supply_materials, 01_supply_suppliers).
Use Auto Loader (cloud_files) to read from the volumes.

Deploy the pipeline to my Databricks workspace using the Databricks CLI with
the WORKSHOP profile.
```

**Validate in the workspace:**
1. In the left sidebar, click **Pipelines** (under Data Engineering)
2. Find your pipeline: `<your_username>_ingestion`
3. Verify that the `01_bronze.sql` file is listed as source code
4. Review the generated SQL — does it look correct?

---

## Exercise 5: Add the Silver Layer

Add data quality constraints and transformations on top of the bronze tables:

```
Add a SQL file called 02_silver.sql to the existing <your_username>_ingestion pipeline.
This file should clean and transform the bronze tables into silver streaming tables.
Tables should be prefixed with "02_" (e.g., 02_manufacturing_batches, 02_retail_sales).
Apply data quality constraints (NOT NULL on key columns, valid ranges,
temperature bounds for cold chain data).
Standardize data types, trim strings, and handle nulls.
```

**Validate:**
1. Review the generated `02_silver.sql` — check that constraints make sense for your data
2. Confirm the file is added to the pipeline source code in the workspace

---

## Exercise 6: Add Gold Layer Tables

Create business-level aggregations as gold materialized views. We'll create **one table at a time** so you can review each one.

**Gold Table 1 — Batch Quality Summary:**
```
Add a gold materialized view called 03_batch_quality_summary to the
<your_username>_ingestion pipeline in a new SQL file called 03_gold.sql.
This view should aggregate quality test pass/fail rates by product and facility
from 02_manufacturing_quality and 02_manufacturing_batches.
```

**Gold Table 2 — Cold Chain Compliance:**
```
Add a gold materialized view called 03_cold_chain_compliance to 03_gold.sql.
This view should calculate temperature compliance rates by route and carrier,
flagging shipments that exceeded temperature thresholds from 02_distribution_cold_chains.
```

**Gold Table 3 — Inventory Status:**
```
Add a gold materialized view called 03_inventory_status to 03_gold.sql.
This view should show current inventory levels with expiry risk by outlet and product,
joining 02_retail_inventory with 02_retail_outlets.
```

**Gold Table 4 — Sales by Outlet:**
```
Add a gold materialized view called 03_sales_by_outlet to 03_gold.sql.
This view should aggregate sales by outlet, product, and month from
02_retail_sales joined with 02_retail_outlets.
```

**Gold Table 5 — Supply Chain Overview:**
```
Add a gold materialized view called 03_supply_chain_overview to 03_gold.sql.
This view should provide end-to-end supply chain metrics from supplier to retail,
joining 02_supply_suppliers, 02_supply_materials, 02_manufacturing_batches,
02_distribution_cold_chains, and 02_retail_inventory.
```

**Validate all gold tables:**
1. Review `03_gold.sql` — confirm each materialized view looks correct
2. In the workspace, verify the pipeline now shows all three SQL files

---

## Exercise 7: Validate and Run the Pipeline

Start the pipeline:

1. In the **Pipelines** page, click on `<your_username>_ingestion`
2. Click **Start** to run the pipeline
3. Monitor the DAG visualization as data flows through bronze → silver → gold

**If the pipeline doesn't have a root directory configured**, use this prompt in your coding assistant:

```
The pipeline <your_username>_ingestion doesn't have its root directory set.
Update the pipeline configuration to set the root directory to the path where
the SQL files were created. Use the Databricks CLI with the WORKSHOP profile.
```

**If the pipeline fails**, use your coding assistant to troubleshoot:

```
The pipeline <your_username>_ingestion failed. Can you check the pipeline
status and error details using the Databricks CLI with the WORKSHOP profile,
and suggest fixes?
```

**Validate the results:**
1. Go to **Catalog** → `<your_catalog>` → `<your_username>_demo`
2. Verify that tables exist with the `01_`, `02_`, and `03_` prefixes
3. Click on a few tables and preview the data to confirm it loaded correctly

---

## Exercise 8: Create Genie Spaces and Dashboards

Now let's make the gold-layer data accessible to business users through **Genie Spaces** and **Dashboards**.

**Create Genie Spaces:**

```
Create 2 Databricks Genie spaces using the Databricks API with the WORKSHOP profile:

1. "<your_username> - Pharma Quality Analytics" - Include the gold tables related to
   quality and compliance (03_batch_quality_summary, 03_cold_chain_compliance).
   Add a description explaining what business questions this space can answer.

2. "<your_username> - Pharma Operations Analytics" - Include the gold tables related to
   operations and sales (03_inventory_status, 03_sales_by_outlet, 03_supply_chain_overview).
   Add a description explaining what business questions this space can answer.

Use the SQL warehouse available in the workspace.
```

**Create Dashboards:**

```
Create 2 Databricks Lakeview dashboards using the Databricks API with the
WORKSHOP profile:

1. "<your_username> - Quality & Compliance Dashboard" - Build a dashboard with
   4-6 visualizations from the quality-related gold tables. Include:
   - A summary counter/stat for overall pass rate
   - A bar chart showing pass/fail rates by product
   - A time series chart showing cold chain compliance trends
   - A table with detailed quality test results

2. "<your_username> - Pharma Operations Dashboard" - Build a dashboard with 4-6
   visualizations from the operations-related gold tables. Include:
   - Key inventory metrics as counters
   - A bar or pie chart for sales by outlet type
   - A time series showing monthly sales trends
   - A detailed table view of supply chain metrics

Use the SQL warehouse available in the workspace and publish both dashboards.
```

**Validate in the workspace:**
1. In the left sidebar, click **Genie** — verify your two Genie spaces appear
2. Try asking a natural language question in each Genie space (e.g., "Which products have the highest quality failure rate?")
3. In the left sidebar, click **Dashboards** — verify your two dashboards appear
4. Open each dashboard and confirm the visualizations render with data

---

## Wrap-Up

Congratulations! You've completed the Pharma tutorial! Here's what you accomplished:

| Step | What You Built |
|------|---------------|
| Exercise 1 | A Unity Catalog catalog (optional) and schema for your demo |
| Exercise 2 | A managed volume for landing raw data |
| Exercise 3 | Uploaded Pharma sample data to the volume |
| Exercise 4 | A Spark Declarative Pipeline with bronze ingestion |
| Exercise 5 | Silver layer with data quality constraints |
| Exercise 6 | Gold layer materialized views for business analytics |
| Exercise 7 | Ran and validated the end-to-end pipeline |
| Exercise 8 | Genie spaces and dashboards for business analytics |

**What's Next?**
- Try modifying the gold-layer transformations or adding new aggregations
- Ask your coding assistant to help you build ML features from the gold tables
- Try the [FSI tutorial](TUTORIAL_FSI.md) to build a second pipeline
