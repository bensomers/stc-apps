class PayformConfiguration < ActiveRecord::Base
  belongs_to :department
  belongs_to :payform_permission,
             :class_name => 'Permission', :dependent => :destroy
  belongs_to :payform_admin_permission,
             :class_name => 'Permission', :dependent => :destroy
             
             
  validates_presence_of :department_id
  validates_numericality_of :description_min, :reason_min, :weeks

  alias_attribute :permission, :payform_permission 
  alias_attribute :admin_permission, :payform_admin_permission 


  def self.permission_name
    'payform'
  end
  
  def self.admin_permission_name
    'payform_admin'
  end
  
  def self.default
    new(:printed            => "This payform has already been printed and may no longer be edited by you.\n" +
                                "If there is a problem that needs to be addressed, please talk to the administration.",
        :reminder           => "Please remember to submit your payform for the week.",
        :warning            => "You have not submitted payforms for the weeks ending on the following dates:\n" +
                                "\n@weeklist@\n" +
                                "Please submit your payforms. If some of the weeks listed are weeks during which you did not work, please just submit a blank payform.",
        :weeks              => 4,
        :description_min    => 4,
        :show_disabled_cats => true,
        :reason_min         => 4,
        :clock              => false)
  end

end
