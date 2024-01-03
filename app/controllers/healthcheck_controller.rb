class HealthcheckController < ApplicationController
    def index
        render status: 200, json: { status: 'ok' }
    end
end
