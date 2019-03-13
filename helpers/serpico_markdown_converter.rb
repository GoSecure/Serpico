require 'kramdown'

class SerpicoMarkdownHTML < Kramdown::Converter::Html
    def convert_p(el, indent)
      inner(el, indent).gsub(/\n/, "\r\n")
    end

    def convert_blank(_el, _indent)
      "\r\n\r\n"
    end
end

class SerpicoHTMLKramdown < Kramdown::Converter::Kramdown
  def convert(el, opts = {indent: 0})
    res = super

    # Change the default linebreak behavior to fit the XSLT format Serpico is expecting
    if (el.type == :p)
      if (el.children and el.children.length > 0)
        if (Kramdown::Element.category(el.children[el.children.length-1]) != :block)
          res = res.gsub(/\n\n$/, "\n")
        end
      end

      if (el.children.count > 0 && el.children[0].type == :header)
        res = res.gsub(/\\\#/, "#")
      end
    end

    res
  end
end
