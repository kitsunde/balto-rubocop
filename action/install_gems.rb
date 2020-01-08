class GemfileStrategy
  def install
    system("gem install -N #{gem_specifications.join(' ')}")
  end

  private

  def gem_specifications
    File
      .read("Gemfile.lock")
      .lines
      .select { |l| line_contains_gem_we_care_about?(l) }
      .select { |l| line_contains_exact_version?(l) }
      .map { |l| gemfile_line_to_cli_specification(l) }
  end

  def gemfile_line_to_cli_specification(line)
    name, version = line.split(' ')
    version = version.tr('()', '')
    %("#{name}:#{version}")
  end

  def line_contains_gem_we_care_about?(line)
    line.include?('rubocop')
  end

  def line_contains_exact_version?(line)
    line.match(/\(\d*\.\d*\.\d*\)/)
  end
end

class GemspecStrategy
  attr_reader :gemspec

  def initialize(filename)
    @gemspec = Gem::Specification.load(filename)
  end

  def install
    gemspec
      .dependencies
      .select { |d| gem_we_care_about?(d.name) }
      .each { |d| Gem.install(d.name, d.requirement) }
  end

  private

  def gem_we_care_about?(name)
    return true if name == 'standard'

    name.start_with?('rubocop')
  end
end

def choose_gem_strategy
  if File.exist?('Gemfile.lock')
    GemfileStrategy.new
  elsif gemspec_file = Dir.glob('*.gemspec').first
    GemspecStrategy.new(gemspec_file)
  else
    raise "Assumed a Gemfile.lock or a .gemspec file existed... but it doesn't!"
  end
end

choose_gem_strategy.install