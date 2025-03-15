class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # https://cdn.pictureit.co.s3.us-east-2.amazonaws.com/gr1vmhphob9i7a2vo85rfqoezbee?response-content-disposition=inline%3B%20filename%3D%22mona-lisa%22%3B%20filename%2A%3DUTF-8%27%27mona-lisa&response-content-type=image%2Fpng&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA4DZBPD5SGOXCTUPJ%2F20191114%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20191114T082157Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=07a21de04e99cf2a197bafde066ba657973364b23911edeacf23ad8c33e26880
  # s3 urls can be written two ways - we want to use our cdn CNAME to cache on cloudflare
  def friendly_url(image)
    url = image.service_url.to_s.split('?')[0]
    return url unless ENV.fetch("IS_USING_CDN") { true }.to_b
    url.sub!('.s3.us-east-2.amazonaws.com', '') # https://cdn.pictureit.co.s3.us-east-2.amazonaws.com/gr1vmhphob9i7a2vo85rfqoezbee
    url.sub!('s3.us-east-2.amazonaws.com/', '') # https://s3.us-east-2.amazonaws.com/cdn.pictureit.co/gr1vmhphob9i7a2vo85rfqoezbee
  end
end
