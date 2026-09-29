# JD Consumer Behaviour and Operations Strategy
## Background
The platform needs to improve retention, product operations and shop performance. This project uses 183,828 JD consumer-behaviour records to answer five business questions: who the users are, what they prefer, whether they are loyal, how they convert, and why shops grow.

## Data and processing
- Window: 2018-02-01 00:00:00 to 2018-04-15 23:59:00, 74 days.
- Raw data: 183,828 rows x 20 fields; cleaned data: 183,827 rows after one business-key duplicate was removed.
- Missing age and city values are kept as Unknown; missing shop registration dates are flagged.
- Shop rating values of 0/-1 are treated as missing rather than valid ratings.
- There is no transaction amount, so RFM uses category, brand and shop breadth as an M proxy rather than inventing GMV.

## 1. User profile and retention
- Male users account for 61.2% and female users 38.5%.
- Users aged 46-55 and 56+ account for about 76.3% of the base.
- Tier 3-5 cities contribute the largest share, showing a lower-tier and older user structure.
- Weighted D1 retention is 1.70%; average daily D1 retention is 1.53%.

## 2. Product and segment preference
- Phone, Coat, Tea and Notebook lead pageviews.
- Huawei, Apple and Lipton are the strongest branded traffic sources.
- Coat and Tea are the leading order categories.
- Only 3.98% of order users bought a product launched within 30 days, indicating conservative purchasing behaviour.

## 3. RFM
- M is proxied by the number of categories, brands and shops purchased.
- Important-value and important-retention users form the core customer base; detailed counts are in rfm_segments.csv.
- Recommended actions: retention benefits for high-value users, frequency campaigns for mid-value users, and low-cost win-back for low-value users.

## 4. Funnel
- View users: 124,433; order users: 10,652.
- Order-user/view-user size ratio: 8.56%. The true view-and-order overlap is only 1,094 users (0.88%), because many orders appear without a preceding PageView event.
- Direct purchase accounts for 99.70% of order users.
- Only 32 users both carted and ordered; cart-to-order overlap is 1.09%.
- Interaction rate is 4.87%.

## 5. Store and category operations
- Valid-rating shops: 5,211; shops with missing ratings: 875.
- Rating-pageview correlation among valid shops is -0.012; a high rating does not guarantee traffic.
- Across all shops, 59.25% have zero orders, and orders concentrate in a small number of shops.
- Outdoor Sports and Electronics have higher top-3 shop concentration; Food, Beauty and Clothes are more fragmented.

## 6. Dashboard and recommendations
The dashboard is organised into four pages: user overview, product preference, user operations, and shop operations. Recommended actions are to improve first-visit retention, recall important-retention users, keep direct purchase friction low, reposition cart as a save/compare tool, and prioritise shop traffic acquisition and sell-through rather than rating alone.
