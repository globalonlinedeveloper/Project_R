"""RATEL build-time content pipeline (subscription-only; NO metered API).

Stages: generate -> jury -> validate -> confidence gate -> versioned JSON.
The generator/jury are network-free seams: in production, content produced via
the Claude/Cowork subscription enters at `generate`; no metered API is ever
called from this code. The pipeline validates its own output against the frozen
schema.json (the single source of truth)."""
