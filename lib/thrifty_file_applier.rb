# frozen_string_literal: true

require_relative "thrifty_file_applier/version"
require "fileutils"

# Executes specified block only if source file had been updated.
module ThriftyFileApplier
  class Error < StandardError; end

  def self.applier(applied_time_path, *source_paths, &executor)
    Applier.new(applied_time_path, *source_paths, &executor)
  end

  def self.apply(applied_time_path, *source_paths, &executor)
    applier(applied_time_path, *source_paths, &executor).apply
  end

  # Actual applier class.
  class Applier
    def initialize(applied_time_path, *source_paths, &executor)
      @last_applied_log_path = Pathname.new applied_time_path
      @source_paths = source_paths.map { Pathname.new _1 }
      @executor = executor
    end

    def apply
      exec_if_updated(&@executor)
    end

    def exec_if_updated(&block)
      update_time_f = source_update_time.to_f
      exec_with_log(update_time_f, &block) if update_time_f > last_applied_time_f
    end

    private

    def exec_with_log(time_f)
      result = yield

      FileUtils.mkdir_p(@last_applied_log_path.dirname)
      @last_applied_log_path.open("wb") { |f| f.write(time_f) }

      result
    end

    def source_update_time
      @source_paths.map do |path|
        path.exist? ? newest_mtime(path) : Time.at(0)
      end.max
    end

    def newest_mtime(path)
      return path.mtime if !path.directory? ||
                           (path.directory? && path.children.size.zero?)

      path.children
          .map { newest_mtime(_1) }
          .max
    end

    def last_applied_time_f
      if @last_applied_log_path.exist?
        @last_applied_log_path.read.to_f
      else
        0.0
      end
    end
  end
end
