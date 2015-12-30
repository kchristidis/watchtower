module ApplicationHelper
  def link_back(default = :root)
    link_to (request.env['HTTP_REFERER'] ? :back : default), class: 'btn btn-default' do
      yield
    end
  end

  def flash_class(key)
    case key
    when 'error'
      'danger'
    else
      key
    end
  end

  def legend text
    "<legend class='col-md-12'>#{text}</legend>".html_safe
  end
end
