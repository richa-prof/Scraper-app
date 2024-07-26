require 'nokogiri'
require 'httparty'

class Api::V1::YcScraperService
  BASE_URL = 'https://www.ycombinator.com/companies'

  def initialize(n, filters)
    @n = n
    @filters = filters
  end

  def scrape_companies
    companies = []
    page = 1
    while companies.size < @n
      response = HTTParty.get("#{BASE_URL}?page=#{page}")
      parsed_page = Nokogiri::HTML(response.body)
      parsed_page.css('.company-card').each do |company_card|
        break if companies.size >= @n

        company = {
          name: company_card.css('.company-name').text,
          location: company_card.css('.company-location').text,
          description: company_card.css('.company-description').text,
          batch: company_card.css('.company-batch').text
        }

        # Fetch detailed info from the company page
        company_url = company_card.css('a').attr('href').value
        fetch_detailed_info(company_url, company)

        companies << company
      end

      page += 1
    end

    companies
  end

  private

  def fetch_detailed_info(url, company)
    response = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(response.body)

    company[:website] = parsed_page.css('.website').text
    company[:founders] = parsed_page.css('.founder-name').map(&:text)
    company[:linkedin_urls] = parsed_page.css('.founder-linkedin a').map { |link| link['href'] }
  end
end
