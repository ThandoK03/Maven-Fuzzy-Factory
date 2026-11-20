# Task 1: Data Understanding and Preparation
Maven Fuzzy Factory | AnalystLab Africa Week 2 | Track 1: Data Analytics

## 1. Datasets and structure

| Table | Rows | Columns | Grain (one row = ) |
|---|---|---|---|
| website_sessions | 472,871 | 9 | one website visit |
| website_pageviews | 1,048,575* | 4 | one page viewed in a session |
| orders_mav | 32,313 | 8 | one customer order |
| order_items | 40,025 | 7 | one product line within an order |
| order_item_refunds | 1,731 | 5 | one refunded order item |
| products | 4 | 3 | one product |

*The pageviews file is cut off at the Excel row limit (see section 4).

Data period: 19 Mar 2012 to 19 Mar 2015.

## 2. Field review

| Table | Field | Type found | Correct type | Meaning |
|---|---|---|---|---|
| website_sessions | website_session_id | Integer | Whole number (ID) | Unique session ID (PK) |
| | created_at | Text | Date/Time | Session start |
| | user_id | Integer | Whole number (ID) | Visitor ID |
| | is_repeat_session | Integer | Whole number (0/1) | 1 = returning visitor |
| | utm_source | Text | Text | Paid source: gsearch, bsearch, socialbook |
| | utm_campaign | Text | Text | brand, nonbrand, desktop_targeted, pilot |
| | utm_content | Text | Text | Ad content |
| | device_type | Text | Text | desktop or mobile |
| | http_referer | Text | Text | Referring website |
| website_pageviews | website_pageview_id | Integer | Whole number (ID) | Unique pageview ID (PK) |
| | created_at | Text | Date/Time | Pageview time |
| | website_session_id | Integer | Whole number (ID) | Session (FK) |
| | pageview_url | Text | Text | Page visited |
| orders_mav | order_id | Integer | Whole number (ID) | PK |
| | created_at | Text | Date/Time | Order time |
| | website_session_id | Integer | Whole number (ID) | Session that produced the order (FK) |
| | user_id | Integer | Whole number (ID) | Customer |
| | primary_product_id | Integer | Whole number (ID) | First product in the order (FK) |
| | items_purchased | Integer | Whole number | 1 or 2 items |
| | price_usd | Float | Decimal | Order revenue |
| | cogs_usd | Float | Decimal | Cost of goods sold |
| order_items | order_item_id | Integer | Whole number (ID) | PK |
| | created_at | Text | Date/Time | Item time |
| | order_id | Integer | Whole number (ID) | Order (FK) |
| | product_id | Integer | Whole number (ID) | Product (FK) |
| | is_primary_item | Integer | Whole number (0/1) | 1 = the first item in the order |
| | price_usd, cogs_usd | Float | Decimal | Item revenue and cost |
| order_item_refunds | order_item_refund_id | Integer | Whole number (ID) | PK |
| | created_at | Text | Date/Time | Refund time |
| | order_item_id | Integer | Whole number (ID) | Refunded item (FK) |
| | order_id | Integer | Whole number (ID) | Order (FK) |
| | refund_amount_usd | Float | Decimal | Refund value |
| products | product_id | Integer | Whole number (ID) | PK |
| | created_at | Text | Date/Time | Launch date |
| | product_name | Text | Text | Product name |

## 3. Keys and relationships

| Relationship | Type |
|---|---|
| website_sessions.website_session_id -> website_pageviews.website_session_id | one to many |
| website_sessions.website_session_id -> orders_mav.website_session_id | one to zero-or-one |
| orders_mav.order_id -> order_items.order_id | one to many |
| products.product_id -> order_items.product_id | one to many |
| products.product_id -> orders_mav.primary_product_id | one to many |
| order_items.order_item_id -> order_item_refunds.order_item_id | one to zero-or-one |
| orders_mav.order_id -> order_item_refunds.order_id | one to many |

Primary keys: the first column of every table (all verified unique, zero duplicates).

## 4. Data quality checks and results

| Check | Result |
|---|---|
| Duplicate rows (all six tables) | 0 |
| Duplicate primary keys | 0 |
| Orphan foreign keys (orders to sessions, orders to products, items to orders, items to products, refunds to items, refunds to orders, pageviews to sessions) | 0 for every relationship |
| items_purchased equals number of order_items rows | 0 mismatches |
| Exactly one primary item per order | True for all orders |
| Order revenue equals sum of its item revenue | 0 mismatches |
| Refund order_id matches the item's order_id | 0 mismatches |
| Refund larger than item price | 0 |
| Zero or negative prices; COGS above price | 0 |
| Leading/trailing spaces in text fields | 0 |

### Issues found
1. **Dates stored as text** in all tables (format M/D/YYYY H:MM). Converted to Date/Time.
2. **Missing values in website_sessions, stored as the text "NULL":**
   - `utm_source`, `utm_campaign` and `utm_content` are "NULL" together in 83,328 sessions. These are not errors: they are sessions that did not come from a paid campaign (direct or organic). The CSV holds the word NULL rather than an empty cell, so it had to be converted to a true null first.
   - `http_referer` is "NULL" in 39,917 sessions. Of the 83,328 unpaid sessions, 39,917 have no referer (direct visits) and 43,411 have a referer (organic search).
   - No other missing values exist in any table.
3. **Decimal columns imported as text.** `price_usd`, `cogs_usd` (orders and order items) and `refund_amount_usd` were loaded as Text because the computer's regional settings use a comma as the decimal separator. Power BI could not convert them automatically. They were converted in Power Query with Change Type > Using Locale > Decimal Number, English (United States). Totals were checked against independent calculations (revenue 1,938,509.75; refunds 85,338.69).
4. **Pageviews file is truncated.** It has exactly 1,048,575 rows (the Excel row limit), ends on 16 Jan 2015 and covers sessions up to ID 421,956 out of 472,871. Treat it as incomplete and do not use it for conclusions.
5. **Hidden BOM character** on the first column header of each CSV (for example the first column of orders_mav). If Power BI shows a name that looks odd, rename it.
6. **Partial months:** Mar 2012 and Mar 2015 only cover part of the month, so note this when comparing months.

## 5. Cleaning and preparation steps

### Power Query (Power BI or Excel): do these for every table
1. Get Data > Text/CSV > Transform Data. Confirm the first row is the header.
2. Rename the first column if it carries a BOM (hidden character).
3. Change types: ID columns to Whole Number, `created_at` to Date/Time (not Date/Time/Timezone) using locale English (United States). Convert `price_usd`, `cogs_usd` and `refund_amount_usd` to Decimal Number using Change Type > Using Locale > English (United States).
4. In `website_sessions`: replace the text "NULL" with a true null in `utm_source`, `utm_campaign`, `utm_content` and `http_referer`.
5. Add column `traffic_channel` to separate unpaid traffic:
   - utm_source not null: the paid source
   - utm_source null and http_referer null: `direct`
   - utm_source null and http_referer not null: `organic search`
6. Replace null in `utm_source`, `utm_campaign`, `utm_content` with `direct/organic`.
7. Create a Calendar table in DAX and add Order Date and Session Date columns to join the facts to it.
8. Remove nothing: there are no duplicates, keys with missing values or invalid values. Keep every row.

```m
// website_sessions (Power Query M)
let
    Source = Csv.Document(File.Contents("C:\\path\\website_sessions.csv"), [Delimiter=",", Encoding=65001]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {
        {"website_session_id", Int64.Type}, {"user_id", Int64.Type}, {"is_repeat_session", Int64.Type},
        {"created_at", type datetime}}, "en-US"),
    NullsFixed = Table.ReplaceValue(Typed, "NULL", null, Replacer.ReplaceValue,
        {"utm_source", "utm_campaign", "utm_content", "http_referer"}),
    Channel = Table.AddColumn(NullsFixed, "traffic_channel", each
        if [utm_source] <> null and [utm_source] <> "" then [utm_source]
        else if [http_referer] = null or [http_referer] = "" then "direct"
        else "organic search", type text),
    Filled = Table.ReplaceValue(Channel, null, "direct/organic", Replacer.ReplaceValue, {"utm_source","utm_campaign","utm_content"})
in
    Filled
```

Order matters: the traffic_channel column is created before the nulls are replaced, because it reads the original nulls.

### SQL (MySQL)
1. Create the tables with DATETIME for each created_at and INT / DECIMAL(10,2) for the others, then load the CSVs (`LOAD DATA INFILE` or the import wizard).
2. If dates were imported as text: add a `created_dt` DATETIME column and fill it with `STR_TO_DATE(created_at, '%m/%d/%Y %H:%i')`.
3. Add primary keys and foreign keys as in section 3.

## 6. Result
The data is clean, consistent and ready for analysis. No rows were deleted. Only types were corrected, unpaid traffic was labelled, and one derived column was added.
