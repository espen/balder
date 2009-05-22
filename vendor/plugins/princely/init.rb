require 'prince'
require 'pdf_helper'

Mime::Type.register 'application/pdf', :pdf

ActionController::Base.send(:include, PdfHelper)