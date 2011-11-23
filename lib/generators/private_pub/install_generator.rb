if ::Rails.version < "3.1"
  module PrivatePub
    module Generators
      class InstallGenerator < Rails::Generators::Base
        def self.source_root
          File.dirname(__FILE__) + "/templates"
        end

        def copy_files
          remove_file "config/initializers/private_pub.rb"
          remove_file "app/helpers/private_pub_helper.rb"
          template "private_pub.yml", "config/private_pub.yml"
          copy_file "../../../../vendor/assets/javascripts/private_pub.js", "public/javascripts/private_pub.js"
          copy_file "faye.ru", "faye.ru"
        end
      end
    end
  end
else
  module PrivatePub
    module Generators
      class InstallGenerator < Rails::Generators::Base
        def do_nothing
          say_status("deprecated", "You are using Rails 3.1, so this generator is no longer needed. The necessary files are already in your asset pipeline.")
          say_status("", "Just add `//= require private_pub` to your app/assets/javascripts/application.js.")
          say_status("", "If you upgraded your app from Rails 3.0 and still have private_pub.js in your javascripts, be sure to remove it.")
        end
      end
    end
  end
end
