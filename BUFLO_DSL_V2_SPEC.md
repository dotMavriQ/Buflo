# BUFLO DSL v2.0 Specification

## Overview
Enhanced JSON-like configuration format for invoice generation with layout control, validation, and PDF rendering.

## Core Concepts

### Pages
Documents are organized into pages. Each page auto-fits content and handles pagination.

### Sections
Sections define layout blocks with positioning, styling, and field grouping.

### Fields
Fields can be text inputs, calculated values, uploads, or static text. Support validation and formatting.

### Layout Directives
Control positioning (horizontal/vertical), alignment, styling, and spacing.

## Syntax

```buflo
{
  # Document metadata
  document: {
    title: "Invoice"
    version: "1.0"
    auto_fit: true  # Auto-resize content to fit page
  }

  # Global settings
  settings: {
    currency: "€"
    date_format: "YYYY-MM-DD"
    number_format: "0,0.00"
    font_family: "Helvetica"
    page_size: "A4"  # A4, Letter, etc.
  }

  # Page definitions
  pages: [
    {
      name: "invoice_page"

      # Sections define layout blocks
      sections: [
        {
          # Header section - two column layout
          type: "columns"
          columns: 2
          gap: 40

          # Left column - Invoice To
          left: {
            heading: {
              text: "Invoice to:"
              style: "bold"
              size: 14
            }
            fields: [
              {
                id: "client_name"
                label: "Client Name"
                type: "text"
                required: true
                placeholder: "Company Name"
              }
              {
                id: "address1"
                label: "Address Line 1"
                type: "text"
                required: true
              }
              {
                id: "address2"
                label: "Address Line 2"
                type: "text"
                required: false
              }
              {
                id: "vat_number"
                label: "VAT:"
                type: "text"
                format: "vat"
                required: true
              }
            ]
          }

          # Right column - Logo
          right: {
            logo: {
              id: "company_logo"
              type: "image_upload"
              position: "top-right"
              max_width: 200
              max_height: 100
              margin: 20
              required: false
              default: "assets/default_logo.png"
            }
          }
        }

        {
          # Invoice details - horizontal layout
          type: "horizontal_fields"
          style: "bold_headers"
          spacing: "distributed"  # Evenly space across page width

          fields: [
            {
              id: "invoice_number"
              label: "Invoice no.:"
              type: "text"
              format: "invoice_number"
              required: true
              generator: "@invoice_number"  # Auto-generate
            }
            {
              id: "invoice_date"
              label: "Invoice date:"
              type: "date"
              required: true
              default: "@today"
            }
            {
              id: "due_date"
              label: "Due date:"
              type: "date"
              required: true
              default: "@calc(invoice_date + 30)"
            }
          ]
        }

        {
          # Period section
          type: "group"
          spacing: 10

          heading: {
            text: "Period:"
            style: "bold"
            size: 12
          }

          fields: [
            {
              id: "period_month"
              label: "Month"
              type: "select"
              options: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
              required: true
            }
            {
              id: "period_year"
              label: "Year"
              type: "number"
              required: true
              default: "@year"
            }
          ]
        }

        {
          # Contractor/Freelancer details
          type: "group"
          spacing: 5

          fields: [
            {
              id: "contractor_name"
              label: "Name:"
              type: "text"
              required: true
            }
            {
              id: "contractor_address"
              label: "Address:"
              type: "text"
              required: true
            }
            {
              id: "contractor_email"
              label: "Email:"
              type: "email"
              required: true
              validation: "email"
            }
            {
              id: "contractor_phone"
              label: "Phone:"
              type: "tel"
              required: true
              format: "+{country_code}"
            }
            {
              id: "contractor_tin"
              label: "TIN:"
              type: "text"
              required: true
            }
            {
              id: "contractor_vat"
              label: "VAT No.:"
              type: "text"
              required: true
            }
          ]
        }

        {
          # Bank Details section
          type: "group"
          spacing: 5

          heading: {
            text: "BANK DETAILS"
            style: "bold"
            size: 12
          }

          fields: [
            {
              id: "bank_name"
              label: "Bank:"
              type: "text"
              required: true
            }
            {
              id: "bank_address"
              label: "Bank Address:"
              type: "text"
              required: true
            }
            {
              id: "account_name"
              label: "Account Name:"
              type: "text"
              required: true
            }
            {
              id: "iban"
              label: "IBAN:"
              type: "text"
              format: "iban"
              required: true
            }
            {
              id: "bic"
              label: "BIC:"
              type: "text"
              format: "bic"
              required: true
            }
          ]
        }

        {
          # Service description
          type: "spacer"
          height: 10
        }

        {
          type: "group"
          spacing: 5

          fields: [
            {
              id: "service_description"
              label: "Service:"
              type: "textarea"
              rows: 2
              required: true
              placeholder: "Professional consulting services for..."
            }
            {
              id: "schedule"
              label: "Schedule:"
              type: "text"
              required: false
              placeholder: "08:00-17:00"
            }
          ]
        }

        {
          # Billing table
          type: "table"
          style: "bordered"
          header_style: "bold"

          columns: [
            {
              id: "description"
              label: "Description"
              type: "text"
              width: "40%"
              required: true
            }
            {
              id: "quantity"
              label: "Quantity"
              type: "number"
              width: "20%"
              required: true
              min: 0
            }
            {
              id: "rate"
              label: "Rate (€)"
              type: "currency"
              width: "20%"
              required: true
              min: 0
            }
            {
              id: "amount"
              label: "Amount (€)"
              type: "currency"
              width: "20%"
              calculated: true
              formula: "@calc(quantity * rate)"
            }
          ]

          # Allow multiple rows
          repeatable: true
          min_rows: 1
          max_rows: 20

          # Summary row
          summary: {
            label: "TOTAL"
            style: "bold"
            calculated: true
            formula: "@sum(items.amount)"
          }
        }
      ]
    }
  ]

  # Validation rules
  validation: {
    # Ensure due date is after invoice date
    rules: [
      {
        condition: "due_date > invoice_date"
        error: "Due date must be after invoice date"
      }
      {
        condition: "@sum(items.amount) > 0"
        error: "Invoice total must be greater than zero"
      }
    ]
  }

  # Special value generators
  generators: {
    invoice_number: "INV-@{date:%Y%m%d}-@{sequence:001}"
  }
}
```

## Field Types

### Input Types
- `text` - Single line text
- `textarea` - Multi-line text
- `number` - Numeric input
- `currency` - Formatted currency
- `date` - Date picker
- `email` - Email with validation
- `tel` - Phone number
- `select` - Dropdown
- `image_upload` - File upload for images

### Validation
- `required: true/false` - Mark field as mandatory
- `min/max` - Range validation for numbers
- `format` - Predefined formats (vat, iban, bic, email, phone)
- `validation` - Custom regex or validation rule
- `pattern` - Regex pattern

### Special Values
- `@today` - Current date
- `@year` - Current year
- `@date:%format` - Formatted date
- `@calc(expression)` - Calculate value
- `@sum(array.field)` - Sum array values
- `@uuid` - Generate UUID
- `@sequence:format` - Auto-increment sequence

## Layout Types

### Section Types
- `columns` - Multi-column layout
- `horizontal_fields` - Fields in a row
- `group` - Vertical group of fields
- `table` - Repeating rows with columns
- `spacer` - Empty space

### Styling
- `bold`, `italic`, `underline`
- `size: number` - Font size
- `color: hex` - Text color
- `align: left|center|right`

## PDF Rendering

The `.buflo` file maps directly to PDF generation:
1. Each page becomes a PDF page
2. Sections define layout containers
3. Fields are rendered with their labels and values
4. Tables auto-expand with data
5. Calculated fields update dynamically
6. Validation runs before PDF generation

## Example Simplified Invoice

```buflo
{
  document: {
    title: "Simple Invoice"
  }

  pages: [
    {
      sections: [
        {
          type: "columns"
          left: {
            heading: "Invoice to:"
            fields: [
              { id: "client_name", type: "text", required: true }
              { id: "client_vat", type: "text", label: "VAT:", required: true }
            ]
          }
          right: {
            logo: { type: "image_upload", position: "top-right" }
          }
        }

        {
          type: "table"
          columns: [
            { id: "item", label: "Description", type: "text" }
            { id: "qty", label: "Quantity", type: "number" }
            { id: "price", label: "Price", type: "currency" }
            { id: "total", label: "Total", calculated: true, formula: "@calc(qty * price)" }
          ]
          summary: { label: "TOTAL", formula: "@sum(items.total)" }
        }
      ]
    }
  ]
}
```

This DSL provides:
- ✅ Complex multi-section layouts
- ✅ Mandatory field validation
- ✅ Calculated fields
- ✅ Table/repeating sections
- ✅ Image uploads
- ✅ Auto-formatting
- ✅ PDF-ready structure
