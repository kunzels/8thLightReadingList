require 'rspec'
require 'readingList'


RSpec.describe ReadingList do

    subject(:list) {ReadingList.new()}
    # describe '#initialize' do
    #     it "Should contain a key" do
    #         expect(list.key).to_not eq(nil)
    #     end
    #     it "Should contain a database" do
    #         expect(list.db).to_not eq(nil) 
    #     end
    # end

    describe '#listAndDbInsert' do
        it "should add an item to list" do
            @held = list.list.length 
            list.listAndDbInsert(["#{rand()}.to_s", ["#{rand()}.to_s"], "#{rand()}.to_s"])
            expect(list.list.length).to eq(@held + 1)
        end
    end

    describe "#searchInput" do
        context "When passed in a nil value" do
            it "should return an empty string" do
                expect(list.searchInput("Hit enter without typing in anything")).to eq('')
            end
        end
        context "When passed in a non nil value" do
            it "should be a populated string" do
                expect(list.searchInput("Enter non empty text for this test")).to_not eq((''))
            end
        end
    end
end
