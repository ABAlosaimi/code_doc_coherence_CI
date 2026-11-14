import os
import snowflake.connector
from cryptography.hazmat.primitives import serialization

key = serialization.load_pem_private_key(
    os.environ["SNOWFLAKE_PRIVATE_KEY"].replace("\\n", "\n").encode(),
    password=None)

key_bytes = key.private_bytes(
    serialization.Encoding.DER,
    serialization.PrivateFormat.PKCS8,
    serialization.NoEncryption())

conn = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    private_key=key_bytes,
    warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
    database=os.environ["SNOWFLAKE_DATABASE"],
    schema=os.environ["SNOWFLAKE_SCHEMA"],
    role=os.environ["SNOWFLAKE_ROLE"],
)

# PR_NUMBER is only present on pull_request events; treat anything non-numeric as NULL
pr_raw = os.environ.get("CI_PR_NUMBER", "")
pr_number = int(pr_raw) if pr_raw.isdigit() else None

conn.cursor().execute(
    "INSERT INTO CI_RUNS (REPO, BRANCH_NAME, EVENT_NAME, PR_NUMBER, STATUS, ACTOR, ENV_VARS) "
    "SELECT %s, %s, %s, %s, %s, %s, PARSE_JSON(%s)",
    (os.environ["CI_REPO"],
     os.environ["CI_BRANCH_NAME"],
     os.environ["CI_EVENT_NAME"],
     pr_number,
     os.environ["CI_STATUS"],
     os.environ["CI_ACTOR"],
     ""))

conn.close()

if os.environ["CI_STATUS"].lower() == "false":
    raise Exception("Coherence check failed: undocumented changes detected")
