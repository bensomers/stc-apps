module FormHelper
  def element(label=nil, clear=true, &block)
    if (clear)
      concat("<div class='element_clear'>", block.binding)
    else
      concat("<div class='element'>", block.binding)
    end
    # Insert a label tag if we're given one
    if (label)
      concat("<label>" + label + "</label>", block.binding)
    end
    yield
    concat("</div>", block.binding)
  end
  
  def question_item(label=nil, &block)
    concat("<div class='question'>", block.binding)
    # Insert a label tag if we're given one
    if (label)
      concat("<label>" + label + "</label>", block.binding)
    end
    yield
    concat("</div>", block.binding)
  end
  
  def question_item_for_print(label=nil, &block)
    concat("<div class='print_question'>", block.binding)
    # Insert a label tag if we're given one
    if (label)
      concat("<label>" + label + "</label>", block.binding)
    end
    yield
    concat("</div>", block.binding)
  end
  
  def parse_question(question, types)
  end
end