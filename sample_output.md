# Claims star schema: build log and mart output (synthetic data)

Produced by `scripts/build_model.py`. All data is synthetic; no real
member, provider, payer or claim data.

```text
staged 3000 claims / 7457 lines (synthetic)
star built: 7457 fact rows; denial rate 12.5%

# Data tests
  PASS         dim_member surrogate key unique
  PASS         dim_provider surrogate key unique
  PASS         dim_date full_date unique
  PASS         no overlapping member intervals
  PASS         exactly one current version per member
  PASS         fact grain unique (claim_id, line_no)
  PASS         fact member keys resolve
  PASS         fact provider keys resolve
  PASS         fact payer keys resolve
  PASS         fact service dates resolve
  PASS         no negative amounts
  PASS         paid never exceeds allowed on paid lines
  PASS         denied lines carry zero payment
  PASS         is_denied accepted values
  PASS         fact row count matches staged lines

# Marts
## Monthly denial rate by payer
year | month | payer_name       | lines | denial_pct | billed 
-----+-------+------------------+-------+------------+--------
2025 | 1     | Aetna            | 187   | 12.3       | 54314.0
2025 | 1     | Cigna            | 156   | 11.5       | 38601.0
2025 | 1     | Humana           | 159   | 10.1       | 42447.0
2025 | 1     | UnitedHealthcare | 188   | 12.2       | 46104.0
2025 | 2     | Aetna            | 158   | 15.2       | 41959.0
2025 | 2     | Cigna            | 148   | 16.9       | 38195.0
2025 | 2     | Humana           | 129   | 12.4       | 32492.0
2025 | 2     | UnitedHealthcare | 111   | 17.1       | 28160.0
2025 | 3     | Aetna            | 153   | 10.5       | 38834.0
2025 | 3     | Cigna            | 123   | 6.5        | 31618.0
2025 | 3     | Humana           | 189   | 10.1       | 48768.0
2025 | 3     | UnitedHealthcare | 145   | 8.3        | 40234.0
2025 | 4     | Aetna            | 139   | 15.1       | 37116.0
2025 | 4     | Cigna            | 181   | 11.0       | 45449.0
2025 | 4     | Humana           | 147   | 8.8        | 38027.0
2025 | 4     | UnitedHealthcare | 152   | 8.6        | 38073.0
2025 | 5     | Aetna            | 176   | 9.1        | 44985.0
2025 | 5     | Cigna            | 126   | 15.1       | 27960.0
2025 | 5     | Humana           | 167   | 13.2       | 39275.0
2025 | 5     | UnitedHealthcare | 185   | 13.0       | 43476.0
2025 | 6     | Aetna            | 152   | 13.8       | 40322.0
2025 | 6     | Cigna            | 196   | 11.7       | 49194.0
2025 | 6     | Humana           | 160   | 12.5       | 44862.0
2025 | 6     | UnitedHealthcare | 150   | 13.3       | 35253.0
2025 | 7     | Aetna            | 147   | 11.6       | 35043.0
2025 | 7     | Cigna            | 154   | 13.6       | 32810.0
2025 | 7     | Humana           | 201   | 11.4       | 55316.0
2025 | 7     | UnitedHealthcare | 119   | 16.8       | 28455.0
2025 | 8     | Aetna            | 149   | 12.8       | 28808.0
2025 | 8     | Cigna            | 187   | 12.3       | 50000.0
2025 | 8     | Humana           | 157   | 9.6        | 38622.0
2025 | 8     | UnitedHealthcare | 167   | 12.6       | 42005.0
2025 | 9     | Aetna            | 139   | 9.4        | 32616.0
2025 | 9     | Cigna            | 134   | 14.9       | 33846.0
2025 | 9     | Humana           | 158   | 10.8       | 41621.0
2025 | 9     | UnitedHealthcare | 156   | 9.0        | 40289.0
2025 | 10    | Aetna            | 178   | 12.4       | 50281.0
2025 | 10    | Cigna            | 128   | 16.4       | 27787.0
2025 | 10    | Humana           | 154   | 11.0       | 33080.0
2025 | 10    | UnitedHealthcare | 157   | 12.7       | 38150.0
2025 | 11    | Aetna            | 128   | 15.6       | 37231.0
2025 | 11    | Cigna            | 154   | 15.6       | 38445.0
2025 | 11    | Humana           | 147   | 12.2       | 37373.0
2025 | 11    | UnitedHealthcare | 152   | 14.5       | 35856.0
2025 | 12    | Aetna            | 164   | 15.9       | 43837.0
2025 | 12    | Cigna            | 147   | 15.6       | 37002.0
2025 | 12    | Humana           | 153   | 15.0       | 41869.0
2025 | 12    | UnitedHealthcare | 150   | 16.7       | 39545.0

## Top providers by collected amount
practice_name | specialty         | lines | collected
--------------+-------------------+-------+----------
Clinic 44     | Cardiology        | 161   | 26038.0  
Clinic 42     | Pediatrics        | 167   | 25320.0  
Clinic 2      | Orthopedics       | 136   | 24547.0  
Clinic 15     | Internal Medicine | 142   | 23905.0  
Clinic 25     | Radiology         | 143   | 23746.0  
Clinic 53     | Orthopedics       | 119   | 23421.0  
Clinic 49     | Radiology         | 146   | 22584.0  
Clinic 55     | Cardiology        | 154   | 22406.0  
Clinic 10     | Radiology         | 136   | 21818.0  
Clinic 57     | Orthopedics       | 142   | 21541.0  

## Allowed-to-billed ratio by payer
payer_name       | billed   | allowed  | allowed_pct_of_billed
-----------------+----------+----------+----------------------
Humana           | 493752.0 | 369974.0 | 74.9                 
UnitedHealthcare | 455599.0 | 341272.0 | 74.9                 
Aetna            | 485346.0 | 365120.0 | 75.2                 
Cigna            | 450906.0 | 341709.0 | 75.8                 

```
