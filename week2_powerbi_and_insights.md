# Week 2 - Power BI build sheet and business insights

## 1. Data model (Model view)
Final model (5 active relationships; the pageviews file is not loaded because it is truncated):
- Calendar[Date] 1 -> * website_sessions[Session Date]
- website_sessions[website_session_id] 1 -> 0..1 orders_mav[website_session_id]
- orders_mav[order_id] 1 -> * order_items[order_id]
- products[product_id] 1 -> * order_items[product_id]
- order_items[order_item_id] 1 -> 0..1 order_item_refunds[order_item_id]
The Calendar is linked through website sessions only. Linking it to orders as well created two paths and Power BI deactivated one of them. Monthly figures therefore follow session date (6 of 32,313 orders differ in month; at most about $80 moves between months).
The orders_mav[order_id] to order_item_refunds[order_id] relationship was deleted so that product filters flow through order_items to refunds.
Power Query: set created_at to Date/Time (locale English US, not Date/Time/Timezone); convert price_usd, cogs_usd and refund_amount_usd to Decimal Number with Change Type > Using Locale > English (United States); replace the text "NULL" with a true null in the utm and referer columns, add traffic_channel, then replace null utm values with "direct/organic".

## 2. DAX measures
```
Total Orders   = DISTINCTCOUNT ( orders_mav[order_id] )
Total Revenue  = SUM ( orders_mav[price_usd] )
Total Refunds  = SUM ( order_item_refunds[refund_amount_usd] )
Refund Count   = COUNTROWS ( order_item_refunds )
Avg Order Value = DIVIDE ( [Total Revenue], [Total Orders] )
Website Sessions = DISTINCTCOUNT ( website_sessions[website_session_id] )
Conversion Rate = DIVIDE ( [Total Orders], [Website Sessions] )
Item Revenue   = SUM ( order_items[price_usd] )
Refund Rate    = DIVIDE ( COUNTROWS ( order_item_refunds ), COUNTROWS ( order_items ) )
```
Note: Total Orders and Website Sessions come from different tables. Orders relate to sessions on website_session_id and the Calendar filters sessions, so Conversion Rate responds to the date slicers.
Product and refund visuals respond to the product slicer; the cards and session visuals do not, because products only link to order items.

## 3. Page layout
- Top row: 6 KPI cards (Orders, Revenue, Refunds, AOV, Sessions, Conversion Rate)
- Line chart: Revenue by month (Date[Year-Month])
- Bar: Top products (Item Revenue by product_name); table or column: Sales by product
- Bar: Sessions by marketing source; donut: Sessions by device type
- Refund Analysis: refund value and refund rate by product (clustered column)
- Slicers: Year, Month, device_type, utm_source, product_name

## 4. Numbers to verify against your cards
Orders 32,313 | Revenue $1,938,509.75 | Refunds 1,731 / $85,338.69 | AOV $59.99 | Sessions 472,871 | Conversion 6.83%

## 5. Business insights (finding -> evidence -> recommendation)
1. **Desktop converts almost 3x better than mobile.** Desktop 8.50% (327,027 sessions) vs mobile 3.09% (145,844 sessions). Mobile is 31% of traffic but 14% of orders. Recommendation: audit the mobile checkout and landing pages, and test a mobile-first redesign. Closing even half the gap would add several thousand orders.
2. **Google search is the revenue engine but not the best converter.** gsearch brings 316,035 sessions (67% of traffic) and about $1.28M of order revenue, with a 6.75% conversion rate. bsearch converts higher at 7.19% on 62,823 sessions. Recommendation: test shifting some budget to bsearch, which has less competition, and watch cost per order.
3. **Socialbook underperforms badly.** 10,685 sessions convert at 3.21%, and the "pilot" campaign converts at only 1.08%, yielding about $22K. Recommendation: pause or restructure the pilot campaign unless its cost per order is very low.
4. **Revenue is highly concentrated in one product.** The Original Mr. Fuzzy earns $1.21M, about 62% of revenue. Recommendation: cross-sell the other products at checkout and bundle them with Mr. Fuzzy to raise AOV (now $59.99). 24% of orders already include two items.
5. **Strong seasonality and growth.** Revenue peaks every Nov-Dec, and Dec 2014 is the highest month at $144,823. Annual conversion rose from 4.1% (2012) to 6.6% (2013) to 7.2% (2014). Recommendation: schedule inventory, ad budget and campaigns ahead of Q4.
6. **Refunds are concentrated in two products.** Overall refund rate is 4.3% of items ($85,339). The Birthday Sugar Panda has the highest rate at 6.0% and Mr. Fuzzy 5.1%, versus 1.3% for the Hudson River Mini bear. Mr. Fuzzy accounts for $61.8K of refunds, 72% of the total. Recommendation: investigate quality or expectation issues with these two products.
7. **Repeat visitors convert better.** Repeat sessions convert at 7.83% vs 6.64% for new sessions. Recommendation: invest in retargeting, email and loyalty to bring visitors back.

## 6. Limitations to state in the report
- Mar 2012 and Mar 2015 are partial months (data runs 19 Mar 2012 to 19 Mar 2015).
- website_pageviews.csv has exactly 1,048,575 rows, which looks cut off at the Excel row limit. It stops at 16 Jan 2015 and covers sessions up to 421,956 of 472,871. Do not base conclusions on it. Use it only for page-level exploration, or re-export it from the source.
- No marketing spend data, so conclusions about channel profitability are based on conversion and revenue only.
