class NotificationMailer < ActionMailer::Base
  default from: "webistrano@webistrano.com"

  def deployment(deployment, email)
    hash = {
      subject:    "Deployment of #{deployment.stage.project.name}/#{deployment.stage.name} finished: #{deployment.status}",
      body:       {:deployment => deployment},
      recipients: email,
      sent_on:    Time.now,
      headers:    {}
    }
    mail(hash)
  end
end
