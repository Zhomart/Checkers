module Zhomart
  module Router
    extend ActiveSupport::Concern

    module ClassMethods
      def route(route, method_name)
        @routes ||= {}
        @routes[route] = method_name
      end

      def routes; @routes || {}; end
    end
  end
end
