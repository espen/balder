Princely
========

Princely is a simple wrapper for the Prince XML PDF generation library 
(http://www.princexml.com). It is almost entirely based on the SubImage 
Prince library found on this blog post:

http://sublog.subimage.com/articles/2007/05/29/html-css-to-pdf-using-ruby-on-rails 

I have taken the helpers and made them a little bit more generalized and 
reusable, and created a render option set for pdf generation. The plugin
will also automatically register the PDF MimeType so that you can use
pdf in controller respond_to blocks.

Example
=======

class Provider::EstimatesController < Provider::BaseController
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "file_name", 
               :template => "controller/action.pdf.erb", 
               :stylesheets => ["application","prince"]
               :layout => "pdf"
      end
    end
  end
  
  def pdf
    make_and_send_pdf("file_name")
  end
end

Render Defaults
===============

The defaults for the render options are as follows:

layout:      false
template:    the template for the current controller/action
stylesheets: none

Resources
=========

Trac: http://trac.intridea.com/trac/public/

Copyright (c) 2007 Michael Bleigh and Intridea, Inc., released under the MIT license
