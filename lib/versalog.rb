# frozen_string_literal: true

require "time"
require "thread"
require "date"
require "fileutils"

begin
  require "win32/notification" if Gem.win_platform?
rescue LoadError
  # win32-notification gem is not available
end

require_relative "versalog/version"

module Versalog
  class VersaLog
    COLOURS = {
      INFO: "\033[32m",
      ERROR: "\033[31m",
      WARNING: "\033[33m",
      DEBUG: "\033[36m",
      CRITICAL: "\033[35m",
  }.freeze

  SYMBOLS = {
    INFO: "[+]",
    ERROR: "[-]",
    WARNING: "[!]",
    DEBUG: "[D]",
    CRITICAL: "[C]",
  }.freeze

  RESET = "\033[0m"

  VALID_MODES = ["simple", "simple2", "detailed", "file"].freeze
  VALID_SAVE_LEVELS = ["INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL"].freeze
  
  def initialize(
    enum: "simple",
    tag: nil,
    show_file: false,
    show_tag: false,
    enable_all: false,
    notice: false,
    all_save: false,
    save_levels: nil,
    silent: false,
    catch_exceptions: false)

    if enable_all
      show_file = true
      show_tag  = true
      notice    = true
      all_save  = true
    end

    @enum = enum.downcase
    @tag = tag
    @show_file = show_file
    @show_tag = show_tag
    @enable_all = enable_all
    @notice = notice
    @all_save = all_save
    @save_levels = save_levels
    @silent = silent
    @catch_exceptions = catch_exceptions

    @log_queue = Queue.new
    @worker_thread = Thread.new { _worker }
    @last_cleanup_date = nil

    unless VALID_MODES.include?(@enum)
      raise ArgumentError, "Invalid enum: #{@enum}"
    end

    if @all_save
      if @save_levels.nil?
        @save_levels = VALID_SAVE_LEVELS.dup
      elsif !@save_levels.is_a?(Array)
        raise ArgumentError, "save_levels must be an Array. Example: ['ERROR']"
      elsif !@save_levels.all? { |level| VALID_SAVE_LEVELS.include?(level) }
        raise ArgumentError, "Invalid save_levels specified. Valid levels are: #{VALID_SAVE_LEVELS.join(', ')}"
      end
    end

    if @catch_exceptions
      at_exit do
        exception = $!
        _handle_exception(exception) if exception && exception.is_a?(Exception)
      end
    end
  end
  
  private

  def _handle_exception(exception)
    tb_str = exception.backtrace.join("\n")
    critical("Unhandled exception:\n#{exception.class}: #{exception.message}\n#{tb_str}")
  end
  
  def _worker
    loop do
      job = @log_queue.pop
      break if job.nil?
      
      case job[:type]
      when :log
        _save_log_sync(job[:log_text], job[:level])
      when :exception
        _handle_exception(job[:exception])
      end
    end
  end

  def _GetTime
    return Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def _GetCaller
    frame = caller(3, 1).first
    return nil if frame.nil?
    
    match = frame.match(/^(.+):(\d+):/)
    return nil unless match
    
    filename = File.basename(match[1])
    lineno = match[2]
    return "#{filename}:#{lineno}"
  end

  def _Cleanup_old_logs(days: 7)
    log_dir = File.join(Dir.pwd, 'log')
    return unless Dir.exist?(log_dir)

    now = Time.now
    Dir.entries(log_dir).each do |filename|
      next unless filename.end_with?('.log')
      next if filename == '.' || filename == '..'
      
      filepath = File.join(log_dir, filename)

      begin
        date_str = filename.gsub('.log', '')
        file_date = Date.strptime(date_str, '%Y-%m-%d').to_time
      rescue ArgumentError
        file_date = File.mtime(filepath)
      end

      if (now - file_date) / (24 * 60 * 60) >= days
        begin
          File.delete(filepath)
          info("[LOG CLEANUP] removed: #{filepath}") unless @silent
        rescue => e
          warning("[LOG CLEANUP WARNING] #{filepath} cannot be removed: #{e}") unless @silent
        end
      end
    end
  end

  def _save_log_sync(log_text, level)
    return unless @all_save
    return unless @save_levels.include?(level)
    
    log_dir = File.join(Dir.pwd, 'log')
    FileUtils.mkdir_p(log_dir)
    log_file = File.join(log_dir, Time.now.strftime('%Y-%m-%d') + '.log')
    
    File.open(log_file, 'a', encoding: 'utf-8') do |f|
      f.write(log_text + "\n")
    end

    today = Date.today
    if @last_cleanup_date != today
      _Cleanup_old_logs(days: 7)
      @last_cleanup_date = today
    end
  end

  def _save_log(log_text, level)
    return unless @save_levels.include?(level)
    
    log_dir = File.join(Dir.pwd, 'log')
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
    log_file = File.join(log_dir, Time.now.strftime('%Y-%m-%d') + '.log')
    
    File.open(log_file, 'a', encoding: 'utf-8') do |f|
      f.write(log_text + "\n")
    end
  end

  def _Log(msg, tye, tag = nil)
    colors = COLOURS[tye.to_sym] || ""
    types = tye.upcase

    final_tag = tag || (@show_tag ? @tag : nil)
    tag_str = final_tag || ""

    caller_info = (@show_file || @enum == "file") ? _GetCaller() : ""

    if @notice && ["ERROR", "CRITICAL"].include?(types)
      begin
        if defined?(Win32::Notification)
          Win32::Notification.new(
            title: "#{types} Log notice",
            message: msg,
            app_name: "VersaLog"
          ).show
        end
      rescue => e
        # Silently ignore notification errors
      end
    end

    case @enum
    when "simple"
      symbol = SYMBOLS[tye.to_sym] || "[?]"
      if @show_file
        formatted = "[#{caller_info}][#{tag_str}]#{colors}#{symbol}#{RESET} #{msg}"
        plain = "[#{caller_info}][#{tag_str}]#{symbol} #{msg}"
      else
        formatted = "#{colors}#{symbol}#{RESET} #{msg}"
        plain = "#{symbol} #{msg}"
      end

    when "simple2"
      symbol = SYMBOLS[tye.to_sym] || "[?]"
      time = _GetTime()
      if @show_file
        formatted = "[#{time}] [#{caller_info}][#{tag_str}]#{colors}#{symbol}#{RESET} #{msg}"
        plain = "[#{time}] [#{caller_info}][#{tag_str}]#{symbol} #{msg}"
      else
        formatted = "[#{time}] #{colors}#{symbol}#{RESET} #{msg}"
        plain = "[#{time}] #{symbol} #{msg}"
      end

    when "file"
      formatted = "[#{caller_info}]#{colors}[#{types}]#{RESET} #{msg}"
      plain = "[#{caller_info}][#{types}] #{msg}"

    else
      time = _GetTime()
      formatted = "[#{time}]#{colors}[#{types}]#{RESET}"
      plain = "[#{time}][#{types}]"
      if final_tag
        formatted += "[#{final_tag}]"
        plain += "[#{final_tag}]"
      end
      if @show_file
        formatted += "[#{caller_info}]"
        plain += "[#{caller_info}]"
      end
      formatted += " : #{msg}"
      plain += " : #{msg}"
    end

    puts(formatted) unless @silent

    @log_queue << { type: :log, log_text: plain, level: types }
  end

  public

  def info(msg, tag = nil)
    _Log(msg, "INFO", tag)
  end

  def error(msg, tag = nil)
    _Log(msg, "ERROR", tag)
  end

  def warning(msg, tag = nil)
    _Log(msg, "WARNING", tag)
  end

  def debug(msg, tag = nil)
    _Log(msg, "DEBUG", tag)
  end

  def critical(msg, tag = nil)
    _Log(msg, "CRITICAL", tag)
  end
  end
end