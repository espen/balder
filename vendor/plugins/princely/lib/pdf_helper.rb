module PdfHelper
  require 'prince'
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :princely
    end
  end
  
  def render_with_princely(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      options[:name] ||= options.delete(:pdf)
      make_and_send_pdf(options.delete(:name), options)      
    else
      render_without_princely(options, *args, &block)
    end
  end  
    
  private
  
  def make_pdf(options = {})
    options[:stylesheets] ||= []
    options[:layout] ||= false
    options[:template] ||= File.join(controller_path,action_name)
    
    prince = Prince.new()
    # Sets style sheets on PDF renderer
    prince.add_style_sheets(*options[:stylesheets].collect{|style| stylesheet_file_path(style)})
    
    html_string = render_to_string(:template => options[:template], :layout => options[:layout])
    
    # Make all paths relative, on disk paths...
    html_string.gsub!(".com:/",".com/") # strip out bad attachment_fu URLs
    html_string.gsub!( /src=["']+([^:]+?)["']/i ) { |m| "src=\"#{RAILS_ROOT}/public/" + $1 + '"' } # re-route absolute paths
    
    # Remove asset ids on images with a regex
    html_string.gsub!( /src=["'](\S+\?\d*)["']/i ) { |m| 'src="' + $1.split('?').first + '"' }
    
    # Send the generated PDF file from our html string.
    return prince.pdf_from_string(html_string)
  end

  def make_and_send_pdf(pdf_name, options = {})
    send_data(
      make_pdf(options),
      :filename => pdf_name + ".pdf",
      :type => 'application/pdf'
    ) 
  end
  
  def stylesheet_file_path(stylesheet)
    stylesheet = stylesheet.to_s.gsub(".css","")
    File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR,"#{stylesheet}.css")
  end
end
