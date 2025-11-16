# BUFLO TOML Profile Specification

Complete guide to creating invoice profiles for BUFLO using TOML format.

**Version**: 3.0
**Last Updated**: November 2025

---

## Table of Contents

- [Overview](#overview)
- [Profile Structure](#profile-structure)
- [Document Metadata](#document-metadata)
- [Settings](#settings)
- [Sections](#sections)
- [Field Types](#field-types)
- [Section Types](#section-types)
- [Formulas and Calculations](#formulas-and-calculations)
- [Complete Examples](#complete-examples)

---

## Overview

BUFLO profiles are defined using standard TOML (Tom's Obvious Minimal Language) format. TOML is easy to read, write, and parse, making it perfect for configuration files.

### Why TOML?

- **Standard format**: Well-documented and widely supported
- **Human-readable**: Clear, minimal syntax
- **Structured**: Supports nested tables and arrays naturally
- **No custom DSL**: Learn once, use everywhere

### Basic TOML Syntax

```toml
# Comments start with #

# Key-value pairs
key = "value"
number = 42
boolean = true
date = 2025-11-16

# Tables (objects)
[table_name]
field = "value"

# Arrays of tables (repeated structures)
[[array_name]]
item1 = "value1"

[[array_name]]
item2 = "value2"
```

---

## Profile Structure

Every BUFLO profile has three main sections:

```toml
[document]          # Metadata about the document
# ...

[settings]          # Display and formatting settings
# ...

[[section]]         # Repeatable sections containing fields
# ...
```

---

## Document Metadata

Describes the invoice template.

### Required Fields

```toml
[document]
title = "My Invoice Template"
version = "3.0"
```

### Optional Fields

```toml
[document]
title = "Consulting Invoice"
version = "3.0"
description = "Standard invoice for consulting services"
author = "Your Name"
created = 2025-11-16
```

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Display name of the template (required) |
| `version` | string | Profile version, use "3.0" (required) |
| `description` | string | Template description |
| `author` | string | Template creator |
| `created` | date | Creation date (YYYY-MM-DD) |

---

## Settings

Configure currency, date formats, and display preferences.

### Currency Settings

```toml
[settings]
currency = "€"           # Currency symbol
currency_position = "after"  # "before" or "after"
decimal_places = 2       # Number of decimal places
thousands_separator = ","    # Thousands separator
decimal_separator = "."      # Decimal separator
```

### Date Settings

```toml
[settings]
date_format = "YYYY-MM-DD"   # ISO format
# or
date_format = "MM/DD/YYYY"   # US format
# or
date_format = "DD.MM.YYYY"   # European format
```

### Page Settings

```toml
[settings]
page_size = "A4"         # A4, Letter, Legal
margin_top = "15mm"
margin_bottom = "15mm"
margin_left = "20mm"
margin_right = "20mm"
```

### Complete Settings Example

```toml
[settings]
currency = "€"
date_format = "YYYY-MM-DD"
page_size = "A4"
```

---

## Sections

Sections organize fields into logical groups. Profiles can have multiple sections.

### Basic Section

```toml
[[section]]
heading = "Client Information"

[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true
```

### Section Without Heading

```toml
[[section]]

[[section.field]]
id = "invoice_date"
label = "Invoice Date"
type = "date"
default = "2025-11-16"
```

---

## Field Types

### Text Field

Single-line text input.

```toml
[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true
placeholder = "Enter company name"
default = "ACME Corp"
```

### Number Field

Numeric input.

```toml
[[section.field]]
id = "quantity"
label = "Quantity"
type = "number"
required = true
min = 1
max = 1000
default = 1
```

### Currency Field

Monetary amounts (formatted according to settings).

```toml
[[section.field]]
id = "amount"
label = "Amount"
type = "currency"
required = true
default = 0
```

### Date Field

Date picker.

```toml
[[section.field]]
id = "invoice_date"
label = "Invoice Date"
type = "date"
required = true
default = "2025-11-16"
```

### Email Field

Email input with validation.

```toml
[[section.field]]
id = "client_email"
label = "Email"
type = "email"
required = true
placeholder = "client@example.com"
```

### Tel Field

Phone number input.

```toml
[[section.field]]
id = "phone"
label = "Phone"
type = "tel"
placeholder = "+1-555-0100"
```

### Image Upload Field

File picker for images (logos, signatures).

```toml
[[section.field]]
id = "company_logo"
label = "Company Logo"
type = "image_upload"
required = false
placeholder = "Click to upload or drag and drop"
```

### PDF Attachment Field

File picker for PDF files to merge with the invoice.

```toml
[[section.field]]
id = "timesheet_pdf"
label = "Attach Timesheet"
type = "pdf_attachment"
required = true
placeholder = "Drop PDF file here or click to browse"
```

### Field Properties Reference

| Property | Type | Description | Applicable To |
|----------|------|-------------|---------------|
| `id` | string | Unique field identifier (required) | All |
| `label` | string | Display label (required) | All |
| `type` | string | Field type (required) | All |
| `required` | boolean | Is field required? | All |
| `default` | string/number | Default value | All |
| `placeholder` | string | Placeholder text | text, email, tel |
| `min` | number | Minimum value | number, currency |
| `max` | number | Maximum value | number, currency |

---

## Section Types

### Group Section (Default)

Vertical stack of fields.

```toml
[[section]]
type = "group"  # or omit, group is default
heading = "Invoice Details"

[[section.field]]
id = "invoice_number"
label = "Invoice #"
type = "text"

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"
```

### Horizontal Section

Fields displayed inline (side-by-side).

```toml
[[section]]
type = "horizontal"

[[section.field]]
id = "invoice_number"
label = "Invoice #"
type = "text"

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"

[[section.field]]
id = "due_date"
label = "Due Date"
type = "date"
```

### Column Section

Two-column layout (left and right).

```toml
[[section]]
type = "columns"

[[section.column]]
heading = "Bill To"

[[section.column.field]]
id = "client_name"
label = "Client"
type = "text"

[[section.column.field]]
id = "client_address"
label = "Address"
type = "text"

[[section.column]]
heading = "Bill From"

[[section.column.field]]
id = "company_name"
label = "Company"
type = "text"

[[section.column.field]]
id = "company_address"
label = "Address"
type = "text"
```

### Table Section

Repeating rows with calculated columns (line items).

```toml
[[section]]
type = "table"
id = "line_items"

[[section.column]]
id = "description"
label = "Description"
type = "text"
width = "40%"
required = true

[[section.column]]
id = "quantity"
label = "Quantity"
type = "number"
width = "20%"
default = 1

[[section.column]]
id = "rate"
label = "Rate (€)"
type = "currency"
width = "20%"
default = 0

[[section.column]]
id = "amount"
label = "Amount (€)"
type = "currency"
width = "20%"
formula = "@calc(quantity * rate)"

[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"

[section.defaults]
description = "Consulting Services"
quantity = 1
rate = 100.00
```

---

## Formulas and Calculations

BUFLO supports automatic calculations using formulas.

### @calc() - Calculate Expression

Calculate a value from an arithmetic expression.

**Syntax:**
```toml
formula = "@calc(expression)"
```

**Examples:**
```toml
# Multiply quantity by rate
formula = "@calc(quantity * rate)"

# Add tax
formula = "@calc(subtotal * 1.25)"

# Complex calculation
formula = "@calc((quantity * rate) - discount)"
```

**Supported Operations:**
- Addition: `+`
- Subtraction: `-`
- Multiplication: `*`
- Division: `/`
- Parentheses: `( )`

### @sum() - Sum Array Field

Sum values from a table column.

**Syntax:**
```toml
formula = "@sum(items.field_id)"
```

**Examples:**
```toml
# Sum all amounts in line_items table
[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"

# Can also sum quantities
formula = "@sum(items.quantity)"
```

### Calculated Column Example

```toml
[[section]]
type = "table"
id = "line_items"

# Regular input columns
[[section.column]]
id = "description"
label = "Description"
type = "text"

[[section.column]]
id = "quantity"
label = "Qty"
type = "number"

[[section.column]]
id = "rate"
label = "Rate"
type = "currency"

# Calculated column
[[section.column]]
id = "amount"
label = "Amount"
type = "currency"
formula = "@calc(quantity * rate)"

# Summary row
[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"
```

---

## Complete Examples

### Simple Invoice

```toml
[document]
title = "Simple Invoice"
version = "3.0"

[settings]
currency = "$"
date_format = "MM/DD/YYYY"

[[section]]
heading = "Invoice Information"

[[section.field]]
id = "invoice_number"
label = "Invoice #"
type = "text"
required = true

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"
required = true

[[section]]
heading = "Client"

[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true

[[section.field]]
id = "amount"
label = "Amount Due"
type = "currency"
required = true
```

### Invoice with Line Items

```toml
[document]
title = "Consulting Invoice"
version = "3.0"

[settings]
currency = "€"
date_format = "YYYY-MM-DD"

[[section]]
type = "horizontal"

[[section.field]]
id = "invoice_number"
label = "Invoice #"
type = "text"
required = true

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"
required = true

[[section.field]]
id = "due_date"
label = "Due Date"
type = "date"
required = true

[[section]]
heading = "Client Information"

[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true

[[section.field]]
id = "client_email"
label = "Email"
type = "email"

[[section]]
type = "table"
id = "line_items"

[[section.column]]
id = "description"
label = "Description"
width = "40%"

[[section.column]]
id = "quantity"
label = "Quantity"
type = "number"
width = "20%"

[[section.column]]
id = "rate"
label = "Rate (€)"
type = "currency"
width = "20%"

[[section.column]]
id = "amount"
label = "Amount (€)"
type = "currency"
width = "20%"
formula = "@calc(quantity * rate)"

[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"

[section.defaults]
description = "Consulting Services"
quantity = 1
rate = 150.00
```

### Invoice with PDF Attachment

```toml
[document]
title = "Monthly Invoice with Timesheet"
version = "3.0"

[settings]
currency = "€"
date_format = "YYYY-MM-DD"

[[section]]
heading = "Invoice Details"

[[section.field]]
id = "invoice_number"
label = "Invoice Number"
type = "text"
required = true

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"
required = true

[[section]]
heading = "Client"

[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true

[[section]]
type = "table"
id = "line_items"

[[section.column]]
id = "description"
label = "Description"
width = "40%"

[[section.column]]
id = "quantity"
label = "Days"
type = "number"
width = "20%"

[[section.column]]
id = "rate"
label = "Daily Rate (€)"
type = "currency"
width = "20%"

[[section.column]]
id = "amount"
label = "Amount (€)"
type = "currency"
width = "20%"
formula = "@calc(quantity * rate)"

[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"

[[section]]
heading = "Attachments"

[[section.field]]
id = "timesheet_pdf"
label = "Attach Timesheet PDF"
type = "pdf_attachment"
required = true
placeholder = "Drop PDF file here or click to browse"
```

### Invoice with Columns Layout

```toml
[document]
title = "Professional Invoice"
version = "3.0"

[settings]
currency = "$"
date_format = "MM/DD/YYYY"

[[section]]
type = "columns"

[[section.column]]
heading = "Bill To"

[[section.column.field]]
id = "client_name"
label = "Company"
type = "text"
required = true

[[section.column.field]]
id = "client_address"
label = "Address"
type = "text"

[[section.column.field]]
id = "client_email"
label = "Email"
type = "email"

[[section.column]]

[[section.column.field]]
id = "company_logo"
label = "Logo"
type = "image_upload"

[[section]]
type = "horizontal"

[[section.field]]
id = "invoice_number"
label = "Invoice #"
type = "text"
required = true

[[section.field]]
id = "invoice_date"
label = "Date"
type = "date"
required = true

[[section.field]]
id = "due_date"
label = "Due"
type = "date"
required = true

[[section]]
type = "table"
id = "services"

[[section.column]]
id = "service"
label = "Service"
width = "50%"

[[section.column]]
id = "amount"
label = "Amount"
type = "currency"
width = "50%"

[section.summary]
label = "TOTAL DUE"
formula = "@sum(items.amount)"
```

---

## Tips and Best Practices

### Field IDs

- Use lowercase with underscores: `client_name`, `invoice_date`
- Be descriptive: `line_items` not `li`
- Keep them unique within the profile

### Organization

- Group related fields in sections
- Use headings to improve readability
- Put invoice metadata first
- Line items in the middle
- Attachments/notes at the end

### Defaults

- Provide sensible defaults where possible
- Use current date for date fields: `default = "2025-11-16"`
- Pre-fill common values to speed up form filling

### Validation

- Mark required fields with `required = true`
- Use appropriate field types for automatic validation
- Email fields automatically validate email format
- Number fields enforce numeric input

### Tables

- Always include a description/name column
- Put calculated columns last
- Use `@calc()` for row calculations
- Use `@sum()` for totals
- Provide defaults for quick testing

### PDF Attachments

- Place in a separate "Attachments" section
- Make required if critical (timesheets, receipts)
- Use clear labels explaining what to attach
- The PDF pages will be appended after the invoice

---

## Validation Rules

BUFLO automatically validates:

- **Required fields**: Must have a value before submitting
- **Email fields**: Must be valid email format
- **Number fields**: Must be numeric
- **Min/max constraints**: Enforced for number and currency fields
- **PDF attachments**: Must be valid PDF file if required

---

## Troubleshooting

### Common Errors

**"Failed to parse profile"**
- Check TOML syntax (commas, quotes, brackets)
- Ensure all required fields are present
- Use a TOML validator online

**"Field ID not found"**
- Ensure field IDs are unique
- Check for typos in formula references

**"Calculation error"**
- Verify formula syntax: `@calc(a * b)` not `@calc(a x b)`
- Ensure referenced fields exist
- Check for division by zero

**"PDF validation failed"**
- Ensure `pdftoppm` is installed
- Check PDF file is not corrupted
- Verify file path is correct

---

## Getting Help

- **Documentation**: This file and README.md
- **Examples**: Check `profiles/diamond_dogs_llc.toml` for a complete example
- **Issues**: [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues)

---

**Version**: 3.0
**Last Updated**: November 2025
**Format**: TOML (Tom's Obvious Minimal Language)
