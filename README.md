Maven Fuzzy Factory: E-commerce Performance and Customer Behaviour Analysis

AnalystLab Africa Experience Lab | Week 2 | Track 1: Data Analytics

Business problem

Maven Fuzzy Factory, an online retailer of plush toys, wants to understand how its website performs, which marketing channels and products drive sales, how many visitors become customers, and where refunds occur. This project analyses website traffic, order, product and refund data (19 March 2012 to 19 March 2015) to support better business decisions.

Dashboard preview

Power BI dashboard

Tools
Power Query (Power BI) for data cleaning and preparation
SQL (MySQL syntax) for business analysis
Power BI Desktop for the interactive dashboard
Python (pandas) for independent verification of the SQL and dashboard numbers
Data
Table	Rows	Notes
website_sessions	472,871	one row per visit
website_pageviews	1,048,575	truncated export (see limitations); not used for conclusions
orders_mav	32,313	one row per order
order_items	40,025	one row per product line
order_item_refunds	1,731	one row per refunded item
products	4	no category field

The raw CSV files were supplied by AnalystLab Africa and are not included in this repository.

Workflow
Data understanding and preparation: field review, keys and relationships, quality checks and cleaning steps (task1_data_understanding_and_preparation.md).
SQL analysis: ten business questions in week2_analysis.sql.
Power BI dashboard: KPIs, revenue trend, products, marketing channels, devices, refunds and slicers (the .pbix file). Build notes, measures and model are in week2_powerbi_and_insights.md.
Business insights: seven findings with recommendations (in the PDF report and week2_powerbi_and_insights.md).
Data preparation summary
No duplicate rows, duplicate keys or orphan foreign keys in any table. Order revenue equals the sum of item revenue for every order.
Dates were stored as text and converted to date-time.
Price, cost and refund columns loaded as text because of regional decimal settings. They were converted to decimal numbers using the English (United States) locale.
Missing marketing values were stored as the text "NULL" (83,328 sessions). They were converted to nulls and labelled direct/organic. A traffic_channel column separates direct visits from organic search.
A DAX Calendar table was added and linked through website sessions.
Answers to the ten SQL questions
#	Question	Answer
1	Total unique orders	32,313
2	Total revenue	$1,938,509.75
3	Top products by revenue	Only 4 products exist: The Original Mr. Fuzzy $1,211,057.74; The Forever Love Bear $347,702.04; The Birthday Sugar Panda $229,260.15; The Hudson River Mini bear $150,489.82
4	Best product category or type	No category field exists, so product name is used. Mr. Fuzzy is 62.5% of revenue
5	Marketing sources by sessions	gsearch 316,035; direct/organic 83,328; bsearch 62,823; socialbook 10,685
6	Device with the most traffic	Desktop (327,027 sessions) vs mobile (145,844)
7	Session-to-order conversion rate	6.83% (32,313 orders / 472,871 sessions)
8	Refunds	1,731 refunds worth $85,338.69
9	Highest and lowest revenue months	Highest: Dec 2014 ($144,823.02). Lowest: Mar 2012 ($2,999.40, a partial launch month starting 19 March). Lowest full month: Apr 2012 ($4,949.01)
10	Average order value	$59.99
Key insights
Desktop converts at 8.50% but mobile at 3.09%, so the mobile experience is the biggest conversion opportunity.
gsearch drives 67% of sessions; bsearch converts slightly better (7.19% vs 6.75%).
The socialbook channel underperforms (3.21%), and its "pilot" campaign converts at only 1.08%.
The Original Mr. Fuzzy earns 62.5% of revenue and only 24% of orders contain two items, so cross-selling could lift average order value.
Revenue peaks every November and December, and yearly conversion rose from 4.1% (2012) to 7.2% (2014).
The Birthday Sugar Panda (6.0%) and Mr. Fuzzy (5.1%) have the highest refund rates.
Repeat visitors convert better than new visitors (7.83% vs 6.64%).
Limitations
The pageviews file stops at the Excel row limit (16 January 2015) and covers only part of the sessions, so page-level and funnel analysis was not done.
March 2012 and March 2015 are partial months.
Monthly figures in Power BI follow session date. In 6 of 32,313 orders the order falls in a different month from its session, which moves at most about $80 between months. Totals are unaffected.
There is no marketing spend data, so channel comparisons use conversion and revenue, not profitability.
The SQL answers were also verified with an independent Python calculation.
How to reproduce
Load the six CSV files into a MySQL database (tables named as in the table above).
Convert each created_at text column to DATETIME (see the header of week2_analysis.sql).
Run week2_analysis.sql.
Open the .pbix file in Power BI Desktop and point the file sources to your copies of the CSVs. The optional theme file is Maven_Fuzzy_Factory_Theme.json (View > Themes > Browse for themes).
Repository contents
File	What it is
README.md	this overview
week2_analysis.sql	SQL answers to the ten business questions
task1_data_understanding_and_preparation.md	data understanding, quality checks and cleaning steps
week2_powerbi_and_insights.md	Power BI model, measures, dashboard layout and business insights
Week2_Analytical_Report.pdf	analytical report (PDF)
.pbix file	Power BI dashboard
Maven_Fuzzy_Factory_Theme.json	Power BI theme used for the dashboard
Dashboard screenshot.png	screenshot of the dashboard
Author

Thando Kheswa | Johannesburg, South Africa

#AnalystLabAfrica
