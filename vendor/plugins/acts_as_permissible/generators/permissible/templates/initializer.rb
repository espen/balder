require 'lib/acts_as_permissible'
ActiveRecord::Base.send(:include, NoamBenAri::Acts::Permissible)