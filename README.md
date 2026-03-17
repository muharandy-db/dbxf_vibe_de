# Vibe Data Engineering Workshop with Databricks

Welcome to the **Vibe Data Engineering Workshop**! In this hands-on tutorial, you'll use **Claude Code** (an AI-powered coding agent) together with **Databricks** to build a complete data pipeline — from raw CSV ingestion to curated gold-layer tables, Genie spaces, and dashboards — all driven by natural language prompts.

> **What is Vibe Data Engineering?** It's the practice of using AI coding agents to build and manage data pipelines through conversational prompts instead of writing every line of code manually. You describe *what* you want, and the AI helps you build it.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Repository Overview](#2-repository-overview)
3. [Setting Up Claude Code](#3-setting-up-claude-code)
4. [Connecting Claude Code to Databricks AI Gateway](#4-connecting-claude-code-to-databricks-ai-gateway)
5. [Workshop Exercises](#5-workshop-exercises)
   - [Exercise 1: Create a Schema](#exercise-1-create-a-schema)
   - [Exercise 2: Create a Landing Volume](#exercise-2-create-a-landing-volume)
   - [Exercise 3: Upload Data to Volume](#exercise-3-upload-data-to-volume)
   - [Exercise 4: Create the Pipeline and Bronze Layer](#exercise-4-create-the-pipeline-and-bronze-layer)
   - [Exercise 5: Add the Silver Layer](#exercise-5-add-the-silver-layer)
   - [Exercise 6: Add Gold Layer Tables](#exercise-6-add-gold-layer-tables)
   - [Exercise 7: Validate and Run the Pipeline](#exercise-7-validate-and-run-the-pipeline)
   - [Exercise 8: Create Genie Spaces and Dashboards](#exercise-8-create-genie-spaces-and-dashboards)
6. [Wrap-Up](#6-wrap-up)

---

## 1. Prerequisites

### Step 1: Verify Workspace Access

You should already have access to a Databricks workspace. Open your workspace URL in a browser and confirm you can log in.

> If you don't have access yet, contact your workshop facilitator before proceeding.

---

### Step 2: Install Claude Code

Claude Code is Anthropic's official CLI tool for AI-assisted coding.

<details open>
<summary><strong>macOS</strong></summary>

```bash
brew install claude-code
```
Or via npm:
```bash
npm install -g @anthropic-ai/claude-code
```
</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
npm install -g @anthropic-ai/claude-code
```
> Requires [Node.js 18+](https://nodejs.org/). Install it first if you don't have it.
</details>

<details>
<summary><strong>Linux</strong></summary>

```bash
npm install -g @anthropic-ai/claude-code
```
</details>

**Verify:**
```bash
claude --version
```

---

### Step 3: Install the Databricks CLI

<details open>
<summary><strong>macOS</strong></summary>

```bash
brew tap databricks/tap
brew install databricks
```
</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
winget install Databricks.DatabricksCLI
```
</details>

<details>
<summary><strong>Linux</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
```
</details>

**Verify:**
```bash
databricks --version
```

---

### Step 4: Configure the Databricks CLI Profile

Create a CLI profile called `WORKSHOP` that points to your workspace:

```bash
databricks configure --profile WORKSHOP
```

When prompted, enter:
- **Host**: Your Databricks workspace URL (e.g., `https://adb-1234567890123456.7.azuredatabricks.net`)
- **Token**: Your personal access token (generate one from **User Settings → Developer → Access Tokens** in the workspace)

**Verify:**
```bash
databricks workspace list / --profile WORKSHOP
```

You should see a list of workspace directories. If you get an authentication error, double-check your host URL and token.

---

### Step 5: Clone This Repository

```bash
git clone https://github.com/muharandy-db/dbxf_vibe_de.git
cd dbxf_vibe_de
```

---

### Step 6: Install the Databricks AI Dev Kit

The [AI Dev Kit](https://github.com/databricks-solutions/ai-dev-kit) gives Claude Code the Databricks-specific tools and knowledge it needs. Run the installer **from inside the project directory**:

**macOS / Linux:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.ps1 | iex
```

Follow the interactive prompts to complete the setup.

> **Note:** This installs at project level — you must always run Claude Code from this directory. The configuration is saved under `.claude/` in the project root.

<details>
<summary><strong>Advanced Options</strong></summary>

```bash
# Specify a Databricks CLI profile
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --profile WORKSHOP

# Force reinstall
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --force

# Install for Claude Code only
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --tools claude
```

</details>

---

### Checklist

Before moving on, confirm all prerequisites are in place:

- [ ] Can log in to Databricks workspace
- [ ] `claude --version` returns a version number
- [ ] `databricks --version` returns a version number
- [ ] `databricks workspace list / --profile WORKSHOP` returns workspace contents
- [ ] Repository cloned and you are in the `dbxf_vibe_de` directory
- [ ] AI Dev Kit installed (`.claude/` directory exists in project root)

---

## 2. Repository Overview

This workshop repository contains sample data for two industries. Browse the `data/` directory:

```
data/
├── fsi/                          # Financial Services Industry
│   ├── banking_accounts/
│   │   └── banking_accounts.csv
│   ├── banking_branches/
│   │   └── banking_branches.csv
│   ├── banking_customers/
│   │   └── banking_customers.csv
│   ├── banking_transactions/
│   │   └── banking_transactions.csv
│   ├── insurance_claims/
│   │   └── insurance_claims.csv
│   ├── insurance_customers/
│   │   └── insurance_customers.csv
│   └── insurance_policies/
│       └── insurance_policies.csv
│
└── pharma/                       # Pharmaceutical Industry
    ├── distribution_cold_chains/
    │   └── distribution_cold_chains.csv
    ├── distribution_warehouses/
    │   └── distribution_warehouses.csv
    ├── manufacturing_batches/
    │   └── manufacturing_batches.csv
    ├── manufacturing_quality/
    │   └── manufacturing_quality.csv
    ├── retail_inventory/
    │   └── retail_inventory.csv
    ├── retail_outlets/
    │   └── retail_outlets.csv
    ├── retail_sales/
    │   └── retail_sales.csv
    ├── supply_materials/
    │   └── supply_materials.csv
    └── supply_suppliers/
        └── supply_suppliers.csv
```

Each CSV file contains between 150 and 10,000 realistic sample records. Pick an industry to work with for the rest of the workshop — **FSI** or **Pharma**.

---

## 3. Setting Up Claude Code

Once Claude Code and the AI Dev Kit are installed, open a terminal and navigate to this repository:

```bash
cd /path/to/dbxf_vibe_de
```

Launch Claude Code:
```bash
claude
```

On first launch, Claude Code will prompt you to authenticate. Follow the on-screen instructions to sign in. The AI Dev Kit installer has already configured the Databricks MCP server and skills for this project.

---

## 4. Connecting Claude Code to Databricks AI Gateway

Databricks **AI Gateway** allows you to route AI model requests through your Databricks workspace, giving you centralized governance, observability, and cost management for all your AI coding tools.

> **Why use AI Gateway?** Instead of each developer using their own Anthropic API key, AI Gateway routes all requests through Databricks — giving you unified billing, usage monitoring, and governance across all coding tools.

### Step 1: Open AI Gateway in Your Workspace

1. Log in to your **Databricks workspace**
2. In the left sidebar, click on **AI Gateway**
3. Click **Integrate coding agents** (or the "Get Started" button)

### Step 2: Select Claude Code Integration

1. Select **Other integrations**
2. Choose **Claude Code** as your coding agent
3. Select your preferred Anthropic model (e.g., Claude Sonnet 4)
4. The UI will display your **AI Gateway endpoint URL** and generate **API credentials**

### Step 3: Copy the Configuration

Databricks will show you the configuration to add. Take note of:
- The **AI Gateway endpoint URL** (looks like: `https://<workspace-url>/serving-endpoints/databricks-claude-sonnet-4/invocations`)
- The **API key** (a model-scoped Databricks personal access token)

### Step 4: Configure Claude Code

Update your Claude Code settings file at `~/.claude/settings.json`:

```json
{
  "apiKeyHelper": "echo <YOUR_DATABRICKS_API_KEY>",
  "model": "databricks-claude-sonnet-4",
  "apiBaseUrl": "https://<your-workspace-url>/serving-endpoints/databricks-claude-sonnet-4",
  "loginDisabled": true
}
```

Replace:
- `<YOUR_DATABRICKS_API_KEY>` with the API key from AI Gateway
- `<your-workspace-url>` with your Databricks workspace URL

> **Tip:** Setting `"loginDisabled": true` prevents Claude Code from prompting you to log in through Anthropic directly, ensuring all requests route through your Databricks AI Gateway.

### Step 5: Verify the Connection

Restart Claude Code and try a simple prompt:
```
> Hello, can you confirm you're connected?
```

If you get a response, you're all set! You can also check the **AI Gateway dashboard** in your workspace to see the request appear in the usage metrics.

### Observability

Once connected, go back to **AI Gateway** in your workspace and click **View dashboard** to monitor:
- Request volume and latency
- Token usage and cost
- Per-user activity across all connected coding tools

---

## 5. Workshop Exercises

Now the fun begins! You'll use Claude Code to build a complete data pipeline using only natural language prompts. Follow each exercise in order.

> **Important:** Throughout the exercises, replace `<your_username>` with your actual username (e.g., `user01`). Replace `<your_catalog>` with the catalog name assigned to you in the workspace.

---

### Exercise 1: Create a Schema

First, let's find out your catalog name. In Claude Code, type:

```
List the catalogs available in my Databricks workspace using the Databricks CLI with the WORKSHOP profile
```

Note down your catalog name from the output.

Now, create a schema for the workshop:

```
Using the Databricks CLI with the WORKSHOP profile, create a schema called
<your_username>_demo under the <your_catalog> catalog in my Databricks workspace
```

**Validate in the workspace:**
1. Go to your Databricks workspace
2. Navigate to **Catalog** in the left sidebar
3. Expand your catalog
4. Confirm the `<your_username>_demo` schema exists

---

### Exercise 2: Create a Landing Volume

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

### Exercise 3: Upload Data to Volume

Choose your industry (FSI or Pharma) and upload the sample data:

**For FSI:**
```
Upload all CSV files from the data/fsi/ directory to my Databricks volume at
/Volumes/<your_catalog>/<your_username>_demo/landing/ using the Databricks CLI
with the WORKSHOP profile.
Each CSV file should be placed under its own subdirectory matching the source
directory name. For example, banking_customers.csv should go to
/Volumes/<your_catalog>/<your_username>_demo/landing/banking_customers/banking_customers.csv
```

**For Pharma:**
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

### Exercise 4: Create the Pipeline and Bronze Layer

First, create the pipeline and ingest raw data into bronze streaming tables.

**For FSI:**
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

**For Pharma:**
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

### Exercise 5: Add the Silver Layer

Now add data quality constraints and transformations on top of the bronze tables.

**For FSI:**
```
Add a SQL file called 02_silver.sql to the existing <your_username>_ingestion pipeline.
This file should clean and transform the bronze tables into silver streaming tables.
Tables should be prefixed with "02_" (e.g., 02_banking_customers, 02_insurance_policies).
Apply data quality constraints (NOT NULL on key columns, valid ranges).
Standardize data types, trim strings, and handle nulls.
```

**For Pharma:**
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

### Exercise 6: Add Gold Layer Tables

Now create business-level aggregations as gold materialized views. We'll create **one table at a time** so you can review each one.

#### FSI Gold Tables

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

#### Pharma Gold Tables

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

### Exercise 7: Validate and Run the Pipeline

Start the pipeline:

1. In the **Pipelines** page, click on `<your_username>_ingestion`
2. Click **Start** to run the pipeline
3. Monitor the DAG visualization as data flows through bronze → silver → gold

**If the pipeline doesn't have a root directory configured**, use this prompt in Claude Code:

```
The pipeline <your_username>_ingestion doesn't have its root directory set.
Update the pipeline configuration to set the root directory to the path where
the SQL files were created. Use the Databricks CLI with the WORKSHOP profile.
```

**If the pipeline fails**, use Claude Code to troubleshoot:

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

### Exercise 8: Create Genie Spaces and Dashboards

Now let's make the gold-layer data accessible to business users through **Genie Spaces** and **Dashboards**.

**Create Genie Spaces:**

```
Create 2 Databricks Genie spaces using the Databricks API with the WORKSHOP profile:

1. "<your_username> - Customer Analytics" - Include the gold tables related to
   customers and risk profiles (e.g., 03_customer_360, 03_customer_risk_profile
   for FSI, or 03_sales_by_outlet, 03_inventory_status for Pharma).
   Add a description explaining what business questions this space can answer.

2. "<your_username> - Operations Analytics" - Include the gold tables related to
   operations and performance (e.g., 03_transaction_daily_summary,
   03_branch_performance for FSI, or 03_batch_quality_summary,
   03_cold_chain_compliance for Pharma).
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

## 6. Wrap-Up

Congratulations! You've completed the Vibe Data Engineering Workshop! Here's what you accomplished:

| Step | What You Built |
|------|---------------|
| Exercise 1 | A Unity Catalog schema for your demo |
| Exercise 2 | A managed volume for landing raw data |
| Exercise 3 | Uploaded industry sample data to the volume |
| Exercise 4 | A Spark Declarative Pipeline with bronze ingestion |
| Exercise 5 | Silver layer with data quality constraints |
| Exercise 6 | Gold layer materialized views for business analytics |
| Exercise 7 | Ran and validated the end-to-end pipeline |
| Exercise 8 | Genie spaces and dashboards for business analytics |

**Key takeaways:**
- You built a complete data pipeline **using only natural language prompts**
- Claude Code handled the Databricks CLI commands, SQL authoring, and API calls
- The AI Gateway gave you centralized observability over all AI-assisted development
- The medallion architecture (bronze → silver → gold) provides a clean, scalable data model

### What's Next?

- **Experiment:** Try modifying the gold-layer transformations or adding new aggregations
- **Explore:** Ask Claude Code to help you build ML features from the gold tables
- **Expand:** Add the other industry dataset and build cross-industry analytics
- **Share:** Show colleagues how Vibe Data Engineering accelerates pipeline development

---

> **Workshop created for Databricks Express Edition**
> For questions or feedback, reach out to your workshop facilitator.
