# ThriftyFileApplier
This program can thrift applications of files.
It applies the specified file and records the time. In the second or after execution time, it compares the last applied time and the modification time of target files.
It it applies file again if the last modification time is newer than the last applied time.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add thrifty_file_applier

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install thrifty_file_applier

## Usage
`ThiriftyFileApplier.applier` method generates the applier.
The first argument is a file path to record the last applied time, and the second argument is the source file or directory.
It needs to be passed the block.
`#apply` method will apply the given block if needed. 
```ruby
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
```

`applier` also treats multiple source path.

```ruby
ThriftyFileApplier.applier("tmp/last_application_time", "source1", "source2") do
  puts "compile"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
