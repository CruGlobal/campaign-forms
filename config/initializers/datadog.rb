require "ddtrace"
require "datadog/statsd"

if ENV["AWS_EXECUTION_ENV"].present?
  Datadog.configure do |c|
    # Global settings
    c.tracing.transport_options = proc { |t|
      # Provide local path to trace agent Unix socket
      t.adapter :unix, "/var/run/datadog/apm.socket"
    }
    c.runtime_metrics.statsd = Datadog::Statsd.new socket_path: "var/run/datadog/dsd.socket"
    c.runtime_metrics.enabled = true

    c.service = ENV["PROJECT_NAME"]
    c.env = ENV["ENVIRONMENT"]

    # Tracing settings
    c.tracing.analytics.enabled = true
    c.tracing.partial_flush.enabled = true

    # Instrumentation
    c.tracing.instrument :rails,
      service_name: ENV["PROJECT_NAME"],
      controller_service: "#{ENV["PROJECT_NAME"]}-controller",
      cache_service: "#{ENV["PROJECT_NAME"]}-cache",
      database_service: "#{ENV["PROJECT_NAME"]}-db"

    c.tracing.instrument :redis, service_name: "#{ENV["PROJECT_NAME"]}-redis"

    c.tracing.instrument :sidekiq, service_name: "#{ENV["PROJECT_NAME"]}-sidekiq"

    c.tracing.instrument :http, service_name: "#{ENV["PROJECT_NAME"]}-http"
  end

  # skipping the health check: if it returns true, the trace is dropped
  Datadog::Tracing.before_flush(Datadog::Tracing::Pipeline::SpanFilter.new { |span|
    span.name == "rack.request" && span.get_tag("http.url") == "/monitors/lb"
  })
end
