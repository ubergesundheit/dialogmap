module ApplicationHelper
  def html_title
    "#{@cms_page.try(:label)} | Wir machen mit" || 'Wir machen mit'
  end

  def active_menu_item_class(label)
    "active" if label == @cms_page.label
  end

  def menu_items
    @cms_site.pages.map do |page|
      content_tag('li', class: active_menu_item_class(page.label)) do
        link_to page.label, page.full_path
      end
    end.join.html_safe
  end
end
