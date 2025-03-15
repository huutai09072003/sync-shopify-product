# Picture It
interactive art preview for Shopify.

### installation

1. `bundle` (ruby 3.1.2, bundler 2.3.22)
2. `yarn` (1.22.19)
3. `rails db:setup`

### development

```sh
bin/dev
```

then, log into Dev app via:
1. Shopify Partners - log in (https://shopify.com/partners)
2. click Picture It - DEV v2
3. click "Select store" button underneath "Test your app" section
4. click "Install" on far right side of "Picture It Demo" store

once logged in you may also navigate to https://picture-it.ngrok.io in a new tab for non-embedded experience.

**credential management**

```sh
EDITOR=vim rails credentials:edit --environment=development
EDITOR=vim rails credentials:edit --environment=production
```
(use `EDITOR=nano` if you don't know vim)


change what you need, and `RAILS_MASTER_KEY` env var will decrypt the proper set in all environments.

**tests**

run all tests:
`spring rspec spec/`

(note: if test runs appear to be caching old code, try `spring stop` then re-run)

### deployment

`git push` to master branch, CI will deploy to production (picture-it-prod.herokuapp.com) after tests pass.

### Build Product CSV
rows = []
file = File.open('A1_big_variants_Landscape_picture.csv', encoding: 'UTF-8')
CSV.parse(file, headers: false) do |row|
  rows.push(row)
end
header = rows.shift
new_rows = rows.dup
50.times do |i|
  rows.each_with_index do |row, index|
    number = i.to_s.rjust(2, '0')
    new_row = row.dup
    new_row[0] = "#{new_row[0]} copy #{number}"

    if index.zero?
      new_row[1] = "#{new_row[1]} copy #{number}"
    end
    new_rows.push(new_row)
  end
end
CSV.open("#{Rails.root}/A1_big_variants_Landscape_picture_50_records.csv", "wb") do |csv|
  csv << header
  new_rows.each do |row|
    csv << row
  end
end
