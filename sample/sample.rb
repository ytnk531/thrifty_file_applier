# frozen_string_literal: true

require "thrifty_file_applier"

applier = ThriftyFileApplier.applier("tmp/last_application_time", "source") do
  puts "compile"
end
FileUtils.touch "source/file"
applier.apply # => compile
applier.apply # => nil
FileUtils.touch "source/file"
applier.apply # => compile
FileUtils.rm "source/file"
applier.apply # => compile