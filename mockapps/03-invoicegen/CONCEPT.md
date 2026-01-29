# InvoiceGen - Automated Invoice Generator

## Executive Summary

InvoiceGen is a CLI-first invoice generation tool designed for freelancers, small agencies, and consulting firms. It transforms invoice data from CSV or JSON files into professional PDF invoices using customizable templates. InvoiceGen eliminates the tedious manual process of creating invoices while ensuring consistent branding and accurate calculations.

Unlike cloud-based invoicing platforms that charge monthly fees and require uploading financial data to third-party servers, InvoiceGen runs entirely locally. This makes it ideal for privacy-conscious professionals, those with intermittent internet access, and businesses that prefer to keep financial data on-premises.

InvoiceGen leverages simple_template's Mustache engine for template customization, simple_decimal for precise currency calculations, and simple_pdf for professional PDF output. The CLI design enables automation through cron jobs, CI/CD integration, and scripting, making it perfect for recurring invoicing workflows.

## Problem Statement

**The problem:** Freelancers and small agencies spend hours each month creating invoices manually. They copy-paste client details, calculate totals, and format documents. Errors are common, branding is inconsistent, and the process doesn't scale.

**Current solutions:**
- **Manual creation:** Time-consuming, error-prone, inconsistent
- **Word/Excel templates:** Limited automation, manual calculations
- **Cloud platforms (FreshBooks, Wave):** $15-50/month, data in cloud, overkill for small volume
- **Generic PDF generators:** No invoice-specific features, poor templates
- **Accounting software (QuickBooks):** Expensive, complex, too much for invoicing only

**Our approach:** Provide a focused CLI tool that:
1. Reads invoice data from simple CSV/JSON files
2. Uses professional, customizable Mustache templates
3. Calculates totals with precision (no floating-point errors)
4. Outputs print-ready PDF invoices
5. Optionally emails invoices directly
6. Runs locally with zero cloud dependency

## Target Users

| User Type | Description | Key Needs |
|-----------|-------------|-----------|
| Primary: Freelancer | Independent consultant/developer | Quick invoice creation, professional look |
| Primary: Small Agency | 2-10 person firm | Batch invoicing, client tracking |
| Secondary: Accountant | Manages client billing | Consistent format, audit trail |
| Secondary: Project Manager | Tracks project billing | Line item detail, hourly rates |

## Value Proposition

**For** freelancers and small agencies
**Who** need to generate professional invoices regularly
**InvoiceGen** is a CLI invoice generator
**That** creates PDF invoices from templates and data files
**Unlike** expensive cloud invoicing platforms
**Our product** is private, offline-capable, and automation-friendly.

## Revenue Model

| Model | Description | Price Point |
|-------|-------------|-------------|
| Free Tier | 5 invoices/month, watermark | $0 |
| Pro | Unlimited invoices, no watermark | $9.99/month or $99/year |
| Business | Multi-user, email delivery, branding | $29.99/month or $299/year |
| Lifetime | One-time purchase, Pro features | $199 one-time |

**Pricing Rationale:**
- Free tier drives adoption and word-of-mouth
- Pro pricing below competitors ($15-50/month)
- Lifetime option appeals to one-time purchasers
- Business tier for growing teams

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time Saved | 90% reduction in invoice creation time | User surveys |
| Error Rate | 99% accurate calculations | Error tracking |
| Adoption | 10,000 downloads in year 1 | Download metrics |
| Conversion | 3% free-to-paid conversion | License activations |
| NPS Score | 55+ | Quarterly user surveys |
