# tensaix2j

require 'open-uri'
require 'nokogiri'
require 'time'
require 'net/smtp'
require 'json'


$config = {
	"-threshold" => 4000000
}

#-------------------
def comma_numbers(number, delimiter = ',')
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
end

#----------
def send_email( smtpserver, smtpport , usetls , sender , sender_password  , receivers , subject , body , displayname)

	receiverList = receivers.to_s.split(',')
	receiverList_str = receiverList.map{ |s| "<#{s}>"}.join(',')

	puts "<send_email> Sending mail To :#{receiverList_str} #{subject}"

	begin
	        message = [ "From: #{displayname} <#{sender}>", "To: #{receiverList_str}","Date:#{ Time.now.rfc2822}", "MIME-Version: 1.0", "Content-type: text/html" , "Subject: #{subject}\n" ,  body ]
	        smtp = Net::SMTP.new( smtpserver , smtpport )
	        smtp.enable_starttls if usetls == true
	    smtp.start( 'localhost', sender , sender_password , :login ) { |s|
	        s.send_message( message.join("\n"), sender , *receiverList )
	        }

	rescue Exception => ex
	        puts "<send email error> #{ ex.to_s}"
	end

end


#-----------
def main( argv )

	$config = $config.merge( Hash[*argv] )

	url  = "http://www.singaporepools.com.sg/en/Documents/SPPL/homepagebodyen.html"
	
	rawhtml = open(url).read
	page = Nokogiri::HTML( rawhtml )   
	
	prize 		= page.css(".lottery .prize").first.text.gsub("$","").gsub(",","").to_i
	drawdate 	= Time.parse( page.css(".lottery .end-date").first.text )

	if prize >= $config["-threshold"].to_i 

		email_config = JSON.parse( open("config.json").read )
		
		send_email( 
			email_config["smtphost"] , 
			email_config["smtpport"] , 
			email_config["usetls"] , 
			email_config["username"] , 
			email_config["password"] , 
			email_config["recipients"] , 
			"TOTO ALERT: Prize of next draw is : $ #{ comma_numbers(prize) } " , 
			"Buy some tickets now!",
			email_config["displayname"]
		)

	else 
		puts "Prize $ #{ comma_numbers(prize) } is less than threshold of $ #{ comma_numbers($config["-threshold"].to_i) }"
	end

end

main ARGV





