FactoryBot.define do
  factory :event do
    object_class { 'Product' }
    event_type { 'preview' }
  end

  trait :preview do
    event_type { 'preview' }
  end

  trait :download do
    event_type { 'download' }
  end

  trait :upload do
    event_type { 'upload' }
  end
end
