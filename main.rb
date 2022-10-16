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
        @settings = JSON.load File.open "./settings.json"
    end
    def main
        clear_terminal
        show_menu
    end
    def show_menu
        possible_input = Array(1..4)
        loop do
            clear_terminal
            puts print_color "Welcome to Mastermind!", @configuration['color_code']['important_color']
            puts
            puts print_color "Please insert the number of the option you want to choose:", @configuration['color_code']['standard_color']
            puts
            puts print_color "#{add_length "f", possible_input[0], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Start new game", @configuration['color_code']['option_color']
            puts print_color "#{add_length "f", possible_input[1], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Open settings", @configuration['color_code']['option_color']
            puts print_color "#{add_length "f", possible_input[2], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Show documentation", @configuration['color_code']['option_color']
            puts print_color "#{add_length "f", possible_input[-1], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Exit game", @configuration['color_code']['option_color']
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
        puts print_color "Thank you for playing Mastermind!",  @configuration['color_code']['important_color']
        puts
    end
    def start_game
        clear_terminal
        new_game = true
        last_game = (JSON.load File.open "./continue_game.json").to_a
        lines = Array.new
        win = false
        unless last_game.length == 0
            File.write "./continue_game.json", JSON.dump(Hash.new)
            possible_input = Array(1..2)
            puts print_color "You did not finish your last game. Do you want to continue it now?", @configuration['color_code']['standard_color']
            puts print_color "Enter the number of the option you want to choose:", @configuration['color_code']['standard_color']
            puts
            puts print_color "#{add_length "f", possible_input[0], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Continue last game", @configuration['color_code']['option_color']
            puts print_color "#{add_length "f", possible_input[-1], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Start new game", @configuration['color_code']['option_color']
            puts
            case get_user_input "i", possible_input
            when possible_input[0]
                new_game = false
            when possible_input[1]
                new_game = true
            else
                return
            end
        end
        if new_game
            lines << Hash['feedback' => nil, 'line' => create_random_line]
        else
            lines = last_game
        end
        output = Array.new
        clear_terminal
        output << ""
        if @settings['number_of_attempts'] == 0
            output << (print_color "#{add_length "f", "", (@configuration['preferences']['length_if_endless_attempts'] + @configuration['preferences']['standard_length'])}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        else
            output << (print_color "#{add_length "f", "", @configuration['preferences']['standard_length'] + @settings['number_of_attempts'].to_s.length}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        end
        @settings['number_of_elements'].times do |counter|
            output[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']}#{add_length "m", counter, (@configuration['preferences']['signs']['color_sign'].length + @configuration['preferences']['standard_length'])}", @configuration['color_code']['standard_color'])
        end
        output[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']}#{add_length "m", "Feedback", (@settings['number_of_elements'] * (@configuration['preferences']['signs']['feedback_sign'].length + 1))}", @configuration['color_code']['standard_color'])
        output << ""
        if @settings['number_of_attempts'] == 0
            (@configuration['preferences']['length_if_endless_attempts'] + @configuration['preferences']['signs']['horizontal_divider'].length + @configuration['preferences']['standard_length']).times do
                output[-1] += (print_color "#{@configuration['preferences']['signs']['vertical_divider']}", @configuration['color_code']['standard_color'])
            end
        else
            (@configuration['preferences']['signs']['horizontal_divider'].length + @configuration['preferences']['standard_length'] + @settings['number_of_attempts'].to_s.length).times do
                output[-1] += (print_color "#{@configuration['preferences']['signs']['vertical_divider']}", @configuration['color_code']['standard_color'])
            end
        end
        @settings['number_of_elements'].times do
            (@configuration['preferences']['signs']['color_sign'].length + @configuration['preferences']['signs']['horizontal_divider'].length + @configuration['preferences']['standard_length']).times do
                output[-1] += (print_color "#{@configuration['preferences']['signs']['vertical_divider']}", @configuration['color_code']['standard_color'])
            end
        end
        (@settings['number_of_elements'] * (@configuration['preferences']['signs']['feedback_sign'].length + 1) + @configuration['preferences']['signs']['horizontal_divider'].length + 1).times do
            output[-1] += (print_color "#{@configuration['preferences']['signs']['vertical_divider']}", @configuration['color_code']['standard_color'])
        end
        if @settings['number_of_attempts'] == 0
            output << (print_color "#{add_length "f", "", (@configuration['preferences']['length_if_endless_attempts'] + @configuration['preferences']['standard_length'])}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        else
            output << (print_color "#{add_length "f", "", (@configuration['preferences']['standard_length'] + @settings['number_of_attempts'].to_s.length)}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        end
        @settings['number_of_elements'].times do
            output[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']}#{add_length "m", "", (@configuration['preferences']['signs']['color_sign'].length + @configuration['preferences']['standard_length'])}", @configuration['color_code']['standard_color'])
        end
        output[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']} #{add_length "e", "", (@settings['number_of_elements'] * (@configuration['preferences']['signs']['feedback_sign'].length + 1))}", @configuration['color_code']['standard_color'])
        lines.each_with_index do |line, index|
            unless index == 0
                output.concat(show_line line, index)
            end
        end
        loop do
            clear_terminal
            if lines.length == @settings['number_of_attempts']
                break
            end
            puts output
            puts
            guessed_line = line_input
            if guessed_line == nil
                File.write "./continue_game.json", JSON.dump(lines)
                return
            else
                lines << Hash['feedback' => (give_feedback lines[0]['line'], guessed_line), 'line' => guessed_line]
                output.concat(show_line lines[-1], lines.length - 1)
                if lines[-1] == lines[0]
                    win = true
                    break
                end
            end
        end
       if win
        
       elsif not win
        
       end
    end
    def show_documentation
        clear_terminal
        documentation = File.read "./documentation.txt"
        puts print_color documentation, @configuration['color_code']['standard_color']
        puts
        puts print_color "Please press 'Enter' to leave documentation.", @configuration['color_code']['standard_color']
        get_user_input nil, nil
    end
    def open_settings
        settings = JSON.load File.open "./settings.json"
        loop do
            clear_terminal
            possible_input = Array(1..(settings.length + 2))
            puts print_color "Please enter the number of the option you want to choose:", @configuration['color_code']['standard_color']
            puts
            puts print_color "Settings:",  @configuration['color_code']['standard_color']
            puts
            counter = 0
            settings.each do |key, value|
                puts print_color "#{add_length "f", possible_input[counter], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: #{add_length "e", (key.to_s.gsub "_", " "), @configuration['preferences']['standard_length']}-> #{value}", @configuration['color_code']['option_color']
                counter += 1
            end
            puts
            puts print_color "#{add_length "f", possible_input[-2], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Reset settings", @configuration['color_code']['option_color']
            puts print_color "#{add_length "f", possible_input[-1], (@configuration['preferences']['standard_length'] + possible_input[-1].to_s.length)}: Exit to menu", @configuration['color_code']['option_color']
            puts
            case get_user_input "i", possible_input
            when possible_input[0]
                possible_values_for_multiple_color_usage = Array[false, true]
                puts print_color "Please enter whether you want multiple usage of one color in one line allowed or not:", @configuration['color_code']['standard_color']
                puts print_color "(Choose 'true' for allowing the option or 'false' to deny.)", @configuration['color_code']['standard_color']
                settings['double_colors'] = get_user_input "b", possible_values_for_multiple_color_usage
            when possible_input[1]
                puts print_color "Please enter the number of attempts you want to have to guess the colors:",  @configuration['color_code']['standard_color']
                puts print_color "(Choose '0' for an endless amount of attempts.)",  @configuration['color_code']['standard_color']
                changed_number_of_attempts = get_user_input "i", nil
                settings['number_of_attempts'] = changed_number_of_attempts
            when possible_input[2]
                possilbe_number_of_colors = Array(@configuration['preferences']['minimal_number_of_elements']..@configuration['preferences']['maximal_number_of_elements'])
                puts print_color "Please enter the number of colors you want to play with:",  @configuration['color_code']['standard_color']
                puts print_color "(You can choose any number between '#{possilbe_number_of_colors[0]}' and '#{possilbe_number_of_colors[-1]}'.)",  @configuration['color_code']['standard_color']
                settings['number_of_elements'] = get_user_input "i", possilbe_number_of_colors
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
        line = Array.new
        if @settings['number_of_attempts'] == 0
            line << (print_color "#{add_length "f", "#{p_counter}", (@configuration['preferences']['length_if_endless_attempts'] + @configuration['preferences']['standard_length'])}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        else
            line << (print_color "#{add_length "f", "#{p_counter}", (@configuration['preferences']['standard_length'] + @settings['number_of_attempts'].to_s.length)}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        end
        p_line['line'].each do |color|
            line[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
            line[-1] += (print_color "#{add_length "m", "#{@configuration['preferences']['signs']['color_sign']}", @configuration['preferences']['signs']['color_sign'].length + @configuration['preferences']['standard_length']}", color)
        end
        line[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']} ", @configuration['color_code']['standard_color'])
        p_line['feedback'].each do |feedback|
            if feedback == nil
                line[-1] += (print_color "  ", @configuration['color_code']['standard_color'])
            else
                if feedback
                    line[-1] += (print_color "#{@configuration['preferences']['signs']['feedback_sign']} ", @configuration['color_code']['right_position_color'])
                else
                    line[-1] += (print_color "#{@configuration['preferences']['signs']['feedback_sign']} ", @configuration['color_code']['right_color'])
                end
            end
        end
        if @settings['number_of_attempts'] == 0
            line << (print_color "#{add_length "f", "", (@configuration['preferences']['length_if_endless_attempts'] + @configuration['preferences']['standard_length'])}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        else
            line << (print_color "#{add_length "f", "", (@configuration['preferences']['standard_length'] + @settings['number_of_attempts'].to_s.length)}#{@configuration['preferences']['signs']['horizontal_divider']}", @configuration['color_code']['standard_color'])
        end
        @settings['number_of_elements'].times do
            line[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']}#{add_length "f", "", (@configuration['preferences']['signs']['color_sign'].length + @configuration['preferences']['standard_length'])}", @configuration['color_code']['standard_color'])
        end
        line[-1] += (print_color "#{@configuration['preferences']['signs']['horizontal_divider']} #{add_length "e", "", (@settings['number_of_elements'] * (@configuration['preferences']['signs']['feedback_sign'].length + 1))}", @configuration['color_code']['standard_color'])
        line
    end
    def give_feedback p_line, p_guessed_line
        feedback = Array.new
        p_guessed_line.each_with_index do |guessed_color, index|
            if guessed_color == p_line[index]
                feedback << true
            else
                temporary_feedback = nil
                p_line.each do |color|
                    if guessed_color == color
                        temporary_feedback = false
                    end
                end
                feedback << temporary_feedback
            end
        end
        feedback
    end
    def line_input
        line = Array.new
        @settings['number_of_elements'].times do |counter|
            puts print_color "Please enter the #{counter + 1}. color:", @configuration['color_code']['standard_color']
            print print_color "(You can choose from following colors: ", @configuration['color_code']['standard_color']
            (@configuration['all_colors'].length - 1).times do |index|
                print (print_color "#{@configuration['all_colors'][index]}", @configuration['all_colors'][index])
                print (print_color ", ", @configuration['color_code']['standard_color'])
            end
            print print_color "#{@configuration['all_colors'][-1]}", @configuration['all_colors'][-1]
            puts print_color ")", @configuration['color_code']['standard_color']
            line << (get_user_input "s", @configuration['all_colors'])
            if line[-1] == nil
                return nil
            end
        end
        line
    end
    def create_random_line
        line = Array.new
        @settings['number_of_elements'].times do |counter|
            new_color = ""
            loop do
                double_colors = false
                new_color = @configuration['all_colors'][rand(@configuration['all_colors'].length)]
                if @settings['double_colors']
                    break
                else
                    line.each do |color, index|
                        unless index == counter
                            if color == new_color
                                double_colors = true
                            end
                        end
                    end
                    break unless double_colors
                end
            end
            line << new_color
        end
        line
    end
    def update_values
        @settings = JSON.load File.open "./settings.json"
    end
    def print_color p_text, p_color
        case p_color
        when @configuration['all_colors'][0]
            return p_text.black
        when @configuration['all_colors'][1]
            return p_text.blue
        when @configuration['all_colors'][2]
            return p_text.green
        when @configuration['all_colors'][3]
            return p_text.red
        when @configuration['all_colors'][4]
            return p_text.white
        when @configuration['all_colors'][5]
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
            if p_expectations == nil
                break
            else
                p_expectations.each do |expectation|
                    if value[-1] == expectation
                        revision = true
                        break
                    end
                end
            end
            break if revision
            puts print_color "Please enter a valid input.", @configuration['color_code']['error_color']
        end
        puts
        value[-1]
    end
    def add_length p_placement, p_text, p_length
        text = ""
        text_length = p_text.to_s.length
        difference = 0
        if p_placement == "front" or p_placement == "f"
            difference = p_length - text_length
        elsif p_placement == "mid" or p_placement == "m"
            difference = ((p_length - text_length) / 2).to_i
        elsif p_placement == "end" or p_placement == "e"
            difference = 0
        end
        difference.times do
            text += " "
        end
        text += p_text.to_s
        text.ljust p_length
    end
    def clear_terminal
        system "#{@clear_terminal}"
        puts
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
