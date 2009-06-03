

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Returns a valid user model based on whether the user exists
  # in the database
#  def get_user
#    if session[:user]
#      if session[:user_exists]
#        return User.find_by_login(session[:casfilteruseruser])
#      else
#        return User.new(:login => session[:casfilteruseruser])
#      end
#    end
#  end

  def notice_script(div = 'notice', notice=flash[:notice], message="Message:", timeout=0)
    #I know these are redundant, but I was having issues passing flash values:
    div = 'notice' if div.nil?
    notice = flash[:notice] if notice.nil?
    message = "Message:" if message.nil?
    timeout = 0 if timeout.nil?
    javascript_tag "$('#{div}').hide();#{notice_popup(notice, message)};" + (timeout > 0 ? "setTimeout('hide_box()', #{timeout});" : "")
  end

  def has_any_admin_item?(items, user)
    for item in items
        return true if (user.permission_strings.include?(item))
    end
    return false
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def section(&block)
    concat("<div class='section'>", block.binding)
    yield
    concat("</div>", block.binding)
  end

  def toggled_section(label=nil, display=false, size="h2", &block)
    concat("<div class='section'>", block.binding)

    # Generate display settings
    display_style = "style='display: none;'" unless display

    # Setup our arrow image
    arrow_label = "<img src='images/" + (display ? "down_arrow" : "right_arrow") + ".gif' width='9' height='11' id='arrow_#{label}' border='0' />" +
                  label

    # Setup our show/hide link and label
    link = link_to_function arrow_label, nil do |page|
             page.call "toggle_arrow", "#{label}"
             page.visual_effect :toggle_appear, label, :duration => 0.5
           end
    concat("<#{size}>" + link + "</#{size}>", block.binding)

    # Generate the label id
    concat("<div id=\"#{label}\" class='toggled' #{display_style}>", block.binding)

    yield

    concat("</div></div>", block.binding)
  end

  def print_section(label=nil, size="h2", &block)
    concat("<div class='section'>", block.binding)
    concat("<#{size}>#{label}</#{size}>", block.binding)
    yield
    concat("</div>", block.binding)
  end

  #Add this to allow us to use nested layout, see layouts/shift.html.erb on how to use it -H
  def inside_layout(layout, &block)
    @template.instance_variable_set("@content_for_layout", capture(&block))

    layout = layout.include?("/") ? layout : "layouts/#{layout}" if layout
    buffer = eval("_erbout", block.binding)
    buffer.concat(@template.render_file(layout, true))
  end

  #This is to slip layout specific stylesheets or javascript without cluttering up the base layout at application.html.erb
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  #Link to controller if there's permission -H
  def link_if_authorized(name, options = {})
    @user ||= get_user
    #capitalize first letter of word, convert underscore to space
    link_name = name.split('_').each { |word| word.capitalize! }.join(' ')
    options[:controller] = '/' + name
    link_to(link_name, options) if @user.authorized? name
  end


  def select_integer (object, column, start, stop, default = nil)
    output = "<select id=\"#{object}_#{column}\" name=\"#{object}[#{column}]\">"
    for i in start..stop
      output << "\n<option value=\"#{i}\""
      output << " selected=\"selected\"" if i == default
      output << ">#{i}"
    end
    output + "</select>"
  end

  #used in user select auto complete
  def get_ids(user_list)
    (user_list||[]).collect(&:id).join(',')
  end

  def make_popup(hash)
    hash[:width] ||= 600
    "Modalbox.show(this.href, {title: '#{hash[:title]}', width: #{hash[:width]}}); return false;"
  end

  def notice_popup(notice = flash[:notice], message = "Message:")
    'Modalbox.show("<div>' + notice.h + "</div>\", {title: \"#{message}\", transitions: false})"
  end

  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
 end

 def hide_flash(name)
   javascript_tag do
        "document.observe(\"dom:loaded\", function() {
          setTimeout(hideFlash#{name}, 5000);
        });

        function hideFlash#{name}() {
          $$('div##{name}').each(function(e) {
            if (e) Effect.Fade(e, { duration: 4.0 });
          });
        }"
    end
 end

 def no_notice_keys #these are the flash[key] exceptions. Put a name here, and it will not auto-display!
   ['message', 'timeout', 'no_hide']
 end

 def flash_script(key)
   unless key == 'big_notice'
     hide_flash(key) unless flash[:no_hide]
   else
     notice_script 'big_notice', flash[:big_notice], flash[:message], flash[:timeout]
   end
 end

end
