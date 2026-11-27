"""Generate synthetic source-system data for the star-schema demo.

All records are synthetic and randomly generated (fixed seed). Names, NPIs,
ZIPs and amounts are not real people, providers or payers' data.
"""
import random
import sqlite3
from datetime import date, timedelta

SEED = 42

FIRST = ["Avery","Jordan","Priya","Marcus","Lena","Diego","Sofia","Ethan","Nadia","Omar",
         "Grace","Victor","Iris","Kyle","Maya","Noel","Tara","Ravi","Elena","Chris"]
LAST = ["Bennett","Cole","Dawson","Ellis","Farrell","Gupta","Hayes","Ingram","Jacobs",
        "Kaur","Lopez","Merritt","Nguyen","Owens","Patel","Quinn","Reyes","Singh","Tran","Vargas"]
SPECIALTIES = ["Family Medicine","Internal Medicine","Cardiology","Orthopedics","Pediatrics","Radiology"]
PAYERS = [("P01","Aetna"),("P02","UnitedHealthcare"),("P03","Cigna"),("P04","Humana")]
CPTS = [("99213",150),("99214",220),("99203",250),("70450",900),("73030",250),
        ("80053",120),("85025",60),("93000",140),("97110",90),("36415",40)]
N_MEMBERS = 600
N_PROVIDERS = 60
N_CLAIMS = 3000
DENIAL_RATE = 0.12


def generate(db_path="claims.db"):
    rng = random.Random(SEED)
    con = sqlite3.connect(db_path)
    with open(__file__.replace("generate_source.py", "").replace("scripts/", "") + "sql/staging.sql") as f:
        con.executescript(f.read())
    for t in ("src_claim_lines","src_claims","src_members","src_member_updates","src_providers","src_payers"):
        con.execute(f"DELETE FROM {t}")

    members = []
    for i in range(N_MEMBERS):
        members.append((
            f"M{100001+i}",
            rng.choice(FIRST), rng.choice(LAST),
            (date(1950,1,1) + timedelta(days=rng.randrange(22000))).isoformat(),
            rng.choice(["F","M"]),
            str(rng.choice([20001,20002,20003,20005,20009,20010,20011,20024,20036,20037])),
        ))
    con.executemany("INSERT INTO src_members VALUES (?,?,?,?,?,?)", members)

    # Attribute changes: ~5% of members move ZIP mid-year (drives the SCD2 demo).
    updates = []
    for m in rng.sample(members, 30):
        updates.append((
            m[0],
            str(rng.choice([20001,20002,20003,20005,20009,20010,20011,20024,20036,20037])),
            (date(2025,3,1) + timedelta(days=rng.randrange(180))).isoformat(),
        ))
    con.executemany("INSERT INTO src_member_updates VALUES (?,?,?)", updates)

    providers = []
    for i in range(N_PROVIDERS):
        providers.append((
            f"PR{1001+i}",
            f"9{rng.randrange(10**9):09d}",  # synthetic NPI-shaped string
            f"Clinic {i+1}",
            rng.choice(SPECIALTIES),
        ))
    con.executemany("INSERT INTO src_providers VALUES (?,?,?,?)", providers)
    con.executemany("INSERT INTO src_payers VALUES (?,?)", PAYERS)

    claims, lines = [], []
    start = date(2025, 1, 1)
    for i in range(N_CLAIMS):
        claim_id = f"CLM{1000001+i}"
        m = members[rng.randrange(N_MEMBERS)]
        p = providers[rng.randrange(N_PROVIDERS)]
        payer = rng.choice(PAYERS)[0]
        svc = start + timedelta(days=rng.randrange(365))
        claims.append((claim_id, m[0], p[0], payer,
                       (svc + timedelta(days=rng.randrange(3, 20))).isoformat()))
        for ln in range(1, rng.randint(2, 5)):
            cpt, price = rng.choice(CPTS)
            billed = round(price * rng.uniform(0.9, 1.4), 2)
            allowed = round(billed * rng.uniform(0.6, 0.9), 2)
            if rng.random() < DENIAL_RATE:
                status, paid = "denied", 0.0
            else:
                status, paid = "paid", round(allowed * rng.uniform(0.85, 1.0), 2)
            lines.append((claim_id, ln, cpt, svc.isoformat(), billed, allowed, paid, status))
    con.executemany("INSERT INTO src_claims VALUES (?,?,?,?,?)", claims)
    con.executemany("INSERT INTO src_claim_lines VALUES (?,?,?,?,?,?,?,?)", lines)
    con.commit()
    n_lines = con.execute("SELECT COUNT(*) FROM src_claim_lines").fetchone()[0]
    con.close()
    return len(claims), n_lines


if __name__ == "__main__":
    c, l = generate()
    print(f"staged {c} claims / {l} lines (synthetic)")
