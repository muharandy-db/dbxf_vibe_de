# Financial Services Industry (FSI) Tutorial

This tutorial walks you through building a complete FSI data pipeline using your coding assistant and Databricks.

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

Upload the FSI sample data to your landing volume:

```
Upload all CSV files from the data/fsi/ directory to my Databricks volume at
/Volumes/<your_catalog>/<your_username>_demo/landing/ using the Databricks CLI
with the WORKSHOP profile.
Each CSV file should be placed under its own subdirectory matching the source
directory name. For example, banking_customers.csv should go to
/Volumes/<your_catalog>/<your_username>_demo/landing/banking_customers/banking_customers.csv
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
(e.g., 01_banking_customers, 01_banking_transactions, 01_banking_accounts,
01_banking_branches, 01_insurance_customers, 01_insurance_policies, 01_insurance_claims).
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
Tables should be prefixed with "02_" (e.g., 02_banking_customers, 02_insurance_policies).
Apply data quality constraints (NOT NULL on key columns, valid ranges).
Standardize data types, trim strings, and handle nulls.
```

**Validate:**
1. Review the generated `02_silver.sql` — check that constraints make sense for your data
2. Confirm the file is added to the pipeline source code in the workspace

---

## Exercise 6: Add Gold Layer Tables

Create business-level aggregations as gold materialized views. We'll create **one table at a time** so you can review each one.

**Gold Table 1 — Customer 360:**
```
Add a gold materialized view called 03_customer_360 to the <your_username>_ingestion
pipeline in a new SQL file called 03_gold.sql. This view should create a unified
profile of banking and insurance customers by joining 02_banking_customers and
02_insurance_customers, enriched with account and policy counts.
```

**Gold Table 2 — Policy Claims Summary:**
```
Add a gold materialized view called 03_policy_claims_summary to 03_gold.sql.
This view should aggregate claims by policy type, showing total claims, approved vs
denied counts, average claim amount, and total settlement amounts from the silver tables.
```

**Gold Table 3 — Transaction Daily Summary:**
```
Add a gold materialized view called 03_transaction_daily_summary to 03_gold.sql.
This view should aggregate daily transaction volumes and amounts by transaction type
and channel from 02_banking_transactions.
```

**Gold Table 4 — Branch Performance:**
```
Add a gold materialized view called 03_branch_performance to 03_gold.sql.
This view should show branch-level metrics including total accounts, total balances,
transaction counts, and active customer counts by joining branch, account, and
transaction silver tables.
```

**Gold Table 5 — Customer Risk Profile:**
```
Add a gold materialized view called 03_customer_risk_profile to 03_gold.sql.
This view should combine banking risk ratings with insurance claim history to
create a unified risk score per customer.
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

1. "<your_username> - Customer Analytics" - Include the gold tables related to
   customers and risk profiles (03_customer_360, 03_customer_risk_profile).
   Add a description explaining what business questions this space can answer.

2. "<your_username> - Operations Analytics" - Include the gold tables related to
   operations and performance (03_transaction_daily_summary, 03_branch_performance).
   Add a description explaining what business questions this space can answer.

Use the SQL warehouse available in the workspace.
```

**Create Dashboards:**

```
Create 2 Databricks Lakeview dashboards using the Databricks API with the
WORKSHOP profile:

1. "<your_username> - Customer Insights Dashboard" - Build a dashboard with
   4-6 visualizations from the customer-related gold tables. Include:
   - A summary counter/stat for total customers
   - A bar chart showing distribution by segment or type
   - A time series chart showing trends
   - A table with detailed metrics

2. "<your_username> - Operations Dashboard" - Build a dashboard with 4-6
   visualizations from the operations-related gold tables. Include:
   - Key operational metrics as counters
   - A bar or pie chart for categorical breakdowns
   - A time series showing operational trends
   - A detailed table view

Use the SQL warehouse available in the workspace and publish both dashboards.
```

**Validate in the workspace:**
1. In the left sidebar, click **Genie** — verify your two Genie spaces appear
2. Try asking a natural language question in each Genie space (e.g., "What are the top 10 customers by transaction volume?")
3. In the left sidebar, click **Dashboards** — verify your two dashboards appear
4. Open each dashboard and confirm the visualizations render with data

---

## Wrap-Up

Congratulations! You've completed the FSI tutorial! Here's what you accomplished:

| Step | What You Built |
|------|---------------|
| Exercise 1 | A Unity Catalog catalog (optional) and schema for your demo |
| Exercise 2 | A managed volume for landing raw data |
| Exercise 3 | Uploaded FSI sample data to the volume |
| Exercise 4 | A Spark Declarative Pipeline with bronze ingestion |
| Exercise 5 | Silver layer with data quality constraints |
| Exercise 6 | Gold layer materialized views for business analytics |
| Exercise 7 | Ran and validated the end-to-end pipeline |
| Exercise 8 | Genie spaces and dashboards for business analytics |

**What's Next?**
- Try modifying the gold-layer transformations or adding new aggregations
- Ask your coding assistant to help you build ML features from the gold tables
- Try the [Pharma tutorial](TUTORIAL_PHARMA.md) to build a second pipeline
