# ActsAsPermissible
module NoamBenAri
  module Acts #:nodoc:
    module Permissible #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_permissible
          has_many :permissions, :as => :permissible, :dependent => :destroy
          
          has_many :role_memberships, :as => :roleable, :dependent => :destroy
          has_many :roles, :through => :role_memberships, :source => :role
          
          include NoamBenAri::Acts::Permissible::InstanceMethods
          extend NoamBenAri::Acts::Permissible::SingletonMethods
          
          alias_method :full_permissions_hash, :permissions_hash
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        
        # Helper method to lookup for permissions for a given object.
        # This method is equivalent to obj.permissions.
        def find_permissions_for(obj)
          permissible = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Permission.find(:all,
            :conditions => ["permissible_id = ? and permissible_type = ?", obj.id, permissible]
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        
        # returns permissions in hash form
        # from all levels recursively
        def permissions_hash
          @permissions_hash ||= lambda do
            @permissions_hash = permissions.inject({}) { |hsh,perm| hsh.merge(perm.to_hash) }.symbolize_keys!
            roles.each do |role|
              merge_permissions!(role.permissions_hash)
            end
            @permissions_hash
          end.call()
        end
        
        # accepts a permission identifier string or an array of permission identifier strings
        # and return true if the user has all of the permissions given by the parameters
        # false if not.
        def has_permission?(*perms)
          perms.all? {|perm| permissions_hash.include?(perm.to_sym) && (permissions_hash[perm.to_sym] == true) }
        end
        
        # accepts a permission identifier string or an array of permission identifier strings
        # and return true if the user has any of the permissions given by the parameters
        # false if none.
        def has_any_permission?(*perms)
          perms.any? {|perm| permissions_hash.include?(perm.to_sym) && (permissions_hash[perm.to_sym] == true) }
        end
        
        # Merges another permissible object's permissions into this permissible's permissions hash
        # In the case of identical keys, a false value wins over a true value.
        def merge_permissions!(other_permissions_hash)
          permissions_hash.merge!(other_permissions_hash) {|key,oldval,newval| oldval.nil? ? newval : oldval && newval}
        end

        # Resets permissions and then loads them.
        def reload_permissions!
          reset_permissions!
          permissions_hash
        end
        
        def roles_list
          list = []
          roles.inject(list) do |list,role|
             list << role.name
             role.roles_list.inject(list) {|list,role| list << role}
          end
          list.uniq
        end
        
        def in_role?(*role_names)
          role_names.all? {|role| roles_list.include?(role) }
        end
        
        def in_any_role?(*role_names)
          role_names.any? {|role| roles_list.include?(role) }
        end

        
        private
        # Nilifies permissions_hash instance variable.
        def reset_permissions!
          @permissions_hash = nil
        end
          
      end
    end
  end
end
