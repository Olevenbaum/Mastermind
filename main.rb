require "os"
require "json"
require "colorize"

BEGIN {
    install = "gem i"
    puts "checking gems..."
    puts
    print "os:".ljust(15)
    begin
        unless system "gem list -i os"
            puts "installing OS..."
            system "#{install} os"
        end
    rescue => exception
        install =  "sudo #{install}"
        unless system "gem list -i os"
            puts "installing OS..."
            system "#{install} os"
        end
    end
    print "json:".ljust(15)
    unless system "gem list -i json"
        puts "installing json..."
        system "#{install} json"
    end
    print "colorized:".ljust(15)
    unless system "gem list -i colorize"
        puts "installing colorize..."
        system "#{install} colorize"
    end
    puts
}
class Main
    def initialize
        @clear_terminal = get_os
        @configuration = JSON.load File.open "./configuration.json"
        @colors = @configuration['all_colors']
        @color_code = @configuration['color_code']
        @settings = JSON.load File.open "./settings.json"
    end
    def main
        system "#{@clear_terminal}"
        puts
        show_menu
    end
    def show_menu
        possible_input = Array(1..4)
        loop do
            system "#{@clear_terminal}"
            puts
            puts print_color "Welcome to Mastermind!", @color_code['important_color']
            puts
            puts print_color "Please insert the number of the option you want to choose:", @color_code['standard_color']
            puts
            puts print_color "#{possible_input[0].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Start new game", @color_code['option_color']
            puts print_color "#{possible_input[1].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Open settings", @color_code['option_color']
            puts print_color "#{possible_input[2].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Show documentation", @color_code['option_color']
            puts print_color "#{possible_input[-1].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Exit game", @color_code['option_color']
            puts
            case get_user_input "i", possible_input
            when possible_input[0]
                start_game
            when possible_input[1]
                open_settings
            when possible_input[2]
                show_documentation
            when possible_input[-1]
                break
            else
                break
            end
        end
        puts print_color "Thank you for playing Mastermind!",  @color_code['important_color']
        puts
    end
    def start_game
        system "#{@clear_terminal}"
        puts
        new_game = true
        last_game = JSON.load File.open "./continue_game.json"
        line = Array.new
        win = false
        lose = false
        counter = 0
        unless last_game.length == 0
            possible_input = Array(1..2)
            puts print_color "You did not finish your last game. Do you want to continue it now?", @color_code['standard_color']
            puts print_color "Enter the number of the option you want to choose:", @color_code['standard_color']
            puts
            puts print_color "#{possible_input[0].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Continue last game", @color_code['option_color']
            puts print_color "#{possible_input[-1].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Start new game", @color_code['option_color']
            case get_user_input "i", possible_input
            when possible_input[0]
                new_game = false
            when possible_input[-1]
                new_game = true
            else
                return
            end
        end
        if new_game
            line = create_random_line
            counter = 1
        else
            line = last_game['line']
            counter = last_game['counter']
        end
        loop do
            guessed_line = line_input
            show_line guessed_line, counter
            counter += 1
            if counter == @settings['number_of_attepmts']
                lose = true
            elsif guessed_line == line
                win = true
            end
            break if win or lose
        end
    end
    def show_documentation
        system "#{@clear_terminal}"
        puts
        documentation = File.read "./documentation.txt"
        puts print_color documentation, @color_code['standard_color']
        puts
        puts print_color "Please press 'Enter' to leave documentation.", @color_code['standard_color']
        get_user_input nil, nil
    end
    def open_settings
        settings = JSON.load File.open "./settings.json"
        loop do
            system "#{@clear_terminal}"
            puts
            possible_input = Array(1..(settings.length + 2))
            puts print_color "Please enter the number of the option you want to choose:", @color_code['standard_color']
            puts
            puts print_color "Settings:",  @color_code['standard_color']
            puts
            counter = 0
            settings.each {|key, value|
                puts print_color "#{possible_input[counter].to_s.ljust @configuration['preferences']['standard_length_of_options']}: #{(key.to_s.gsub "_", " ").ljust @configuration['preferences']['standard_length_of_settings']}-> #{value}", @color_code['option_color']
                counter += 1
            }
            puts
            puts print_color "#{possible_input[-2].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Reset settings", @color_code['option_color']
            puts print_color "#{possible_input[-1].to_s.ljust @configuration['preferences']['standard_length_of_options']}: Exit to menu", @color_code['option_color']
            puts
            case get_user_input "i", possible_input
            when possible_input[0]
                possilbe_number_of_colors = Array(@configuration['preferences']['minimal_number_of_elements']..@configuration['preferences']['maximal_number_of_elements'])
                puts print_color "Please enter the number of colors you want to play with:",  @color_code['standard_color']
                puts print_color "(You can choose any number between '#{possilbe_number_of_colors[0]}' and '#{possilbe_number_of_colors[-1]}'.)",  @color_code['standard_color']
                settings['number_of_elements'] = get_user_input "i", possilbe_number_of_colors
            when possible_input[1]
                puts print_color "Please enter the number of attempts you want to have to guess the colors:",  @color_code['standard_color']
                puts print_color "(Choose '0' for an endless amount of attempts.)",  @color_code['standard_color']
                changed_number_of_attempts = get_user_input "i", nil
                settings['number_of_attempts'] = changed_number_of_attempts
            when possible_input[2]
                possible_values_for_multiple_color_usage = Array[false, true]
                puts print_color "Please enter whether you want multiple usage of one color in one line allowed or not:", @color_code['standard_color']
                puts print_color "(Choose 'true' for allowing the option or 'false' to deny.)", @color_code['standard_color']
                settings['double_colors'] = get_user_input "b", possible_values_for_multiple_color_usage
            when possible_input[-2]
                settings = @configuration['standard_settings']
            when possible_input[-1]
                break
            else
                break
            end
        end
        File.write "./settings.json", JSON.dump(settings)
        update_values
    end
    def show_line p_line, p_counter

    end
    def line_input
        
    end
    def create_random_line
        line = Array.new
        @settings['number_of_elements'].times {|counter|
            double_colors = false
            loop do
                line << @colors[rand(@configuration['all_colors'].length)]
                unless @settings['double_colors']
                    index = 0
                    line.each {|color|
                        unless index == counter
                            if color == line[counter]
                                double_colors = true
                            end
                        end
                        index += 1
                    }
                    break if not double_colors
                else
                    break
                end
            end
        }
        line
    end
    def update_values
        @settings = JSON.load File.open "./settings.json"
    end
    def print_color p_text, p_color
        case p_color
        when "black"
            return p_text.black
        when "blue"
            return p_text.blue
        when "green"
            return p_text.green
        when "red"
            return p_text.red
        when "white"
            return p_text.white
        when "yellow"
            return p_text.yellow
        else
            return p_text
        end
    end
    def get_user_input p_type, p_expectations
        revision = false
        value = Array.new
        loop do
            input = gets.chomp
            if p_type == nil or input == nil or input == "exit"
                puts
                return nil
            end
            value << input
            if p_type == "string" or p_type == "str" or p_type == "s"
                value << input.to_s
            elsif p_type == "integer" or p_type == "int" or p_type == "i"
                value << input.to_i
            elsif p_type == "float" or p_type == "flo" or p_type == "f"
                value << input.to_f
            elsif p_type == "boolean" or p_type == "boo" or p_type == "b"
                if value[-1] == "true" or value[-1] == "t"
                    value << true
                elsif value[-1] == "false" or value[-1] == "f"
                    value << false
                end
            end
            unless p_expectations == nil
                p_expectations.each { |expectation|
                    if value[-1] == expectation
                        revision = true
                        break
                    end
                }
            else
                break
            end
            break if revision
            puts print_color "Please enter a valid input.", @color_code['error_color']
        end
        puts
        value[-1]
    end
    def get_os
        if OS.windows?
            clear_command = "cls"
        else
            clear_command = "clear"
        end
        clear_command
    end
end

Main.new.main
