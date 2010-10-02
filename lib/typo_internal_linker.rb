# TypoInternalLinker
module TypoInternalLinker
  
end

module TypoInternalLinkerHelper
  def show_seo_tags(article)
    tags = []
    
    article.tags.each do |tag|
      link = LinkArticlesTags.find(:first, :conditions => "tag = #{tag.id}  and article != #{article.id}", :order => 'tag_count DESC')
      if link
        art = Article.find(link.article)
        tags << link_to_permalink(art, tag.display_name)
      end
    end
    
    return _("Tags") + ' ' +  tags.map do |tag| tag end.sort.join(', ')
    
  end
end
