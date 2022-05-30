# frozen_string_literal: true

RSpec.describe ThriftyFileApplier::Applier do
  include FileUtils

  it "applies if needed" do
    log_path = 'tmp/timestamp'
    source_path = 'tmp/source'
    mkdir_p(source_path)
    applier = ThriftyFileApplier::Applier.new(
      'tmp/timestamp',
      'tmp/source'
    ) do
      "compile"
    end

    touch(source_path + 'file')
    rm_f(log_path)
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end
end
