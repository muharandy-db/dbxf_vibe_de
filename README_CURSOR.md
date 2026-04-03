# Vibe Data Engineering Workshop with Databricks (Cursor)

Welcome to the **Vibe Data Engineering Workshop**! In this hands-on tutorial, you'll use **Cursor** (an AI-powered IDE by Anysphere) together with **Databricks** to build a complete data pipeline — from raw CSV ingestion to curated gold-layer tables, Genie spaces, and dashboards — all driven by natural language prompts.

> **What is Vibe Data Engineering?** It's the practice of using AI coding agents to build and manage data pipelines through conversational prompts instead of writing every line of code manually. You describe *what* you want, and the AI helps you build it.

### Choose Your Coding Agent

| Coding Agent | Provider | Guide |
|-------------|----------|-------|
| **Claude Code** | Anthropic | [**Go to Claude Code setup**](README.md) |
| **Codex CLI** | OpenAI | [**Go to Codex CLI setup**](README_CODEX.md) |
| **Cursor** | Anysphere | You are here |

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Repository Overview](#2-repository-overview)
3. [Setting Up Cursor](#3-setting-up-cursor)
4. [Connecting Cursor to Databricks AI Gateway](#4-connecting-cursor-to-databricks-ai-gateway)
5. [Choose Your Tutorial](#5-choose-your-tutorial)

---

## 1. Prerequisites

Before you begin, make sure you have:
- Access to a **Databricks workspace** ([sign up for a free trial](https://www.databricks.com/try-databricks) if you don't have one)
- **Git** installed on your machine
- **Cursor** installed ([cursor.com](https://www.cursor.com/)) — the AI-powered IDE
- **Homebrew** (macOS) or **winget** (Windows) — for package installs

> If you don't have workspace access yet, contact your workshop facilitator before proceeding.

### One-Command Setup

The installer will handle Databricks CLI, CLI profile configuration, repo cloning, and AI Dev Kit installation. Cursor must be installed separately beforehand.

**macOS / Linux:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/muharandy-db/dbxf_vibe_de/main/install.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/muharandy-db/dbxf_vibe_de/main/install.ps1 | iex
```

When prompted, select **Cursor** as your coding agent.

The script will walk you through each step interactively. Once complete, you'll be inside the `dbxf_vibe_de` directory with everything configured.

<details>
<summary><strong>What does the installer do?</strong></summary>

1. Confirms **Cursor** is installed
2. Installs **Databricks CLI** (via Homebrew, winget, or curl)
3. Configures a Databricks CLI profile called `WORKSHOP` (prompts for workspace URL and token)
4. Clones this repository
5. Installs the **Databricks AI Dev Kit** (MCP server + skills for your coding agent)
6. Verifies everything is working

</details>

<details>
<summary><strong>Prefer to install manually?</strong></summary>

If you'd rather set things up step by step:

1. Install Cursor: Download from [cursor.com](https://www.cursor.com/)
2. Install Databricks CLI: `brew install databricks` (macOS) / `winget install Databricks.DatabricksCLI` (Windows)
3. Configure profile: `databricks configure --profile WORKSHOP`
4. Clone repo: `git clone https://github.com/muharandy-db/dbxf_vibe_de.git && cd dbxf_vibe_de`
5. Install AI Dev Kit: `bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh)`

</details>

### Checklist

Before moving on, confirm:

- [ ] Cursor is installed and opens successfully
- [ ] `databricks --version` returns a version number
- [ ] `databricks workspace list / --profile WORKSHOP` returns workspace contents
- [ ] You are in the `dbxf_vibe_de` directory
- [ ] `.cursor/` directory exists in the project root

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

## 3. Setting Up Cursor

Once Cursor and the AI Dev Kit are installed, open the workshop repository in Cursor:

1. Launch **Cursor**
2. Go to **File → Open Folder** and select the `dbxf_vibe_de` directory
3. The AI Dev Kit installer has already configured the Databricks MCP server and skills in `.cursor/mcp.json`

To start interacting with the AI agent, open the **Composer** panel:
- Press `Cmd+I` (macOS) or `Ctrl+I` (Windows/Linux) to open Composer
- Or click the **Composer** icon in the sidebar

> **Tip:** Make sure you're in **Agent** mode (not just "Ask" or "Edit") so that Cursor can execute commands and interact with your Databricks workspace through the MCP tools.

---

## 4. Connecting Cursor to Databricks AI Gateway

Databricks **AI Gateway** allows you to route AI model requests through your Databricks workspace, giving you centralized governance, observability, and cost management for all your AI coding tools.

> **Why use AI Gateway?** Instead of each developer using their own API key, AI Gateway routes all requests through Databricks — giving you unified billing, usage monitoring, and governance across all coding tools.

### Step 1: Open AI Gateway in Your Workspace

1. Log in to your **Databricks workspace**
2. In the left sidebar, click on **AI Gateway**
3. Click **Coding agents** tab, then click **Other Integrations**

### Step 2: Select Cursor and Configure Models

1. Select **Cursor** as your coding integration
2. Choose your preferred models for each role (primary, secondary, etc.)
3. Review the settings and proceed to the next step

### Step 3: Copy the Configuration

Databricks will show you the configuration details and a **Generate API Key** button. Click it to generate your API key, then copy the configuration.

### Step 4: Configure Cursor

Open Cursor and go to **Settings → Models**:

1. Click **Add Model** or edit an existing model configuration
2. Set the **API Base URL** to your AI Gateway endpoint:
   ```
   https://<your-ai-gateway-url>/openai/v1
   ```
3. Set the **API Key** to the key generated in Step 3
4. Select the model name shown in the AI Gateway configuration

Alternatively, you can configure this in your Cursor settings JSON:

```json
{
  "models": {
    "providers": [
      {
        "name": "Databricks AI Gateway",
        "baseUrl": "https://<your-ai-gateway-url>/openai/v1",
        "apiKey": "<your_token_will_appear_here>",
        "models": ["databricks-claude-sonnet-4-6"]
      }
    ]
  }
}
```

Replace:
- `<your-ai-gateway-url>` with the AI Gateway URL shown in Step 3 (e.g., `https://7474644321313099.ai-gateway.cloud.databricks.com`)
- `<your_token_will_appear_here>` with the API key generated in Step 3

### Step 5: Verify the Connection

Open the Composer panel and try a simple prompt:
```
Hello, can you confirm you're connected?
```

If you get a response, you're all set! You can also check the **AI Gateway dashboard** in your workspace to see the request appear in the usage metrics.

### Observability

Once connected, go back to **AI Gateway** in your workspace and click **View dashboard** to monitor:
- Request volume and latency
- Token usage and cost
- Per-user activity across all connected coding tools

---

## 5. Choose Your Tutorial

Pick an industry and follow the step-by-step tutorial. Each tutorial contains 8 exercises that guide you through building a complete data pipeline using your coding assistant.

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

> **Workshop guide for Cursor** — by Anysphere
>
> For other coding agents, see [Claude Code](README.md) or [Codex CLI](README_CODEX.md).
> For questions or feedback, reach out to your workshop facilitator.
