# Vibe Data Engineering Workshop with Databricks

Welcome to the **Vibe Data Engineering Workshop**! In this hands-on tutorial, you'll use **Claude Code** (an AI-powered coding agent) together with **Databricks** to build a complete data pipeline — from raw CSV ingestion to curated gold-layer tables, Genie spaces, and dashboards — all driven by natural language prompts.

> **What is Vibe Data Engineering?** It's the practice of using AI coding agents to build and manage data pipelines through conversational prompts instead of writing every line of code manually. You describe *what* you want, and the AI helps you build it.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Repository Overview](#2-repository-overview)
3. [Setting Up Claude Code](#3-setting-up-claude-code)
4. [Connecting Claude Code to Databricks AI Gateway](#4-connecting-claude-code-to-databricks-ai-gateway)
5. [Choose Your Tutorial](#5-choose-your-tutorial)

---

## 1. Prerequisites

Before you begin, make sure you have:
- Access to a **Databricks workspace** (confirm you can log in)
- **Git** installed on your machine
- **Node.js 18+** installed ([nodejs.org](https://nodejs.org/)) — required for Claude Code on Windows/Linux
- **Homebrew** (macOS) or **winget** (Windows) — for package installs

> If you don't have workspace access yet, contact your workshop facilitator before proceeding.

### One-Command Setup

The installer will handle everything: Claude Code, Databricks CLI, CLI profile configuration, repo cloning, and AI Dev Kit installation.

**macOS / Linux:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/muharandy-db/dbxf_vibe_de/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/muharandy-db/dbxf_vibe_de/main/install.ps1 | iex
```

The script will walk you through each step interactively. Once complete, you'll be inside the `dbxf_vibe_de` directory with everything configured.

<details>
<summary><strong>What does the installer do?</strong></summary>

1. Installs **Claude Code** (via Homebrew or npm)
2. Installs **Databricks CLI** (via Homebrew, winget, or curl)
3. Configures a Databricks CLI profile called `WORKSHOP` (prompts for workspace URL and token)
4. Clones this repository
5. Installs the **Databricks AI Dev Kit** (MCP server + skills for Claude Code)
6. Verifies everything is working

</details>

<details>
<summary><strong>Prefer to install manually?</strong></summary>

If you'd rather set things up step by step:

1. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
2. Install Databricks CLI: `brew install databricks` (macOS) / `winget install Databricks.DatabricksCLI` (Windows)
3. Configure profile: `databricks configure --profile WORKSHOP`
4. Clone repo: `git clone https://github.com/muharandy-db/dbxf_vibe_de.git && cd dbxf_vibe_de`
5. Install AI Dev Kit: `bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh)`

</details>

### Checklist

Before moving on, confirm:

- [ ] `claude --version` returns a version number
- [ ] `databricks --version` returns a version number
- [ ] `databricks workspace list / --profile WORKSHOP` returns workspace contents
- [ ] You are in the `dbxf_vibe_de` directory
- [ ] `.claude/` directory exists in the project root

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

## 5. Choose Your Tutorial

Pick an industry and follow the step-by-step tutorial. Each tutorial contains 8 exercises that guide you through building a complete data pipeline using Claude Code prompts.

| Tutorial | Description | Exercises |
|----------|-------------|-----------|
| [**FSI (Financial Services)**](TUTORIAL_FSI.md) | Banking customers, accounts, transactions, insurance policies, and claims | 8 exercises |
| [**Pharma (Pharmaceutical)**](TUTORIAL_PHARMA.md) | Manufacturing batches, quality control, cold chain distribution, retail sales, and supply chain | 8 exercises |

Both tutorials follow the same structure:

1. Create a schema
2. Create a landing volume
3. Upload sample data
4. Build the bronze layer (raw ingestion)
5. Build the silver layer (data quality)
6. Build the gold layer (business aggregations — one table at a time)
7. Validate and run the pipeline
8. Create Genie spaces and dashboards

---

> **Workshop created for Databricks Express Edition**
> For questions or feedback, reach out to your workshop facilitator.
