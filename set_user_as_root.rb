# RUN WITH: rails s set_user_as_root.rb

puts "what Slack ID (uid) does the target user have?:"
target_uid = gets.chomp

failed = false
prev = User.where("id":0).first
if prev != nil
failed = true
puts "Root user already exists!! their Slack ID (uid) is:"
puts prev.uid
puts "Do you want to move that user to a different id? y/n:"
move = gets.chomp == "y"
if move
puts "which id to move user to? (make sure new id is definetily unused). must be a number"
new_uid = gets.chomp.to_i
prev.id = new_uid
prev.save
failed = false
puts "yay!! moved old root user to id:"
puts new_uid
end
end

if not failed
target = User.where("uid":target_uid).first
if target == nil
puts "no user with target uid exists!! target uid is:"
puts target_uid
else
target.id = 0
target.save
puts "phew, everything worked!! user with uid: " + target_uid + ", is now root at id 0"
end
end