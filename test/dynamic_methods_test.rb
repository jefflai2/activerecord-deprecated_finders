require 'helper'

describe 'dynamic_methods' do
  before do
    @posts = [
      Post.create(title: 'foo', category: '1'),
      Post.create(title: 'bar', category: '1'),
      Post.create(title: 'bar', category: '2')
    ]
  end

  after do
    Post.delete_all
  end

  it 'supports find_all_by' do
    Post.find_all_by_title('bar').must_equal [@posts[1], @posts[2]]
    Post.find_all_by_title_and_category('bar', '2').must_equal [@posts[2]]
  end

  it 'supports find_all_by with finder options' do
    Post.find_all_by_title('bar', conditions: { category: '1' }).must_equal [@posts[1]]
  end

  it 'supports find_last_by' do
    Post.find_last_by_title('foo').must_equal @posts[0]
    Post.find_last_by_title('bar').must_equal @posts[2]
  end

  it 'supports find_last_by with finder options' do
    Post.find_last_by_title('bar', conditions: { category: '1' }).must_equal @posts[1]
  end

  it 'supports scoped_by' do
    scope = Post.scoped_by_title('bar')
    scope.is_a?(ActiveRecord::Relation).must_equal true
    scope.to_a.must_equal [@posts[1], @posts[2]]
  end

  it 'supports find_or_initialize_by' do
    Post.find_or_initialize_by_title_and_category('bar', '1').must_equal @posts[1]

    post = Post.find_or_initialize_by_title_and_category('bar', '3')
    post.new_record?.must_equal true
    post.title.must_equal 'bar'
    post.category.must_equal '3'
  end

  it 'supports find_or_create_by' do
    Post.find_or_create_by_title_and_category('bar', '1').must_equal @posts[1]

    post = Post.find_or_create_by_title_and_category('bar', '3')
    post.new_record?.must_equal false
    post.title.must_equal 'bar'
    post.category.must_equal '3'
  end

  it 'supports find_or_create_by!' do
    Post.find_or_create_by_title_and_category!('bar', '1').must_equal @posts[1]

    post = Post.find_or_create_by_title_and_category!('bar', '3')
    post.new_record?.must_equal false
    post.title.must_equal 'bar'
    post.category.must_equal '3'

    klass = Class.new(ActiveRecord::Base)
    def klass.name; 'Post'; end
    klass.table_name = 'posts'
    klass.validates_presence_of :category

    lambda { klass.find_or_create_by_title!('z') }.must_raise ActiveRecord::RecordInvalid
  end

  it 'supports find_by with finder options' do
    Post.find_by_title('bar', conditions: { category: '2' }).must_equal @posts[2]
  end

  it 'supports find_by! with finder options' do
    Post.find_by_title!('bar', conditions: { category: '2' }).must_equal @posts[2]
    lambda { Post.find_by_title!('bar', conditions: { category: '3' }) }.must_raise ActiveRecord::RecordNotFound
  end

  it 'supports find_by with a block' do
    Post.find_by_title('foo') { |r| [r, 'block'] }.must_equal [@posts[0], 'block']
    Post.find_by_title('baz') { |r| [r, 'block'] }.must_equal nil
  end

  it 'supports find_by! with a block' do
    Post.find_by_title!('foo') { |r| [r, 'block'] }.must_equal [@posts[0], 'block']
  end
end