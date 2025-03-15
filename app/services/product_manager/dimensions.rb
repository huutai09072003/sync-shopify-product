class ProductManager::Dimensions
  WIDTH_DIMENSIONS = %w[w].freeze
  HEIGHT_DIMENSIONS = %w[h l].freeze

  class << self
    def extract_dimensions(raw_data)
      raw_data = raw_data.downcase

      # "10cmx10cm"
      # "10cm x 10cm"
      # "10 cmx10 cm"
      # "10 cm x 10 cm"
      # "10x10cm"
      # "10 x 10cm"
      # "10x10 cm"
      # "10 x 10 cm"
      pattern_cm = /(\d+(\.\d+)?)(\s)?(cm)?(\s)?x(\s)?(\d+(\.\d+)?)(\s)?cm/

      # "10inx10in"
      # "10in x 10in"
      # "10 inx10 in"
      # "10 in x 10 in"
      # "10x10in"
      # "10 x 10in"
      # "10x10 in"
      # "10 x 10 in"
      pattern_in = /(\d+(\.\d+)?)(\s)?(in)?(\s)?x(\s)?(\d+(\.\d+)?)(\s)?in/

      # "10\"x10\""
      # "10\" x 10\""
      # "10 \"x10 \""
      # "10 \" x 10 \""
      # "10x10\""
      # "10 x 10\""
      # "10x10 \""
      # "10 x 10 \""
      pattern_inch_double_quotes = /(\d+(\.\d+)?)(\s)?(")?(\s)?x(\s)?(\d+(\.\d+)?)(\s)?"/

      match_data = raw_data.match(pattern_cm) || raw_data.match(pattern_in) || raw_data.match(pattern_inch_double_quotes)

      if match_data
        width = match_data[1].to_f
        height = match_data[7].to_f

        {
          width: width,
          height: height,
          dimensions_unit: raw_data.match(pattern_cm) ? 'centimetres' : 'inches'
        }
      else
        extract_dimensions_with_letters(raw_data)
      end
    end

    def extract_dimensions_with_letters(raw_data)
      raw_data = raw_data.downcase

      # "24\" W x 16\" L"
      # "24\"W x 16\" L"
      # "24\"Wx 16\" L"
      # "24\"Wx16\" L"
      # "24\"Wx16\"L"
      # "24\" L x 16\" W"
      # "24\"L x 16\" W"
      # "24\"Lx 16\" W"
      # "24\"Lx16\" W"
      # "24\"Lx16\"W"
      # "24\" H x 16\" W"
      # "24\"H x 16\" W"
      # "24\"Hx 16\" W"
      # "24\"Hx16\" W"
      # "24\"Hx16\"W"
      # "24\" W x 16\" H"
      # "24\"W x 16\" H"
      # "24\"Wx 16\" H"
      # "24\"Wx16\" H"
      # "24\"Wx16\"H"
      pattern_inch_letter_with_x = /(\d+(\.\d+)?)(")(\s)?([wlh])?(\s)?x(\s)?(\d+(\.\d+)?)(")(\s)?([wlh])?/

      # "24\" W, 16\" L"
      # "24\" L, 16\" W"
      # "24\" H, 16\" W"
      # "24\" W, 16\" H"
      # "24\" W , 16\" L"
      # "24\"W , 16\" L"
      # "24\"W, 16\" L"
      # "24\"W,16\" L"
      # "24\"W,16\"L"
      # "24\" L , 16\" W"
      # "24\"L , 16\" W"
      # "24\"L, 16\" W"
      # "24\"L,16\" W"
      # "24\"L,16\"W"
      # "24\" H , 16\" W"
      # "24\"H , 16\" W"
      # "24\"H, 16\" W"
      # "24\"H,16\" W"
      # "24\"H,16\"W"
      # "24\" W , 16\" H"
      # "24\"W , 16\" H"
      # "24\"W, 16\" H"
      # "24\"W,16\" H"
      # "24\"W,16\"H"
      pattern_inch_letter_with_comma = /(\d+(\.\d+)?)(")(\s)?([wlh])?(\s)?,(\s)?(\d+(\.\d+)?)(")(\s)?([wlh])?/

      match_data = raw_data.match(pattern_inch_letter_with_x) || raw_data.match(pattern_inch_letter_with_comma)

      if match_data
        first_dimension = match_data[5]
        second_dimension = match_data[12]

        if WIDTH_DIMENSIONS.include?(first_dimension) && HEIGHT_DIMENSIONS.include?(second_dimension)
          width = match_data[1].to_f
          height = match_data[8].to_f
        elsif WIDTH_DIMENSIONS.include?(second_dimension) && HEIGHT_DIMENSIONS.include?(first_dimension)
          width = match_data[8].to_f
          height = match_data[1].to_f
        else
          return nil
        end

        {
          width: width,
          height: height,
          dimensions_unit: 'inches'
        }
      else
        nil
      end
    end

    def extract_html_dimensions(raw_data)
      Nokogiri::HTML(raw_data).text
    end
  end
end
