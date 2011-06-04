require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

class GetResponse::CampaignTest < Test::Unit::TestCase

  def setup
    @gr_connection = GetResponse::Connection.new("my_secret_api_key")
    @campaign = GetResponse::Campaign.new({"id" => 1005, "name" => "test_campaign",
      "from_name" => "Joe Doe", "from_email" => "test@test.xx", "reply_to_email" => "bounce@test.xx",
      "created_on" => "2010-02-15 15:40"}, @gr_connection)
  end


  def test_contacts
    mock(@gr_connection).send_request('get_contacts', {:campaigns => [@campaign.id]}) { JSON.parse get_contacts_resp }
    contacts = @campaign.contacts

    assert_kind_of Array, contacts
    assert contacts.all? { |contact| contact.kind_of? GetResponse::Contact }
  end


  def test_domain
    mock(@gr_connection).send_request("get_campaign_domain", {"campaign" => @campaign.id}) { domain_resp }
    domain = @campaign.domain

    assert_kind_of GetResponse::Domain, domain
  end


  def test_set_domain
    @domain = GetResponse::Domain.new("id" => "23", "domain" => "domain.com")
    params = { "domain" => @domain.id, "campaign" => @campaign.id }
    mock(@gr_connection).send_request("set_campaign_domain", params) { set_domain_resp }
    domain = @campaign.domain= @domain

    assert_kind_of GetResponse::Domain, domain
  end


  def test_messages
    params = {:campaigns => [@campaign.id]}
    mock(@gr_connection).send_request("get_messages", params) { JSON.parse get_messages_response_success }
    messages = @campaign.messages

    assert_kind_of Array, messages
    assert_equal true, messages.all? { |msg| msg.instance_of? GetResponse::Message }
  end


  protected


  def domain_resp
    {
      "result" => {
        "2345" => {
          "domain" => "domain.com",
          "created_on" => "2011-01-20 00:00:00"
        }
      },
      "error" => nil
    }
  end


  def set_domain_resp
    {
      "result" => { "updated" => "1" },
      "error" => nil
    }
  end

end
