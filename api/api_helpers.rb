module ApiHelpers
    def warwick_auth
      env['warwick_auth']
    end

    def current_user
      warwick_auth.user
    end

    # returns 401 if there's no current user
    def authenticate_user!
      error!('401 Unauthorized', 401) unless current_user
    end
end
