class RegMailer < ActionMailer::Base
  default :from => "Reginald Netsky <donotreply@bookrenter.com>", :charset => 'utf8'
  
  def deploy_notification(options={})
    @options = options
    mail(:to => "siteops@bookrenter.com",
         :subject => "Deploy Notification"
    )
  end
end
