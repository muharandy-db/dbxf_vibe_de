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
   - [Exercise 4: Create a Declarative Pipeline (Bronze → Silver → Gold)](#exercise-4-create-a-declarative-pipeline-bronze--silver--gold)
   - [Exercise 5: Validate and Run the Pipeline](#exercise-5-validate-and-run-the-pipeline)
   - [Exercise 6: Create Genie Spaces and Dashboards](#exercise-6-create-genie-spaces-and-dashboards)
6. [Wrap-Up](#6-wrap-up)

---

## 1. Prerequisites

Before starting this workshop, ensure the following:

### Access to a Databricks Workspace

You should already have access to a Databricks workspace. Confirm you can log in and navigate the workspace UI.

### Install Claude Code

Claude Code is Anthropic's official CLI tool for AI-assisted coding.

**macOS (using Homebrew):**
```bash
brew install claude-code
```

**macOS / Linux (using npm):**
```bash
npm install -g @anthropic-ai/claude-code
```

**Windows (using npm):**
```powershell
npm install -g @anthropic-ai/claude-code
```

> If you don't have Node.js installed, download it first from [nodejs.org](https://nodejs.org/) (version 18+).

Verify installation:
```bash
claude --version
```

### Install and Configure the Databricks CLI

**macOS (using Homebrew):**
```bash
brew tap databricks/tap
brew install databricks
```

**Windows (using winget):**
```powershell
winget install Databricks.DatabricksCLI
```

**Linux / Other (using curl):**
```bash
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
```

Configure a profile to connect to your workspace:
```bash
databricks configure --profile WORKSHOP
```

When prompted, enter:
- **Host**: Your Databricks workspace URL (e.g., `https://adb-1234567890123456.7.azuredatabricks.net`)
- **Token**: Your personal access token

Verify the connection:
```bash
databricks workspace list / --profile WORKSHOP
```

### Install the Databricks AI Dev Kit

The [AI Dev Kit](https://github.com/databricks-solutions/ai-dev-kit) gives your AI coding assistant the tools and knowledge it needs to build on Databricks. Install it directly into this project directory.

Make sure you are in the workshop repository root before running the installer:
```bash
cd /path/to/dbsf_vibe_de
```

**macOS / Linux:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.ps1 | iex
```

Follow the interactive prompts to complete the setup. The installer will configure Claude Code with the Databricks MCP server and skills for this project.

> **Note:** This installs at project level, so you must run Claude Code from this directory. The configuration files are created under `.claude/` in the project root.

<details>
<summary><strong>Advanced Options</strong> (click to expand)</summary>

**Specify a Databricks CLI profile:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --profile WORKSHOP
```

**Force reinstall (if you need to reconfigure):**
```bash
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --force
```

**Install for specific tools only:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh) --tools claude
```

</details>

### Prerequisites Summary

| Prerequisite | Install Command | Verify |
|---|---|---|
| Databricks Workspace | _(provided by your admin)_ | Log in to workspace URL |
| Claude Code | `npm install -g @anthropic-ai/claude-code` | `claude --version` |
| Databricks CLI | `brew install databricks` (macOS) | `databricks --version` |
| AI Dev Kit | `bash <(curl -sL ...)` (see above) | Check `.claude/` directory exists |

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
cd /path/to/dbsf_vibe_de
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

> **Important:** Throughout the exercises, replace `<your_username>` with your actual username (e.g., `fajar_muharandy`). Replace `<your_catalog>` with the catalog name assigned to you in the workspace.

---

### Exercise 1: Create a Schema

First, let's find out your catalog name. In Claude Code, type:

```
> List the catalogs available in my Databricks workspace using the Databricks CLI with the WORKSHOP profile
```

Note down your catalog name from the output.

Now, create a schema for the workshop:

```
> Using the Databricks CLI with the WORKSHOP profile, create a schema called
> <your_username>_demo under the <your_catalog> catalog in my Databricks workspace
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
> Using the Databricks CLI with the WORKSHOP profile, create a volume called
> "landing" of type MANAGED under the schema <your_catalog>.<your_username>_demo
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
> Upload all CSV files from the data/fsi/ directory to my Databricks volume at
> /Volumes/<your_catalog>/<your_username>_demo/landing/ using the Databricks CLI
> with the WORKSHOP profile.
> Each CSV file should be placed under its own subdirectory matching the source
> directory name. For example, banking_customers.csv should go to
> /Volumes/<your_catalog>/<your_username>_demo/landing/banking_customers/banking_customers.csv
```

**For Pharma:**
```
> Upload all CSV files from the data/pharma/ directory to my Databricks volume at
> /Volumes/<your_catalog>/<your_username>_demo/landing/ using the Databricks CLI
> with the WORKSHOP profile.
> Each CSV file should be placed under its own subdirectory matching the source
> directory name. For example, retail_sales.csv should go to
> /Volumes/<your_catalog>/<your_username>_demo/landing/retail_sales/retail_sales.csv
```

**Validate in the workspace:**
1. In **Catalog**, navigate to your volume: `<your_catalog>` → `<your_username>_demo` → `landing`
2. Browse the volume and confirm all subdirectories and CSV files are present

---

### Exercise 4: Create a Declarative Pipeline (Bronze → Silver → Gold)

Now let's build the heart of the data pipeline — a **Spark Declarative Pipeline** using SQL.

**For FSI:**
```
> Create a Databricks Spark Declarative Pipeline called <your_username>_ingestion
> targeting the schema <your_catalog>.<your_username>_demo.
> The pipeline should read CSV files from
> /Volumes/<your_catalog>/<your_username>_demo/landing/
> and process them through bronze, silver, and gold layers.
>
> Create three SQL files:
> 1. 01_bronze.sql - Ingest raw CSV data from the landing volume into bronze
>    streaming tables. Create one streaming table per CSV source. Tables should
>    be prefixed with "01_" (e.g., 01_banking_customers, 01_banking_transactions).
>    Use Auto Loader (cloud_files) to read from the volumes.
>
> 2. 02_silver.sql - Clean and transform bronze data into silver streaming tables.
>    Apply data quality constraints (NOT NULL on key columns, valid ranges).
>    Tables should be prefixed with "02_" (e.g., 02_banking_customers).
>    Standardize data types, trim strings, and handle nulls.
>
> 3. 03_gold.sql - Create gold materialized views with business-level aggregations.
>    Tables should be prefixed with "03_". Examples:
>    - 03_customer_360: Unified view of banking + insurance customers
>    - 03_policy_claims_summary: Claims aggregated by policy type
>    - 03_transaction_daily_summary: Daily transaction volumes and amounts
>    - 03_branch_performance: Branch-level metrics
>    - 03_customer_risk_profile: Risk scoring combining banking and insurance data
>
> Deploy the pipeline to my Databricks workspace using the Databricks CLI with
> the WORKSHOP profile.
```

**For Pharma:**
```
> Create a Databricks Spark Declarative Pipeline called <your_username>_ingestion
> targeting the schema <your_catalog>.<your_username>_demo.
> The pipeline should read CSV files from
> /Volumes/<your_catalog>/<your_username>_demo/landing/
> and process them through bronze, silver, and gold layers.
>
> Create three SQL files:
> 1. 01_bronze.sql - Ingest raw CSV data from the landing volume into bronze
>    streaming tables. Create one streaming table per CSV source. Tables should
>    be prefixed with "01_" (e.g., 01_manufacturing_batches, 01_retail_sales).
>    Use Auto Loader (cloud_files) to read from the volumes.
>
> 2. 02_silver.sql - Clean and transform bronze data into silver streaming tables.
>    Apply data quality constraints (NOT NULL on key columns, valid ranges,
>    temperature bounds for cold chain). Tables should be prefixed with "02_".
>    Standardize data types, trim strings, and handle nulls.
>
> 3. 03_gold.sql - Create gold materialized views with business-level aggregations.
>    Tables should be prefixed with "03_". Examples:
>    - 03_batch_quality_summary: Quality pass/fail rates by product and facility
>    - 03_cold_chain_compliance: Temperature compliance rates by route
>    - 03_inventory_status: Current inventory levels with expiry risk
>    - 03_sales_by_outlet: Sales aggregated by outlet, product, and time period
>    - 03_supply_chain_overview: End-to-end supply chain metrics from supplier to retail
>
> Deploy the pipeline to my Databricks workspace using the Databricks CLI with
> the WORKSHOP profile.
```

**Validate in the workspace:**
1. In the left sidebar, click **Pipelines** (under Data Engineering)
2. Find your pipeline: `<your_username>_ingestion`
3. Verify that the three SQL files are listed as source code

---

### Exercise 5: Validate and Run the Pipeline

Start the pipeline:

1. In the **Pipelines** page, click on `<your_username>_ingestion`
2. Click **Start** to run the pipeline
3. Monitor the DAG visualization as data flows through bronze → silver → gold

**If the pipeline doesn't have a root directory configured**, use this prompt in Claude Code:

```
> The pipeline <your_username>_ingestion doesn't have its root directory set.
> Update the pipeline configuration to set the root directory to the path where
> the SQL files were created. Use the Databricks CLI with the WORKSHOP profile.
```

**If the pipeline fails**, use Claude Code to troubleshoot:

```
> The pipeline <your_username>_ingestion failed. Can you check the pipeline
> status and error details using the Databricks CLI with the WORKSHOP profile,
> and suggest fixes?
```

**Validate the results:**
1. Go to **Catalog** → `<your_catalog>` → `<your_username>_demo`
2. Verify that tables exist with the `01_`, `02_`, and `03_` prefixes
3. Click on a few tables and preview the data to confirm it loaded correctly

---

### Exercise 6: Create Genie Spaces and Dashboards

Now let's make the gold-layer data accessible to business users through **Genie Spaces** and **Dashboards**.

**Create Genie Spaces:**

```
> Create 2 Databricks Genie spaces using the Databricks API with the WORKSHOP profile:
>
> 1. "<your_username> - Customer Analytics" - Include the gold tables related to
>    customers and risk profiles (e.g., 03_customer_360, 03_customer_risk_profile
>    for FSI, or 03_sales_by_outlet, 03_inventory_status for Pharma).
>    Add a description explaining what business questions this space can answer.
>
> 2. "<your_username> - Operations Analytics" - Include the gold tables related to
>    operations and performance (e.g., 03_transaction_daily_summary,
>    03_branch_performance for FSI, or 03_batch_quality_summary,
>    03_cold_chain_compliance for Pharma).
>    Add a description explaining what business questions this space can answer.
>
> Use the SQL warehouse available in the workspace.
```

**Create Dashboards:**

```
> Create 2 Databricks Lakeview dashboards using the Databricks API with the
> WORKSHOP profile:
>
> 1. "<your_username> - Customer Insights Dashboard" - Build a dashboard with
>    4-6 visualizations from the customer-related gold tables. Include:
>    - A summary counter/stat for total customers
>    - A bar chart showing distribution by segment or type
>    - A time series chart showing trends
>    - A table with detailed metrics
>
> 2. "<your_username> - Operations Dashboard" - Build a dashboard with 4-6
>    visualizations from the operations-related gold tables. Include:
>    - Key operational metrics as counters
>    - A bar or pie chart for categorical breakdowns
>    - A time series showing operational trends
>    - A detailed table view
>
> Use the SQL warehouse available in the workspace and publish both dashboards.
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
| Exercise 4 | A Spark Declarative Pipeline with bronze, silver, and gold layers |
| Exercise 5 | Ran and validated the end-to-end pipeline |
| Exercise 6 | Genie spaces and dashboards for business analytics |

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
