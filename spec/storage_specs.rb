# Mixin methods for storage implementation test classes. The behavioral
# tests are the same regardless of implementation so share those methods
# here.
module StorageSpecs
  def fragment_id
    Digest::SHA1.hexdigest("characters:urn:wonderland")
  end

  def fragment
    Nokogiri::XML(%q{
      <characters xmlns="urn:wonderland">
        <character>Alice</character>
      </characters>
    }.strip).root
  end

  def vcard
    Nokogiri::XML(%q{
      <vCard xmlns="vcard-temp">
        <FN>Alice in Wonderland</FN>
      </vCard>
    }.strip).root
  end

  def fibered
    EM.run do
      Fiber.new do
        yield
        EM.stop
      end.resume
    end
  end

  def test_authenticate
    fibered do
      db = storage
      db.authenticate(nil, nil).must_be_nil
      db.authenticate(nil, 'secret').must_be_nil
      db.authenticate('bogus', nil).must_be_nil
      db.authenticate('bogus', 'secret').must_be_nil
      db.authenticate('empty@wonderland.lit', 'secret').must_be_nil
      db.authenticate('no_password@wonderland.lit', 'secret').must_be_nil
      db.authenticate('clear_password@wonderland.lit', 'secret').must_be_nil

      user = db.authenticate('bcrypt_password@wonderland.lit', 'secret')
      user.wont_be_nil
      user.jid.to_s.must_equal 'bcrypt_password@wonderland.lit'

      user = db.authenticate('full@wonderland.lit', 'secret')
      user.wont_be_nil
      user.name.must_equal 'Tester'
      user.jid.to_s.must_equal 'full@wonderland.lit'

      user.roster.length.must_equal 2
      user.roster[0].jid.to_s.must_equal 'contact1@wonderland.lit'
      user.roster[0].name.must_equal 'Contact1'
      user.roster[0].groups.length.must_equal 2
      user.roster[0].groups[0].must_equal 'Group1'
      user.roster[0].groups[1].must_equal 'Group2'

      user.roster[1].jid.to_s.must_equal 'contact2@wonderland.lit'
      user.roster[1].name.must_equal 'Contact2'
      user.roster[1].groups.length.must_equal 2
      user.roster[1].groups[0].must_equal 'Group3'
      user.roster[1].groups[1].must_equal 'Group4'
    end
  end

  def test_find_user
    fibered do
      db = storage
      user = db.find_user(nil)
      user.must_be_nil

      user = db.find_user('full@wonderland.lit')
      user.wont_be_nil
      user.jid.to_s.must_equal 'full@wonderland.lit'

      user = db.find_user(Vines::JID.new('full@wonderland.lit'))
      user.wont_be_nil
      user.jid.to_s.must_equal 'full@wonderland.lit'

      user = db.find_user(Vines::JID.new('full@wonderland.lit/resource'))
      user.wont_be_nil
      user.jid.to_s.must_equal 'full@wonderland.lit'
    end
  end

  def test_save_user
    fibered do
      db = storage
      user = Vines::User.new(
        jid: 'save_user@domain.tld/resource1',
        name: 'Save User',
        password: 'secret')
      user.roster << Vines::Contact.new(
        jid: 'contact1@domain.tld/resource2',
        name: 'Contact 1')
      db.save_user(user)
      user = db.find_user('save_user@domain.tld')
      user.wont_be_nil
      user.jid.to_s.must_equal 'save_user@domain.tld'
      user.name.must_equal 'Save User'
      user.roster.length.must_equal 1
      user.roster[0].jid.to_s.must_equal 'contact1@domain.tld'
      user.roster[0].name.must_equal 'Contact 1'
    end
  end

  def test_find_vcard
    fibered do
      db = storage
      card = db.find_vcard(nil)
      card.must_be_nil

      card = db.find_vcard('full@wonderland.lit')
      card.wont_be_nil
      card.to_s.must_equal vcard.to_s

      card = db.find_vcard(Vines::JID.new('full@wonderland.lit'))
      card.wont_be_nil
      card.to_s.must_equal vcard.to_s

      card = db.find_vcard(Vines::JID.new('full@wonderland.lit/resource'))
      card.wont_be_nil
      card.to_s.must_equal vcard.to_s
    end
  end

  def test_save_vcard
    fibered do
      db = storage
      db.save_user(Vines::User.new(jid: 'save_user@domain.tld'))
      db.save_vcard('save_user@domain.tld/resource1', vcard)
      card = db.find_vcard('save_user@domain.tld')
      card.wont_be_nil
      card.to_s.must_equal vcard.to_s
    end
  end

  def test_find_fragment
    fibered do
      db = storage
      root = Nokogiri::XML(%q{<characters xmlns="urn:wonderland"/>}).root
      bad_name = Nokogiri::XML(%q{<not_characters xmlns="urn:wonderland"/>}).root
      bad_ns = Nokogiri::XML(%q{<characters xmlns="not:wonderland"/>}).root

      node = db.find_fragment(nil, nil)
      node.must_be_nil

      node = db.find_fragment('full@wonderland.lit', bad_name)
      node.must_be_nil

      node = db.find_fragment('full@wonderland.lit', bad_ns)
      node.must_be_nil

      node = db.find_fragment('full@wonderland.lit', root)
      node.wont_be_nil
      node.to_s.must_equal fragment.to_s

      node = db.find_fragment(Vines::JID.new('full@wonderland.lit'), root)
      node.wont_be_nil
      node.to_s.must_equal fragment.to_s

      node = db.find_fragment(Vines::JID.new('full@wonderland.lit/resource'), root)
      node.wont_be_nil
      node.to_s.must_equal fragment.to_s
    end
  end

  def test_save_fragment
    fibered do
      db = storage
      root = Nokogiri::XML(%q{<characters xmlns="urn:wonderland"/>}).root
      db.save_user(Vines::User.new(jid: 'save_user@domain.tld'))
      db.save_fragment('save_user@domain.tld/resource1', fragment)
      node = db.find_fragment('save_user@domain.tld', root)
      node.wont_be_nil
      node.to_s.must_equal fragment.to_s
    end
  end
end
