# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def breadcrumbs(sep = "/", include_home = true)
     levels = request.path.split('?')[0].split('/')
     levels.delete_at(0)

     #links = "You are here: "
     links  = content_tag('a', "HOME", :href => root_path ) if include_home
     
     nocrumb = ["collections", "albums", "photos", "tags", "new", "edit", "tags"]

     levels.each_with_index do |level, index|
       level = level.gsub(/^[0-9]+\-/,"") #if levels[index-1] == "photos"
       level = level.gsub("-", " ")
       if index+1 == levels.length
         #links += " #{sep} #{level.upcase}" unless nocrumb.include?(level)
       elsif !nocrumb.include?(level)
         links += " " + sep + " "
         links += content_tag('a', level.upcase, :href => '/'+levels[0..index].join('/'))
       end
     end

     content_tag("div", links, :id => "breadcrumb")
   end  
end
