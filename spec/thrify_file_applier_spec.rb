# frozen_string_literal: true

RSpec.describe ThriftyFileApplier::Applier do
  include FileUtils

  it "applies if needed" do
    log_path = "tmp/timestamp"
    source_path = "tmp/source"
    mkdir_p(source_path)
    applier = ThriftyFileApplier::Applier.new(
      "tmp/timestamp",
      "tmp/source"
    ) do
      "compile"
    end

    rm_f(log_path)
    touch("#{source_path}file")
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end

  it "processes array source_path" do
    applier = ThriftyFileApplier::Applier.new(
      "tmp/timestamp",
      "tmp/source/file1",
      "tmp/source/file2"
    ) do
      "compile"
    end

    rm_f "tmp/timestamp"

    touch("tmp/source/file1")
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil

    wait
    touch("tmp/source/file2")
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end

  it "searches files recursively" do
    applier = ThriftyFileApplier::Applier.new(
      "tmp/timestamp",
      "tmp/source/"
    ) do
      "compile"
    end

    mkdir_p "tmp/source/p1/p2/p3"
    mkdir_p "tmp/source/p1/p2/p4"
    rm_f "tmp/timestamp"

    touch("tmp/source/p1/p2/file1")
    expect(applier.apply).to eq "compile"

    wait
    touch("tmp/source/p1/p2/p3/file2")
    expect(applier.apply).to eq "compile"

    wait
    touch("tmp/source/p1/p2/p4/file3")
    expect(applier.apply).to eq "compile"
    expect(applier.apply).to eq nil
  end

  def wait
    # This waiting time is needed to update mtime.
    # In CI environment, mtime is not updated in short time.
    sleep 0.01
  end
end
