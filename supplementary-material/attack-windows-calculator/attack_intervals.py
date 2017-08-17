'''
Maximum Attack Window 

@version 0.1
@author Alex Bardas
'''
import sys
import ast
import math
import csv
#import plotly

#References: http://rosettacode.org/wiki/Chinese_remainder_theorem#Python
#            https://github.com/sigh/Python-Math
def chinese_remainder(T_r,start_t):
    sum = 0
    prod = reduce(lambda x,y: x*y, T_r)
 
    for T_r_i, start_t_i in zip(T_r, start_t):
        p = prod / T_r_i
        sum += start_t_i * mul_inv(p, T_r_i) * p
    return sum % prod
 
 
def mul_inv(a,b):
    b0 = b
    x0 = 0 
    x1 = 1
    if b == 1: return 1
    while a > 1:
        q = a / b
        rest = a%b
        a = b
        b = rest
        dif = x1 - q * x0
        x1 = x0
        x0 = dif
    if x1 < 0: x1 += b0
    return x1


def gen_all_adap_points(T_r,start_t,upper_limit):
    adap_points = {}
    for i in range(0,len(T_r)):
        val = []
        for j in range(start_t[i],upper_limit + 1, T_r[i]):
            val.append(j)
        adap_points.update({i: val})
    return adap_points


def brute_force_sol(T_r,start_t):
    prod = reduce(lambda x,y: x*y, T_r)
    adap_points = gen_all_adap_points(T_r,start_t,prod)
    lowest_m = -1
    for ap in adap_points[0]:
        for key in adap_points:
            if ap not in adap_points[key]:
                lowest_m = -1
                break
            else: 
                lowest_m = ap
        if lowest_m != -1: break
    return lowest_m


def pairwise_coprime(T_r):
    for i in range(0, len(T_r)-1):
        for j in range(i + 1, len(T_r)):
            if gcd([T_r[i], T_r[j]]) != 1: return False
    return True
    

def gcd(numbers):
    if len(numbers) > 2:
        return reduce(lambda x,y: gcd([x,y]), numbers)
    else:
        if numbers[1] == 0: 
            return numbers[0]
        else:
            return gcd([numbers[1], numbers[0]%numbers[1]])


def lcm(numbers):
    if len(numbers) > 2:
        return reduce(lambda a, b: lcm([a,b]), numbers)
    else:
        return numbers[0]*numbers[1]//gcd([numbers[0],numbers[1]])


def sanity_checks(T_r,start_t):
    if len(T_r) != len(start_t):
        print "Every Tr should have exactly one starting time!"
        exit(1)

    if len(T_r) == 0:
        print "No adaptation intervals (T_r values) available!"
        exit(1)

    for i in range(0,len(T_r)):
        if T_r[i] < 0:
            print "T_r values cannot be less than 0!"
            exit(1)
        if T_r[i] == 0:
            print "T_r values need to be equal t0 0!"
            exit(1)

    for i in range(0,len(start_t)):
        if start_t[i] < 0:
            print "Start times cannot be less than 0!"
            exit(1)


def congruent(i,j,base):
    if i%base == j%base: return i%base 


def more_solutions(lowest_m,T_p,T_r):
    if lowest_m > T_p:
        print "First aligned point happens later than T_p"
        #exit(1)
    else:
        sol = []
        for i in range(lowest_m, T_p + 1):
            if congruent(i,lowest_m,lcm(T_r)) != None:
                sol.append(i)
        return sol


def valid_case2_st_times(T_r,start_t):
    for i in range(0, len(T_r) - 1):
        for j in range(i + 1, len(T_r)):
            if congruent(start_t[i],start_t[j],gcd([T_r[i],T_r[j]])) == None:
                return False
    return True

def valid_case3_st_times(T_r,start_t):
    for i in range(0, len(T_r) - 1):
        for j in range(i + 1, len(T_r)):
            if congruent(start_t[i],start_t[j],gcd([T_r[i],T_r[j]])) != None:
                return False
    return True


def timeline_adap_points(adap_points):
    timeline = []
    for i in adap_points:
        # union operation on sets
        timeline = list(set(timeline) | set(adap_points[i]))
    timeline.sort()
    return timeline

def total_adaptations(adap_points):
    total_adapt = 0
    for i in adap_points:
        # union operation on sets
        total_adapt += len(adap_points[i])
    return total_adapt

def window_lengths_dist(timeline):
    dist = {}
    for i in range(0,len(timeline) - 1):
        j = i + 1
        attack_window = timeline[j] - timeline[i] 
        if attack_window in dist:
            dist[attack_window] += 1
        else:
            dist.update({attack_window: 1})
    return dist


#main method
if __name__ == '__main__':
    
    if len(sys.argv) == 4:
        T_p = int(sys.argv[1])
        T_r = ast.literal_eval(sys.argv[2])
        start_t = ast.literal_eval(sys.argv[3])
        print "Time period under consideration (T_p) = ", T_p
        #print "T_r values:", T_r
        #print "Starting times:", start_t
    else:
        print "Needs three parameters: time_period, T_r values, and starting_times"
        print "usage: python attack_intervals.py time_period T_r-s starting_times"
        print " e.g., python attack_intervals.py 1440 \"[11,10,11]\" \"[0,4,7]\""
        exit(1)

    ##### Overriding parameters ###############
    #T_p = 1440
    #T_r = [11,10,11]
    #start_t = [0,4,7]
    ###########################################

    sanity_checks(T_r,start_t)

    if pairwise_coprime(T_r):
        print "Case 1 - pairwise coprime adaptation intervals (T_r values)"
        lowest_m = chinese_remainder(T_r,start_t)
        print "First aligned point \"m\" = ", lowest_m

        lowest_m = brute_force_sol(T_r,start_t)
        print "First aligned point \"m\" (brute force) = ", lowest_m

        print "All solutions for \"m\" in T_p =", T_p, ":", more_solutions(lowest_m,T_p,T_r)

    elif valid_case2_st_times(T_r,start_t):
        print "Case 2 - Not pairwise coprime adaptation intervals, BUT with pairwise congruent starting times mod gcd"
        lowest_m = brute_force_sol(T_r,start_t)
        print "First aligned point \"m\" = ", lowest_m
        print "All solutions for \"m\" in T_p =", T_p, ":", more_solutions(lowest_m,T_p,T_r)

    elif valid_case3_st_times(T_r,start_t):
        print("Case 3 - No aligned points for any T_r values")

    else:
        print "Does not fall under Case 1, 2, or 3!" 
        print "Aligned points between part of the T_r values exist. May also exist for all T_r values"
    
    adap_points = gen_all_adap_points(T_r,start_t,T_p)
    timeline = timeline_adap_points(adap_points)
    print "\nTotal number of adaptations = ", total_adaptations(adap_points)
    print "Number of interruptions during T_p  (", T_p, "min):", len(timeline)
    print "All interruption points during T_p (", T_p, "min):"
    print timeline

    print "\nT_r values:", T_r
    print "Starting times:", start_t
    dist = window_lengths_dist(timeline)
    print "Distribution of the attack windows (window_length: #_of_windows):", dist

    window_lengths = []
    window_occurrences = []

    #Write to CSV file
    writer = csv.writer(open('attack_windows.csv', 'wb'))
    for key, value in dist.items():
        writer.writerow([key, value])
        window_lengths.append(str(key) + " min window")
        window_occurrences.append(value)

    
    #Plot data
    #from plotly.graph_objs import Scatter, Layout
    #from plotly.graph_objs import Bar

    #plotly.offline.plot({
    #"data": [
    #    Bar(x = window_lengths, y = window_occurrences)
    #],
    #"layout": Layout(
    #    title = "X-axis: Window lengths\n Y-axis: Number of windows"
    #)
    #})
    

    