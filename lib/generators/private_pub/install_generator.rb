class PrivatePub
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def copy_files
        template "private_pub_initializer.rb", "config/initializers/private_pub.rb"
        copy_file "private_pub_helper.rb", "app/helpers/private_pub_helper.rb"
        copy_file "private_pub.js", "public/javascripts/private_pub.js"
        copy_file "faye.ru", "faye.ru"
      end
    end
  end
end
