

Toto Alarm
=============


Send email if next Toto draw prize is greater than some threshold (e.g 4,000,000 SGD)


Need to gem install nokogiri if you don't the gem already

```
  gem install nokogiri
```  


Use crontab -e to setup cronjob to run on every Monday and Thursday at 0:00 hr.

```
  0 0 * * 1,4  /path/to/your/ruby  path/to/your/totoalarm.rb
```










