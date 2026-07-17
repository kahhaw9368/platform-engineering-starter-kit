# Ritual: Metrics Review (monthly, 45 min)

Owner: Platform Team PM-hat. Facilitator: Apex (platform-as-product skill). Data: derived
metrics only (ADR-0011) — if a number needs new infrastructure to produce, it waits for DevLake.

## Agenda

1. **Adoption** (10 min) — Team instances in git (onboarded), WebService instances by template
   version, deploys/week from PR history.
2. **The trap check** (10 min) — of the onboarded, how many services are ALIVE in CloudWatch
   (traffic/logs in last 7 days)? Onboarded-but-idle teams get named and a discovery
   conversation scheduled — never assume why (criteria #7: reach out, don't guess).
3. **Satisfaction** (10 min) — micro-survey trend, NPS if collected this month. Worst journey
   gets a discovery question.
4. **Support pressure** (5 min) — #platform-help volume trend. Rising during adoption = not
   ready for wider rollout (TT25 doom-loop early warning).
5. **One decision** (10 min) — the review must END with one recorded decision (prune something,
   fix one journey, onboard next team, adjust a quota default). No-decision reviews are
   theater; log the decision as a PR or issue.
