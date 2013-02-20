# require 'open-uri'
# require 'renderers/markdown_renderer'

# class MarkdownOffRenderer < MarkdownRenderer
#   # def link(link, title, alt_text)
#   #   if link
#   #     safelink = URI.escape(link).gsub(/%23/, '#')
#   #     "<a target=\"_blank\" href=\"#{safelink}\">#{alt_text}</a>"
#   #   else
#   #     "<a href=\"#\">#{alt_text}</a>"
#   #   end
#   # end

#   # def autolink(link, link_type)
#   #   safelink = URI.escape(link).gsub(/%23/, '#')
#   #   if link_type == :email
#   #     "<a target=\"_blank\" href=\"mailto:#{link}\">#{link}</a>"
#   #   else
#   #     "<a target=\"_blank\" href=\"#{safelink}\">#{link}</a>"
#   #   end
#   # end

#   def codespan(code)
#     nil
#   end

#   def emphasis(text)
#     nil
#   end

#   def double_emphasis(text)
#     nil
#   end

#   def triple_emphasis(text)
#     nil
#   end
  
#   def linebreak()
#     nil
#   end

#   def strikethrough(text)
#     nil
#   end

#   def superscript(text)
#     nil
#   end

#   def header(text, header_level)
#     "# #{text} <br/>"
#   end

#   def hrule()
#     nil
#   end

#   def list(contents, list_type)
    
#   end

#   def list_item(text, list_type)
#     nil
#   end

# end