module Cryptoexchange::Exchanges
  module Tokenize
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Tokenize::Market::API_URL}/get-market-summaries"
        end

        def adapt_all(output)
          output['data'].map do |output|
            target, base = output['market'].split('-')
            market_pair = Cryptoexchange::Models::MarketPair.new(
              base: base,
              target: target,
              market: Tokenize::Market::NAME
              )
            adapt(market_pair, output)
          end
        end

        def adapt(market_pair, output)
          ticker = Cryptoexchange::Models::Ticker.new
          ticker.base = market_pair.base
          ticker.target = market_pair.target
          ticker.market = Tokenize::Market::NAME

          ticker.ask = NumericHelper.to_d(output['askPrice'])
          ticker.bid = NumericHelper.to_d(output['bidPrice'])
          ticker.last = NumericHelper.to_d(output['lastPrice'])
          ticker.high = NumericHelper.to_d(output['high'])
          ticker.low = NumericHelper.to_d(output['low'])
          ticker.volume = NumericHelper.divide(NumericHelper.to_d(output['volume']), ticker.last)
          
          ticker.timestamp = nil
          ticker.payload = output
          ticker
        end
      end
    end
  end
end
