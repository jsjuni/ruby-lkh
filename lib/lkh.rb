# frozen_string_literal: true

require 'open3'
require 'tsplib'
require 'tmpdir'

class LKH

  def initialize(tsp)
    @tsp = tsp
  end

  attr_reader :tour, :cost

  def optimize(&block)

    # Create temporary directory.

    Dir.mktmpdir do |dir|

      Dir.chdir(dir) do

        File.open('problem.par', 'w') do |f|
          f.puts('PROBLEM_FILE = problem.tsp')
          f.puts('TOUR_FILE = problem.sol')
        end

        File.open("problem.tsp", 'w') do |f|
          f.puts(@tsp.to_s)
        end

        lkh_cmd = 'lkh problem.par 2> /dev/null'
        Open3.popen2(lkh_cmd) do |stdin, stdout, wait_thr|

          stdout.each do |line|
            yield line if block_given?
          end

        end

        tour_file = File.open("problem.sol").read
        @cost = tour_file.match(/Length = (\d+)/)[1].to_i
        @tour = tour_file.match(/TOUR_SECTION\s+(((\d+)\s+)+)/m)[1].split.map { |s| s.to_i - 1}
      end

    end
  end

end
