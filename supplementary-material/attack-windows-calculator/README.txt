Calculating Attack Windows

This is a Python application that calculates the attack windows and their distribution 
for various inputs.



Usage

A. Default (command-line output):
    attack-intervals.py needs three parameters: time_period, T_r values, and starting_times
    usage: python attack_intervals.py time_period T_r-s starting_times
  
    e.g., python attack_intervals.py 1440 "[11,10,11]" "[0,4,7]"


B. Command-line Output and Generating Graphs

    1. Install ploty
	sudo pip install plotly

    2. In “attack-intervals.py”, uncomment rows: 11, 242 - 253

    3. Run attack-intervals.py
	   e.g., python attack_intervals.py 1440 "[11,10,11]" "[0,4,7]"


