##
## Custom Pundit policy class for Users
##
class UserPolicy < ApplicationPolicy
  # guard /users, the index CMS page
  # TODO relocate to some other action
  def index?
    user and user.has_role? :Administrator
  end

  ## Users can update their own account; admins can update everyone's account
  def update?
    (user and user.has_role? :Administrator) || user == :user
  end

  ## Referenced by the controller using a defined safe attribute list
  ## e.g., @user.update(safe_params)
  ## which in turns checks:
  ##  def safe_params
  ##     params.require(:user).permit(*policy(@user || User).permitted_attributes)
  ##  end
  def permitted_attributes
    allowed_attrs =  JazzHoustonConstants::USER_WHITELIST_ATTRS
   if user.has_role? :Administrator
      allowed_attrs.push(:role_ids)
    else
     allowed_attrs
    end
  end

  ## for limiting, or "scoping," result sets
  ##   scope.where(:role => :enduser), for example
  ## invoked in the controller with: policy_scope(User)
  class Scope < Struct.new(:user, :scope)
    def resolve
     if user.has_role? :Administrator
        scope.all
      end
    end
  end

end


