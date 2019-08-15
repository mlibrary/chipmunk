class DepositStatusType < ActiveRecord::Type::Value
  def cast(value)
    puts "#cast(#{value} #[#{value.class}]) from #{caller[0]}"
    # if value.is_a? Chipmunk::DepositStatus
    #   value
    # else
    #   Chipmunk::DepositStatus.new(value)
    # end
    super(value.to_s)
  end

  # this is the default implementation
  # def deserialize(value_from_db)
  #   cast(value_from_db)
  # end
  def deserialize(value)
    puts "#deserialize(#{value} #[#{value.class}]) from #{caller[0]}"
    Chipmunk::DepositStatus.new(value)
  end

  # So this just doesn't get fucking called
  def serialize(deposit_status)
    puts "#serialize(#{deposit_status} #[#{deposit_status.class}]) from #{caller[0]}"
    deposit_status.to_s
  end

end
