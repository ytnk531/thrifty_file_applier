# frozen_string_literal: true

require_relative "thrifty_file_applier/version"
require "fileutils"

# Executes specified block only if source file had been updated.
module ThriftyFileApplier
  class Error < StandardError; end

  def self.applier(last_execution_log_path, source_path, &executor)
    Applier.new(last_execution_log_path, source_path, &executor)
  end

  # Actual applier class.
  class Applier
    def initialize(last_execution_log_path, source_path, &executor)
      @last_execution_log_path = Pathname.new last_execution_log_path
      @update_source_path = Pathname.new source_path
      @executor = executor
    end

    def apply
      exec_if_needed(&@executor)
    end

    def exec_if_needed(&block)
      return if last_execution_time >= last_update_time

      log_execution(&block)
    end

    private

    def log_execution
      execution_time = Time.now.to_f
      result = yield
      FileUtils.mkdir_p(@last_execution_log_path.dirname)
      @last_execution_log_path.open("wb") { |f| f.write(execution_time) }
      result
    end

    def last_update_time
      if @update_source_path.directory? && @update_source_path.children.size.positive?
        newest_mtime path
      else
        @update_source_path.mtime
      end
    end

    def last_execution_time
      time_float = if @last_execution_log_path.exist?
                     @last_execution_log_path.read.to_f
                   else
                     0.0
                   end
      Time.at time_float
    end

    def newest_mtime(path)
      path.each_child
          .map { File.mtime(_1) }
          .max
    end
  end
end
