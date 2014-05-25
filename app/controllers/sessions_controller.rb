class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => :version
  def new
    render layout: false
  end

  def create
    username = params[:login]
    password = params[:password]

    ccfile = File.join(Dir.tmpdir, "KAKAOLOGIN.#{Time.now.to_i}")

    inputmethod = ""
    if (/darwin/ =~ RUBY_PLATFORM) != nil
      inputmethod = "--password-file=STDIN"
    end

    kinit_cmd = "kinit -c #{ccfile} #{inputmethod} #{username}"
    status = POpen4::popen4(kinit_cmd) do |stdout, stderr, stdin, pid|
      stdin.puts password
    end
    if status.exitstatus != 0
      flash[:error] = "Login/password wrong (Please use kerberos password)"
      logger.error "KERBEROS FAIL: #{status.exitstatus} #{kinit_cmd}"
      render action: 'new', layout: false
      return
    end

    `kdestory -c #{ccfile}`

    current_user = User.authenticate(params[:login], params[:password])
    unless current_user
      current_user = User.find_by_login params[:login]

      unless current_user
        current_user = User.new
        current_user.login = params[:login]
        current_user.email ="#{params[:login]}@kakao.com"
      end

      current_user.password = params[:password]
      current_user.password_confirmation = params[:password]
      current_user.save
    end

    self.current_user = current_user
    data = {username: username, password: password}.to_json
    session[:kerberos] = Base64.encode64(SessionsHelper::encrypt(data))
    self.current_user = current_user

    if logged_in?
      puts "remember_me #{params[:remember_me]}"
      if params[:remember_me] == '1'
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      redirect_back_or_default( root_path )
      flash[:notice] = 'Logged in successfully'

    else
      flash[:error] = 'Login/password wrong (Please use kerberos password)'
      render action: 'new', layout: false
    end
  end

  def destroy
    logout
  end
end
