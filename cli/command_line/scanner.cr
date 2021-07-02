module Cloudflare::CommandLine
  module Scanner
    def self.perform(option_parser : OptionParser)
      case serialized_scanner = option_parser.scanner
      in Serialized::Scanner
        case controller = serialized_scanner.controller
        in Serialized::Scanner::Controller::BuiltIn
        in Serialized::Scanner::Controller::External
          process serialized_scanner: serialized_scanner, controller: controller
        in Serialized::Scanner::Controller
        end
      in Nil
        raise Exception.new "CommandLine::Scanner.perform: OptionParser.scanner is Nil! (Payload may not be specified)."
      end
    end

    private def self.process(serialized_scanner : Serialized::Scanner, controller : Serialized::Scanner::Controller::External)
      scanner_tuple = serialized_scanner.unwrap
      tasks, scanner = scanner_tuple

      external_controller = ExternalController.new io: controller.unwrap_server, scanner: scanner, serializedController: controller
      spawn { external_controller.perform }

      scanner.perform task_expects: tasks
    end
  end
end

require "./scanner/*"
