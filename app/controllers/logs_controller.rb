class LogsController < ApplicationController
  include FileTail
  def index
    loop do
      f = File.open("log/acd.text", "r")
      new_hash = File.stat(f).mtime.to_i
      hash ||= new_hash
      diff_hash = new_hash - hash
      unless diff_hash.zero?
        hash = new_hash
        binding.pry
        print tail("log/acd.text", 10)
      end
    end
  end
end

