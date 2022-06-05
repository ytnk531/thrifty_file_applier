# frozen_string_literal: true

require_relative "thrifty_file_applier/version"
require "fileutils"

# Executes specified block only if source file had been updated.
module ThriftyFileApplier
  class Error < StandardError; end

  def self.applier(last_execution_log_path, *source_paths, &executor)
    Applier.new(last_execution_log_path, *source_paths, &executor)
  end

  def self.apply(last_execution_log_path, *source_paths, &executor)
    applier(last_execution_log_path, *source_paths, &executor).apply
  end

  # Actual applier class.
  class Applier
    def initialize(last_execution_log_path, *source_paths, &executor)
      @last_applied_log_path = Pathname.new last_execution_log_path
      @source_paths = source_paths.map { Pathname.new _1 }
      @executor = executor
    end

    def apply
      exec_if_updated(&@executor)
    end

    def exec_if_updated(&block)
      t = source_update_time
      exec_with_log(t, &block) if t > last_applied_mtime
    end

    private

    def exec_with_log(time)
      result = yield

      FileUtils.mkdir_p(@last_applied_log_path.dirname)
      @last_applied_log_path.open("wb") { |f| f.write(time.to_f) }

      result
    end

    def source_update_time
      @source_paths.map { last_update_time_in _1 }.max.to_f
    end

    def last_update_time_in(path)
      return Time.at 0 unless path.exist?

      newest_mtime path
    end

    def last_applied_mtime
      if @last_applied_log_path.exist?
        @last_applied_log_path.read.to_f
      else
        0.0
      end
    end

    def newest_mtime(path)
      return path.mtime if !path.directory? ||
                           (path.directory? && path.children.size.zero?)

      path.children
          .map { newest_mtime(_1) }
          .max
    end
  end
end
