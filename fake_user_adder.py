# helper python script for easily creating fake users for the database

import os

print("hi!! welcome to the user adder script! lets get started!\n")

uid = input("enter a uid that you will use to log in with: ")

name = input("enter a username: ")

user = 'User.new({"name":"' + name + '","pfp":"","token":"","uid":"' + uid + '"}).save()'

command = "echo " + repr(user) + " | rails console"

print("\ncool! i will run this command: " + command)

if input("is this okay? Y\\N: ").lower() == "y":
    os.system(command)
else:
    print("okay! wont run it then :)")