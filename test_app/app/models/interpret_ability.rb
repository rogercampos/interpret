class InterpretAbility
  include CanCan::Ability

  def initialize(user)
    can :manage, :all
    cannot :use, :tools
  end
end
