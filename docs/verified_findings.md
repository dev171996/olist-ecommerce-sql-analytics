# Verified findings

## Data reliability

- Core key candidates were checked for missing and duplicate values before constraints were added.
- Core transactional foreign-key audits returned no orphans in the tested relationships.
- `review_id` was not globally unique, so the validated candidate for the source review records was `(order_id, review_id)`.

## Financial grain

- Direct item-payment joins caused many-to-many multiplication.
- In the tested order, 3 item rows and 21 payment rows produced 63 joined rows.
- The correct item and payment total was 161.32.
- The unsafe join inflated item total to 3,387.72 and payment total to 483.96.
- One-row-per-order item and payment views removed this risk.

## Executive results

- Total orders: 99,441
- Delivered orders: 96,478
- Canceled orders: 625
- Unique actual customers: 96,096
- Delivered order percentage: 97.02%
- Canceled order percentage: 0.63%
- Delivered product value: 13,221,498.11
- Delivered freight value: 2,198,275.64
- Delivered item total: 15,419,773.75
- Delivered payment value: 15,422,461.77
- Average delivered order value: 159.83

## Delivery

- On-time delivered orders: 88,644
- Late delivered orders: 7,826
- Missing actual delivery date among delivered orders: 8
- Approximately 42.74% of late orders were delayed by more than 8 days

## Data exceptions

- 610 products had the same descriptive metadata block missing
- 2 products were missing all four physical measurements
- 383 order-item rows had zero freight value
- 2 credit-card payment rows had zero installments but positive payment values
