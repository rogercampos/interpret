class InterpretAbility
  include CanCan::Ability

  def initialize(user)
    can :manage, :all
    cannot :use, :tools
    cannot :use, :interpret_in_es
  end
end
