require 'pry'
module Pripalang
  OPERATORS = { increment: 'ぷり',
                decrement: 'ぷしゅ〜',
                ptr_next: 'マックスー',
                ptr_prev: 'リラックス〜',
                loop_start: 'かしこま！',
                loop_end: 'イゴ',
                put: 'ホログラメーション！',
                get: 'スキャンしてね',
                ajimi: 'ダ・ヴィンチ' }.freeze
  MEMORY_SIZE = 2**15
  class AjimiError < StandardError; end
  class InvalidAccessError < StandardError; end
  class InvalidLoopError < StandardError; end
  class Executor
    def initialize
      @ptr = 0
      @memory = Array.new(MEMORY_SIZE, 0)
    end

    def exec(str)
      pc = 0
      tokens = str.scan(/#{OPERATORS.values.join('|')}/)
      stack = []
      loop do
        case tokens[pc]
        when OPERATORS[:increment]
          raise InvalidAccessError if @ptr < 0 && @ptr >= MEMORY_SIZE
          @memory[@ptr] += 1
        when OPERATORS[:decrement]
          raise InvalidAccessError if @ptr < 0 && @ptr >= MEMORY_SIZE
          @memory[@ptr] -= 1
        when OPERATORS[:ptr_next]
          @ptr += 1
        when OPERATORS[:ptr_prev]
          @ptr -= 1
        when OPERATORS[:loop_start]
          if @memory[@ptr].zero?
            depth = 0
            tokens[pc + 1..-1].each.with_index(1) do |token, i|
              if depth.zero? && token == OPERATORS[:loop_end]
                pc += i
                break
              elsif token == OPERATORS[:loop_end]
                depth -= 1
              elsif token == OPERATORS[:loop_start]
                depth += 1
              end
            end
          else
            stack.push(pc)
          end
        when OPERATORS[:loop_end]
          raise InvalidLoopError if stack.empty?
          loop_start_pc = stack.pop - 1
          pc = loop_start_pc if @memory[@ptr] != 0
        when OPERATORS[:put]
          putc @memory[@ptr]
        when OPERATORS[:get]
          STDIN.getc
        when OPERATORS[:ajimi]
          raise AjimiError
        end
        pc += 1
        break if pc >= tokens.size
      end
    end
  end
end

file_name = ARGV[0]
File.open(file_name, 'r') do |file|
  Pripalang::Executor.new.exec(file.read)
end
