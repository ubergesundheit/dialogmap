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
    titles_shown = []
    content_tag('table') do
      Contribution.angebote(5).in_groups_of(6).map do |contribs|
        content_tag('tr') do
          contribs.map do |con|
            content_tag('td') do
              link_to("/25-angebote/#{con.title.parameterize}-#{con.id}") do
                content_tag('div', class: 'angebot-img-container') do
                  category_title = ""
                  unless titles_shown.include? con.properties['category']
                    titles_shown << con.properties['category']
                    category_title = con.properties['category']
                  end
                  content_tag('span', category_title, title: con.properties['category'], class: "angebot-category-header", style: "background-color: #{con.properties['category_color']}") +
                  content_tag('span', con.title, class: "angebot-label", style: "background-color: #{con.properties['category_color']}") +
                  content_tag('span', con.page_actor, class: "angebot-actor", style: "background-color: #{con.properties['category_color']}") +
                  image_tag(con.image)
                end
              end unless con == nil
            end
          end.join.html_safe
        end
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
