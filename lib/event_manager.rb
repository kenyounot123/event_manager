require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_numbers(phone_numbers)
  phone_numbers.gsub!(/[()\-,. ]/, '')
  if phone_numbers.length == 11 && phone_numbers[0] == '1'
    phone_numbers = phone_numbers[1..10]
  elsif phone_numbers.length > 10 || phone_numbers.length < 10
    phone_numbers = nil
  else
    phone_numbers
  end
  puts phone_numbers
  
end
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def most_popular_hour
  contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
  all_hours = Hash.new(0)
  contents.each do |row|
    date = row[:regdate]
    hour = Time.strptime(date, '%m/%d/%y %k:%M').strftime('%k')
    all_hours[hour] += 1
  end
  all_hours.max_by {|k, v| v}[0]
end

def most_popular_day
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
    all_days = Hash.new(0)
    contents.each do |row|
      date = row[:regdate]
      day = Time.strptime(date, '%m/%d/%y %k:%M').strftime('%A')
      all_days[day] += 1
    end
    all_days.max_by { |key,value| value}[0]
end

puts 'EventManager initialized.'
puts "The most popular hour is #{most_popular_hour}:00"
puts "The most popular day is #{most_popular_day}"

# contents = CSV.open(
#   'event_attendees.csv',
#   headers: true,
#   header_converters: :symbol
# )

# template_letter = File.read('form_letter.erb')
# erb_template = ERB.new template_letter

# contents.each do |row|
#   id = row[0]
#   name = row[:first_name]
#   zipcode = clean_zipcode(row[:zipcode])
#   phone_numbers = clean_phone_numbers(row[:homephone])


#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)
 
#   save_thank_you_letter(id,form_letter)
# end


#if the zip code is five digits , it is good
#if it is more than five digits, truncate it to the first 5
#if it is less than five digits, add zeros to the front till it becomes 5 digits

