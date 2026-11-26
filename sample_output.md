# Claims star schema: build log and mart output (synthetic data)

Produced by `scripts/build_model.py`. All data is synthetic; no real
member, provider, payer or claim data.

```text
staged 3000 claims / 7460 lines (synthetic)
star built: 7460 fact rows; denial rate 12.5%

# Data tests
  PASS         dim_member surrogate key unique
  PASS         dim_provider surrogate key unique
  PASS         dim_date full_date unique
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
2025 | 1     | Aetna            | 184   | 12.5       | 52842.0
2025 | 1     | Cigna            | 156   | 11.5       | 38601.0
2025 | 1     | Humana           | 158   | 10.1       | 42318.0
2025 | 1     | UnitedHealthcare | 188   | 12.2       | 46104.0
2025 | 2     | Aetna            | 158   | 15.2       | 41959.0
2025 | 2     | Cigna            | 148   | 16.9       | 38195.0
2025 | 2     | Humana           | 130   | 12.3       | 32622.0
2025 | 2     | UnitedHealthcare | 112   | 17.0       | 28209.0
2025 | 3     | Aetna            | 156   | 10.3       | 39317.0
2025 | 3     | Cigna            | 125   | 6.4        | 31852.0
2025 | 3     | Humana           | 190   | 10.0       | 49076.0
2025 | 3     | UnitedHealthcare | 145   | 8.3        | 40234.0
2025 | 4     | Aetna            | 139   | 15.1       | 37116.0
2025 | 4     | Cigna            | 181   | 11.0       | 45449.0
2025 | 4     | Humana           | 147   | 8.8        | 38027.0
2025 | 4     | UnitedHealthcare | 151   | 8.6        | 37755.0
2025 | 5     | Aetna            | 173   | 8.7        | 44449.0
2025 | 5     | Cigna            | 126   | 15.1       | 27960.0
2025 | 5     | Humana           | 165   | 13.3       | 38735.0
2025 | 5     | UnitedHealthcare | 185   | 13.0       | 43476.0
2025 | 6     | Aetna            | 154   | 13.6       | 40846.0
2025 | 6     | Cigna            | 196   | 11.7       | 49194.0
2025 | 6     | Humana           | 160   | 12.5       | 44862.0
2025 | 6     | UnitedHealthcare | 150   | 13.3       | 35253.0
2025 | 7     | Aetna            | 147   | 11.6       | 35043.0
2025 | 7     | Cigna            | 154   | 13.6       | 32810.0
2025 | 7     | Humana           | 201   | 11.4       | 55316.0
2025 | 7     | UnitedHealthcare | 117   | 17.1       | 28057.0
2025 | 8     | Aetna            | 149   | 12.8       | 28808.0
2025 | 8     | Cigna            | 187   | 12.3       | 50000.0
2025 | 8     | Humana           | 156   | 9.6        | 38441.0
2025 | 8     | UnitedHealthcare | 167   | 12.6       | 42005.0
2025 | 9     | Aetna            | 138   | 9.4        | 32496.0
2025 | 9     | Cigna            | 134   | 14.9       | 33846.0
2025 | 9     | Humana           | 158   | 10.8       | 41621.0
2025 | 9     | UnitedHealthcare | 158   | 9.5        | 40486.0
2025 | 10    | Aetna            | 178   | 12.4       | 50281.0
2025 | 10    | Cigna            | 128   | 16.4       | 27787.0
2025 | 10    | Humana           | 154   | 11.0       | 33080.0
2025 | 10    | UnitedHealthcare | 157   | 12.7       | 38150.0
2025 | 11    | Aetna            | 128   | 15.6       | 37231.0
2025 | 11    | Cigna            | 154   | 15.6       | 38445.0
2025 | 11    | Humana           | 149   | 12.1       | 37835.0
2025 | 11    | UnitedHealthcare | 152   | 14.5       | 35856.0
2025 | 12    | Aetna            | 164   | 15.9       | 43837.0
2025 | 12    | Cigna            | 150   | 15.3       | 39274.0
2025 | 12    | Humana           | 153   | 15.0       | 41869.0
2025 | 12    | UnitedHealthcare | 150   | 16.7       | 39545.0

## Top providers by collected amount
practice_name | specialty         | lines | collected
--------------+-------------------+-------+----------
Clinic 44     | Orthopedics       | 161   | 26038.0  
Clinic 42     | Family Medicine   | 168   | 25354.0  
Clinic 2      | Family Medicine   | 136   | 24547.0  
Clinic 15     | Orthopedics       | 143   | 23993.0  
Clinic 25     | Radiology         | 143   | 23746.0  
Clinic 53     | Cardiology        | 119   | 23421.0  
Clinic 49     | Internal Medicine | 146   | 22584.0  
Clinic 55     | Family Medicine   | 154   | 22406.0  
Clinic 10     | Internal Medicine | 136   | 21818.0  
Clinic 24     | Radiology         | 133   | 21456.0  

## Allowed-to-billed ratio by payer
payer_name       | billed   | allowed  | allowed_pct_of_billed
-----------------+----------+----------+----------------------
Humana           | 493804.0 | 370028.0 | 74.9                 
UnitedHealthcare | 455130.0 | 340938.0 | 74.9                 
Aetna            | 484224.0 | 364378.0 | 75.2                 
Cigna            | 453412.0 | 343635.0 | 75.8                 

```
