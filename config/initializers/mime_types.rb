# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register "text/javascript", :mjs, %w[application/javascript application/x-javascript]
Rack::Mime::MIME_TYPES[".mjs"] = "text/javascript"
