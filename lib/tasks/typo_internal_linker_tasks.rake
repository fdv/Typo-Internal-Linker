# desc "Explaining what the task does"
# task :typo_internal_linker do
#   # Task goes here
# end
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'rubygems'

require "#{RAILS_ROOT}/config/boot"
require "#{RAILS_ROOT}/config/environment"

def connect(environment)
  conf = YAML::load(File.open(File.dirname(__FILE__) + '/../../config/database.yml'))
  ActiveRecord::Base.establish_connection(conf[environment])
end

desc "Create needed table"
task :typo_internal_linker_create_table => :environment do
  ActiveRecord::Base.transaction do
    ActiveRecord::Migration::create_table :link_articles_tags do |t|
      t.column :article, :integer
      t.column :tag, :integer
      t.column :tag_count, :integer
    end
  end
end

desc "Populates table"
task :typo_internal_linker_populate_table => :environment do
  articles = Article.find(:all)
  
  articles.each do |article|
    next if article.tags.empty?
    article.tags.each do |tag|
      
      test = LinkArticlesTags.find(:all, :conditions => ['tag = ?', tag.id])
      next unless test.empty?
      
      dummyarticles = Article.find(:all, :conditions => ['state = "published" AND (LOWER(body) LIKE ? OR LOWER(extended) LIKE ? OR LOWER(title) LIKE ?)', "%#{tag.display_name}%", "%#{tag.display_name}%", "%#{tag.display_name}%"])
      dummyarticles.each do |dm|
        i = 0
        i += dm.title.downcase.scan(tag.display_name.downcase).length 
        i += dm.body.strip_html.downcase.scan(tag.display_name.downcase).length unless dm.body.empty?
        i += dm.extended.strip_html.downcase.scan(tag.display_name.downcase).length unless dm.extended.empty?
        if i > 0
          lat = LinkArticlesTags.new
          lat.article = dm.id
          lat.tag = tag.id
          lat.tag_count = i
          lat.save
          puts "Article #{dm.id} a #{i} occurrences du tag #{tag.name}"
        end
        
      end
    end
    
  end
  
end