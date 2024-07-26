module Api
  module V1
    class CompaniesController < ApplicationController
      def index
        n = params[:n].to_i
        filters = params[:filters] || {}

        scraper_service = YCScraperService.new(n, filters)
        companies = scraper_service.scrape_companies

        respond_to do |format|
          format.json { render json: companies }
          format.csv { send_data to_csv(companies), filename: "companies-#{Date.today}.csv" }
        end
      end

      private

      def to_csv(companies)
        CSV.generate(headers: true) do |csv|
          csv << %w[name location description batch website founders linkedin_urls]

          companies.each do |company|
            csv << [
              company[:name],
              company[:location],
              company[:description],
              company[:batch],
              company[:website],
              company[:founders].join(', '),
              company[:linkedin_urls].join(', ')
            ]
          end
        end
      end
    end
  end
end
