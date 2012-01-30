require 'thread'
require 'highline'

module Hammertime
  def self.ignored_errors
    @ignored_errors ||= [LoadError]
  end

  def self.ignored_lines
    @ignored_lines ||= []
  end

  def self.stopped
    @stopped ||= false
  end

  def self.stopped=(value)
    @stopped = value
  end

  def self.debug_supported?
    require 'ruby-debug'
    @debug_support = true
  rescue LoadError
    warn "Unable to load ruby-debug"
    warn "Gem not installed or debugging not supported on your platform"
    @debug_support = false
  end

  def hammertime_raise(*args)
    backtrace = caller(2)
    fallback = lambda do
      hammertime_original_raise(*args)
    end
    exclusive_and_non_reentrant(fallback) do
      error, backtrace =
        case args.size
        when 0 then [($!.nil? ? RuntimeError.new : $!), backtrace]
        when 1 then
          if args[0].is_a?(String)
            [RuntimeError.exception(args[0]), backtrace]
          else
            [args[0].exception, backtrace]
          end
        when 2 then
          [args[0].exception(args[1]), backtrace]
        when 3 then
          [args[0].exception(args[1]), args[2]]
        else
          super(ArgumentError, "wrong number of arguments", backtrace)
        end
      error.set_backtrace(backtrace)

      if hammertime_ignore_error?(error, backtrace)
        hammertime_original_raise(error)
      else
        ::Hammertime.stopped = true
      end

      c = ::Hammertime.hammertime_console
      c.say "\n"
      c.say "=== Stop! Hammertime. ==="
      c.say "An error has occurred at #{backtrace.first}"
      c.say "The error is: #{error.inspect}"
      menu_config = lambda do |menu|
        menu.prompt    = "What now?"
        menu.default   = "Continue"
        menu.select_by = :index_or_name

        menu.choice "Continue (process the exception normally)" do
          hammertime_original_raise(error)
          true
        end
        menu.choice "Ignore (proceed without raising an exception)" do
          true
        end
        menu.choice "Permit by type (don't ask about future errors of this type)" do
          ::Hammertime.ignored_errors << error.class
          c.say "Added #{error.class} to permitted error types"
          hammertime_original_raise(error)
          true
        end
        menu.choice "Permit by line (don't ask about future errors raised from this point)" do
          ::Hammertime.ignored_lines << backtrace.first
          c.say "Added #{backtrace.first} to permitted error lines"
          hammertime_original_raise(error)
          true
        end
        menu.choice "Backtrace (show the call stack leading up to the error)" do
          backtrace.each do |frame| c.say frame end
          false
        end
        if Hammertime.debug_supported?
          menu.choice "Debug (start a debugger)" do
            debugger
            false
          end
        end
        menu.choice "Console (start an IRB session)" do
          require 'irb'
          IRB.start
          false
        end
      end
      continue = c.choose(&menu_config) until continue
    end
  ensure
    ::Hammertime.stopped = false
  end

  def hammertime_original_raise(*args)
    Kernel.instance_method(:raise).bind(self).call(*args)
  end

  def fail(*args)
    hammertime_raise(*args)
  end

  def raise(*args)
    hammertime_raise(*args)
  end

  private

  # No lazy initialization where threads are concerned. We still use
  # ||= on the off chance that this file gets loaded twice in 1.8.
  @mutex ||= Mutex.new

  def self.mutex
    @mutex
  end

  def self.hammertime_console
    @console ||= HighLine.new($stdin, $stderr)
  end

  def hammertime_ignore_error?(error, backtrace)
    return true if ::Hammertime.stopped
    return true if ::Hammertime.ignored_errors.any?{|e| error.is_a?(e)}
    return true if ::Hammertime.ignored_lines.include?(backtrace.first)
    return false
  end

  def exclusive_and_non_reentrant(fallback, &block)
    lock_acquired = ::Hammertime.mutex.try_lock
    if lock_acquired
      yield
      ::Hammertime.mutex.unlock
    else
      fallback.call
    end
  end

end

unless ::Object < Hammertime
  class ::Object
    include ::Hammertime
  end
  Debugger.start if $hammertime_debug_support
end
