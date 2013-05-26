json.array!(@fortunes) do |fortune|
  json.extract! fortune, :quotation, :source
  json.url fortune_url(fortune, format: :json)
end