# Storage Module - GCS Buckets & BigQuery

Creates all data storage resources: GCS buckets for raw data and BigQuery datasets/tables for the data warehouse.

## Purpose

Implements the storage layer of the data platform with cost optimization features like partitioning and lifecycle policies.

## Resources Created

- GCS bucket with lifecycle policies
- BigQuery dataset
- Raw tables: `raw_invoice`, `raw_country`
- Optimized table configurations (partitioning, clustering)

## Features

- ✅ **Partitioning** - Date-based partitioning for cost optimization
- ✅ **Lifecycle Policies** - Automatic data archival and deletion
- ✅ **Encryption** - Data encrypted at rest by default
- ✅ **Versioning** - GCS object versioning for data recovery

## Usage

See module README for implementation details.
