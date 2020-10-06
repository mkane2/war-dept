require 'json'
require 'mechanize'

class Scraper
  attr_accessor :call, :agent, :scraper
  puts "boo boo"

  def initialize
    @agent = Mechanize.new
    # @count = 1
    @per_page = 100
    @page = 0
    @sleep = 0.1
    @file = "war_dept.txt"
    puts "init"
  end

  def get_letters(scraper)
    puts "get letters"
    1000.times do |i|
      puts "page #{@page + i}"
      count = 0
      begin
        @call ||= @agent.get("https://wardepartmentpapers.org/api/items?resource_class_id=174&per_page=#{@per_page}&page=#{@page + i}")
      rescue Mechanize::ResponseCodeError => e
        puts e.response_code
        if e.response_code == "429"
          count += 1
          @sleep += 1
          puts "sleeping #{@sleep}"
          sleep 300
          retry unless count > 10
          puts "tried 10 times"
          return
        end
      rescue Errno::ECONNRESET => e
        count += 1
        sleep 1
        retry unless count > 10
        puts "tried 10 times"
      end
      if @call.nil?
        open(@file, 'a') { |f|
          f.puts "no page #{@page}"
        }
        puts "no page #{@page}"
        return
      else
        write_info(scraper, @call)
      end
      @call = nil
      sleep @sleep
    end
  end

  def write_info(scraper, call)
    # @get = agent.get("https://wardepartmentpapers.org/api/items?resource_class_id=174&per_page=#{@per_page}")
    @items = JSON.parse(call.body)
    @items.each do |item|
        @id = item["o:id"]
        if item["dcterms:creator"]
          @creator = item["dcterms:creator"][0]["display_title"]
          @creator_id = item["dcterms:creator"][0]["value_resource_id"]
        else
          @creator = ""
          @creator_id = ""
        end
        if item["pwd:createdYear"]
          @year = item["pwd:createdYear"][0]["@value"]
        else
          @year = ""
        end
        if item["pwd:createdMonth"]
          @month = item["pwd:createdMonth"][0]["@value"]
        else
          @month = ""
        end
        if item["pwd:createdDay"]
          @day = item["pwd:createdDay"][0]["@value"]
        else
          @day = ""
        end
      if item["pwd:sentFromLocation"]
        @loc = item["pwd:sentFromLocation"][0]["@value"]
      else
        @loc = ""
      end
      if item["bibo:recipient"]
        @recip = item["bibo:recipient"][0]["display_title"]
        @recip_id = item["bibo:recipient"][0]["value_resource_id"]
      else
        @recip = ""
        @recip_id = ""
      end
      if item["pwd:collection"]
        @collection = item["pwd:collection"][0]["display_title"]
      else
        @collection = ""
      end
      puts "#{@id}|#{@year}|#{@month}|#{@day}|#{@creator}|#{@creator_id}|#{@recip}|#{@recip_id}|#{@loc}|#{@collection}"
      open(@file, 'a') { |f|
        f.puts "#{@id}|#{@year}|#{@month}|#{@day}|#{@creator}|#{@creator_id}|#{@recip}|#{@recip_id}|#{@loc}|#{@collection}"
      }
    end
  end

  @scraper = Scraper.new
  @scraper.get_letters(@scraper)
  puts "boo"
end
