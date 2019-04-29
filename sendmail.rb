require 'json'
require 'sendgrid-ruby'
require 'erb'
require 'dotenv/load'

entries = JSON.parse($stdin.read, symbolize_names: true)

erb = ERB.new <<-TEMP
<% if entries.empty? %>
    更新はありません
<% else %>
    <% entries.each do |entry| %>
        <div style='border: solid 2px; padding: 5px; margin: 10px;'>
            <a style='text-decoration: none; color: black;' href='<%= entry[:entry_url] %>'>
                <div style='display: flex; flex-direction: row;'>
                    <div style='width: 30%;'>
                        <img style='width: 100%;' src='<%= entry[:icon_url] %>'>
                    </div>
                    <div style='width: 70%; margin-left: 10px;'>
                        <h2><%= entry[:title] %></h2>
                        <p><%= entry[:abstract][0..200] %></p>
                    </div>
                </div>
            </a>
        </div>
    <% end %>
<% end %>
TEMP

from = SendGrid::Email.new(email: 'fee@mail.kuminecraft.xyz')
to = SendGrid::Email.new(email: ENV.fetch('USER_MAIL_ADDRESS'))
subject = entries.empty? ? 'フィードの更新はありません' : "#{entries.length}件のフィードが更新されました"
content = SendGrid::Content.new(type: 'text/html', value: erb.result)
mail = SendGrid::Mail.new(from, subject, to, content)

sg = SendGrid::API.new(api_key: ENV.fetch('SENDGRID_APIKEY'))
sg.client.mail._('send').post(request_body: mail.to_json)
