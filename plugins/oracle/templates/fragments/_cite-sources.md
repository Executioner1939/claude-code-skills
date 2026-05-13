## Citation discipline

Every factual claim in the output cites a source in the
`{{ verification.citation_format }}` format:

{% if verification.citation_format == "url" -%}
- URL only. Example: `https://docs.rs/tokio/latest/tokio/`.
{% elif verification.citation_format == "url-and-line" -%}
- URL plus the file path or page anchor and line number when applicable.
  Example: `https://github.com/tokio-rs/tokio/blob/master/tokio/src/runtime/builder.rs#L42`.
{% else -%}
- URL, file/anchor and line, plus a short verbatim quote (under 25 words)
  proving the claim. Example:
  `https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.worker_threads
  -- "Sets the number of worker threads the Runtime will use."`.
{%- endif %}

{% if verification.forbid_speculation -%}
Speculation is forbidden. If the cascade fails to produce a citation
for a claim, do not state the claim -- report `unverified` and explain
what was attempted.
{%- endif %}
