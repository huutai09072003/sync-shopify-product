class GlobalWidgetContent
  @@widget_js = nil

  def get_cached_widget_js
    @@widget_js = get_widget_js if @@widget_js.blank?

    @@widget_js
  end

  def get_widget_js
    File.read("#{Rails.root}/widget/dist/widget.js").html_safe
  end
end

class LoadScript
  def self.content
    if Rails.env.development?
      GlobalWidgetContent.new.get_widget_js
    else
      GlobalWidgetContent.new.get_cached_widget_js
    end
  end
end
