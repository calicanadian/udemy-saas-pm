class Tenant < ApplicationRecord
  acts_as_universal_and_determines_tenant
  has_many :members, dependent: :destroy
  has_many :projects, dependent: :destroy
  validates_uniqueness_of :title
  validates_uniqueness_of :name
  validates_presence_of :name
  validate :free_plan_can_only_have_one_project

  def self.create_new_tenant(tenant_params, user_params, coupon_params)

    tenant = Tenant.new(tenant_params)

    if new_signups_not_permitted?(coupon_params)

      raise ::Milia::Control::MaxTenantExceeded, "Sorry, new accounts not permitted at this time"

    else
      tenant.save    # create the tenant
    end
    return tenant
  end

  def free_plan_can_only_have_one_project
    if self.new_record? && (tenants.projects.count > 0) && (tenant.plan == 'free')
      errors.add(:base, "Free plans cannot have more than one project")
    end
  end

  def self.by_plan_and_tenant(tenant_id)
    tenant = Tenant.find(tenant_id)
    if tenant.plan == 'premium'
      tenant.projects
    else
      tenant.projects.order(:id).limit(1)
    end
  end

  def can_create_projects?
    (plan == 'free' && projects.count < 1) || (plan == 'premium')
  end

  # ------------------------------------------------------------------------
  # new_signups_not_permitted? -- returns true if no further signups allowed
  # args: params from user input; might contain a special 'coupon' code
  #       used to determine whether or not to allow another signup
  # ------------------------------------------------------------------------
  def self.new_signups_not_permitted?(params)
    return false
  end

  # ------------------------------------------------------------------------
  # tenant_signup -- setup a new tenant in the system
  # CALLBACK from devise RegistrationsController (milia override)
  # AFTER user creation and current_tenant established
  # args:
  #   user  -- new user  obj
  #   tenant -- new tenant obj
  #   other  -- any other parameter string from initial request
  # ------------------------------------------------------------------------
  def self.tenant_signup(user, tenant, other = nil)
    #  StartupJob.queue_startup( tenant, user, other )
    # any special seeding required for a new organizational tenant
    #
    Member.create_org_admin(user)
    #
  end

end
