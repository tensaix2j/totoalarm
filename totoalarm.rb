# tensaix2j

require 'open-uri'
require 'nokogiri'
require 'time'
require 'net/smtp'
require 'json'


$config = {
	"-threshold" => 4000000,
	"-sendEmail" => 1
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

	url  = "http://www.singaporepools.com.sg/DataFileArchive/Lottery/Output/toto_next_draw_estimate_en.html"

	rawhtml = open(url).read
	page = Nokogiri::HTML( rawhtml )   
	
	email_config = JSON.parse( open("config.json").read )
			
	begin 
		
		prize 		= page.css("span")[0].text.gsub(" est","").gsub(/[$,]/,"").to_i

		drawdate 	= Time.parse( page.css(".toto-draw-date")[0].text )

		if prize >= $config["-threshold"].to_i 

			puts "Ready to send.."
			

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
			) if $config["-sendEmail"] == 1

		else 
			puts "Prize $ #{ comma_numbers(prize) } is less than threshold of $ #{ comma_numbers($config["-threshold"].to_i) }"
		end

	rescue Exception => ex 

		puts ex.to_s
		send_email( 
				email_config["smtphost"] , 
				email_config["smtpport"] , 
				email_config["usetls"] , 
				email_config["username"] , 
				email_config["password"] , 
				email_config["recipients"] , 
				"Error." , 
				"#{ ex.to_s }",
				email_config["displayname"]
			) if $config["-sendEmail"] == 1
	end

end

main ARGV





