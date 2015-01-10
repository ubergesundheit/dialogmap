module ApplicationHelper
  def html_title
    "#{@cms_page.try(:label)} | Wir machen mit" || 'Wir machen mit'
  end

  def in_page_title
    "#{@cms_page.try(:label)}" || '1000 Stunden für Münster'
  end

  def aktuelles_items(items, label)
    if items.none?
      content_tag(:div, class: 'aktuelles_container') do
        "Noch keine #{label} vorhanden"
      end
    else
      items.map do |c|
        content_tag(:div, class: 'aktuelles_container') do
          link_to(c.full_path) do
            content_tag(:div, class: 'aktuelles_img_container') do
              image_tag(cms_block_content(:aktuelles_img, c))
            end +
            c.label
          end
        end
      end.join.html_safe
    end
  end

  def angebot
    @contrib = Contribution.find(@cms_page.slug.split("-").last)
    render(:partial => 'page/angebot')
  end

  def angebote
    content_tag('table') do
      Contribution.angebote(5).map do |category, contributions|
        content_tag('tr') do
          content_tag('td', { colspan: 6, class: "angebot-category-header", style: "background-color: #{contributions.first.properties['category_color']}" }) do
            content_tag('div', "", { class: "maki-icon #{contributions.first.properties['activity_icon']}" }) +
            category
          end
        end +
        contributions.in_groups_of(6).map do |contribs|
          content_tag('tr') do
            contribs.map do |con|
              content_tag('td') do
                link_to("/25-angebote/#{con.title.parameterize}-#{con.id}") do
                  content_tag('div', class: 'angebot-img-container') do
                    content_tag('span', con.title, class: "angebot-label") +
                    content_tag('span', con.page_actor, class: "angebot-actor") +
                    image_tag(con.image)
                  end
                end unless con == nil
              end
            end.join.html_safe
          end
        end.join.html_safe
      end.join.html_safe
    end.html_safe
  end

  def active_menu_item_class(label)
    "active" if label == @cms_page.label or (@cms_page.parent != nil and label == @cms_page.parent.label)
  end

  def header_submenu
    unless @cms_page.parent_id != 1 or @cms_page.label == "25 Angebote"
      @cms_page.children.map do |child|
        link_to child.label, child.full_path
      end.join(' | ').html_safe
    end
  end

  def menu_items
    @cms_site.pages.map do |page|
      unless page.label == "Startseite" or page.parent_id != 1 or page.label == "Impressum"
        content_tag('li', class: active_menu_item_class(page.label)) do
          link_to page.label, page.full_path
        end
      end
    end.join.html_safe
  end
end
