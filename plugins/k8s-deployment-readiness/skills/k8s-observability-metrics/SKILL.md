---
name: k8s-observability-metrics
internal: true
---

# Microservices observability & OpenTelemetry deep dive

**Audience:** internal — loaded only by the `observability-auditor` subagent.

The LearnKube checklist's "Going Live" → "Visibility" item is one bullet.
This skill is what it actually expands into for a production microservice
fleet: signals, semantic conventions, exemplars, sampling, SLOs, and
multi-burn-rate alerting.

The skill grounds every claim in a primary source. The four worked examples
at the end show the methodology end-to-end — two introductory (RED, USE)
and two showing the full power of the stack (exemplar-based latency drill-in,
tail-sampled error-trace pipeline + multi-burn-rate SLO alerting).

---

## 1. Signals and where they fit

OpenTelemetry defines three signals:

| Signal | What it answers | Cardinality cost | Source |
|---|---|---|---|
| **Metrics** | "Is the system healthy in aggregate? How is it trending?" | Bounded by label set; cheap. | [OTel Metrics data model](https://opentelemetry.io/docs/specs/otel/metrics/data-model/) |
| **Traces** | "What did *this one request* do, end-to-end?" | One row per span; expensive at full fidelity. | [OTel Traces data model](https://opentelemetry.io/docs/specs/otel/trace/api/) |
| **Logs** | "What did the application say at this point in time?" | One row per event; cheap per row, expensive in volume. | [OTel Logs data model](https://opentelemetry.io/docs/specs/otel/logs/data-model/) |

The pairing rule: **metrics for alerts, traces for root cause, logs for
context**. Alerting on individual traces does not scale; trying to root-cause
from aggregated metrics does not converge. The exemplar (§4) is what bridges
the two.

---

## 2. Instrumentation: semantic conventions and instrument types

Source: [OpenTelemetry — General metrics semantic conventions](https://opentelemetry.io/docs/specs/semconv/general/metrics/) and [HTTP metrics semantic conventions](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/).

The cardinal sin in microservice metrics is **inventing names**. Each team
exports `requests_total`, `http_count`, `api_calls`, with different
attribute names (`endpoint` vs `path` vs `route`). Dashboards stop working
when a service is migrated. Standardize on OTel semantic conventions.

### The canonical HTTP server set (from OTel semconv)

| Metric | Instrument | Unit | Required attributes |
|---|---|---|---|
| `http.server.request.duration` | Histogram | `s` (seconds) | `http.request.method`, `url.scheme` |
| `http.server.active_requests` | UpDownCounter | `{request}` | `http.request.method`, `url.scheme` |
| `http.server.request.body.size` | Histogram | `By` (bytes) | same as duration |

Recommended additional attributes (the OTel spec marks these "conditionally
required" or "recommended"):

- `http.response.status_code` (the HTTP status, integer)
- `http.route` (the *templated* route — `/users/{id}`, not `/users/42`)
- `server.address`, `server.port`
- `error.type` (set when the call failed; the exception class name or
  status code class — `"500"`, `"timeout"`, `"connection_refused"`)

**Cardinality control:** never put a raw URL path in `http.route`, never put
a user ID in `client.address`. Histograms with high-cardinality labels are
the most common cause of cardinality explosions in Prometheus.

### Instrument types

Source: [OTel Metrics API — Instrument types](https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument).

| Instrument | When to use | Reset semantics |
|---|---|---|
| `Counter` | Monotonically increasing total (requests, bytes, errors). | Resets on process restart. Always view as `rate()` for alerting. |
| `UpDownCounter` | Quantity that can go up *or* down (queue depth, active connections). | Reset on restart. |
| `Histogram` | Distribution of values (request duration, request body size). | Reset on restart. Use `histogram_quantile()` to get percentiles. |
| `Gauge` (Observable Gauge) | Instantaneous value sampled at scrape time (memory usage, temperature). | No reset semantics — each scrape is independent. |

### Histogram buckets — get this right or pay forever

Source: [Prometheus — Histograms and Summaries](https://prometheus.io/docs/practices/histograms/).

A classic Prometheus histogram is N+1 timeseries (`_bucket{le="…"}` per
bucket, plus `_count` and `_sum`). Each `(metric × label combo × bucket)`
is a stored timeseries. A 10-bucket histogram on a metric with 50
label-combinations is 600 timeseries. Multiply across pods and services.

**Pick buckets for the SLO threshold, not for visual prettiness.** If your
SLO is "p99 < 250ms", you need bucket boundaries clustered around 250ms:

```
0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10   # seconds
```

The OTel SDK lets you override per-instrument via the **View** API:

```go
// Go SDK example — set custom buckets for HTTP server duration
import sdkmetric "go.opentelemetry.io/otel/sdk/metric"

view := sdkmetric.NewView(
    sdkmetric.Instrument{Name: "http.server.request.duration"},
    sdkmetric.Stream{
        Aggregation: sdkmetric.AggregationExplicitBucketHistogram{
            Boundaries: []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10},
        },
    },
)
provider := sdkmetric.NewMeterProvider(
    sdkmetric.WithView(view),
    sdkmetric.WithReader(reader),
)
```

The upstream Prometheus doc states the reason bucket selection matters:

> "Note that this expression strictly requires a bucket boundary configured
> at 0.3. If the histograms involved do not have a bucket with that
> boundary, no interpolation is applied."

Native histograms (sparse histograms) sidestep this: they use dynamic
exponential bucketing so the *same* timeseries can answer any quantile
query. The OTel exponential histogram aggregation maps directly to
Prometheus native histograms via the `prometheusremotewrite` exporter when
the receiver is recent enough.

---

## 3. Sampling: head vs tail

Source: [OTel — Sampling](https://opentelemetry.io/docs/concepts/sampling/) and the
[Tail sampling processor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor).

### Head sampling — the cheap, lossy default

The decision is made at root-span time, based on `trace_id`, using a
deterministic hash. **All services in the trace make the same decision**
(via the `ParentBased(TraceIdRatioBased(0.01))` sampler), so partial traces
do not happen.

But head sampling at 1% means you keep 1% of *everything* — including 1%
of the failing requests, which is the exact set you wanted.

### Tail sampling — what you actually want in production

The OTel Collector's `tail_sampling` processor holds spans in memory until
the full trace is observed (or `decision_wait` expires), then applies
policies. Supported policies include:

- `always_sample`
- `latency` — keep traces whose total duration exceeds a threshold
- `numeric_attribute`, `string_attribute`, `boolean_attribute` — keep
  traces matching an attribute
- `status_code` — keep traces with `ERROR` (or `UNSET`)
- `probabilistic` — keep a fixed fraction
- `rate_limiting`, `bytes_limiting` — caps for cost control
- `span_count`, `trace_state`, `trace_flags`
- `ottl_condition` — full OTTL expression
- `and`, `not`, `drop`, `composite` — combinators

Trade-offs from the spec:

> "The component(s) that implement tail sampling must be stateful systems
> that can accept and store a large amount of data."

> "Tail sampling can be difficult to implement [and] difficult to operate."

The decision-wait window (default 30s) is the trace-completion bound: any
span arriving later than that is dropped. Long-running traces (cron jobs,
streaming connections) need either a longer window or a different sampler.

---

## 4. Exemplars: the bridge from metrics to traces

Source: [OTel Metrics — Exemplars](https://opentelemetry.io/docs/specs/otel/metrics/data-model/#exemplars).

An **exemplar** is a single observation attached to a metric data point,
carrying the trace context that originated the observation:

| Field | Purpose |
|---|---|
| `time_unix_nano` | When the observation happened. |
| `value` | The recorded value (e.g., `0.732` seconds for a request duration). |
| `trace_id`, `span_id` | The trace context — *this is the bridge*. |
| `filtered_attributes` | Attributes from the recording context not already on the metric stream. |

Quoting the spec:

> "An exemplar is a recorded value that associates OpenTelemetry context to
> a metric event within a Metric."

> "Exemplars allow users to link Trace signals w/ Metrics."

For histograms:

> "When an exemplar exists, its value already participates in
> `bucket_counts`, `count` and `sum`."

This is what makes Grafana's "click a histogram bar → jump to the slowest
trace in that bucket" actually work. Without exemplars, you have a p99
spike with no way to find an example request that contributed to it. With
exemplars, every histogram bucket carries a small reservoir of (trace_id,
span_id) pointers; one click takes you from the metric to the trace.

The verifier flags any HTTP/RPC histogram exporter that is **not** emitting
exemplars when running through an OTel Collector with the OTLP HTTP/gRPC
exporter, because the cost is near-zero and the diagnostic value is the
entire reason to instrument with OTel rather than vanilla Prometheus.

---

## 5. SLOs and multi-burn-rate alerting

Source: [Google SRE Workbook — Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/), Table 5-8.

An SLO ("99.9% of requests succeed over 30 days") implies an **error
budget** (0.1% × 30 days × requests-per-day). Alerting on raw error rate
("page when error rate > 1%") produces both false positives and false
negatives:

- A 30-second 100% outage burns ~0.07% of the monthly budget — possibly
  acceptable, but most teams page on it.
- A sustained 0.5% error rate over 24 hours burns ~16% of the budget —
  catastrophic, but doesn't trip a "1%" alert.

The fix: alert on **burn rate** — how fast the budget is being consumed
relative to its 30-day rate.

### Table 5-8 from the SRE workbook (99.9% SLO)

| Severity | Long window | Short window | Burn rate | Budget consumed at fire time |
|---|---|---|---|---|
| Page | 1 hour | 5 minutes | 14.4× | 2% |
| Page | 6 hours | 30 minutes | 6× | 5% |
| Ticket | 3 days | 6 hours | 1× | 10% |

Quoting the workbook:

> "We recommend the parameters listed in [Table 5-8] … as the starting
> point for your SLO-based alerting configuration."

> "A good guideline is to make the short window 1/12 the duration of the
> long window."

### Why two windows joined by `AND`

The long window has good precision but a long reset time (an alert that
fired at 1h-mean keeps firing for ~1h after the underlying issue stopped).
The short window has fast reset but is noisy. The conjunction gives you
both:

> "you can send a page-level alert when you exceed the 14.4× burn rate over
> both the previous one hour and the previous five minutes. This alert
> fires only once you've consumed 2% of the budget, but exhibits a better
> reset time."

The recording rules + alerting rules from the workbook:

```yaml
groups:
  - name: slo
    rules:
      - record: job:slo_errors_per_request:ratio_rate5m
        expr: sum(rate(slo_errors[5m])) by (job) / sum(rate(slo_requests[5m])) by (job)
      - record: job:slo_errors_per_request:ratio_rate30m
        expr: sum(rate(slo_errors[30m])) by (job) / sum(rate(slo_requests[30m])) by (job)
      - record: job:slo_errors_per_request:ratio_rate1h
        expr: sum(rate(slo_errors[1h])) by (job) / sum(rate(slo_requests[1h])) by (job)
      - record: job:slo_errors_per_request:ratio_rate6h
        expr: sum(rate(slo_errors[6h])) by (job) / sum(rate(slo_requests[6h])) by (job)

      - alert: ErrorBudgetBurnFast
        # 99.9% SLO -> error budget = 0.001
        # 14.4x burn rate -> threshold = 14.4 * 0.001 = 0.0144
        expr: |
          (
            job:slo_errors_per_request:ratio_rate1h{job="myjob"}  > (14.4 * 0.001)
            and
            job:slo_errors_per_request:ratio_rate5m{job="myjob"}  > (14.4 * 0.001)
          )
          or
          (
            job:slo_errors_per_request:ratio_rate6h{job="myjob"}  > (6 * 0.001)
            and
            job:slo_errors_per_request:ratio_rate30m{job="myjob"} > (6 * 0.001)
          )
        labels: { severity: page }
```

The verifier confirms that every workload with a stated SLO has:

1. A recording rule producing the SLI as a ratio (success / total).
2. Recording rules for the four windows above.
3. A page alert with both `1h ∧ 5m` and `6h ∧ 30m`, joined by `or`.
4. A ticket alert for the slow 3d / 6h pair.

---

## 6. Worked examples

### Example 1 — RED method (sourced introductory)

Source: [Tom Wilkie — The RED Method (Grafana blog, 2018-08-02)](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/).

Tom Wilkie's RED method instruments every request-driven service with
exactly three signals:

- **Rate** — requests per second
- **Errors** — failing requests per second
- **Duration** — distribution of request latency

Wilkie's own framing:

> "The USE Method doesn't really apply to services; it applies to hardware,
> network disks, things like this. We really wanted a microservices-oriented
> monitoring philosophy, so we came up with the RED Method."

The OTel mapping is one-to-one against `http.server.request.duration`:

```promql
# Rate
sum by (service, http_route, http_request_method) (
  rate(http_server_request_duration_seconds_count[5m])
)

# Errors (anything with a 5xx or an error.type label)
sum by (service, http_route) (
  rate(
    http_server_request_duration_seconds_count{
      http_response_status_code=~"5..|^$"
    }[5m]
  )
)

# Duration (p50, p95, p99 from the same histogram)
histogram_quantile(0.99,
  sum by (le, service, http_route) (
    rate(http_server_request_duration_seconds_bucket[5m])
  )
)
```

Every workload dashboard should have these three panels per service. The
auditor flags missing RED panels at the service level.

---

### Example 2 — USE method for node resources (sourced introductory)

Source: [Brendan Gregg — The USE Method](https://www.brendangregg.com/usemethod.html).

For *physical resources* (CPU cores, memory, network interfaces, disks),
the USE method asks three questions:

- **Utilization** — % of time the resource is busy
- **Saturation** — degree of queued work waiting on the resource
- **Errors** — error events on the resource

Wilkie places it in contrast to RED:

> "It's like the RED Method is about caring about your users and how happy
> they are, and the USE Method is about caring about your machines and how
> happy they are. It's really just two different views on the same system."

For Kubernetes nodes (via `node_exporter` and `cadvisor`):

```promql
# CPU utilization per node
1 - avg by (node) (rate(node_cpu_seconds_total{mode="idle"}[5m]))

# CPU saturation — run-queue length
node_load1 / count without () (node_cpu_seconds_total{mode="idle"})

# Memory utilization (RSS / total)
1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)

# Disk saturation — IO wait %
rate(node_disk_io_time_weighted_seconds_total[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
  + rate(node_network_transmit_errs_total[5m])
```

The auditor confirms a USE dashboard exists for the underlying node pool —
if it doesn't, a node-level performance problem is invisible behind the
service-level RED metrics.

---

### Example 3 (complex) — Exemplar-driven latency drill-in

Source: [OTel Metrics — Exemplars](https://opentelemetry.io/docs/specs/otel/metrics/data-model/#exemplars), [Prometheus — Exemplar storage](https://prometheus.io/docs/prometheus/latest/feature_flags/#exemplars-storage), [Grafana — Tempo + Prometheus exemplars](https://grafana.com/docs/grafana/latest/fundamentals/exemplars/).

**Problem.** The p99 of `http.server.request.duration` for the `checkout`
service jumped from 180ms to 1.4s at 14:32. The aggregate metric tells you
*that* it happened and which bucket it spilled into. It does not tell you
*why*. Without exemplars you'd run a series of `topk` queries by route,
status, instance, hoping to narrow it down; if the cause is a
parameter-specific slow query, you may never find it.

**Pipeline.** Three concrete pieces:

1. **SDK emits exemplars.** OTel SDKs record an exemplar whenever the
   current span context is sampled. With `tracesSampler=parentbased_traceidratio(0.05)`
   and `metric_exemplar_filter=trace_based` (default in most SDKs), an
   exemplar is recorded for ~5% of requests — but **only sampled ones**, so
   they're guaranteed to be findable in the trace store.

2. **Collector forwards exemplars to Prometheus.** The
   `prometheusremotewrite` exporter (and the in-process `prometheus`
   exporter) preserves exemplars when `enable_exemplars: true`. Prometheus
   needs `--enable-feature=exemplar-storage`.

3. **Tempo (or Jaeger, or any OTLP trace backend) stores the trace
   keyed by `trace_id`.** Grafana's Prometheus datasource is linked to the
   trace datasource via a derived field, so clicking an exemplar dot on
   the latency histogram opens the trace.

**Full Collector config:**

```yaml
receivers:
  otlp:
    protocols:
      grpc: { endpoint: 0.0.0.0:4317 }
      http: { endpoint: 0.0.0.0:4318 }

processors:
  batch: {}
  # Convert delta-temporality histograms from Go/Java SDKs to cumulative
  # so Prometheus can ingest them, while preserving exemplars.
  cumulativetodelta: {}
  # Trim high-cardinality attributes BEFORE export
  attributes:
    actions:
      - key: url.full
        action: delete
      - key: user.id
        action: delete

exporters:
  prometheusremotewrite:
    endpoint: https://prom.internal/api/v1/write
    send_exemplars: true            # << this is the bit
    resource_to_telemetry_conversion:
      enabled: true
  otlp/tempo:
    endpoint: tempo:4317
    tls: { insecure: true }

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [attributes, batch]
      exporters: [prometheusremotewrite]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/tempo]
```

**Grafana panel** showing exemplars on the p99 line:

```promql
# Latency p99 with exemplars
histogram_quantile(0.99,
  sum by (le, http_route) (
    rate(http_server_request_duration_seconds_bucket{service="checkout"}[5m])
  )
)
```

In the panel options, set `Exemplars: on`. Each exemplar appears as a
small diamond on the chart at its `(time, value)` coordinate. Hover →
"Query with Tempo" → the matching trace opens, with the slow span(s)
highlighted.

**What this gives you that aggregates never will.** The exemplar carries the
trace context for the specific request that pushed p99 over the cliff. When
the underlying issue is "this one large customer's checkout has an N+1
query against a 10M-row table", the exemplar drops you directly into a
trace showing the 832 DB spans. Without it, you would not find this from
a histogram.

**Cost.** Exemplars are stored in a per-series ring buffer (default ~10 per
series in Prometheus). Storage cost is a single-digit percentage on top of
the existing histogram cost.

---

### Example 4 (complex) — Tail-sampled error pipeline + multi-burn-rate SLO alerts

This is the production-grade observability pipeline. It combines:

- **Tail sampling** to retain 100% of error traces and a tunable fraction
  of slow traces, while head-sampling the rest at 1%.
- **RED metrics** unaffected by trace sampling (metrics are recorded for
  every request).
- **Multi-burn-rate SLO alerting** (Google SRE Table 5-8) wired against the
  RED error counter.
- **Exemplars** plumbed end-to-end so each alert deep-links to a trace.

**Collector config.** Each agent runs as a DaemonSet (per-node receiver +
batch processor), then forwards to a small fleet of "gateway" collectors
that own the tail-sampling decision (the gateway holds *all* spans of a
given trace_id, which means a load-balancing exporter is required to ensure
trace affinity).

```yaml
# AGENT (DaemonSet) — receive OTLP, batch, forward to gateway with trace_id affinity
receivers:
  otlp:
    protocols: { grpc: {}, http: {} }
processors:
  batch: { send_batch_size: 10000, timeout: 200ms }
exporters:
  loadbalancing:
    routing_key: traceID            # << ensures all spans of a trace land on same gateway
    protocol:
      otlp:
        tls: { insecure: true }
    resolver:
      k8s:
        service: otel-gateway.observability.svc.cluster.local
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [loadbalancing]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/prom-gateway]
```

```yaml
# GATEWAY (Deployment) — tail-sample + export
receivers:
  otlp:
    protocols: { grpc: {} }
processors:
  tail_sampling:
    decision_wait: 30s
    num_traces: 200000
    expected_new_traces_per_sec: 5000
    policies:
      # Always keep error traces
      - name: errors
        type: status_code
        status_code: { status_codes: [ERROR] }
      # Always keep slow traces (>1s)
      - name: slow
        type: latency
        latency: { threshold_ms: 1000 }
      # Always keep traces touching a critical route
      - name: critical-route
        type: string_attribute
        string_attribute:
          key: http.route
          values:
            - "/v1/checkout"
            - "/v1/payment"
      # Keep 1% of everything else as a baseline
      - name: baseline
        type: probabilistic
        probabilistic: { sampling_percentage: 1 }
      # Cap total throughput to keep the backend honest
      - name: cap
        type: rate_limiting
        rate_limiting: { spans_per_second: 50000 }
exporters:
  otlp/tempo:
    endpoint: tempo-distributor.observability:4317
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [tail_sampling]
      exporters: [otlp/tempo]
```

**Why `loadbalancing` matters.** Tail-sampling decisions need the *whole*
trace in one process. If two agents send different spans of the same
`trace_id` to different gateway replicas, neither gateway sees the full
trace, the `status_code` policy never fires for the error span, and you
lose the trace you most wanted. The `loadbalancing` exporter with
`routing_key: traceID` guarantees trace affinity per gateway.

**Recording rules** (Prometheus) computing the SLI:

```yaml
groups:
  - name: checkout-slo
    interval: 30s
    rules:
      # Total requests
      - record: checkout:requests:rate5m
        expr: |
          sum(rate(http_server_request_duration_seconds_count{
            service="checkout"
          }[5m]))
      # Successful requests (2xx, 3xx)
      - record: checkout:successes:rate5m
        expr: |
          sum(rate(http_server_request_duration_seconds_count{
            service="checkout",
            http_response_status_code!~"5.."
          }[5m]))
      # Failure ratio (this is the SLI complement)
      - record: checkout:slo_errors:ratio_rate5m
        expr: |
          1 - (checkout:successes:rate5m / checkout:requests:rate5m)
      # … repeat for 30m, 1h, 6h, 3d windows
```

**Alerting rules** (the Google SRE multi-burn-rate pair):

```yaml
groups:
  - name: checkout-slo-alerts
    rules:
      # Page: fast burn — 14.4x over 1h AND 5m
      - alert: CheckoutBudgetBurnFast
        expr: |
          (
            checkout:slo_errors:ratio_rate1h  > (14.4 * 0.001)
            and
            checkout:slo_errors:ratio_rate5m  > (14.4 * 0.001)
          )
          or
          (
            checkout:slo_errors:ratio_rate6h  > (6 * 0.001)
            and
            checkout:slo_errors:ratio_rate30m > (6 * 0.001)
          )
        for: 2m
        labels:
          severity: page
          slo: "99.9"
        annotations:
          summary: "Checkout is burning the error budget fast"
          runbook: "https://runbooks.internal/checkout/budget-burn"
          # Direct link to the slowest exemplar in the same window
          trace_query: |-
            histogram_quantile(0.99,
              sum by (le) (rate(http_server_request_duration_seconds_bucket{service="checkout"}[5m]))
            )

      # Ticket: slow burn — 1x over 3d AND 6h
      - alert: CheckoutBudgetBurnSlow
        expr: |
          checkout:slo_errors:ratio_rate3d  > (1 * 0.001)
          and
          checkout:slo_errors:ratio_rate6h  > (1 * 0.001)
        for: 1h
        labels:
          severity: ticket
          slo: "99.9"
```

**Total error-budget for 99.9% over 30 days** = `0.001 × 30d ×
requests/30d`. The thresholds above (`14.4 × 0.001` = `0.0144`) come
directly from Table 5-8.

**What this whole pipeline gives you.**

- The page fires at 2% budget consumption (Table 5-8) — fast enough to
  prevent a budget blowout, slow enough that a 30s blip does not page.
- The alert annotation links straight to the latency histogram with
  exemplars on; the on-call clicks any red exemplar dot to land in a
  100%-retained error trace.
- Because tail-sampling retains every error trace, the trace is *always*
  there — not "we sampled 1% and lost this one".
- The metrics that drive the alert are unaffected by sampling — they are
  recorded for every request before any sampler runs.

**Cost knobs.**

- `decision_wait` (30s) trades memory for trace completeness.
- `num_traces` (200000) bounds the in-memory buffer.
- The `probabilistic: 1` baseline keeps your traffic-profile dashboards
  honest without paying full freight.
- The `rate_limiting` policy is the cost ceiling; everything else is
  best-effort below it.

---

## 7. Log correlation

Source: [OTel — Logs data model](https://opentelemetry.io/docs/specs/otel/logs/data-model/).

For logs to be useful next to traces, every log line emitted while a span
is active must carry the `trace_id` and `span_id`. OTel SDKs do this
automatically when the logging integration is wired (Python `LoggingHandler`,
Node `@opentelemetry/instrumentation-winston` / `pino`, Go `slog` with
`otelslog`, Java `OpenTelemetryAppender` for Logback).

The auditor greps for the integration and rejects "logs without trace_id"
on any service that emits OTel metrics — the disconnect is the most common
reason "we have observability" is technically true but operationally useless.

---

## 8. Events

Source: [Kubernetes — Events](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/).

Kubernetes Events (`kubectl get events`) are first-class observability data
— they explain why a pod is `Pending`, `OOMKilled`, `ImagePullBackOff`. By
default they expire after 1 hour. The auditor checks that the cluster has
an event exporter (the `kubernetes_events` receiver in OTel Collector, or
the [event-exporter project](https://github.com/opsgenie/kubernetes-event-exporter))
forwarding them to long-term storage and that dashboards pivot on
`involvedObject.uid` to correlate with workloads.

---

## Auditor checklist (summary)

The auditor produces a report keyed against this list:

| Item | Source |
|---|---|
| HTTP/RPC server histograms use OTel semantic conventions | §2 |
| Histogram buckets clustered around the SLO threshold | §2 |
| Cardinality controlled — no raw user IDs, paths, etc. | §2 |
| At least one RED panel per service | §6.1 |
| At least one USE dashboard per node pool | §6.2 |
| Exemplars enabled SDK → collector → Prometheus, linked to trace store | §6.3 |
| Tail sampling configured with status_code + latency + probabilistic baseline | §6.4 |
| Trace affinity via loadbalancing exporter or equivalent | §6.4 |
| Multi-burn-rate SLO alerts (1h∧5m, 6h∧30m, 3d∧6h) per Table 5-8 | §5, §6.4 |
| Logs carry trace_id / span_id when emitted within a span | §7 |
| Kubernetes Events exported and correlated by `involvedObject.uid` | §8 |
