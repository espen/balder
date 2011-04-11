#require 'acts_as_permissible/rails_commands'
class PermissibleGenerator < Rails::Generator::NamedBase
  default_options :skip_migrations => false, :skip_timestamps => false

  attr_reader :role_model_name
  attr_reader :role_model_file_name
  attr_reader :role_membership_model_name
  attr_reader :role_membership_model_file_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    unless options[:skip_roles]
      if @args.first.blank?
        puts "No Roles model name supplied! Please use --skip-roles if you do not want roles support generated."
        exit()
      end
      @role_model_name = @args.first
      @role_model_file_name = role_model_name.underscore
      @role_membership_model_name = role_model_name + "Membership"
      @role_membership_model_file_name = role_membership_model_name.underscore
    end
    
    @rspec = has_rspec?
  end

  def manifest
    recorded_session = record do |m|
      m.directory File.join('app/models', class_path)

      if @rspec
        m.directory File.join('spec/models', class_path)
        m.directory File.join('spec/fixtures', class_path)
      # else
      #   m.directory File.join('test/unit', class_path)
      end

      m.template 'model.rb',
                  File.join('app/models',
                            class_path,
                            "#{file_name}.rb")
      m.template 'acts_as_permissible.rb',
                  File.join('lib',
                            "acts_as_permissible.rb")
      # m.template 'initializer.rb',
      #                   File.join('config/initializers',
      #                             "acts_as_permissible_init.rb")
      unless options[:skip_roles]
        m.template 'role_model.rb',
                    File.join('app/models',
                              "#{role_model_file_name}.rb")
        m.template 'role_membership_model.rb',
                    File.join('app/models',
                              "#{role_membership_model_file_name}.rb")
      end

      if @rspec
        m.template 'model_spec.rb',
                    File.join('spec/models',
                                    class_path,
                                    "#{file_name}_spec.rb")
        m.template 'fixtures.yml',
                          File.join('spec/fixtures',
                                    "#{table_name}.yml")
        m.template 'acts_as_permissible_spec.rb',
                          File.join('spec/models',
                                    "acts_as_permissible_spec.rb")
        unless options[:skip_roles]
          m.template 'role_model_spec.rb',
                      File.join('spec/models',
                                "#{role_model_file_name}_spec.rb")
          m.template 'role_membership_model_spec.rb',
                      File.join('spec/models',
                                "#{role_model_file_name}_membership_spec.rb")
          m.template 'role_model_fixtures.yml',
                      File.join('spec/fixtures',
                                "#{role_model_file_name.pluralize}.yml")
          m.template 'role_membership_model_fixtures.yml',
                      File.join('spec/fixtures',
                                "#{role_membership_model_file_name.pluralize}.yml")
        end
      # else
      #   m.template 'unit_test.rb',
      #               File.join('test/unit',
      #                         class_path,
      #                         "#{file_name}_test.rb")
      #   m.template 'fixtures.yml',
      #               File.join('test/fixtures',
      #                         "#{table_name}.yml")
      end

      unless options[:skip_migrations]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_name.pluralize}"
        unless options[:skip_roles]
          m.migration_template 'role_migration.rb', 'db/migrate', :assigns => {
            :migration_name => "Create#{role_model_name.pluralize.gsub(/::/, '')}"
          }, :migration_file_name => "create_#{role_model_file_name.pluralize}"
          m.migration_template 'role_membership_migration.rb', 'db/migrate', :assigns => {
            :migration_name => "Create#{role_membership_model_name.pluralize.gsub(/::/, '')}"
          }, :migration_file_name => "create_#{role_membership_model_file_name.pluralize}"
        end
      end
    end

    action = nil
    action = $0.split("/")[1]
    case action
      when "generate" 
        puts
        puts ("-" * 70)
        puts 
        puts "acts_as_permissible"
        puts
        puts ("-" * 70)
        puts
      when "destroy" 
        puts
        puts ("-" * 70)
        puts
        puts "Thanks for using acts_as_permissible"
        puts
        puts ("-" * 70)
        puts
      else
        puts
    end

    recorded_session
  end

  def has_rspec?
    options[:rspec] || (File.exist?('spec') && File.directory?('spec'))
  end
  
  protected
    def banner
      "Usage: #{$0} permissible <PermissionsModelName> [RoleModelName]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-roles",
             "Don't generate roles support") { |v| options[:skip_roles] = v }
      opt.on("--skip-migrations", 
             "Don't generate migration files for these models") { |v| options[:skip_migrations] = v }
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--rspec",
             "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    end
end