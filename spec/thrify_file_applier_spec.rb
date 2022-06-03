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

  it "processes array source_path" do
    applier = ThriftyFileApplier::Applier.new(
      'tmp/timestamp',
      'tmp/source/file1',
                'tmp/source/file2'
    ) do
      "compile"
    end

    rm_f 'tmp/timestamp'

    touch('tmp/source/file1')
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
    touch('tmp/source/file2')
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end

  it "searches files recursively" do
    applier = ThriftyFileApplier::Applier.new(
      'tmp/timestamp',
      'tmp/source/'
    ) do
      "compile"
    end

    mkdir_p 'tmp/source/p1/p2/p3'
    mkdir_p 'tmp/source/p1/p2/p4'

    touch('tmp/source/p1/p2/file1')
    expect(applier.apply).to eq "compile"
    touch('tmp/source/p1/p2/p3/file1')
    expect(applier.apply).to eq "compile"
    touch('tmp/source/p1/p2/p4/file1')
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end
end
