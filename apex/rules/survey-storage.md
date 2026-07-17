# Micro-survey storage format (ADR-0011)

Responses append to `metrics/surveys.jsonl` in the GitOps repo (one PR per batch is overkill —
Apex batches with the journey's own PR when possible, else weekly):

    {"date":"YYYY-MM-DD","journey":"scaffold|onboard|promote","score":1-5,"nps":null|0-10,"user":"<anonymized-stable-hash>"}

- `user` is a stable anonymized hash (same person = same hash, no identity) so etiquette rules
  ("once per month per user" for NPS) are enforceable without storing who anyone is.
- The satisfaction ritual reads this file; nothing else consumes it.
- Etiquette itself lives in apex-rules.md — this file is only the storage contract.
