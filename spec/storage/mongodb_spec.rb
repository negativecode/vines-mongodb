require 'spec_helper'

describe Vines::Storage::MongoDB do
  include StorageSpecs

  MOCK_MONGO = MockMongo.new

  before do
    fibered do
      db = MOCK_MONGO
      db.collection(:users).save({'_id' => 'empty@wonderland.lit'})
      db.collection(:users).save({'_id' => 'no_password@wonderland.lit', 'foo' => 'bar'})
      db.collection(:users).save({'_id' => 'clear_password@wonderland.lit', 'password' => 'secret'})
      db.collection(:users).save({'_id' => 'bcrypt_password@wonderland.lit', 'password' => BCrypt::Password.create('secret')})
      db.collection(:users).save({
        '_id'      => 'full@wonderland.lit',
        'password' => BCrypt::Password.create('secret'),
        'name'     => 'Tester',
        'roster'   => {
          'contact1@wonderland.lit' => {
            'name'   => 'Contact1',
            'groups' => %w[Group1 Group2]
          },
          'contact2@wonderland.lit' => {
            'name'   => 'Contact2',
            'groups' => %w[Group3 Group4]
          }
        }
      })
      db.collection(:vcards).save({'_id' => 'full@wonderland.lit', 'card' => VCARD.to_xml})
      db.collection(:fragments).save({'_id' => "full@wonderland.lit:#{FRAGMENT_ID}", 'xml' => FRAGMENT.to_xml})
    end
  end

  after do
    MOCK_MONGO.clear
  end

  def storage
    storage = Vines::Storage::MongoDB.new do
      host 'localhost', 27017
      database 'xmpp_testcase'
    end
    def storage.db
      MongoDBTest::MOCK_MONGO
    end
    storage
  end

  describe 'creating a new instance' do
    it 'raises with no database' do
      fibered do
        -> { Vines::Storage::MongoDB.new {} }.must_raise RuntimeError
      end
    end

    it 'raises with no host' do
      fibered do
        -> { Vines::Storage::MongoDB.new { database 'test' } }.must_raise RuntimeError
      end
    end

    it 'raises with duplicate hosts' do
      fibered do
        proc do
          Vines::Storage::MongoDB.new do
            host 'localhost', 27017
            host 'localhost', 27017
            database 'test'
          end
        end.must_raise RuntimeError
      end
    end

    it 'does not raise with host and database' do
      fibered do
        obj =
          Vines::Storage::MongoDB.new do
            host 'localhost', 27017
            database 'test'
          end
        obj.wont_be_nil
      end
    end

    it 'does not raise with two hosts' do
      fibered do
        obj =
          Vines::Storage::MongoDB.new do
            host 'localhost', 27017
            host 'localhost', 27018
            database 'test'
          end
        obj.wont_be_nil
      end
    end
  end
end
