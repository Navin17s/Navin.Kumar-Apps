import random
import time

print("You are now going to play a dice game with the computer....ENJOY!!")


def dice():
    player1 = random.randint(1, 6)
    print("Player1 rolls....... ")
    print("Player1 rolled - " + str(player1))
    time.sleep(2)
    print("Its Computer's turn now")
    ai = random.randint(1, 6)
    print("Computer rolls....... ")
    time.sleep(5)
    print("Computer rolled - " + str(ai))
    time.sleep(2)
    if player1 > ai:
        print("You Win :)")
    elif player1 == ai:
        print("Tie game")
    else:
        print("Computer Wins :)")


while True:
    print("Press Enter to roll your dice")
    roll = input()
    dice()
