fortunes = [
  {quotation: 'I hear and I forget. I see and I remember. I do and I understand.', source: 'unknown'},
  {quotation: 'Everything has its beauty but not everyone sees it.', source: 'unknown'},
  {quotation: 'It does not matter how slowly you go so long as you do not stop.', source: 'chinese'},
  {quotation: 'Study the past if you would define the future.', source: 'chinese'}
]

fortunes.each do |attr|
  # puts attr[:quotation]
  Fortune.find_or_initialize_by_quotation(attr[:quotation]).tap do |t|
    t.source = attr[:source]
    t.save!
  end
end
