#
# Behold: I stand on the shoulders of giants...rossmeissl@github.com 
# is the _(wo?)man_
#
require 'bombshell'
require 'logger'

module RubyRobot
class Shell < ::Bombshell::Environment
  include ::Bombshell::Shell

  prompt_with 'ILoveNetflixStudio'

  attr_reader :logger

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc { |severity, datetime, progname, msg|
      "#{msg}\n"
    }
  end

  #
  # Place a robot
  #
  def PLACE(x, y, direction)
    # Save state in case place is called w/ invalid coords
    orig_robot = @robot
    orig_tabletop = @tabletop
    # TODO: What happens when place is called > 1x per session?
    # Answer under time crunch: just replace the Robot and Tabletop
    @robot = Robot.new(direction)
    @tabletop = NetflixTabletop.new
    begin
      @tabletop.place(@robot, x: x, y: y)
      true
    rescue
      @robot = orig_robot
      @tabletop = orig_tabletop
      @logger.info $!
      false
    end
  end

  def MOVE
    return if @robot.nil?
    @robot.move
  end

  def LEFT
    return if @robot.nil?
    @robot.left
  end

  def RIGHT
    return if @robot.nil?
    @robot.right
  end

  def REPORT(to_stderr=true)
    return nil if @robot.nil?
    @logger.info(@robot.report) if to_stderr
    @robot.report
  end

  # Exit Bombshell
  alias :QUIT   :quit
end
end

#
# Monkeypatch Irb to allow no-arg uppercase methods
#
module IRB
class Irb
    # Evaluates input for this session.
    def eval_input
      @scanner.set_prompt do
        |ltype, indent, continue, line_no|
        if ltype
          f = @context.prompt_s
        elsif continue
          f = @context.prompt_c
        elsif indent > 0
          f = @context.prompt_n
        else
          f = @context.prompt_i
        end
        f = "" unless f
        if @context.prompting?
          @context.io.prompt = p = prompt(f, ltype, indent, line_no)
        else
          @context.io.prompt = p = ""
        end
        if @context.auto_indent_mode
          unless ltype
            ind = prompt(@context.prompt_i, ltype, indent, line_no)[/.*\z/].size +
              indent * 2 - p.size
            ind += 2 if continue
            @context.io.prompt = p + " " * ind if ind > 0
          end
        end
      end

      @scanner.set_input(@context.io) do
        signal_status(:IN_INPUT) do
          if l = @context.io.gets
            #
            # Begin monkeypatch: turn uppercase constants into
            # method calls
            #
            if [:MOVE,:LEFT,:RIGHT,:REPORT,:REMOVE,:QUIT].include?(l.strip.to_sym)
              l = "#{l.strip}()\n"
            end
            #
            # End monkeypatch
            #
            print l if @context.verbose?
          else
            if @context.ignore_eof? and @context.io.readable_after_eof?
              l = "\n"
              if @context.verbose?
                printf "Use \"exit\" to leave %s\n", @context.ap_name
              end
            else
              print "\n"
            end
          end
          l
        end
      end

      @scanner.each_top_level_statement do |line, line_no|
        signal_status(:IN_EVAL) do
          begin
            line.untaint
            @context.evaluate(line, line_no)
            output_value if @context.echo?
            exc = nil
          rescue Interrupt => exc
          rescue SystemExit, SignalException
            raise
          rescue Exception => exc
          end
          if exc
            print exc.class, ": ", exc, "\n"
            if exc.backtrace && exc.backtrace[0] =~ /irb(2)?(\/.*|-.*|\.rb)?:/ && exc.class.to_s !~ /^IRB/ &&
                !(SyntaxError === exc)
              irb_bug = true
            else
              irb_bug = false
            end

            messages = []
            lasts = []
            levels = 0
            if exc.backtrace
              for m in exc.backtrace
                m = @context.workspace.filter_backtrace(m) unless irb_bug
                if m
                  if messages.size < @context.back_trace_limit
                    messages.push "\tfrom "+m
                  else
                    lasts.push "\tfrom "+m
                    if lasts.size > @context.back_trace_limit
                      lasts.shift
                      levels += 1
                    end
                  end
                end
              end
            end
            print messages.join("\n"), "\n"
            unless lasts.empty?
              printf "... %d levels...\n", levels if levels > 0
              print lasts.join("\n"), "\n"
            end
            print "Maybe IRB bug!\n" if irb_bug
          end
          if $SAFE > 2
            abort "Error: irb does not work for $SAFE level higher than 2"
          end
        end
      end
    end
end
end

#
# Map these constants to symbols so the shell
# will pass them through
#
module Bombshell
module Shell
  NORTH=:north
  SOUTH=:south
  EAST=:east
  WEST=:west
end
end
# Tell shell not to show lower-case 'quit' method; it is aliased
# to #QUIT along w/ all the other upper-case methods.
::Bombshell::Shell::Commands::HIDE << :quit
