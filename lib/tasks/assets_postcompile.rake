# frozen_string_literal: true

require 'pathname'

# Every time assets:precompile is called, trigger assets:postcompile afterwards.
Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:postcompile'].invoke
end

namespace :assets do
  logger = Logger.new($stderr)

  # Based on suggestion at https://github.com/rails/sprockets-rails/issues/49#issuecomment-20535134
  task postcompile: :"assets:environment" do
    manifest_path = Dir.glob(File.join(Rails.root, 'public/assets/.sprockets-manifest-*.json')).first
    manifest_data = JSON.load(File.new(manifest_path))

    manifest_data['assets'].each do |logical_path, digested_path|
      next unless %w[campaign-form.js].include? logical_path

      full_digested_path    = Rails.root.join('public', 'assets', digested_path)
      full_nondigested_path = Rails.root.join('public', 'assets', logical_path)

      logger.info "Copying to #{full_nondigested_path}"

      # Use FileUtils.copy_file with true third argument to copy
      # file attributes (eg mtime) too, as opposed to FileUtils.cp
      # Making symlnks with FileUtils.ln_s would be another option, not
      # sure if it would have unexpected issues.
      FileUtils.copy_file full_digested_path, full_nondigested_path, true
    end
  end
end
