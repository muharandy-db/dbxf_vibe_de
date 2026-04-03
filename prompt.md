i want to create a workshop tutorial of vibe data engineering with databricks express edition. The tutorial assumes that the workshop attendees will already have an access to a databricks workspace.

the tutorial starts with asking the workshop participant to check the cloned repository (this repo). Under data/ directory there will be folders such as:
- fsi
- pharma


we can start with these two for now. then inside each of these directories there will be subdirectories for data samples in CSV. Each CSV will be under their own directory. Each CSV will contain around 1000-10000 records. I want to simulate data ingestions and pipeline starting from bronze to silver to gold. For example, in fsi sample data we can have:
- insurance_customers
- insurance_policies
- insurance_payments
- banking_customers
- banking_transactions
- banking_branches
- etc...

an in pharma we can have:
- distribution_cold_chains
- distribution_warehouse
- manufacturing_batches
- manufacturing_quality
- retail_outlets
- retail_inventory
- retail_sales
- supply_materials
- supply_suppliers
- etc...

The repo will also contain README.md which contains this tutorial.
then the tutorial we'll continue with asking the participants to make sure the prerequisites are met:
- having access to workspace
- install claude code (give instruction on how to do it via command line for windows and amc)
- clone https://github.com/databricks-solutions/ai-dev-kit/tree/main
- install databricks cli and configure a profile to access their workspace

once done, ask the participant to check their workspace and then go to AI Gateway in the workspace to connect with claude code following this tutorial:
- https://dbxdev.medium.com/turning-databricks-into-an-ai-pair-programmer-with-claude-powered-coding-agents-1665ad0bb43f

Please rewrite it, make sure you change model serving to AI Gateway since it's what it's being called now (refer to https://docs.databricks.com/aws/en/ai-gateway/coding-agent-integration-beta but there's no claude code here)

once everything is configured, we can ask the user to start writing the prompt in claude code
1. start by giving prompt to ask claude code to create a schema under their catalog (ask them to check their catalog name) then give instruction to create schema called <their_username>_demo under their catalog. Once done, give instruction to check and validate in the workspace
2. then give prompt to ask claude to create landing volume under the recently created schema. Once done, give instruction to check and validate in the workspace
3. then give another prompt to ask claude code to upload each of the files under their chosen industry (for example fsi) into a landing volume. Remember that each CSV files should be put under their own directory
4. give another prompt to ask claude to create spark declarative pipeline using SQL to load the files from the volumes. Name the pipeline as <their_username>_ingestions. The pipeline should contain 01_bronze.sql, 02_silver.sql, and 03_gold.sql respectively for bronze, silver, and gold transformations. And resulting target table should have 01_, 02_, 03_ prefix to indicate bronze, silver, and gold tables. The tables in bronze and silver should be streaming table whenever possible
5. once done, ask the participant to check if the pipeline is created and run. If the pipeline doesn't have root directory, suggest a prompt to set root directory for the pipeline
6. give prompt to create 2 genie spaces and 2 dashboards from the gold tables
