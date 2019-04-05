require 'kramdown'

class SerpicoMarkdownHTML < Kramdown::Converter::Html
    def convert_p(el, indent)
      inner(el, indent).gsub(/\n/, "\r\n")
    end

    def convert_codespan(el, _indent)
      attr = el.attr.dup

      if el.value =~ /\n/
        return convert_codeblock(el, indent)
      else
        result = escape_html(el.value)
        return format_as_span_html('code', attr, result)
      end
    end

    def convert_codeblock(el, indent)
      attr = el.attr.dup

      codeblocks = ""
      el.value.split("\n").each do |block|
        result = escape_html(block)
        codeblocks += format_as_span_html('code', attr, result)
        codeblocks += "\n"
      end

      return format_as_span_html('pre', attr, codeblocks)
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
      if ((el.children and el.children.length > 0 and Kramdown::Element.category(el.children[el.children.length-1]) != :block) or
          !el.children or
          el.children.length == 0)
        res = res.gsub(/\n\n$/, "\n")
      end

      # Unescape the default escaping of headers
      if (el.children.count > 0 && el.children[0].type == :header)
        res = res.gsub(/\\\#/, "#")
      end

      # Unescape the default escaping of quotes and double quotes
      res = res.gsub(/\\\'/, "'")
      res = res.gsub(/\\\"/, "\"")
    end

    res
  end

  def convert_codeblock(el, _opts)
    "~~~\n#{el.value}~~~"
  end
end
