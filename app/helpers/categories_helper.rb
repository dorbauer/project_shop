module CategoriesHelper  
  BREADCRUMBS_SPACER = "&nbsp;&gt; "
  BREADCRUMBS_NL = "<br />"
  
  def show_breadcrumbs(category, append_title = nil, options = {})
    options[:spacer] ||= BREADCRUMBS_SPACER
    options[:nl] ||= BREADCRUMBS_NL
    
    crumbs = category.get_breadcrumbs

    crumbs.map do |line|
      line << append_title if append_title
      line.map do |cat|
        if cat != line.last
          link_to h(cat), cat
        else
          content_tag :span, h(cat), :class=> "crumb_current"
        end
      end.join(options[:spacer])
    end.join(options[:nl])
  end
    
  CATEGORY_INDENT = '- '

=begin
  /* 
   * call-seq:
   *    selected_categories_tag(name, selected = nil, toplevel = nil) { |category| block }  => html_string
   * 
   * Generates a select tag for all categories from <i>toplevel</i> and beneath (all of them if not specified). Takes a <i>selected</i> parameter as select_tag does; the optional <i>block</i> can be used to check if an option-tag should be enabled (false => disabled).
   */
=end
  def select_categories_tag(name, selected = nil, toplevel = nil, options = {}, &block)
    if toplevel.kind_of? Category
      cats = toplevel.sub_categories
    else
      cats = Category.find_toplevel_categories
    end
    
    return I18n.t("NoCategoriesFound") if cats.empty?
    
    selected ||= {}
    selected = { :selected => selected } if selected.is_a? Hash
    selected[:selected] = params[name]   if params[name]
    
    # Easier, but can't indent the title to show sub-categories:
    # select_tag name, options_from_collection_for_select(cats, :id, :title, selected)
    
    categories = category_options(cats)
    
    selected[:disabled] = disabled_options(categories.collect { |c| c[1] }, &block) if block_given?
    
    select_tag name, options_for_select(categories, selected), options
  end
  
  private
  
=begin
  Returns <i>nil</i> if no category is disabled, array of disabled ids otherwise.
=end
  def disabled_options(categories, &block)
    categories.inject([]) do |disabled, c|
      if yield(c)
        disabled
      else
        disabled << c.id
      end
    end
  end
   
  def category_options(cats, indent = "", &block)
    return [] if cats.empty?
#puts "ja" + indent
    
    options = []
    cats.each do |c|
#puts "#{c.inspect}"
      options << category_option(c, indent)
      options += category_options(c.sub_categories, indent + CATEGORY_INDENT)
    end
    options
  end

  def category_option(cat, indent)
#    return nil if cat.title.nil?
    [indent + cat.title, cat, cat.id]
  end

  def CategoriesHelper.find_products(category)

    categoriesId = Array.new
    categoriesId.push(category.id)

    find_sub_products(category, categoriesId)

    products = Product.find(:all, :conditions => ["category_id IN (?)", categoriesId])

    return products
      
  end

  def CategoriesHelper.find_sub_products (dbCategory, categoriesId)

    if (!dbCategory.sub_categories.blank?)

          dbCategory.sub_categories.each do |dbSubCategory|

              categoriesId.push(dbSubCategory.id)

              find_sub_products(dbSubCategory, categoriesId)
          end
      end

  end
  
end
